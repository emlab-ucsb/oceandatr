#' Get seamount peaks for area of interest
#' 
#' @description This function collects data for seamount peak locations within the area of interest. Seamounts are classified as peaks at least 1000m higher than the surrounding seafloor (Morato et al. 2008)
#'
#' @param area_polygon an sf polygon or multipolygon object of the area of interest (e.g., a country's EEZ)
#' @param planning_grid an sf or raster planning grid
#' @param name name to give to the raster or sf column
#' @param antimeridian should be set to TRUE if the area_polygon or planning_grid crosses the antimeridian. If NULL the function will check
#'
#' @return An sf or raster object of seamounts depending on the area_polygon or planning_grid format
#' @export
#'
#' @examples
#' # Grab EEZ data first 
#' bermuda_eez <- get_area(area_name = "Bermuda")
#' # Get seamount peak locations 
#' seamount_peaks <- get_seamount_peaks(bermuda_eez)
get_seamount_peaks <- function(area_polygon = NULL, planning_grid = NULL, name = "seamounts", antimeridian = NULL){
  
  check_grid_or_polygon(planning_grid, area_polygon)
  
  seamounts <- system.file("extdata", "seamounts.rds", package = "offshoredatr", mustWork = TRUE) %>%
    readRDS()

  meth <- if(check_raster(planning_grid)) "near" else "mode"

  data_to_planning_grid(area_polygon = area_polygon, planning_grid = planning_grid, dat = seamounts, meth = meth, name = name, antimeridian = antimeridian)
}