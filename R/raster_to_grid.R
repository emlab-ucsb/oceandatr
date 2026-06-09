#' Internal helper function for gridding raster input data
#'
#' @description
#' Called from `get_data_in_grid` when needed
#'
#' @param spatial_grid `terra::rast()` or `sf` planning grid
#' @param dat `terra::rast()` input data
#' @param matching_crs `logical` TRUE if crs of data and planning grid match, else FASE
#' @param meth `string` name of method using for projecting/ resampling of raster, or gridding to sf
#' @param name `string` name of returned raster or if sf, column name in sf object
#' @param antimeridian `logical` TRUE if data to be gridded cross the antimeridian
#'
#' @return `terra::rast()` or `sf` gridded data, depending on `spatial_grid` format
#'
#' @noRd
ras_to_grid <- function(spatial_grid, dat, matching_crs, meth, name, antimeridian){

  if(is.null(name)) name <- names(dat)

  if(is(spatial_grid, "SpatRaster")) {
    if(antimeridian){
      spatial_grid |>
        terra::as.polygons() |>
        sf::st_as_sf() |>
        sf::st_transform(sf::st_crs(dat)) |>
        sf::st_shift_longitude() |>
        terra::crop(x = terra::rotate(dat), y = _) |>
        terra::project(spatial_grid, method = meth) |>
        terra::mask(spatial_grid) |>
        stats::setNames(name)
    }else{
      cropped_data <- if(matching_crs) {
        terra::crop(dat, spatial_grid) |>
          terra::resample(spatial_grid, method = meth)
        } else {
          terra::as.polygons(spatial_grid) |>
            terra::project(terra::crs(dat)) |>
            terra::crop(dat, y = _) |>
            terra::project(spatial_grid, method = meth)
        }

      cropped_data |>
            terra::mask(spatial_grid) |>
            stats::setNames(name)
    }
  } else {
    grid_has_extra_cols <- if(ncol(spatial_grid)>1) TRUE else FALSE

    if(grid_has_extra_cols) extra_cols <- sf::st_drop_geometry(spatial_grid)


    temp_grid <- if(matching_crs){
      spatial_grid |>
        sf::st_geometry()
    }  else {
      spatial_grid |>
        sf::st_geometry() |>
        sf::st_transform(sf::st_crs(dat)) |>
        (\(x) if(antimeridian) sf::st_shift_longitude(x) else x)()
    }

    dat |>
      (\(x) if(antimeridian) terra::rotate(x) else x)() |>
      exactextractr::exact_extract(temp_grid, meth , force_df = TRUE)  |>
      stats::setNames(name) |>
      (\(x) data.frame(temp_grid, x))() |>
      sf::st_sf() |>
      (\(x) if(matching_crs) x else sf::st_transform(x, sf::st_crs(spatial_grid)))() |>
      (\(x) if(grid_has_extra_cols) cbind(x, extra_cols) |>  dplyr::relocate(colnames(extra_cols), .before = 1) else x)() |>
      sf::st_set_geometry("geometry")
  }
}
