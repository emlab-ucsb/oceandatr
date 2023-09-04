#function to handle conversion of AOI (could be simple polygon or planning grid) in sf or raster format to polygon which can then be used for cropping features

aoi_to_cropping_polygon <- function(aoi, data){
  
  if(class(aoi)[1] %in% c("RasterLayer", "SpatRaster")){
    if(sf::st_crs(aoi) == sf::st_crs(data)){
      area_polygon <- aoi %>% 
        terra::as.polygons() %>% 
        sf::st_as_sf()
    }else{
      area_polygon <- aoi %>%
        terra::as.polygons() %>% 
        terra::project(terra::crs(data)) %>% 
        sf::st_as_sf()
    }
  }
  
  if(class(aoi)[1] == "sf"){
    if(sf::st_crs(aoi) == sf::st_crs(data)){
      area_polygon <- aoi
    } else{
      area_polygon <- sf::st_transform(aoi, sf::st_crs(data))
    }
  }
  
  return(area_polygon)
}