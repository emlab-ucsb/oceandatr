#' Get bathymetry data
#'
#' @description Get bathymetry data for an area from the ETOPO 2022 Global
#'   Relief model. If data are already downloaded locally, the user can specify
#'   the file path of the dataset. Data can be classified into depth zones by
#'   setting `classify_bathymetry = TRUE`
#'
#' @details Extracts bathymetry data for an `area_polygon`, or if a
#'   `spatial_grid` is supplied, gridded bathymetry is returned.
#'
#'   Data can be classified into depth zones by setting `classify_bathymetry =
#'   TRUE`. Depths are classified as follows:
#' \itemize{
#' \item Epipelagic Zone: 0-200 m depth
#' \item Mesopelagic Zone: 200-1000 m depth
#' \item Bathypelagic Zone: 1000-4000 m depth
#' \item Abyssopelagic Zone: 4000-6000 m depth
#' \item Hadopelagic Zone: 6000+ m depth
#' }
#'
#'   If the user has downloaded bathymetry data for the area of interest, for
#'   example from GEBCO (https://www.gebco.net), they can pass the file path to
#'   this function in `bathymetry_data_filepath`. If no file path is provided,
#'   the function will extract bathymetry data for the area from the ETOPO 2022
#'   Global Relief model served by NOAA
#'   (https://www.ncei.noaa.gov/products/etopo-global-relief-model).
#'
#' @param spatial_grid `sf` or `terra::rast()` grid, e.g. created using
#'   `get_grid()`. Alternatively, if raw data is required, an `sf` polygon can
#'   be provided, e.g. created using `get_boundary()`, and set `raw = TRUE`.
#' @param raw `logical` if TRUE, `spatial_grid` should be an `sf` polygon, and
#'   the raw data in that polygon(s) will be returned
#' @param classify_bathymetry `logical`; whether to classify the bathymetry into
#'   depth zones. Original bathymetry data can be classified if `raw = TRUE` and
#'   `spatial_grid` is an `sf` polygon.
#' @param above_sea_level_isNA `logical`; whether to set bathymetry (elevation)
#'   data values that are above sea level (i.e. greater than or equal to zero)
#'   to `NA` (`TRUE`) or zero (`FALSE`)
#' @param name `string`; name of raster or column in sf object that is returned
#' @param bathymetry_data_filepath `string`; the file path (including file name
#'   and extension) where bathymetry raster data are saved locally
#' @param resolution `numeric`; the resolution (in minutes) of data to pull from
#'   the ETOPO 2022 Global Relief model. Values less than 1 can only be 0.5 (30
#'   arc seconds) and 0.25 (15 arc seconds)
#' @param keep `logical`; whether to save the bathymetry data locally
#' @param path `string`; the file path where you would like to save bathymetry
#'   data
#' @param download_timeout `numeric`; the maximum number of seconds a query to
#'   the NOAA website is allowed to run
#' @param antimeridian Does `spatial_grid` span the antimeridian? If so, this
#'   should be set to `TRUE`, otherwise set to `FALSE`. If set to `NULL`
#'   (default) the function will try to check if `spatial_grid` spans the
#'   antimeridian and set this appropriately.
#'
#' @return If `classify_bathymetry = FALSE`, bathymetry data in the
#'   `spatial_grid` supplied, or in the original raster file resolution if `raw
#'   = TRUE`. If `classify_bathymetry = TRUE` a multi-layer raster or an `sf`
#'   object with one zone in each column is returned, depending on the
#'   `spatial_grid` format. If `classify_bathymetry = TRUE` and `raw = TRUE` (in
#'   which case `spatial_grid` should be an `sf` polygon), the raw raster
#'   bathymetry data is classified into depth zones.
#' @export
#'
#' @examples
#' # Get EEZ data first
#' bermuda_eez <- get_boundary(name = "Bermuda")
#' # Get raw bathymetry data, not classified into depth zones
#' bathymetry <- get_bathymetry(spatial_grid = bermuda_eez, raw = TRUE, classify_bathymetry = FALSE)
#' terra::plot(bathymetry)
#' # Get depth zones in spatial_grid
#' bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 20000)
#' depth_zones <- get_bathymetry(spatial_grid = bermuda_grid)
#' terra::plot(depth_zones)
#' #It is also possible to get the raw bathymetry data in gridded format by setting raw = FALSE and classify_bathymetry = FALSE
#' bermuda_grid_sf <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 20000, output = "sf_hex")
#' gridded_bathymetry <- get_bathymetry(spatial_grid = bermuda_grid_sf, classify_bathymetry = FALSE)
#' plot(gridded_bathymetry)
get_bathymetry <- function(spatial_grid = NULL, raw = FALSE, classify_bathymetry = TRUE, above_sea_level_isNA = FALSE, name = "bathymetry", bathymetry_data_filepath = NULL, resolution = 1, keep = FALSE, path = NULL, download_timeout = 300, antimeridian = NULL){

  check_grid(spatial_grid)
  
  meth <- if(check_sf(spatial_grid)) 'mean' else 'average'
  
  area_polygon_for_cropping <- polygon_in_4326(spatial_grid)
  
  antimeridian <- area_polygon_for_cropping %>%
    terra::vect() %>% 
    terra::densify(interval = 1e4) %>% 
    sf::st_as_sf() %>% 
    check_antimeridian(sf::st_crs(4326))
  
  if(is.null(bathymetry_data_filepath)){
    bathymetry <- get_etopo_bathymetry(area_polygon_for_cropping, resolution = resolution, keep = keep, path = path, download_timeout = download_timeout) %>% 
      get_data_in_grid(spatial_grid = spatial_grid, dat = ., raw = raw, meth = meth, name = name, antimeridian = antimeridian)
  } else{
    bathymetry <- get_data_in_grid(spatial_grid = spatial_grid, dat = bathymetry_data_filepath, raw = raw, meth = meth, name = name, antimeridian = antimeridian) 
    }

  if(classify_bathymetry){
    
    depth_zones <- c("hadopelagic", "abyssopelagic", "bathypelagic", "mesopelagic", "epipelagic" )
    
    bathymetry_cuts <- c(-12000, -6000, -4000, -1000, -200, 10)
  
    
    reclass_var <- ifelse(above_sea_level_isNA, NA, 0)
    
    if(check_sf(bathymetry)){
      grid_has_extra_cols <- if(ncol(spatial_grid)>1) TRUE else FALSE
      
      if(grid_has_extra_cols) extra_cols <- sf::st_drop_geometry(spatial_grid)

      bathymetry %>% 
        dplyr::select(name) %>% 
        dplyr::mutate(bathymetry = dplyr::case_when(bathymetry >=0 ~ reclass_var,
                                                    .default = as.numeric(bathymetry))) %>%
        classify_layers(dat_breaks = bathymetry_cuts, classification_names = depth_zones) %>%
        dplyr::select((ncol(.)-1):1) %>% #reorder shallowest to deepest depth zones
        {if(grid_has_extra_cols) cbind(., extra_cols) %>% dplyr::relocate(colnames(extra_cols), .before = 1) else .}

    }else{
      bathymetry %>%
        terra::classify(matrix(c(0, 1e4, reclass_var), ncol = 3), include.lowest = TRUE) %>%
        classify_layers(dat_breaks = bathymetry_cuts, classification_names = depth_zones) %>% 
        terra::subset(terra::nlyr(.):1) #reorder shallowest to deepest depth zones
    }
    
  }else{
    return(bathymetry)
  }
}
#This function extracts bathymetry data for the area of interest from the ETOPO 2022 Global Relief model, using a script similar to that from `marmap::getNOAA.bathy()`. This is a helper function for get_bathymetry()

get_etopo_bathymetry <- function(aoi, resolution, keep, path, download_timeout){
  b_box <- sf::st_bbox(aoi)
  lon1 = as.numeric(b_box$xmin)
  lon2 = as.numeric(b_box$xmax)
  lat1 = as.numeric(b_box$ymin)
  lat2 = as.numeric(b_box$ymax)
  
  # Expand range a little bit
  lon1 = max(c(-180, lon1-0.5))
  lon2 = min(c(180, lon2+0.5))
  lat1 = max(c(-90, lat1-0.5))
  lat2 = min(c(90, lat2+0.5))
  
  # Quick checks of specified lat/lons and resolution 
  if (lon1 == lon2) 
    stop("The longitudinal range defined by lon1 and lon2 is incorrect")
  if (lat1 == lat2) 
    stop("The latitudinal range defined by lat1 and lat2 is incorrect")
  if (lat1 > 90 | lat1 < -90 | lat2 > 90 | lat2 < -90) 
    stop("Latitudes should have values between -90 and +90")
  if (lon1 < -180 | lon1 > 180 | lon2 < -180 | lon2 > 180) 
    stop("Longitudes should have values between -180 and +180")
  if (resolution < 0) 
    stop("The resolution must be greater than 0")
  
  # Make it so that the antimeridian is generated based on the data itself
  # (make it easier for the user)
  if(lon1 == -180 & lon2 == 180) { antimeridian = TRUE } else { antimeridian = FALSE}
  
  # Tweak bounds if antimeridian 
  if(antimeridian) { 
    suppressMessages({
      aoi_left <- sf::st_crop(sf::st_geometry(aoi), xmin = 0, xmax = 180, ymin = -90, ymax = 90)
      aoi_right <- sf::st_crop(sf::st_geometry(aoi), xmin = -180, xmax = 0, ymin = -90, ymax = 90)
    })
    lon1_left <- max(c(-180, as.numeric(sf::st_bbox(aoi_left)$xmin-0.5)))
    lon2_left <- min(c(180, as.numeric(sf::st_bbox(aoi_left)$xmax)+0.5))
    lon1_right <- max(c(-180, as.numeric(sf::st_bbox(aoi_right)$xmin)-0.5))
    lon2_right <- min(c(180, as.numeric(sf::st_bbox(aoi_right)$xmax)+0.5)) 
  }
  
  #here on copied directly from marmap package
  
  if (resolution < 0.5) {
    resolution <- 0.25
  } else {
    if (resolution < 1) {
      resolution <- 0.5
    }
  }
  if (resolution == 0.25) database <- "27ETOPO_2022_v1_15s_bed_elev"
  if (resolution == 0.50) database <- "27ETOPO_2022_v1_30s_bed"
  if (resolution  > 0.50) database <- "27ETOPO_2022_v1_60s_bed"
  
  if (is.null(path)) 
    path <- "."
  x1 = x2 = y1 = y2 = NULL
  
  if (lon1 < lon2) {
    x1 <- lon1
    x2 <- lon2
  } else {
    x2 <- lon1
    x1 <- lon2
  }
  if (lat1 < lat2) {
    y1 <- lat1
    y2 <- lat2
  } else {
    y2 <- lat1
    y1 <- lat2
  }
  if (antimeridian) {
    # if (x1 == -180 & x2 == 180) {
    #   x1 <- 0
    #   x2 <- 0
    # }
    l1 <- lon1_left
    l2 <- lon2_left
    l3 <- lon1_right
    l4 <- lon2_right
    ncell.lon.left <- (l2 - l1) * 60/resolution
    ncell.lon.right <- (l4 - l3) * 60/resolution
    ncell.lat <- (y2 - y1) * 60/resolution
    if ((ncell.lon.left + ncell.lon.right) < 2 & ncell.lat < 
        2) 
      stop("It's impossible to fetch an area with less than one cell. Either increase the longitudinal and longitudinal ranges or the resolution (i.e. use a smaller res value)")
    if ((ncell.lon.left + ncell.lon.right) < 2) 
      stop("It's impossible to fetch an area with less than one cell. Either increase the longitudinal range or the resolution (i.e. use a smaller resolution value)")
    if (ncell.lat < 2) 
      stop("It's impossible to fetch an area with less than one cell. Either increase the latitudinal range or the resolution (i.e. use a smaller resolution value)")
  } else {
    ncell.lon <- (x2 - x1) * 60/resolution
    ncell.lat <- (y2 - y1) * 60/resolution
    if (ncell.lon < 2 & ncell.lat < 2) 
      stop("It's impossible to fetch an area with less than one cell. Either increase the longitudinal and longitudinal ranges or the resolution (i.e. use a smaller res value)")
    if (ncell.lon < 2) 
      stop("It's impossible to fetch an area with less than one cell. Either increase the longitudinal range or the resolution (i.e. use a smaller resolution value)")
    if (ncell.lat < 2) 
      stop("It's impossible to fetch an area with less than one cell. Either increase the latitudinal range or the resolution (i.e. use a smaller resolution value)")
  }
  fetch <- function(x1, y1, x2, y2, ncell.lon, ncell.lat) {
    ncell.lon <- floor(ncell.lon)
    ncell.lat <- floor(ncell.lat)
    x1 <- round(x1, 1)
    x2 <- round(x2, 1)
    y1 <- round(y1, 1)
    y2 <- round(y2, 1)
    
    #increase timeout for download which is 60s by default; too short time to download largers files
    options(timeout = max(download_timeout, getOption("timeout")))
    
    # message(paste0("x1 = ", x1, " y1 = ", y1, " x2 = ", x2, " y2 = ", y2, "
    # ncell.lon = ", ncell.lon, " ncell.lat = ", ncell.lat, "\n"))
    WEB.REQUEST <- paste0("https://gis.ngdc.noaa.gov/arcgis/rest/services/DEM_mosaics/DEM_all/ImageServer/exportImage?bbox=", x1, ",", y1, ",", x2, ",", y2, "&bboxSR=4326&size=", ncell.lon, ",", ncell.lat,"&imageSR=4326&format=tiff&pixelType=F32&interpolation=+RSP_NearestNeighbor&compression=LZ77&renderingRule={%22rasterFunction%22:%22none%22}&mosaicRule={%22where%22:%22Name=%", database, "%27%22}&f=image")
    filename <- gsub("[.]", "", paste(x1, x2, y1, y2, sep = "_"))
    utils::download.file(url = WEB.REQUEST, destfile = paste0(filename, "_tmp.tif"), mode = "wb", quiet = TRUE)
    dat <- suppressWarnings(try(terra::rast(paste0(filename, "_tmp.tif")), silent = TRUE))
    return(dat)
  }
  
  # Naming the file 
  if (antimeridian) {
    FILE <- paste0("marmap_coord_", x1, ";", y1, ";", x2, 
                   ";", y2, "_res_", resolution, "_anti", ".grd")
  } else {
    FILE <- paste0("marmap_coord_", x1, ";", y1, ";", x2, 
                   ";", y2, "_res_", resolution, ".grd")
  }
  if (FILE %in% list.files(path = path)) {
    message("File already exists ; loading \'", FILE, "\'", 
            sep = "")
    existing.bathy <- terra::rast(file.path(path, FILE))
    return(existing.bathy)
  } else { # otherwise, fetch it from the NOAA server
    if (antimeridian) {
      # message("Querying NOAA database ...")
      message("This may take seconds to minutes, depending on grid size\n")
      left <- fetch(l1, y1, l2, y2, ncell.lon.left, ncell.lat)
      right <- fetch(l3, y1, l4, y2, ncell.lon.right, ncell.lat)
      if (methods::is(left, "try-error") | methods::is(right, "try-error")) {
        stop("The NOAA server cannot be reached\n")
      } else {
        # message("Got data crossing antimeridian")
        # resample so both are the same exact res (they're a little off)
        left <- terra::resample(left, 
                                terra::rast(ymin = y1, ymax = y2, 
                                            xmin = lon1_left, xmax = lon2_left, 
                                            resolution = terra::res(right)))
        bath <- terra::merge(left, right) %>%
          stats::setNames("bathymetry")
        # left <- marmap::as.bathy(raster::raster(left))
        # left <- left[-nrow(left), ]
        # right <- marmap::as.bathy(raster::raster(right))
        # rownames(right) <- as.numeric(rownames(right)) +
        #  360
        # bath2 <- rbind(left, right)
        # class(bath2) <- "bathy"
        # bath <- marmap::as.xyz(bath2)
        
      }
    } else {
      # message("Querying NOAA database ...")
      message("This may take seconds to minutes, depending on grid size")
      bath <- fetch(x1, y1, x2, y2, ncell.lon, ncell.lat) %>% 
        stats::setNames("bathymetry")
      
      if (methods::is(bath, "try-error")) {
        stop("The NOAA server cannot be reached\n")
      } else{
        "Got data"
      }
    }
    
    if(!terra::inMemory(bath)){
      terra::set.values(bath)
    }
    
    if (keep) {
      terra::writeRaster(bath, file = file.path(path, FILE), overwrite =FALSE)
    }
    #clean up the temp file
    file.remove(list.files(pattern = "tmp.tif"))
    return(bath)
  }
  
}
