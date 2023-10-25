#return data intersected with a polygon

get_raw_data <- function(area_polygon, dat, meth, matching_crs){
  
  if(check_raster(dat)){
    if(matching_crs){
      raw_data_masked <- terra::crop(dat, area_polygon, mask = TRUE)
      return(raw_data_masked)
    }else{
      raw_data_masked <- area_polygon %>% 
        sf::st_transform(sf::st_crs(dat)) %>% 
        terra::crop(dat, .) %>% 
        terra::project(terra::crs(area_polygon), method = meth) %>% 
        terra::mask(area_polygon)
      return(raw_data_masked)
    }
  }else{
    if(matching_crs){
      raw_data_masked <- sf::st_intersection(dat, sf::st_geometry(area_polygon)) %>% 
        {if(check_antimeridian(.)) sf::st_wrap_dateline(.) %>% sf::st_make_valid() else .}
      return(raw_data_masked)
    }else{
      raw_data_masked <- area_polygon %>% 
        sf::st_transform(sf::st_crs(dat)) %>% 
        sf::st_intersection(dat, sf::st_geometry(.)) %>% 
        sf::st_transform(sf::st_crs(area_polygon)) %>% 
        {if(check_antimeridian(.)) sf::st_wrap_dateline(.) %>% sf::st_make_valid() else .}
      return(raw_data_masked)
    }
  }
}