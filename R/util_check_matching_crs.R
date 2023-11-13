#check if crs of data match
check_matching_crs <- function(area_polygon, planning_grid, dat){
  if(is.null(planning_grid)){
    ifelse(sf::st_crs(area_polygon) == sf::st_crs(dat), TRUE, FALSE) 
  }else{
    ifelse(sf::st_crs(planning_grid) == sf::st_crs(dat), TRUE, FALSE)
  } 
}