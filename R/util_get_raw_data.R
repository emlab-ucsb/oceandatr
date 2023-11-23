#return data intersected with a polygon

get_raw_data <- function(area_polygon, dat, meth, matching_crs, antimeridian){
  area_polygon <- area_polygon %>% 
    sf::st_geometry() %>% 
    sf::st_as_sf()
  
  if(check_raster(dat)){
    if(matching_crs){
      dat %>% 
        terra::crop(sf::st_as_sf(area_polygon), mask = TRUE)
    }else{
      area_polygon %>% 
        sf::st_transform(sf::st_crs(dat)) %>%
        sf::st_as_sf() %>% 
        {if(antimeridian) terra::crop(terra::rotate(dat, left = FALSE), sf::st_shift_longitude(.)) else terra::crop(dat, .)} %>% 
        terra::project(terra::crs(area_polygon), method = meth) %>% 
        terra::mask(., area_polygon)
    }
  }else{
    if(matching_crs){
      dat %>% 
        sf::st_intersection(sf::st_geometry(area_polygon)) %>%
        {if(antimeridian) sf::st_wrap_dateline(.) else .}
        
    }else{
      if(antimeridian){
        area_polygon %>% 
          sf::st_transform(sf::st_crs(dat)) %>% 
          sf::st_shift_longitude() %>% 
          sf::st_intersection(dat %>% sf::st_shift_longitude()) %>% 
          sf::st_wrap_dateline() %>% 
          sf::st_transform(sf::st_crs(area_polygon))
      }else{
        area_polygon %>% 
          sf::st_transform(sf::st_crs(dat)) %>% 
          sf::st_intersection(dat, sf::st_geometry(.)) %>% 
          sf::st_transform(sf::st_crs(area_polygon))        
      }
    }
  }
}