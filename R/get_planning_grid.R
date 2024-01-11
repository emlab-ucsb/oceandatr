#' Create a planning grid raster for an area of interest
#' 
#' @description This function creates a planning grid for area of interest.
#' 
#' @details
#' This function uses `sf::st_make_grid()` to create an `sf` planning grid. The default ordering of this grid type is from bottom to top, left to right. In contrast, the planning grid resulting from a `raster` object is ordered from top to bottom, left to right. To preserve consistency across the data types, we have reordered the `sf` planning grid to also fill from top to bottom, left to right.
#'
#' @param area_polygon an sf polygon or multipolygon object of the area of interest (e.g., a country's EEZ)
#' @param projection_crs a suitable crs for the area of interest; for prioritization work, best practices is to use a local, equal area projection
#' @param option the desired output format, either "raster", "sf_square" (vector), or "sf_hex" (vector); default is "raster"
#' @param resolution numeric; the desired planning unit (grid cell) resolution in units (usually metres or degrees) of the projection_crs: `sf::st_crs(projection_crs, parameters = TRUE)$units_gdal`
#'
#' @return A `terra::rast()` of `sf` planning grid of the same resolution and crs provided
#' @export
#'
#' @examples 
#' # Get area of interest first. In this case Bermuda's EEZ
#' bermuda_eez <- get_area(area_name = "Bermuda")
#' # Create a CRS using a local, equal area projection for Bermuda. 
#' # You can a suitable equal area projection for your area of interest from https://projectionwizard.org
#' projection <- '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs'
#' # Create a planning grid with 5 km (5000 m) resolution covering the `bermuda_eez` in projection specified by `projection_crs` object
#' planning_grid <- get_planning_grid(area_polygon = bermuda_eez, projection_crs = projection, resolution = 5000)

get_planning_grid <- function(area_polygon, projection_crs, option = "raster", resolution = 5000){
  
  # Add repeated errors for area_polygon
  if(!check_sf(area_polygon)) { 
    stop("area_polygon must be an sf object")}
  
  if(!(option %in% c("raster", "sf_square", "sf_hex"))) stop("option must be either 'raster', 'sf_square' or 'sf_hex'")
  
  area_polygon <- area_polygon %>% 
    sf::st_geometry() %>% 
    sf::st_as_sf() %>% 
    {if(sf::st_crs(area_polygon) == projection_crs) . else sf::st_transform(., projection_crs)}
  
  if(option == "raster") { 
    area_polygon %>% 
      terra::rast(resolution = resolution) %>% 
      terra::rasterize(area_polygon, ., touches=FALSE, field = 1)
    
  } else{
    grid_out <- if(option == "sf_square") sf::st_make_grid(area_polygon, cellsize = resolution, square = TRUE) %>% sf::st_as_sf() else sf::st_make_grid(area_polygon, cellsize = resolution, square = FALSE) %>% sf::st_as_sf() 
    
    grid_centroids <- sf::st_centroid(grid_out)
    
    overlap <- sf::st_intersects(grid_centroids, area_polygon) %>% 
      lengths() > 0
    grid_out[overlap,] %>% 
      dplyr::bind_cols(sf::st_coordinates(sf::st_centroid(.)) %>%
                         as.data.frame() %>%
                         dplyr::select(X, Y)) %>%
      dplyr::mutate(X = round(X, digits = 4),
                    Y = round(Y, digits = 4)) %>%
      dplyr::arrange(dplyr::desc(Y), X) %>%
      dplyr::select(-X, -Y)
  } 
} 