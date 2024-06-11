#' Get knolls base areas
#'
#' @description Get knolls base area data in a spatial grid or polygon
#' 
#' @details Knolls are small seamounts; seamounts with peaks 200-1000 m higher than the surrounding seafloor [(Morato et al., 2008)](https://doi.org/10.3354/meps07268). The knolls base area data is from [Yesson et al. 2011](https://doi.org/10.1016/j.dsr.2011.02.004)
#'
#' @param spatial_grid `sf` or `terra::rast()` grid, e.g. created using `get_grid()`. Alternatively, if raw data is required, an `sf` polygon can be provided, e.g. created using `get_boundary()`, and set `raw = TRUE`.
#' @param raw `logical` if TRUE, `spatial_grid` should be an `sf` polygon, and the raw knolls data in that polygon(s) will be returned
#' @param name name of raster or column in sf object that is returned
#' @param antimeridian Does `spatial_grid` span the antimeridian? If so, this should be set to `TRUE`, otherwise set to `FALSE`. If set to `NULL` (default) the function will try to check if data spans the antimeridian and set this appropriately.
#'
#' @return For gridded data, a `terra::rast()` or `sf` object, depending on the `spatial_grid` format. If `raw = TRUE` an `sf` object crop and intersected with the polygon supplied.
#' @export
#'
#' @examples
#' # Get EEZ data first 
#' bermuda_eez <- get_area(name = "Bermuda")
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
