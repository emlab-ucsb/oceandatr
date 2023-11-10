antimeridian_l_r_bbox <- function(polygon_antimeridian_crossing){
  polys_lr <- list()
  
  temp_poly <- polygon_antimeridian_crossing %>% 
    sf::st_as_sf() %>% 
    sf::st_geometry() %>%
    sf::st_transform(4326) %>% 
    sf::st_wrap_dateline()
  
  polys_lr[["left"]] <- sf::st_bbox(c(xmin = 0, ymin = -90, xmax = 180.5, ymax = 90)) %>% 
    sf::st_crop(temp_poly, .) 
  
  polys_lr[["right"]] <- sf::st_bbox(c(xmin = -180.5, ymin = -90, xmax = 0, ymax = 90)) %>% 
    sf::st_crop(temp_poly, .)
  
  polys_lr
}