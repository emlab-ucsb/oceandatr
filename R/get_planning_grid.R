#' Create a planning grid raster for an area of interest
#'
#' @param area_polygon An sf object that will be rasterized
#' @param projection_crs A suitable crs for the area of interest
#' @param resolution_km The desired planning unit (grid cell) resolution in km
#'
#' @return A raster planning grid of the same resolution and crs provided
#' @export
#'
#' @examples 
get_planning_grid <- function(area_polygon, projection_crs, resolution_km = 5){
  area_polygon %>% 
    sf::st_transform(projection_crs) %>% 
    raster::raster(resolution = resolution_km*1000) %>% 
    terra::rasterize(sf::st_transform(area_polygon, projection_crs), ., touches=TRUE, field = 1)
}