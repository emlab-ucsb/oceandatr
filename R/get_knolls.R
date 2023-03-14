#' Get knolls base areas for area of interest
#'
#' Knolls are 'small' seamounts, classified as seamounts between 200 and 1000m higher than the surrounding seafloor [Morato et al. 2008](https://doi.org/10.3354/meps07268). These data are the knoll base area data from [Yesson et al. 2011](https://doi.org/10.1016/j.dsr.2011.02.004).
#'
#' @param area_polygon 
#' @param planning_grid 
#'
#' @return A raster of knolls found within the area polygon, rasterized using the planning_grid input raster, or an sf object of knolls for the area of interest if no planning grid is supplied
#' @export
#'
#' @examples
get_knolls <- function(area_polygon, planning_grid = NULL){
  if(is.null(planning_grid)){
    knolls <- system.file("extdata", "knolls.rds", package = "offshoredatr", mustWork = TRUE) %>%
      readRDS() %>% 
      sf::st_crop(area_polygon) %>%
      sf::st_intersection(area_polygon)
  }
  else{
    knolls <- system.file("extdata", "knolls.rds", package = "offshoredatr", mustWork = TRUE) %>%
      readRDS() %>%
      sf::st_crop(area_polygon) %>% 
      sf::st_transform(crs = crs(planning_grid)) %>%
      raster::rasterize(planning_grid, field = 1) %>%
      raster::mask(., planning_grid) %>%
      setNames("knolls")
  }
  return(knolls)
}