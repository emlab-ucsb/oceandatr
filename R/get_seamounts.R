#' Get seamounts
#' 
#' @description Get seamounts data in a spatial grid or polygon
#' 
#' @details Seamounts are classified as peaks at least 1000m higher than the surrounding seafloor [Morato et al. 2008](https://doi.org/10.3354/meps07268). The seamounts peak dataset is from [Yeson et al. 2021](https://doi.org/10.14324/111.444/ucloe.000030). 
#' [Morato et al. 2010](https://doi.org/10.1073/pnas.0910290107) found that seamounts have higher biodiversity within 30 - 40 km of the peak. To enable this radius of higher biodiversity to be included in conservation planning, the `buffer` argument can be set, so that each seamount peak is buffered to the radius specified
#'
#' @param spatial_grid `sf` or `terra::rast()` grid, e.g. created using `get_grid()`. Alternatively, if raw data is required, an `sf` polygon can be provided, e.g. created using `get_boundary()`, and set `raw = TRUE`.
#' @param raw `logical` if TRUE, `spatial_grid` should be an `sf` polygon, and the raw seamounts data in that polygon(s) will be returned
#' @param buffer `numeric`; the distance from the seamount peak to include in the output. Distance should be in the same units as the spatial_grid, use e.g. `sf::st_crs(spatial_grid, parameters = TRUE)$units_gdal` to check units. If buffering raw data, units are metres, unless `sf::sf_use_s2()` is set to `FALSE`, in which case the units are degrees.
#' @param name name of raster or column in sf object that is returned
#' @param antimeridian Does `spatial_grid` span the antimeridian? If so, this should be set to `TRUE`, otherwise set to `FALSE`. If set to `NULL` (default) the function will try to check if data spans the antimeridian and set this appropriately.
#'
#' @return For buffered seamounts as gridded data, a `terra::rast()` or `sf` object, depending on the `spatial_grid` format. If `raw = TRUE` and `buffer = NULL` an `sf` POINT geometry object of seamount peaks within the polygon provided. If `raw = TRUE` and `buffer` is not `NULL` an `sf` polygon geometry object of buffered seamount peaks within the polygon provided. Note: at present, it is not possible to return gridded seamount peaks: https://github.com/emlab-ucsb/oceandatr/issues/48
#' @export
#'
#' @examples
#' # Get EEZ data first 
#' bermuda_eez <- get_boundary(name = "Bermuda")
#' # Get raw seamounts data
#' seamount_peaks <- get_seamounts(spatial_grid = bermuda_eez, raw = TRUE)
#' plot(seamount_peaks["Depth"])
#' # Get gridded seamount data
#' bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 10000)
#' #buffer seamounts to a distance of 30 km (30,000 m)
#' seamounts_gridded <- get_seamounts(spatial_grid = bermuda_grid, buffer = 30000)
#' terra::plot(seamounts_gridded)
get_seamounts <- function(spatial_grid = NULL, raw = FALSE, buffer = NULL, name = "seamounts", antimeridian = NULL){
  
  check_grid(spatial_grid)
  
  seamounts <- system.file("extdata", "seamounts.rds", package = "oceandatr", mustWork = TRUE) %>%
    readRDS()
  
  if(raw){
    sf::sf_use_s2(FALSE)
    raw_seamounts <- get_data_in_grid(spatial_grid = spatial_grid, dat = seamounts, raw = TRUE, antimeridian = antimeridian) %>% 
      {if(is.null(buffer)) . else sf::st_buffer(., buffer)}
    sf::sf_use_s2(TRUE)
    return(raw_seamounts)
  } else{
    
    meth <- if(check_raster(spatial_grid)) "near" else "mode"
    
    cropping_polygon <- if(check_raster(spatial_grid)){
      terra::as.polygons(spatial_grid) %>%
        sf::st_as_sf()
      }else{
        spatial_grid
    } 
    sf::sf_use_s2(FALSE)
    gridded_buffered_seamounts <- get_data_in_grid(spatial_grid = cropping_polygon, dat = seamounts, raw = TRUE, antimeridian = antimeridian) %>% 
      sf::st_geometry() %>% 
      sf::st_sf() %>% 
      sf::st_buffer(buffer) %>% 
      sf::st_union() %>% 
      sf::st_sf() %>% 
      get_data_in_grid(spatial_grid = spatial_grid, dat = ., raw = FALSE, meth = meth, name = "seamounts", antimeridian = antimeridian)
    
    sf::sf_use_s2(TRUE)
    
    return(gridded_buffered_seamounts)
  }
  
}
