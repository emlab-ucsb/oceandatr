#' Get coral habitat suitability data for area of interest
#' 
#' Antipatharia: Global extent of black coral habitat suitability modelled using Maxent. The antipatharia habitat suitability was converted to a presence/ absence map "by choosing a threshold value of habitat suitability based on the maximum sum of sensitivity and specificity (threshold mss = 0.23)". Text from the source paper, Yesson et al. 2017. This threshold can be altered via the function input.
#' 
#' Cold water corals: Modelled habitat suitability for five species of Scleractinia, using Maxent. Presence defined using Maxent values above the lowest 10% of values (see Fig 7 in reference)
#' 
#' Octocorals: Modelled global habitat suitability for 7 species of cold-water octocoral, found deeper than 50m. "A consensus/summary map incorporating all seven octocoral suborders was constructed by generating binary presence/absence maps from the model outputs indicating areas of high suitability using a score threshold that maximized the sum of the specificity and sensitivity based on the validation data (Carroll, 2010). These binary layers were summed to generate a layer containing the number of octocoral suborders predicted to be present per cell."
#' 
#' 
#'
#' @param area_polygon 
#' @param planning_grid 
#' @param octocoral_threshold 
#' @param antipatharia_threshold 
#'
#' @return A raster stack with of coral habitat suitabilities within the area polygon, this is rasterized using the planning_grid input raster if supplied
#' @export
#'
#' @examples
get_coral_habitat <- function(area_polygon, planning_grid = NULL, antipatharia_threshold = 0.22, octocoral_threshold = 2){
 
  antipatharia <- system.file("extdata", "YessonEtAl_2016_Antipatharia.tif", package = "offshoredatr", mustWork = TRUE) %>% 
    raster::raster() %>% 
    raster::crop(area_polygon) %>% 
    raster::mask(area_polygon) %>% 
    setNames("Antipatharia")
  
  ifelse(cellStats(antipatharia, sum) < 1, print("No antipatharia in area of interest"), print("Antipatharia data done"))

  
  cold_corals <- system.file("extdata", "binary_grid_figure7.tif", package = "offshoredatr", mustWork = TRUE) %>% 
    raster::raster() %>% 
    raster::crop(area_polygon) %>% 
    raster::mask(area_polygon) %>% 
    setNames("Cold_Corals")
  
  ifelse(cellStats(cold_corals, sum) < 1, print("No octocorals in area of interest"), print("Cold water coral data done"))
  
  octocorals <- system.file("extdata", "YessonEtAl_Consensus.tif", package = "offshoredatr", mustWork = TRUE) %>% 
    raster::raster() %>% 
    raster::crop(area_polygon) %>% 
    raster::mask(area_polygon) %>% 
    setNames("Octocoral")
  
  ifelse(cellStats(octocorals, sum) < 1, print("No octocorals in area of interest"), print("Octocoral data done"))
  
  corals_stack <- raster::stack(antipatharia, cold_corals, octocorals) %>% 
    raster::subset(which(cellStats(., sum) >1))

  gc()
  
  if(is.null(planning_grid)){
    return(corals_stack)
  }
  else{
    antipatharia <- antipatharia %>%     
      projectRaster(., to = planning_grid) %>% 
      mask(planning_grid) %>%
      #convert antipatharia habitat suitability to presence/ absence map "by choosing a threshold value of habitat suitability based on the maximum sum of sensitivity and specificity (threshold mss = 0.23)". Text from the original source paper, Yesson et al. 2017
      reclassify(c(0, antipatharia_threshold, NA, 
                   antipatharia_threshold, 100, 1)) %>%
      setNames("antipatharia")
    
    cold_corals <- cold_corals %>% 
      reclassify(c(0, 0.5, NA, 
                   0.5, 1.1, 1), include.lowest = TRUE) %>%
      projectRaster(., to = planning_grid, method = 'ngb') %>% 
      mask(planning_grid) %>% 
      setNames("cold_coral")
    
    octocorals <- octocorals %>% 
      reclassify(c(0, octocoral_threshold, NA,
                   octocoral_threshold,7, 1), include.lowest = TRUE) %>% 
      projectRaster(., to = planning_grid, method = 'ngb') %>% 
      mask(planning_grid) %>% 
      setNames("octocorals")
  }
  
}