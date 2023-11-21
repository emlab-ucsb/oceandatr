#function to check and retrieve data if a file is not already loaded 

data_from_filepath <- function(dat){
  ## First deal with whether the input is a file or a dataset
  if (class(dat)[1] == "character") { # If a file, we need to load the data
    
    ext <- tools::file_ext(dat)
    nm <- basename(dat) 
    if (ext %in% c("tif", "tiff", "grd", "gri")) {
      print("Data is in raster format")
      dat <- terra::rast(dat)
    } else if (ext %in% c("shp", "gpkg")) {
      print("Data is in vector format")
      dat <- sf::read_sf(dat)
    }
  }
 return(dat) 
}