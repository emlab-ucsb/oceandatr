sf_to_planning_grid <- function(dat, planning_grid, matching_crs, meth, name, sf_col_layer_names){

  #1st option: the sf data object is polygons showing a single feature presence or there is a column with the each feature named, e.g. sand, seagrass, coral
  
  if(is.null(name)) name <- as.character(substitute(dat))
  
  if(is.null(sf_col_layer_names)){
    dat <- dat %>% 
      sf::st_geometry() %>% 
      sf::st_as_sf()
  }  else {
    dat <- data %>% 
      dplyr::select(dplyr::all_of(sf_col_layer_names))
  }
  
  if(check_raster(planning_grid)){
    if(matching_crs){
      sf_dat <- dat %>% 
        terra::rasterize(planning_grid, field = 1, by = sf_col_layer_names) %>% 
        terra::mask(planning_grid) %>% 
        setNames(name)
    }else{
      sf_dat <- planning_grid %>%
                terra::as.polygons() %>%
                sf::st_as_sf() %>% 
                sf::st_transform(sf::st_crs(dat)) %>%
                sf::st_crop(dat, .) %>%
                sf::st_transform(sf::st_crs(planning_grid)) %>%
                terra::rasterize(planning_grid, field=1, by = sf_col_layer_names) %>%
                terra::mask(planning_grid) %>% 
                setNames(name)
    }
  } else{ #this is for sf planning grid output
    if(matching_crs){
      sf_dat <- dat %>% 
        sf::st_crop(planning_grid) %>%
        sf::st_intersection(planning_grid, .) #this isn't doing what I think it should: check spatialplanr
    }else {
      sf_dat <- planning_grid %>% 
        sf::st_transform(sf::st_crs(dat)) %>% 
        sf::st_crop(dat, .) %>% 
        sf::st_transform(sf::st_crs(planning_grid)) %>% 
        sf::st_intersection(planning_grid, .)
    }
  }
  
  return(sf_dat)
}