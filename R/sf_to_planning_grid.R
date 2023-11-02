sf_to_planning_grid <- function(dat, planning_grid, matching_crs, meth, name, sf_col_layer_names){

  #1st option: the sf data object is polygons showing a single feature presence or sf_col_layer_names is names of each habitat/ species/ other feature
  
  if(is.null(name)) name <- "data"
  
  if(is.null(sf_col_layer_names)){
    dat <- dat %>% 
      sf::st_geometry() %>% 
      sf::st_as_sf() %>% 
      dplyr::mutate(sf_col_layer_names = 1, .before = 1)
  }  else {
    dat <- dat %>% 
      dplyr::select(dplyr::all_of(sf_col_layer_names))
  }
  
  if(check_raster(planning_grid)){
    if(matching_crs){
      dat %>% 
        terra::rasterize(planning_grid, field = 1, by = sf_col_layer_names) %>% 
        terra::mask(planning_grid) %>% 
        setNames(name)
    }else{
      planning_grid %>%
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
      presence_absence <- dat %>% 
        sf::st_crop(planning_grid) %>%
        sf::st_intersects(planning_grid, .) %>% 
        {lengths(.)>0} %>% 
        as.integer()
      
     planning_grid %>% 
        dplyr::mutate("{name}" := presence_absence, .before = 1) %>% 
        {if(check_antimeridian(planning_grid)) sf::st_wrap_dateline(.) %>% sf::st_make_valid() else .}
      
    }else {
      presence_absence <- planning_grid %>% 
        sf::st_transform(sf::st_crs(dat)) %>% 
        sf::st_crop(dat, .) %>% 
        sf::st_transform(sf::st_crs(planning_grid)) %>% 
        sf::st_intersects(planning_grid, .) %>% 
        {lengths(.)>0} %>% 
        as.integer() 
      
      planning_grid %>% 
        dplyr::mutate("{name}" := presence_absence, .before = 1) %>% 
        {if(check_antimeridian(planning_grid)) sf::st_wrap_dateline(.) %>% sf::st_make_valid() else .}
    }
  }

}