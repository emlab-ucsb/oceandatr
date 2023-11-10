ras_to_planning_grid <- function(dat, planning_grid, matching_crs, meth, name, antimeridian){
  
  if(is.null(name)) name <- names(dat) 
  
  if(check_raster(planning_grid)) {
    if(antimeridian){
      planning_grid %>% 
        terra::as.polygons() %>% 
        terra::project(dat) %>% 
        terra::rotate(left = FALSE) %>% 
        terra::crop(terra::rotate(dat, left = FALSE), .) %>% 
        terra::project(planning_grid, method = meth) %>% 
        terra::mask(planning_grid) %>% 
        setNames(name)
    }else{
      planning_grid %>%
        {if(matching_crs) . else terra::as.polygons(.) %>% terra::project(terra::crs(dat))} %>% 
            terra::crop(dat, .) %>% 
            {if(matching_crs) terra::resample(., planning_grid, method = meth) else terra::project(., planning_grid, method = meth)} %>%
            terra::mask(planning_grid) %>% 
            setNames(name)
    }
  } else {
    if(antimeridian){
      p_grid <- sf::st_geometry(planning_grid) %>%
        sf::st_transform(sf::st_crs(dat)) %>% 
        sf::st_shift_longitude()
      
      dat %>% 
        terra::rotate(left = FALSE) %>% 
        exactextractr::exact_extract(p_grid, meth , force_df = TRUE) %>% 
        setNames(name) %>%
        data.frame(p_grid, .) %>%
        sf::st_sf() %>% 
        sf::st_transform(., sf::st_crs(planning_grid)) 
      
    }else{
      p_grid <- if(matching_crs) sf::st_geometry(planning_grid) else sf::st_transform(sf::st_geometry(planning_grid), sf::st_crs(dat))
      
      dat %>% 
        exactextractr::exact_extract(p_grid, meth , force_df = TRUE) %>% 
        setNames(name) %>%
        data.frame(p_grid, .) %>%
        sf::st_sf() %>% 
        {if(matching_crs) . else sf::st_transform(., sf::st_crs(planning_grid))}
    }
  }
}