#' Get a set of feature data for a spatial grid
#'
#' @description This is a wrapper of `get_bathymetry()`,
#'   `get_seamounts_buffered()`, `get_knolls()`, `get_geomorphology()`,
#'   `get_coral_habitat()`, and `get_enviro_zones()`. See the individual
#'   functions for details.
#'
#' @inheritParams get_bathymetry
#' @param raw `logical` if TRUE, `spatial_grid` should be an `sf` polygon, and
#'   the raw feature data in that polygon(s) will be returned. Note that this
#'   will be a list object, since raster and `sf` data may be returned.
#' @param features a vector of feature names, can include: "bathymetry",
#'   "seamounts", "knolls", "geomorphology", "corals", "enviro_zones"
#' @param bathy_resolution `numeric`; the resolution (in minutes) of data to
#'   pull from the ETOPO 2022 Global Relief model. Values less than 1 can only
#'   be 0.5 (30 arc seconds) and 0.25 (15 arc seconds)
#' @param seamount_buffer `numeric`; the distance from the seamount peak to
#'   include in the output. Distance should be in the same units as the
#'   area_polygon or spatial_grid provided, use e.g. `sf::st_crs(spatial_grid,
#'   parameters = TRUE)$units_gdal` to check what units your planning grid or
#'   area polygon is in (works for raster as well as sf objects)
#' @param antipatharia_threshold `numeric` between 0 and 100; the threshold
#'   value for habitat suitability for antipatharia corals to be considered
#'   present (default is 22, as defined in Yesson et al., 2017)
#' @param octocoral_threshold `numeric` between 0 and 7; the threshold value for
#'   how many species (of 7) should be predicted present in an area for
#'   octocorals to be considered present (default is 2)
#' @param enviro_clusters `numeric`; the number of environmental zones to
#'   cluster the data into - to be used when a clustering algorithm is not
#'   necessary (default is NULL)
#' @param max_enviro_clusters `numeric`; the maximum number of environmental
#'   zones to try when using the clustering algorithm (default is 8)
#'
#' @return If `raw = TRUE`, a list of feature data is returned (mixed raster and
#'   `sf` objects). If a `spatial_grid` is supplied, a multi-layer raster or
#'   `sf` object of gridded data is returned, depending on the `spatial_grid`
#'   format.
#' @export
#' 
#' @examples
#' # Grab EEZ data first 
#' bermuda_eez <- get_boundary(name = "Bermuda")
#' # Get raw data for Bermuda's EEZ
#' raw_data <- get_features(spatial_grid = bermuda_eez, raw = TRUE)
#' # Get feature data in a spatial grid
#' bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 20000)
#' #set seed for reproducibility in the get_enviro_zones() function
#' set.seed(500)
#' features_gridded <- get_features(spatial_grid = bermuda_grid)
#' terra::plot(features_gridded)

get_features <- function(spatial_grid = NULL, raw = FALSE, features = c("bathymetry", "seamounts", "knolls", "geomorphology", "corals", "enviro_zones"), bathy_resolution = 1, seamount_buffer = 30000, antipatharia_threshold = 22, octocoral_threshold = 2, enviro_clusters = NULL, max_enviro_clusters = 6, antimeridian = NULL){
  
  #set extra columns aside - only need this is it a spatial grid, so added
  #nrow() check to remove the need for this step if only raw data is required
  #and using an sf polygon with one row
  if(check_sf(spatial_grid) & nrow(spatial_grid) > 1){
    grid_has_extra_cols <- if(ncol(spatial_grid)>1) TRUE else FALSE
    
    if(grid_has_extra_cols) {
      extra_cols <- sf::st_drop_geometry(spatial_grid)
      spatial_grid <- spatial_grid %>% 
        sf::st_geometry() %>% 
        sf::st_sf()
    }
  }
  
  if("bathymetry" %in% features) { 
    message("Getting depth zones...")
    bathymetry <- get_bathymetry(spatial_grid = spatial_grid, raw = raw, classify_bathymetry = ifelse(raw, FALSE, TRUE) , resolution = bathy_resolution, antimeridian = antimeridian)
  }
  
  if("seamounts" %in% features) { 
    message("Getting seamount data...")
    seamounts <- get_seamounts(spatial_grid = spatial_grid, raw = raw, buffer = seamount_buffer, antimeridian = antimeridian)
  }
  
  if("knolls" %in% features) { 
    message("Getting knoll data...")
    knolls <- get_knolls(spatial_grid = spatial_grid, raw = raw, antimeridian = antimeridian)
  }
  
  if("geomorphology" %in% features) { 
    message("Getting geomorphology data...")
    suppressMessages({
      geomorphology <- get_geomorphology(spatial_grid = spatial_grid, raw = raw, antimeridian = antimeridian)
    })
  }
  
  if("corals" %in% features) { 
    message("Getting coral data...")
    suppressMessages({
      corals <- get_coral_habitat(spatial_grid = spatial_grid, raw = raw, antipatharia_threshold = antipatharia_threshold, octocoral_threshold = octocoral_threshold, antimeridian = antimeridian)
    })
  }
  
  if("enviro_zones" %in% features) { 
    message("Getting environmental zones data... This could take several minutes")
    suppressMessages({
      enviro_zones <- get_enviro_zones(spatial_grid = spatial_grid, raw = raw, enviro_zones = !raw, show_plots = FALSE, num_clusters = enviro_clusters, max_num_clusters = max_enviro_clusters, antimeridian = antimeridian)
    })
  }
  
  if(raw){
    mget(features)
  } else if(check_raster(spatial_grid)) { 
    ras_names <- sapply(mget(features), names) %>% 
      unlist(use.names = FALSE)
    
    mget(features) %>% 
      terra::rast() %>% 
      stats::setNames(ras_names)
  } else{ 
    sf_features <- mget(features)
    
    lapply(sf_features[1:(length(sf_features)-1)], function(x) sf::st_drop_geometry(x)) %>% 
      do.call(dplyr::bind_cols, .) %>% 
      cbind(sf_features[[length(sf_features)]]) %>% 
      sf::st_sf() %>% 
      {if(grid_has_extra_cols) dplyr::bind_cols(., extra_cols) %>% dplyr::relocate(colnames(extra_cols), .before = 1) else .}
  }
} 
