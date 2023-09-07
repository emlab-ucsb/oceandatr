#check if data is raster
check_raster <- function(dat){
  if(class(dat)[1] %in% c("RasterLayer", "SpatRaster")){
    return(TRUE)
  }else{
    return(FALSE)
  }
}