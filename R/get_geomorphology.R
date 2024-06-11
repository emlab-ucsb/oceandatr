#' Get seafloor geomorphology data
#' 
#' @description Get geomorphological data for a spatial grid or polygon
#' 
#' @details Geomorphological features are from the [Harris et al. 2014](https://doi.org/10.1016/j.margeo.2014.01.011) dataset, available at: https://www.bluehabitats.org. The features included are limited to those listed in [Cecarelli et al. 2021](https://doi.org/10.3389/fmars.2021.634574) Table 5.
#'
#' @param spatial_grid `sf` or `terra::rast()` grid, e.g. created using `get_grid()`. Alternatively, if raw data is required, an `sf` polygon can be provided, e.g. created using `get_boundary()`, and set `raw = TRUE`.
#' @param raw `logical` if TRUE, `spatial_grid` should be an `sf` polygon, and the raw geomorphology data in that polygon(s) will be returned
#' @param antimeridian Does `spatial_grid` span the antimeridian? If so, this should be set to `TRUE`, otherwise set to `FALSE`. If set to `NULL` (default) the function will try to check if data spans the antimeridian and set this appropriately.
#'
#' @return For gridded data, a multi-layer raster object, or an `sf` object with geomorphology class in each column, depending on the `spatial_grid` format. If `raw = TRUE` an `sf` object with each row as a different geomorphological feature.
#' @export
#'
#' @examples
#' # Grab EEZ data first 
#' bermuda_eez <- get_boundary(name = "Bermuda")
#' # Get geomorphology for the EEZ
#' bermuda_geomorph <- get_geomorphology(spatial_grid = bermuda_eez, raw = TRUE)
#' plot(geomorphology)
#' # Get geomorphological features in spatial_grid
#' bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 20000)
#' geomorph_gridded <- get_geomorphology(spatial_grid = bermuda_grid)
get_geomorphology <- function(spatial_grid = NULL, raw = FALSE, antimeridian = NULL){
  
  check_grid(spatial_grid)
  
  meth <- if(check_raster(spatial_grid)) 'near' else 'mode'
  
  sf::sf_use_s2(FALSE)
  geomorph_data <- system.file("extdata/geomorphology", package = "oceandatr") %>% 
    list.files() %>% 
    system.file("extdata/geomorphology", ., package = "oceandatr") %>% 
    lapply(readRDS) %>% 
    do.call(rbind, .) %>%
    get_data_in_grid(spatial_grid = spatial_grid, dat = ., raw = raw, meth = meth, feature_names = "geomorph_type", antimeridian = antimeridian)
  
  sf::sf_use_s2(TRUE)
  
  return(geomorph_data)
}
