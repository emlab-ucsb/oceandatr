#' Get distance to port or shore for a spatial grid
#' 
#' @description
#' Calculates distance from port or shore for each grid cell in the provided spatial grid. Spatial grid can be `terra::rast()` or `sf` format.
#' Port locations are downloaded directly from the World Port Index (Pub 150): https://msi.nga.mil/Publications/WPI. Alternatively, anchorages can be used instead. T
#' The anchorages data is from Global Fishing Watch and identifies anchorages as anywhere vessels with AIS remain stationary for 12 hours or more (see https://globalfishingwatch.org/datasets-and-code-anchorages/).
#' The Natural Earth high resolution land polygons are used as the shoreline and are downloaded from the Natural Earth website (https://www.naturalearthdata.com/downloads/10m-physical-vectors/), so an internet connection is required.
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
get_dist <- function(spatial_grid, inverse = FALSE, ports = TRUE, ports_data = "wpi"){
  
  check_grid(spatial_grid)
  
  matching_crs <- check_matching_crs(spatial_grid, 4326)
  
  if(ports){
    if(ports_data == "wpi"){
      if(!file.exists(file.path(tempdir(), "wpi_ports.csv"))){
        utils::download.file(url = "https://msi.nga.mil/api/publications/download?type=view&key=16920959/SFH00000/UpdatedPub150.csv", destfile = file.path(tempdir(), "wpi_ports.csv"), method = "curl", quiet = TRUE) 
      }
      dat <- utils::read.csv(file.path(tempdir(), "wpi_ports.csv"))[,c("Longitude", "Latitude")]  %>% 
        sf::st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)
      
      layer_name <- "dist_ports"
    } else if(ports_data == "gfw"){
    dat <- readRDS(system.file("extdata", "gfw_anchorages.rds", package = "oceandatr", mustWork = TRUE)) %>% 
      sf::st_as_sf(coords = c("lon", "lat"), crs = 4326)
    
    layer_name <- "dist_anchorages"
    }
  } else{
    if(!file.exists(file.path(tempdir(), "ne_10m_land.shp"))){
      #get high res land polygons from Natural Earth
      ne_data_filename <- "ne_land_data.zip"
      
      utils::download.file(url = "https://naturalearth.s3.amazonaws.com/10m_physical/ne_10m_land.zip", destfile = file.path(tempdir(), ne_data_filename), mode = "wb", quiet = TRUE)
      utils::unzip(file.path(tempdir(), ne_data_filename), exdir = tempdir())
    }
    
    dat <- sf::read_sf(file.path(tempdir(), "ne_10m_land.shp")) %>% 
      sf::st_geometry() %>% 
      sf::st_sf()
    
    layer_name <- "dist_shore"
  }
  
     if(check_raster(spatial_grid)){
       
       if(matching_crs){
         temp_ras <- spatial_grid %>% 
           terra::distance(terra::vect(dat)) %>% 
           terra::mask(spatial_grid) %>% 
           setNames(layer_name)
         
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
           sf::st_distance(dat) %>% 
           {do.call(pmin, as.data.frame(.))} 
         
         spatial_grid[!is.na(spatial_grid)] <- dist_vect
         
         spatial_grid <- setNames(spatial_grid, layer_name)
         
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
         sf::st_distance(dat) %>% 
         {do.call(pmin, as.data.frame(.))} %>% 
         cbind(temp_grid) %>% 
         dplyr::rename({{layer_name}} := 1) %>% 
         {if(matching_crs) . else sf::st_transform(., sf::st_crs(spatial_grid))} %>%
         {if(inverse) dplyr::mutate(., dist_shore = max(.data[[1]], na.rm = TRUE) - dist_shore - min(.data[[1]], na.rm = TRUE)) else .} %>% 
         {if(grid_has_extra_cols) cbind(., extra_cols) %>% dplyr::relocate(colnames(extra_cols), .before = 1) else .}
     }
}