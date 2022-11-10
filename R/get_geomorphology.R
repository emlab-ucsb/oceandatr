#' Get geomorphology for an area of interest
#'
#' @param area_polygon 
#' @param planning_grid 
#' @param raster_or_vector 
#'
#' @return A raster stack with geomorphological features found within the area polygon rasterized using the planning_grid input raster, or a list of geomorphological features in sf format
#' @export
#'
#' @examples
get_geomorphology <- function(area_polygon, planning_grid, raster_or_vector = "raster"){
  geomorph_files <- c("Basins_Basins perched on the shelf.rds", "Basins_Basins perched on the slope.rds", 
                      "Basins_Large basins of seas and oceans.rds", "Basins_Major ocean basins.rds", 
                      "Basins_Small basins of seas and oceans.rds", "Bridges.rds", 
                      "Canyons_blind.rds", "Canyons_shelf incising.rds", "Escarpments.rds", 
                      "Fans.rds", "Glacial_troughs.rds", "Guyots.rds", "Plateaus.rds", 
                      "Ridges.rds", "Rift_valleys.rds", "Rises.rds", "Shelf_valleys_Large shelf valleys and glacial troughs.rds", 
                      "Shelf_valleys_Moderate size shelf valley.rds", "Shelf_valleys_Small shelf valley.rds", 
                      "Sills.rds", "Spreading_ridges.rds", "Terraces.rds", "Trenches.rds", 
                      "Troughs.rds")
  
  geomorph_file_paths <- system.file("extdata", geomorph_files, package = "offshoredatr", mustWork = TRUE)
  print(geomorph_file_paths)

  sf_use_s2(FALSE)

  geomorph_data <- list()

  for (file_name in geomorph_file_paths) {
    feature_name <- gsub(pattern =  ".rds",replacement =  "", basename(file_name))
  
    temp_file <- readRDS(file_name) %>%
      st_crop(area_polygon) %>%
      st_intersection(area_polygon)

    if(nrow(temp_file)>0)
    {
      geomorph_data[[feature_name]] <- temp_file
    }
  }

  geomorph_data_stack <- stack()

  for (geomorph_feature in names(geomorph_data)) {
    geomorph_data_stack <- geomorph_data[[geomorph_feature]] %>%
      st_transform(crs = crs(planning_grid)) %>%
      rasterize(planning_grid, field = 1) %>%
      mask(., planning_grid) %>%
      setNames(geomorph_feature) %>%
      addLayer(geomorph_data_stack, .)
  }

  ifelse(raster_or_vector == "raster", return(geomorph_data_stack), return(geomorph_data))
}