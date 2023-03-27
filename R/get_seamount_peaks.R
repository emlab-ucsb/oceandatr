#' Get seamount peaks for area of interest
#' 
#' @description This function collects data for seamount peak locations within the area of interest. Seamounts are classified as peaks at least 1000m higher than the surrounding seafloor (Morato et al. 2008)
#'
#' @param area_polygon an sf polygon or multipolygon object of the area of interest (e.g., a country's EEZ)
#'
#' @return An sf object of seamounts for the area of interest
#' @export
#'
#' @examples
#' # Grab EEZ data first 
#' bermuda_eez <- get_area(area_name = "Bermuda")
#' # Get seamount peak locations 
#' seamount_peaks <- get_seamount_peaks(bermuda_eez)
get_seamount_peaks <- function(area_polygon){
  system.file("extdata", "seamounts.rds", package = "offshoredatr", mustWork = TRUE) %>%
    readRDS() %>% 
    sf::st_crop(area_polygon) %>%
    sf::st_intersection(area_polygon)
}