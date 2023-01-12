#' Classify bathymetry into depth zones
#'
#' Depth classifications are:
#' * 0 - 200m: Epipelagic zone
#' * 200 - 1000m: Mesopelagic zone
#' * 1000 - 4000m: Bathypelagic zone
#' * 4000 - 6000m: Abyssopelagic zone
#' * 6000m+: Hadopelagic zone
#' 
#' @param bathymetry_raster 
#' @param planning_grid 
#'
#' @return A raster of depth zones, rasterized to the planning grid resolution and CRS if supplied.
#' @export
#'
#' @examples
classify_depths <- function(bathymetry_raster, planning_grid = NULL){
  
  depth_zone_names <- c("epipelagic", "mesopelagic", "bathypelagic", "abyssopelagic", "hadopelagic")
  
  if(is.null(planning_grid)){
    depth_classification <- bathymetry_raster %>%
      raster::reclassify(c(-200, Inf, 1,
                   -1000, -200, 2,
                   -4000, -1000, 3,
                   -6000, -4000, 4,
                   -12000, -6000, 5))
      
    depth_zones_stack <- depth_classification %>% 
      raster::layerize() %>% 
      raster::reclassify(c(-0.1,0.1,NA)) %>% 
      setNames(depth_zone_names[raster::cellStats(depth_classification, min):raster::cellStats(depth_classification, max)])
  } else{
    depth_classification <- bathymetry_raster %>%
      raster::projectRaster(., to = planning_grid) %>% 
      raster::mask(planning_grid) %>% 
      raster::reclassify(c(-200, Inf, 1,
                           -1000, -200, 2,
                           -4000, -1000, 3,
                           -6000, -4000, 4,
                           -12000, -6000, 5))
    
    depth_zones_stack <- depth_classification %>% 
      raster::layerize() %>% 
      raster::mask(planning_grid) %>% 
      raster::reclassify(c(-0.1,0.1,NA)) %>% 
      setNames(depth_zone_names[raster::cellStats(depth_classification, min):raster::cellStats(depth_classification, max)])
  }
  return(depth_zones_stack)
}