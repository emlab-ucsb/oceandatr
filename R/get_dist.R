#' Get distance to port or shore for a spatial grid
#'
#' @description Calculates distance from shore, port or anchorage for each grid
#' cell in the provided spatial grid. Spatial grid can be `terra::rast()` or
#' `sf` format.
#'
#' @section Shore:
#'
#'   The Natural Earth high resolution land polygons are used as the shoreline
#'   and are downloaded from the Natural Earth website
#'   (https://www.naturalearthdata.com/downloads/10m-physical-vectors/), so an
#'   internet connection is required.
#'
#' @section Ports:
#'
#'   Port locations are downloaded directly from the World Port Index (Pub 150):
#'   https://msi.nga.mil/Publications/WPI.
#' 
#' @section Anchorages: 
#' 
#' The anchorages data is from Global Fishing Watch and identifies anchorages as
#' anywhere vessels with AIS remain stationary for 12 hours or more (see
#' https://globalfishingwatch.org/datasets-and-code-anchorages/). This results
#' in a very large number of points (~167,000). Calculating distance from all
#' these points to each grid cell is computationally expensive. Anchorages close
#' together have the same names, so to reduce the number of anchorages, they are
#' aggregated by iso3 code (country code) and label (name) and the mean
#' longitude and latitude coordinates obtained to get one anchorage point per
#' name in each country. This data can be used by specifying `dist_to =
#' "anchorages_grouped"`.
#'
#' To further reduce the number of points, anchorages within countries' land
#' boundaries, e.g. along rivers, can be removed. I do this by buffering the
#' Natural Earth land boundaries by 10km inland so as to avoid cutting off
#' coastal anchorages that fall within the land boundary, due to inaccuracies in
#' the Natural Earth land boundaries, e.g. for islands and other small scale
#' coastlines, and then masking points that fall within the resulting polygons.
#' This data can be used by specifying `dist_to = "anchorages_land_masked"`.
#'
#' The full anchorages dataset can be used by specifying `dist_to =
#' "anchorages_all"`, but this option may take a long time to calculate and/ or
#' cause your system to hang.
#' 
#' @inheritParams get_bathymetry
#' @param dist_to `character` which data to use to calculate distance to.
#'   Default is `"shore"` (Natural Earth land polygons); other possible values
#'   are `"ports"` (WPI Ports), `"anchorages_land_masked"`,
#'   `"anchorages_grouped"` and `"anchorages_all"` (GFW anchorages).
#' @param raw `logical` set to TRUE to retrieve the raw shore, port or anchorage
#'   data within the extent of the `spatial_grid`. Note that the closest shore,
#'   port or anchorage may be outside the extent.
#' @param inverse `logical` set to `TRUE` to get the inverse of distance, i.e.
#'   highest values become lowest and vice versa. Can be useful if the result is
#'   to be used as a proxy for fishing activity, where the closer a grid cell is
#'   to the port or shore, the more fishing activity there might be. Default is
#'   `FALSE`.
#'
#' @return a `terra::rast` or `sf` object (same type as `spatial_grid` input)
#'   with distance to shore for each grid cell.
#' @export
#'
#' @examples
#' # Get some EEZ data first 
#' fiji_eez <- get_boundary(name = "Fiji")
#' # Get a raster spatial grid for Fiji
#' fiji_grid <- get_grid(boundary = fiji_eez, crs = 32760, resolution = 20000)
#' #get distance from shore for each cell in the raster
#' dist_from_shore_rast <- get_dist(fiji_grid)
#' terra::plot(dist_from_shore_rast)
#' 
#' #get distance to ports
#' dist_ports <- get_dist(fiji_grid, dist_to = "ports")
#' terra::plot(dist_ports)
#'
#' #get distance to anchorages, as defined by Global Fishing Watch data
#' dist_anchorages <- get_dist(fiji_grid, dist_to = "anchorages_land_masked")
#' terra::plot(dist_anchorages)
get_dist <- function(spatial_grid, dist_to = "shore", raw = FALSE, inverse = FALSE, name = NULL, antimeridian = NULL){

  check_grid(spatial_grid)
  
  matching_crs <- check_matching_crs(spatial_grid, 4326)
  
  if(dist_to == "shore"){
    if(!file.exists(file.path(tempdir(), "ne_10m_land.shp"))){
      #get high res land polygons from Natural Earth
      ne_data_filename <- "ne_land_data.zip"
      
      utils::download.file(url = "https://naturalearth.s3.amazonaws.com/10m_physical/ne_10m_land.zip", destfile = file.path(tempdir(), ne_data_filename), mode = "wb", quiet = TRUE)
      utils::unzip(file.path(tempdir(), ne_data_filename), exdir = tempdir())
    }
    
    dat <- sf::read_sf(file.path(tempdir(), "ne_10m_land.shp")) %>% 
      sf::st_geometry() %>% 
      sf::st_sf()
    
  }else if(dist_to == "ports"){
    if(!file.exists(file.path(tempdir(), "wpi_ports.csv"))){
      utils::download.file(url = "https://msi.nga.mil/api/publications/download?type=view&key=16920959/SFH00000/UpdatedPub150.csv", destfile = file.path(tempdir(), "wpi_ports.csv"), method = "curl", quiet = TRUE) 
    }
    dat <- utils::read.csv(file.path(tempdir(), "wpi_ports.csv"))[,c("Longitude", "Latitude")]  %>% 
      sf::st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)

  }else if(dist_to == "anchorages_all"){
    message("Attempting to calculate distances using the original GFW anchorages dataset will take a long time and may cause your system to hang.")
    dat <- readRDS(system.file("extdata", "anchorages_all.rds", package = "oceandatr", mustWork = TRUE)) %>% 
      sf::st_as_sf(coords = c("x", "y"), crs = 4326)
    
  }else if(dist_to == "anchorages_grouped" | dist_to == "anchorages_land_masked"){
    dat <- readRDS(system.file("extdata", "anchorages_grouped.rds", package = "oceandatr", mustWork = TRUE))
    if(dist_to == "anchorages_grouped"){
      dat <- dat[,c("x", "y")] %>% 
        sf::st_as_sf(coords = c("x", "y"), crs = 4326)
    }else{
      dat <- dat %>% 
        subset(on_land == FALSE) %>% 
        {.[,c("x", "y")]} %>% 
        sf::st_as_sf(coords = c("x", "y"), crs = 4326)
    }
    } else{
      stop('Data for calculating distance from must be one of: "shore", "ports", "anchorages_all", "anchorages_grouped", "anchorages_land_masked"')
    }

  layer_name <- if(is.null(name)) paste0("dist_", dist_to) else name
  
  if(raw == TRUE){
    cropping_poly <- if(spatialgridr:::check_raster(spatial_grid)) terra::ext(spatial_grid) %>% terra::vect(terra::crs(spatial_grid)) %>% terra::densify(1e4) %>% sf::st_as_sf() else sf::st_bbox(spatial_grid) %>% sf::st_as_sfc(crs = sf::st_crs(spatial_grid)) %>% sf::st_sf() %>% terra::vect() %>% terra::densify(1e4) %>% sf::st_as_sf()
    
    return(get_data_in_grid(spatial_grid = cropping_poly, dat = dat, raw = TRUE, name = dist_to, antimeridian = antimeridian))
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
         
       temp_pts <- spatial_grid %>% 
         sf::st_centroid() %>%
         {if(matching_crs) . else sf::st_transform(., 4326)}
       
       temp_pts %>% 
         sf::st_distance(dat) %>% 
         {do.call(pmin, as.data.frame(.))} %>% 
         as.numeric() %>% 
         cbind(temp_pts) %>% 
         dplyr::rename({{layer_name}} := 1) %>% 
         {if(matching_crs) . else sf::st_transform(., sf::st_crs(spatial_grid))} %>%
         sf::st_drop_geometry() %>% 
         cbind(spatial_grid, .) %>% 
         {if(inverse) dplyr::mutate(., dist_shore = max(.data[[1]], na.rm = TRUE) - .data[["dist_shore"]] - min(.data[[1]], na.rm = TRUE)) else .}
     }
}