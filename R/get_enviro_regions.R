#function for extracting Bio-Oracle environmental data for an area using a polygon
# base case is using this list, but user can supply custom layer codes: "Chlorophyll Mean", "Dissolved oxygen Mean", "Nitrate Mean", "pH mean", "Phosphate Mean", "Phytoplankton Mean", "Primary productivity Mean", "Salinity Mean", "Silicate Mean", "Temperature Max", "Temperature Mean", "Temperature Min"
#returns a raster stack of data

#' Create environmental regions for area of interest
#'
#' @param area_polygon 
#' @param bo_layer_codes 
#' @param data_dir 
#'
#' @return
#' @export
#'
#' @examples
get_enviro_regions <- function(area_polygon){
  
  tif_list <- list.files(system.file("extdata", "bio_oracle", package = "offshoredatr", mustWork = TRUE), full.names = TRUE)
  
  print(tif_list)
  
  enviro_data <- terra::rast()
  for (i in tif_list) {
    
  terra::add(enviro_data) <- terra::rast(tif_list[i]) %>% 
      terra::crop(area_polygon, mask = TRUE)
  }
  
  return(enviro_data)
  
}