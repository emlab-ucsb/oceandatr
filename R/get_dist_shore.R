#' Get distance to shore for a spatial grid
#' 
#' @description
#' Calculates distance from shore for each grid cell in the provided spatial grid. Spatial grid can be `terra::rast()` or `sf` format. The Natural Earth high resolution land polygons are used as the coastline and are downloaded from the Natural Earth website (https://www.naturalearthdata.com/downloads/10m-physical-vectors/), so an internet connection is required.
#' 
#' @param spatial_grid `sf` or `terra::rast()` grid, e.g. created using `get_grid()`.
#' @param inverse `logical` set to `TRUE` to get the inverse of distance to shore, i.e. highest values become lowest and vice versa. This is useful for use in spatial prioritization as a proxy for fishing activity, where the further a grid cell is from the shore, the less fishing activity there might be. Default is `FALSE` and returns distance from shore.
#'
#' @return a `terra::rast` or `sf` object (same type as `spatial_grid` input) with distance to shore for each grid cell.
#' @export
#'
#' @examples
#' # Get EEZ data first 
#' bermuda_eez <- get_boundary(name = "Bermuda")
#' # Get a raster spatial grid for Bermuda
#' bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 20000)
#' dist_from_shore_rast <- get_dist_shore(bermuda_grid)
#' terra::plot(dist_from_shore_rast)
get_dist_shore <- function(spatial_grid, inverse = FALSE){
  
  check_grid(spatial_grid)
     
     #get high res land polygons from Natural Earth
     ne_data_filename <- "ne_land_data.zip"
     
     if(!file.exists(file.path(tempdir(), "ne_10m_land.shp"))){
       utils::download.file(url = "https://naturalearth.s3.amazonaws.com/10m_physical/ne_10m_land.zip", destfile = file.path(tempdir(), ne_data_filename), mode = "wb", quiet = TRUE)
       utils::unzip(file.path(tempdir(), ne_data_filename), exdir = tempdir())
     }
     
     ne_data <- sf::read_sf(file.path(tempdir(), "ne_10m_land.shp")) %>% 
       sf::st_geometry() %>% 
       sf::st_sf() 
     
     matching_crs <- check_matching_crs(spatial_grid, 4326)
     
     if(check_raster(spatial_grid)){
       
       if(matching_crs){
         temp_ras <- spatial_grid %>% 
           terra::distance(terra::vect(ne_data)) %>% 
           terra::mask(spatial_grid) %>% 
           setNames("dist_shore")
         
         if(inverse){
           ras_min <- as.numeric(terra::global(temp_ras, "min", na.rm = TRUE)[1])
           ras_max <- as.numeric(terra::global(temp_ras, "max", na.rm = TRUE)[1])
           
           return((ras_max - temp_ras - ras_min))  
         }else temp_ras
         
       }else{
         dist_vect <- spatial_grid %>% 
           terra::as.data.frame(xy = TRUE, cell = TRUE) %>% 
           sf::st_as_sf(coords = c("x", "y"), crs = sf::st_crs(spatial_grid)) %>%
           sf::st_geometry() %>% 
           sf::st_sf() %>% 
           sf::st_transform(4326) %>% 
           sf::st_distance(ne_data) %>% 
           {do.call(pmin, as.data.frame(.))} 
         
         spatial_grid[!is.na(spatial_grid)] <- dist_vect
         
         spatial_grid <- setNames(spatial_grid, "dist_shore")
         
         if(inverse){
           ras_min <- as.numeric(terra::global(spatial_grid, "min", na.rm = TRUE)[1])
           ras_max <- as.numeric(terra::global(spatial_grid, "max", na.rm = TRUE)[1])
           
           return((ras_max - spatial_grid - ras_min))  
         }else spatial_grid
         
       }
     } else{
         grid_has_extra_cols <- if(ncol(spatial_grid)>1) TRUE else FALSE
         
         if(grid_has_extra_cols) extra_cols <- sf::st_drop_geometry(spatial_grid)
         
       temp_grid <- spatial_grid %>% 
         {if(grid_has_extra_cols) sf::st_geometry(.) %>% sf::st_sf() else .} %>% 
         {if(matching_crs) . else sf::st_transform(., 4326)}
       
       temp_grid %>% 
         sf::st_centroid() %>% 
         sf::st_distance(ne_data) %>% 
         {do.call(pmin, as.data.frame(.))} %>% 
         cbind(temp_grid) %>% 
         dplyr::rename(dist_shore = 1) %>% 
         {if(matching_crs) . else sf::st_transform(., sf::st_crs(spatial_grid))} %>%
         {if(inverse) dplyr::mutate(., dist_shore = max(.data$dist_shore, na.rm = TRUE) - dist_shore - min(.data$dist_shore, na.rm = TRUE)) else .} %>% 
         {if(grid_has_extra_cols) cbind(., extra_cols) %>% dplyr::relocate(colnames(extra_cols), .before = 1) else .}
     }
}