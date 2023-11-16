#function to check if an sf polygon crosses the antimeridian

check_antimeridian <- function(sf_object){
  if(sf::st_crs(sf_object) != sf::st_crs(4326)){
    b_box <- sf::st_transform(sf_object, 4326) %>% 
      sf::st_bbox()
  } else{
    b_box <- sf::st_bbox(sf_object) 
  }

  if(round(b_box$xmin) == -180 & round(b_box$xmax) == 180){
    TRUE
  } else{
    FALSE
  }
}