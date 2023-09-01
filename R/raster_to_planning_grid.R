raster_to_planning_grid <- function(ras, planning_grid, name){
  
  if(class(planning_grid)[1] %in% c("RasterLayer", "SpatRaster")) {
    if(sf::st_crs(ras) == sf::st_crs(planning_grid)){
      ras_planning_grid <- ras %>%
        terra::resample(planning_grid, method = 'average') %>% 
        terra::crop(planning_grid, mask = TRUE) %>% 
        setNames(name)
    }else{
      ras_planning_grid <- ras %>% 
        terra::project(planning_grid, method = 'average') %>%
        terra::crop(planning_grid, mask = TRUE) %>% 
        setNames(name)
      }
  } else {
    if(sf::st_crs(ras) == sf::st_crs(planning_grid)){
      ras_planning_grid <- ras %>% 
        exactextractr::exact_extract(planning_grid, 'mean', force_df = TRUE) %>% 
        setNames(name) %>% 
        cbind(planning_grid, .)
    }else{
      ras_planning_grid <- ras %>% 
        exactextractr::exact_extract(sf::st_transform(planning_grid, sf::st_crs(.)), 'mean', force_df = TRUE) %>% 
        setNames(name) %>%
        cbind(planning_grid, .) %>% 
        sf::st_transform(sf::st_crs(planning_grid))
    }
  }
  return(ras_planning_grid) 
}