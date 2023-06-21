#' Create a planning grid raster for an area of interest
#' 
#' @description This function creates a planning grid raster around the area of interest; this is used in several other functions to standardize the extent and CRS of downloaded data.
#'
#' @param area_polygon an sf polygon or multipolygon object of the area of interest (e.g., a country's EEZ)
#' @param projection_crs a suitable crs for the area of interest (must be in meters); for prioritization work, best practices is to use a local, equal area projection in WKT format
#' @param option the desired output format, either "raster", "sf_square" (vector), or "sf_hex" (vector); default is "raster"
#' @param resolution_km numeric; the desired planning unit (grid cell) resolution in km
#'
#' @return A raster planning grid of the same resolution and crs provided
#' @export
#'
#' @examples 
#' # Grab EEZ data first 
#' bermuda_eez <- get_area(area_name = "Bermuda")
#' # Create a CRS using a local, equal area projection in WKT format for Bermuda. 
#' # You can get WKT outputs in equal area projections for your area of interest from https://projectionwizard.org
#' projection <- 'PROJCS["ProjWiz_Custom_Lambert_Azimuthal", GEOGCS["GCS_WGS_1984", DATUM["D_WGS_1984", SPHEROID["WGS_1984",6378137.0,298.257223563]], PRIMEM["Greenwich",0.0], UNIT["Degree",0.0174532925199433]], PROJECTION["Lambert_Azimuthal_Equal_Area"], PARAMETER["False_Easting",0.0], PARAMETER["False_Northing",0.0], PARAMETER["Central_Meridian",-64.5], PARAMETER["Latitude_Of_Origin",32], UNIT["Meter",1.0]]'
#' # Create a planning grid with 5 km resolution; reproject the `bermuda_eez` object to the CRS defined in the `projection` object
#' planning_grid <- get_planning_grid(area_polygon = bermuda_eez, projection_crs = projection, resolution_km = 5)

get_planning_grid <- function(area_polygon, projection_crs, option = "raster", resolution_km = 5){
  
  # Add repeated errors for area_polygon
  if(!(class(area_polygon)[1] == "sf")) { 
    stop("area_polygon must be an sf object")}
  
  area_polygon <- area_polygon %>% 
    sf::st_transform(projection_crs) 
  
  if(option == "raster") { 
    grid_out <- area_polygon %>% 
      terra::rast(resolution = resolution_km*1000) %>% 
      terra::rasterize(terra::vect(sf::st_transform(area_polygon, projection_crs)), ., touches=TRUE, field = 1)
  } else if (option == "sf_square") { 
    grid_out <- sf::st_make_grid(area_polygon, cellsize = resolution_km*1000, square = TRUE) %>% 
      sf::st_as_sf()
    overlap <- unlist(sf::st_intersects(area_trans, grid_out))
    grid_out <- grid_out[overlap,]
  } else if (option == "sf_hex") { 
    grid_out <- sf::st_make_grid(area_polygon, cellsize = resolution_km*1000, square = FALSE) %>% 
      sf::st_as_sf()
    overlap <- unlist(sf::st_intersects(area_trans, grid_out))
    grid_out <- grid_out[overlap,]
  } else { stop("option must be of either 'raster', 'sf_square' or 'sf_hex'")}
  
  return(grid_out)
  
} 