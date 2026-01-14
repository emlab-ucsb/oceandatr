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
#' @param path `string`; the folder path where you would like to save the bathymetry
#'   data. Defaults to `tempdir()`
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
get_bathymetry <- function(spatial_grid = NULL, raw = FALSE, classify_bathymetry = TRUE, above_sea_level_isNA = FALSE, name = "bathymetry", bathymetry_data_filepath = NULL, resolution = 1, path = NULL, download_timeout = 300, antimeridian = NULL){

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
#This function extracts relief data for the area of interest from the GEBCO 2025 grid
#This is a helper function for get_bathymetry()

get_gebco_bathymetry <- function(area_polygon_for_cropping, resolution, keep, path, download_timeout){
  #Get spatial indices of desired extent
  
  spat_ext <- terra::ext(area_polygon_for_cropping)
  
  min_x <- as.numeric(spat_ext[1])
  max_x <- as.numeric(spat_ext[2])
  min_y <- as.numeric(spat_ext[3])
  max_y <- as.numeric(spat_ext[4])
  
  #Check for data that might extend over the antimeridian
  if(is.null(antimeridian)) {
    if(min_x == -180 & max_x == 180) antimeridian = TRUE  else antimeridian = FALSE
  }
  
  # Get two left and right sides of the antimeridian x extents if antimeridian
  if(antimeridian) { 
    suppressMessages({
      aoi_left <- sf::st_crop(sf::st_geometry(area_polygon_for_cropping), xmin = 0, xmax = 180, ymin = -90, ymax = 90)
      aoi_right <- sf::st_crop(sf::st_geometry(area_polygon_for_cropping), xmin = -180, xmax = 0, ymin = -90, ymax = 90)
    })
    min_x_left <- max(c(0, as.numeric(sf::st_bbox(aoi_left)$xmin)))
    max_x_left <- min(c(180, as.numeric(sf::st_bbox(aoi_left)$xmax)))
    min_x_right <- max(c(-180, as.numeric(sf::st_bbox(aoi_right)$xmin)))
    max_x_right <- min(c(0, as.numeric(sf::st_bbox(aoi_right)$xmax))) 
  }
  
  file_name <- paste0("bathy_", min_x, "_", max_x, "_", min_y, "_", max_y, ".tif")
  
  path <- if(is.null(path)) tempdir() else path
  
  if(file_name %in% list.files(path = path)) {
    message("Bathymetry data already downloaded, using cached version", 
            sep = "")
    return(rast(file.path(path, file_name)))  
  }
  
  gebco_data_fetch <- function(min_x, max_x){
    #Add or subtract 30 arc seconds (2 steps in the index) to each coordinate to ensure we get the full extent
    
    index_min_x <- which.min(abs(nc_lon_vals - min_x)) -2
    index_max_x <- which.min(abs(nc_lon_vals - max_x)) +2
    index_min_y <- which.min(abs(nc_lat_vals - min_y)) -2
    index_max_y <- which.min(abs(nc_lat_vals - max_y)) +2
    
    #make sure we don't go out of the index range (due to the +/-2 adjustment)
    if(index_min_x < 1) index_min_x <- 1
    if(index_max_x > length(nc_lon_vals)) index_max_x <- length(nc_lon_vals)
    if(index_min_y < 1) index_min_y <- 1
    if(index_max_y > length(nc_lat_vals)) index_max_y <- length(nc_lat_vals)
    
    x_count <- abs(index_max_x - index_min_x)
    
    y_count <- abs(index_max_y - index_min_y)
    
    bathy_arr <- ncdf4::ncvar_get(nc, "elevation", start = c(index_min_x, index_min_y), count = c(x_count, y_count))
    
   terra::rast(t(bathy_arr), 
               crs = ncdf4::ncatt_get(nc, "crs")$epsg_code,
               ext = c(nc_lon_vals[index_min_x], nc_lon_vals[index_max_x], nc_lat_vals[index_min_y], nc_lat_vals[index_max_y])) |> 
     terra::flip()
  }
  #GEBCO data url
  url <- "https://dap.ceda.ac.uk/thredds/dodsC/bodc/gebco/global/gebco_2025/sub_ice_topography_bathymetry/netcdf/gebco_2025_sub_ice.nc"
  
  #open the connection to the remote netcdf file
  nc <- ncdf4::nc_open(url)
  
  nc_lat_vals <- nc$dim$lat$vals
  nc_lon_vals <- nc$dim$lon$vals
  
  if(antimeridian){
    left <- gebco_data_fetch(min_x_left, max_x_left)
    right <- gebco_data_fetch(min_x_right, max_x_right)
    
    bath <- terra::merge(left, right) |> 
      stats::setNames("bathymetry")
  } else{
    bath <- gebco_data_fetch(min_x, max_x) |> 
      stats::setNames("bathymetry")
  }
  
  if(!terra::inMemory(bath)) terra::set.values(bath)
  
  terra::writeRaster(bath, filename = file.path(path, file_name))
  
  ncdf4::nc_close(nc) 
  
  return(bath)
  
}
