#function to handle conversion of planning grid in sf or raster format to polygon which can then be used for cropping features

planning_grid_to_polygon <- function(planning_grid, matching_crs){
  
  if(check_raster(planning_grid)){
    planning_grid %>% 
      terra::as.polygons() %>% 
      {if(matching_crs) . else terra::project(., "epsg:4326")} %>% 
      sf::st_as_sf()
  }else{
    planning_grid %>% 
      {if(matching_crs) . else sf::st_transform(., 4326)}
  }
}