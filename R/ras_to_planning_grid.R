ras_to_planning_grid <- function(dat, planning_grid, matching_crs, meth, name){
  
  if(is.null(name)) name <- names(dat) 
  
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
        exactextractr::exact_extract(sf::st_geometry(planning_grid), meth , force_df = TRUE) %>% 
        setNames(name) %>% 
        data.frame(planning_grid, .) %>% 
        sf::st_sf()
    }else{
      p_grid_transformed <- sf::st_transform(sf::st_geometry(planning_grid), sf::st_crs(dat))
      
      ras_dat <- dat %>% 
        exactextractr::exact_extract(p_grid_transformed, meth , force_df = TRUE) %>% 
        setNames(name) %>%
        data.frame(p_grid_transformed, .) %>%
        sf::st_sf() %>% 
        sf::st_transform(sf::st_crs(planning_grid))
    }
  }
  return(ras_dat) 
}