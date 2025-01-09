#' Get knolls base areas
#'
#' @description Get knolls base area data in a spatial grid or polygon
#'
#' @details Knolls are small seamounts; seamounts with peaks 200-1000 m higher
#'   than the surrounding seafloor [(Morato et al.,
#'   2008)](https://doi.org/10.3354/meps07268). The knolls base area data is
#'   from [Yesson et al. 2011](https://doi.org/10.1016/j.dsr.2011.02.004)
#'
#' @inheritParams get_bathymetry
#'
#' @return For gridded data, a `terra::rast()` or `sf` object, depending on the
#'   `spatial_grid` format. If `raw = TRUE` an `sf` object crop and intersected
#'   with the polygon supplied.
#' @export
#' 
#' @examples
#' # Get EEZ data first 
#' bermuda_eez <- get_boundary(name = "Bermuda")
#' # Get raw knolls data for Bermuda's EEZ
#' knolls <- get_knolls(spatial_grid= bermuda_eez, raw = TRUE)
#' # Get gridded knolls data: first create a grid
#' bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 10000)
#' knolls_gridded <- get_knolls(spatial_grid = bermuda_grid)
get_knolls <- function(spatial_grid = NULL, raw = FALSE, name = "knolls", antimeridian = NULL){
  
  check_grid(spatial_grid)
  
      knolls <- system.file("extdata", "knolls.rds", package = "oceandatr", mustWork = TRUE) %>%
        readRDS() 
      
      sf::sf_use_s2(FALSE)
      knolls_dat <- get_data_in_grid(spatial_grid = spatial_grid, dat = knolls, raw = raw, name = name, antimeridian = antimeridian)
    
      sf::sf_use_s2(TRUE)
      
      return(knolls_dat)
}
