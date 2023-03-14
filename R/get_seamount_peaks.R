#' Get seamount peaks for area of interest
#'
#' Seamounts, classified as peaks at least 1000m higher than the surrounding seafloor [Morato et al. 2008](https://doi.org/10.3354/meps07268). These data are from [Yesson et al. 2021](https://doi.org/10.14324/111.444/ucloe.000030).
#' @param area_polygon 
#'
#' @return An sf object of seamounts for the area of interest
#' @export
#'
#' @examples
get_seamount_peaks <- function(area_polygon){
  system.file("extdata", "seamounts.rds", package = "offshoredatr", mustWork = TRUE) %>%
    readRDS() %>% 
    sf::st_crop(area_polygon) %>%
    sf::st_intersection(area_polygon)
}