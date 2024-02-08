get_dist_shore <- function(spatialgrid){
  if(!any(check_raster(spatialgrid) & check_sf(spatialgrid))) stop("spatialgrid must be in raster or sf format")
     
     #get high res land polygons from Natural Earth
     ne_data_filename <- "ne_land_data.zip"
     
     if(!file.exists(file.path(tempdir(), "ne_10m_land.shp"))){
       utils::download.file(url = "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_land.zip", destfile = file.path(tempdir(), ne_data_filename), mode = "wb", quiet = TRUE)
       utils::unzip(file.path(tempdir(), ne_data_filename), exdir = tempdir())
     }
     
     ne_data <- sf::read_sf(file.path(tempdir(), "ne_10m_land.shp")) %>% 
       sf::st_geometry() %>% 
       sf::st_combine() %>% 
       sf::st_sf() %>% 
       sf::st_make_valid() %>% 
       terra::vect()
}