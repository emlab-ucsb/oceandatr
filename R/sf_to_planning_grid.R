sf_to_planning_grid <- function(dat, planning_grid, matching_crs, meth, name, sf_col_names){
  
  #covers single type of data in sf or column with data types (coral, sand,...)
  if(is.null(sf_col_names) | class(dat[[sf_col_names]]) == "character"){
    if(check_raster(planning_grid)) {
      if(matching_crs){
        sf_dat <- dat %>% 
          sf::st_as_sf() %>% 
          terra::rasterize(planning_grid, field = 1, by = sf_col_names) %>% 
          setNames(name)
      }else{
        sf_dat <- planning_grid %>%
          terra::as.polygons() %>% 
          sf::st_as_sf() %>% 
          sf::st_transform(sf::st_crs(dat)) %>% 
          sf::st_crop(dat, .) %>% 
          sf::st_transform(st_crs(planning_grid)) %>% 
          terra::rasterize(planning_grid, field=1, by = sf_col_names) %>% 
          setNames(name)
      }
    }else{ #TO DO: equivalent to above with sf planning grid output
      if(matching_crs){
        sf <- data %>% 
          {if(is.null(sf_col_names)) sf::st_geometry(.) else dplyr::select(sf_col_names)} %>% 
          sf::st_crop(planning_grid) %>% 
          sf::st_intersection(planning_grid, .) #this isn't doing what I think it should: check spatialplanr
      }else{
        
      }
    }
  }
  
  return(sf_dat)
}