#function to handle conversion of planning grid in sf or raster format to polygon which can then be used for cropping features

planning_grid_to_polygon <- function(planning_grid){
  
  if(class(planning_grid)[1] %in% c("RasterLayer", "SpatRaster")){
    if(sf::st_crs(planning_grid) == sf::st_crs(4326)){
      area_polygon <- planning_grid %>% 
        terra::as.polygons() %>% 
        sf::st_as_sf()
    }else{
      area_polygon <- planning_grid %>%
        terra::as.polygons() %>% 
        terra::project("epsg:4326") %>% 
        sf::st_as_sf()
    }
  }
  
  if(class(planning_grid)[1] == "sf"){
    if(sf::st_crs(planning_grid) == sf::st_crs(4326)){
      area_polygon <- planning_grid
    } else{
      area_polygon <- sf::st_transform(planning_grid, 4326)
    }
  }
  
  return(area_polygon)
}