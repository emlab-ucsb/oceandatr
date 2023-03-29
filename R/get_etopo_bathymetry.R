#' Get bathymetry data for the area of interest - helper function to `get_bathymetry()`
#'
#' @description This function extracts bathymetry data for the area of interest from the ETOPO 2022 Global Relief model, using a script similar to that from `marmap::getNOAA.bathy()`
#' 
#' @param aoi an sf polygon or multipolygon object of the area of interest (e.g., a country's EEZ)
#' @param resolution numeric; the resolution (in decimal degrees) of data to pull from the ETOPO 2022 Global Relief model
#' @param keep logical; whether to save the bathymetry data locally
#' @param path string; the file path where you would like to save bathymetry data
#' @param download_timeout numeric; the maximum number of seconds a query is allowed to run
#'
#' @return A raster of bathymetry for the area of interest
#'
#' @keywords internal

get_etopo_bathymetry <- function(aoi, resolution, keep, path, download_timeout){

  lon1 = as.numeric(sf::st_bbox(aoi)$xmin)
  lon2 = as.numeric(sf::st_bbox(aoi)$xmax)
  lat1 = as.numeric(sf::st_bbox(aoi)$ymin)
  lat2 = as.numeric(sf::st_bbox(aoi)$ymax)
  
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
  if(lon1 == -180 & lon2 == 180) { antimeridian = TRUE }
  
  # Tweak bounds if antimeridian 
  if(antimeridian) { 
    aoi_left <- sf::st_crop(aoi, xmin = 0, xmax = 180, ymin = -90, ymax = 90)
    aoi_right <- sf::st_crop(aoi, xmin = -180, xmax = 0, ymin = -90, ymax = 90)
    lon1_left <- as.numeric(sf::st_bbox(aoi_left)$xmin)
    lon2_left <- as.numeric(sf::st_bbox(aoi_left)$xmax)
    lon1_right <- as.numeric(sf::st_bbox(aoi_right)$xmin)
    lon2_right <- as.numeric(sf::st_bbox(aoi_right)$xmax) 
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
    
    message(paste0("x1 = ", x1, " y1 = ", y1, " x2 = ", x2, " y2 = ", y2, " ncell.lon = ", ncell.lon, " ncell.lat = ", ncell.lat, "\n"))
    WEB.REQUEST <- paste0("https://gis.ngdc.noaa.gov/arcgis/rest/services/DEM_mosaics/DEM_all/ImageServer/exportImage?bbox=", x1, ",", y1, ",", x2, ",", y2, "&bboxSR=4326&size=", ncell.lon, ",", ncell.lat,"&imageSR=4326&format=tiff&pixelType=F32&interpolation=+RSP_NearestNeighbor&compression=LZ77&renderingRule={%22rasterFunction%22:%22none%22}&mosaicRule={%22where%22:%22Name=%", database, "%27%22}&f=image")
    filename <- gsub("[.]", "", paste(x1, x2, y1, y2, sep = "_"))
    download.file(url = WEB.REQUEST, destfile = paste0(filename, "_tmp.tif"), mode = "wb")
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
      message("Querying NOAA database ...")
      message("This may take seconds to minutes, depending on grid size\n")
      left <- fetch(l1, y1, l2, y2, ncell.lon.left, ncell.lat)
      right <- fetch(l3, y1, l4, y2, ncell.lon.right, ncell.lat)
      if (is(left, "try-error") | is(right, "try-error")) {
        stop("The NOAA server cannot be reached\n")
      } else {
        message("Got data crossing antimeridian")
        # resample so both are the same exact res (they're a little off)
        left <- terra::resample(left, 
                                terra::rast(ymin = y1, ymax = y2, 
                                            xmin = lon1_left, xmax = lon2_left, 
                                            resolution = terra::res(right)))
        bath <- terra::merge(left, right) %>%
          setNames("bathymetry")
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
      message("Querying NOAA database ...")
      message("This may take seconds to minutes, depending on grid size")
      bath <- fetch(x1, y1, x2, y2, ncell.lon, ncell.lat) %>% 
        setNames("bathymetry")
      
      if (is(bath, "try-error")) {
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