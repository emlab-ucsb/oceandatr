antimeridian_l_r_bbox <- function(polygon_antimeridian_crossing){
  polys_lr <- list()
  
  #turn of s2 to try and resolve issue with duplicate vertex errors
  sf::sf_use_s2(FALSE)
  
  temp_poly <- sf::st_as_sf(polygon_antimeridian_crossing) %>% 
    sf::st_geometry() %>% 
    sf::st_break_antimeridian()
  
  print(plot(temp_poly))
  
  polys_lr[["left"]] <- sf::st_bbox(c(xmin = 0, ymin = -90, xmax = 180, ymax = 90)) %>% 
    sf::st_crop(temp_poly, .) 
  
  polys_lr[["right"]] <- sf::st_bbox(c(xmin = -180, ymin = -90, xmax = 0, ymax = 90)) %>% 
    sf::st_crop(temp_poly, .)
  
  polys_lr
}