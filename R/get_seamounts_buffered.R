#' Get seamount peak areas buffered to a specified radius
#'
#' Seamounts, classified as peaks at least 1000m higher than the surrounding seafloor [Morato et al. 2008](https://doi.org/10.3354/meps07268). These data are from [Yesson et al. 2021](https://doi.org/10.14324/111.444/ucloe.000030). Each peak is buffered to the distance specified in the function call which has to be in kilometres
#' @param area_polygon 
#' @param planning_grid 
#' @param buffer_km 
#'
#' @return A raster of buffered seamount areas found within the area polygon, rasterized using the planning_grid input raster
#' @export
#'
#' @examples
get_seamounts_buffered <- function(area_polygon, planning_grid, buffer_km = 30){
  system.file("extdata", "seamounts.rds", package = "offshoredatr", mustWork = TRUE) %>%
    readRDS() %>% 
    sf::st_crop(area_polygon) %>%
    sf::st_intersection(area_polygon) %>% 
    sf::st_transform(crs = crs(planning_grid)) %>% 
    sf::st_buffer(buffer_km*1000) %>% 
    sf::st_union() %>% 
    sf::st_as_sf() %>% 
    raster::rasterize(planning_grid, field = 1) %>% 
    raster::mask(., planning_grid) %>% 
    setNames("seamounts")
}