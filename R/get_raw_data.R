#' Crop and mask/ intersect data
#'
#' @description
#' Called by `get_data_in_grid` when needed
#'
#' @param spatial_grid `sf` polygon to crop/ mask/ intersect data with
#' @param dat `terra::rast()` or `sf` data
#' @param matching_crs `logical` TRUE if `spatial_grid` and `dat` have the same crs
#' @param antimeridian `logical` TRUE if cropping area crosses the antimeridian
#'
#' @return `terra::rast()` or `sf`; same as `dat`
#' @noRd
get_raw_data <- function(spatial_grid, dat, matching_crs, antimeridian, meth){

  if(is(dat, "SpatRaster")){
    if(matching_crs){
        terra::crop(dat, sf::st_as_sf(spatial_grid)) |>
        terra::mask(sf::st_as_sf(spatial_grid)) # separate step rather than mask = TRUE because that doesn't work well with antimeridian crossing sf objects
    }else{
      spatial_grid_in_data_crs <- spatial_grid |>
        sf::st_transform(sf::st_crs(dat)) |>
        sf::st_as_sf()

       data_cropped <- if(antimeridian) {
         terra::crop(terra::rotate(dat), sf::st_shift_longitude(spatial_grid_in_data_crs))
         } else terra::crop(dat, spatial_grid_in_data_crs)

       data_cropped |>
        terra::project(terra::crs(spatial_grid), method = meth) |>
        terra::mask(spatial_grid)
    }
  }else{
    if(matching_crs){
      data_intersected <- suppressWarnings(sf::st_intersection(dat, sf::st_geometry(spatial_grid)))

        if(antimeridian) data_intersected <- sf::st_wrap_dateline(data_intersected)

        return(data_intersected)

    }else{
      if(antimeridian){
        spatial_grid |>
          sf::st_transform(sf::st_crs(dat)) |>
          sf::st_shift_longitude() |>
          sf::st_intersection(sf::st_shift_longitude(dat)) |>
          sf::st_wrap_dateline() |>
          sf::st_transform(sf::st_crs(spatial_grid))
      }else{
        spatial_grid_in_data_crs <- spatial_grid |>
          sf::st_transform(sf::st_crs(dat))

        spatial_grid_in_data_crs |>
          sf::st_intersection(dat, sf::st_geometry(spatial_grid_in_data_crs)) |>
          sf::st_transform(sf::st_crs(spatial_grid))
      }
    }
  }
}
