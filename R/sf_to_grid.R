#' Internal helper function for gridding sf input data
#'
#' @description
#' Called from `get_data_in_grid` when needed
#'
#' @param spatial_grid `terra::rast()` or `sf` planning grid
#' @param dat `sf` input data
#' @param matching_crs `logical` TRUE if crs of data and planning grid match, else FASE
#' @param name `string` name of returned raster or if sf, column name in sf object
#' @param feature_names `string` names of columns in sf data that will be gridded
#' @param antimeridian `logical` TRUE if data to be gridded cross the antimeridian
#' @param cutoff `numeric` for `sf` gridded data only, i.e. an `sf` `spatial_grid` is provided. How much of each grid cell should be covered by an `sf` feature for it to be classified as that feature type (cover fraction value between 0 and 1). For example, if `cutoff = 0.5` (default), at least half of each grid cell has to be covered by a feature for the cell to be classified as that feature. If `NULL`, the % coverage of each feature in each grid cell is returned.
#'
#' @return `terra::rast()` or `sf` gridded data, depending on `spatial_grid` format
#' @noRd
sf_to_grid <- function(spatial_grid, dat, matching_crs, name, feature_names, antimeridian, cutoff){

  is_raster <- is(spatial_grid, "SpatRaster")

  if(matching_crs) {
    dat_cropped <- dat |>
      sf::st_crop(spatial_grid)
  } else{
    grid_temp <- spatial_grid |>
      (\(x) if(is_raster) terra::as.polygons(x) |>  sf::st_as_sf() else x)() |>
      sf::st_transform(sf::st_crs(dat)) |>
      (\(x) if(antimeridian) sf::st_shift_longitude(x) else x)()

    if(antimeridian){
      if(!(any(c("POINT", "MULTIPOINT") %in% unique(sf::st_geometry_type(dat))))){
        dat_temp <- dat |>
          sf::st_break_antimeridian(lon_0 = 180) |>
          sf::st_shift_longitude()
      } else{
        data_temp <- sf::st_shift_longitude(dat)
      }
    } else{
      dat_temp <- dat
    }

    dat_cropped <- dat_temp |>
      sf::st_crop(grid_temp) |>
      sf::st_transform(sf::st_crs(spatial_grid)) |>
      (\(x) if (all(sf::st_is_valid(x))) x else sf::st_make_valid(x))() |>
      #after cropping, can end up with mixed geometry type: get only polygons (includes MULTIPOLYGON)
      (\(x) if(any(sf::st_is(x, c("POINT", "MULTIPOINT")), all(sf::st_is(x, "POLYGON")),  all(sf::st_is(x, "MULTIPOLYGON")))) x else sf::st_collection_extract(x, "POLYGON"))()

  }

  if(is.null(feature_names)){
    if(is.null(name)) name <- "data"

    #return raster or sf object with zeroes if no data in the spatial grid
    if(nrow(dat_cropped) == 0){
      message("No ", name, " in grid")
      if(is_raster){
        return(spatial_grid |>
                 terra::subst(1,0) |>
                 stats::setNames(name))
      } else{
        return(dplyr::mutate(spatial_grid, {{name}} := 0, .before = ncol(spatial_grid)))
      }
    }

    dat_grouped <- dat_cropped |>
      dplyr::mutate({{name}} := 1, .before = 1) |>
      dplyr::group_by({{name}}) |>
      dplyr::summarise() |>
      dplyr::ungroup() |>
      (\(x) if(all(c("POLYGON", "MULTIPOLYGON") %in% (sf::st_geometry_type(x) |>  unique() |>  as.character()))) sf::st_cast(x, to = "MULTIPOLYGON") else x)()

  }  else {
    #return raster or sf object with zeroes if no data in the spatial grid
    if(nrow(dat_cropped) == 0){
      message("No data in grid")

      layer_names <- unique(dat[[feature_names]])

      if(is_raster){
        return(spatial_grid |>
                 terra::subst(1,0) |>
                 rep(length(layer_names)) |>
                 stats::setNames(layer_names))
      } else{
        new_cols <- data.frame(matrix(data = 0, ncol= length(layer_names), nrow=nrow(spatial_grid), dimnames=list(NULL, layer_names)))
        return(spatial_grid |>
                 dplyr::bind_cols(new_cols))
      }
    }

    dat_grouped <- dplyr::group_by(dat_cropped, dat_cropped[[feature_names]]) |>
      dplyr::summarise() |>
      dplyr::ungroup() |>
      (\(x) if(all(c("POLYGON", "MULTIPOLYGON") %in% (sf::st_geometry_type(x) |>  unique() |>  as.character()))) sf::st_cast(x, to = "MULTIPOLYGON") else x)()
  }
  if(is_raster){

    nms <- dat_grouped[[1]]

 temp_rast  <- exactextractr::coverage_fraction(spatial_grid, dat_grouped) |>
      terra::rast() |>
      stats::setNames(nms) |>
      terra::mask(spatial_grid) |>
      (\(x) if(!is.null(cutoff)) terra::classify(x, matrix(c(-1, cutoff, 0, cutoff, 1.2, 1), ncol = 3, byrow = TRUE), include.lowest = FALSE, right = FALSE) else x)()

    #check if some features were cropped out; if so, need to add raster layers with zeroes in
    if(is.null(feature_names)) {
        return(temp_rast)
      } else if(all(unique(dat[[feature_names]]) %in% nms)){
        return(temp_rast)
      }  else{
        missing_feature_nms <- setdiff(unique(dat[[feature_names]]), nms)

        missing_features_rast <- spatial_grid |>
          terra::subst(1,0) |>
          rep(length(missing_feature_nms)) |>
          stats::setNames(missing_feature_nms)

        return(c(temp_rast, missing_features_rast))
      }
  } else{

    grid_has_extra_cols <- if(ncol(spatial_grid)>1) TRUE else FALSE

    if(grid_has_extra_cols) extra_cols <- sf::st_drop_geometry(spatial_grid)

    spatial_grid_geom <- spatial_grid |>
      sf::st_geometry() |>
      sf::st_sf()

    spatial_grid_with_id <- dplyr::mutate(spatial_grid_geom, cellID = 1:nrow(spatial_grid_geom))

    spatial_grid_with_area <- spatial_grid_with_id |>
      (\(x) dplyr::mutate(x, area_cell = as.numeric(sf::st_area(x))))() |>
      sf::st_drop_geometry()

    layer_names <- if(is.null(feature_names)) name else dat_grouped[[1]]

    dat_list <- if(is.null(feature_names)) list(dat_grouped) |>  stats::setNames(layer_names) else split(dat_grouped, layer_names)

    intersected_data_list <- list()

    for (layer in layer_names) {
      temp_intersection <- sf::st_intersection(spatial_grid_with_id, dat_list[[layer]]) |>
        (\(x) if(all(sf::st_is_valid(x))) x else sf::st_make_valid(x))()

      if(nrow(temp_intersection)>0) {
        intersected_data_list[[layer]] <- temp_intersection |>
          dplyr::mutate(area = as.numeric(sf::st_area(temp_intersection))) |>
          sf::st_drop_geometry() |>
          dplyr::full_join(x = spatial_grid_with_area, y = _, by = c("cellID")) |>
          (\(x) dplyr::mutate(x, perc_area = x$area / x$area_cell, .keep = "unused", .before = 1))() |>
          (\(x) dplyr::mutate(x, perc_area = dplyr::case_when(is.na(x$perc_area) ~ 0,
                                                              .default = as.numeric(x$perc_area))))() |>
          dplyr::left_join(spatial_grid_with_id, y = _,  by = "cellID") |>
          (\(x) if(is.null(cutoff)) {
            dplyr::select(x, x$perc_area, {{layer}} := x$perc_area)}
           else {
            dplyr::mutate(x, {{layer}} := dplyr::case_when(x$perc_area >= cutoff  ~ 1,
                                                           .default = 0)) |>
              dplyr::select({{layer}})
           })()
        } else{
        intersected_data_list[[layer]] <- spatial_grid_geom |>
          dplyr::mutate({{layer}} := 0, .before = 1)
      }
    }
    intersected_data_df <- lapply(intersected_data_list, function(x) sf::st_drop_geometry(x)) |>
      do.call(cbind, args = _)

    nms <- colnames(intersected_data_df)

    intersected_data_sf <- intersected_data_df |>
      (\(x) if(grid_has_extra_cols) cbind(extra_cols, x) else x)() |>
      sf::st_set_geometry(sf::st_geometry(intersected_data_list[[1]])) |>
      sf::st_set_geometry("geometry")

    if(is.null(feature_names)) {
      return(intersected_data_sf)
    } else if(all(unique(dat[[feature_names]]) %in% nms)){
      return(intersected_data_sf)
    }  else{
      missing_feature_nms <- setdiff(unique(dat[[feature_names]]), nms)

      new_cols <- data.frame(matrix(data = 0, ncol= length(missing_feature_nms), nrow=nrow(spatial_grid), dimnames=list(NULL, missing_feature_nms)))
      return(intersected_data_sf |>
               dplyr::bind_cols(new_cols))

    }
   }
  }
