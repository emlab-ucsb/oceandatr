ras_to_planning_grid <- function(dat, planning_grid, matching_crs, meth, name){
  
  if(check_raster(planning_grid)) {
    if(matching_crs){
      ras_dat <- dat %>% 
        terra::crop(planning_grid)
        terra::resample(planning_grid, method = meth) %>% 
        terra::mask(planning_grid) %>% 
        setNames(name)
    }else{
      ras_dat <- planning_grid %>%
        terra::as.polygons() %>% 
        terra::project(terra::crs(dat)) %>% 
        terra::crop(dat, .) %>% 
        terra::project(planning_grid, method = meth) %>%
        terra::mask(planning_grid) %>% 
        setNames(name)
      }
  } else {
    if(matching_crs){
      ras_dat <- dat %>% 
        exactextractr::exact_extract(sf::st_geometry(planning_grid), 'mean', force_df = TRUE) %>% 
        setNames(name) %>% 
        cbind(planning_grid, .)
    }else{
      p_grid_transformed <- sf::st_transform(sf::st_geometry(planning_grid), sf::st_crs(dat))
      
      ras_dat <- dat %>% 
        exactextractr::exact_extract(p_grid_transformed, 'mean', force_df = TRUE) %>% 
        setNames(name) %>%
        cbind(p_grid_transformed, .) %>% 
        sf::st_transform(sf::st_crs(planning_grid))
    }
  }
  return(ras_dat) 
}