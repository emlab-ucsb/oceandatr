#' Get bathymetry data
#'
#' @description Get bathymetry data from the GEBCO 2026 global terrain model. If data are already downloaded locally, the user can specify the file path of the dataset. Data can be classified into depth zones by setting `classify_bathymetry = TRUE`
#'
#' @details Extracts bathymetry data for an `area_polygon`, or if a
#'   `spatial_grid` is supplied, gridded bathymetry is returned.
#'
#'   Data can be classified into depth zones by setting `classify_bathymetry =
#'   TRUE`. Depths are classified as follows:
#' \itemize{
#' \item Continental Shelf: 0 - 200 m depth
#' \item Upper Bathyal: 200 - 800 m depth
#' \item Lower Bathyal: 800 - 3500 m depth
#' \item Abyssal: 3500 - 6500 m depth
#' \item Hadal: 6500+ m depth
#' }
#'
#'   If the user has downloaded bathymetry data for the area of interest, for
#'   example from GEBCO (https://www.gebco.net), they can pass the file path to
#'   this function in `bathymetry_data_filepath`. If no file path is provided,
#'   the function will extract bathymetry data for the area from the GEBCO 2026
#'   global terrain model (sub-ice) from  the Natural Environment Research Council's (NERC) Centre for Environmental Data Analysis (CEDA)
#'   (https://data.ceda.ac.uk/bodc/gebco/global/gebco_2026). 
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
#' @param bathymetry_data_filepath `string`; the file path (including file name
#'   and extension) where bathymetry raster data are saved locally
#' @param name `string`; name of raster or column in sf object that is returned
#' @param path `string`; the folder path where you would like to save the
#'   bathymetry data. Defaults to `tempdir()`. If you are downloading data for
#'   large areas (e.g. whole oceans), we strongly recommend you set your own
#'   path to save to.
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
#' bathymetry <- get_bathymetry(spatial_grid = bermuda_eez, 
#'                              raw = TRUE, 
#'                              classify_bathymetry = FALSE)
#' terra::plot(bathymetry)
#' # Get depth zones in spatial_grid
#' 
#' #equal area projection for Bermuda
#' bermuda_crs <- '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs'
#' 
#' bermuda_grid <- get_grid(boundary = bermuda_eez, 
#'                          crs = bermuda_crs, 
#'                          resolution = 10000)
#'                          
#' depth_zones <- get_bathymetry(spatial_grid = bermuda_grid)
#' terra::plot(depth_zones)
#' 
#' #It is also possible to get the raw bathymetry data in gridded format by setting raw = FALSE
#' # and classify_bathymetry = FALSE
#'   
#' gridded_bathymetry <- get_bathymetry(spatial_grid = bermuda_grid, 
#'                                      classify_bathymetry = FALSE)
#'                                      
#' terra::plot(gridded_bathymetry)
get_bathymetry <- function(spatial_grid = NULL, raw = FALSE, classify_bathymetry = TRUE, above_sea_level_isNA = FALSE, name = "bathymetry", bathymetry_data_filepath = NULL, path = NULL, antimeridian = NULL){

  checkmate::assert_multi_class(spatial_grid, c("SpatRaster", "sf"))
  checkmate::assert_logical(classify_bathymetry, null.ok = FALSE)
  checkmate::assert_logical(above_sea_level_isNA, null.ok = FALSE)
  checkmate::assert_character(name, len = 1, null.ok = TRUE)
  checkmate::assert_character(bathymetry_data_filepath, len = 1, null.ok = TRUE)
  checkmate::assert_character(path, len = 1, null.ok = TRUE)
  checkmate::assert_logical(antimeridian, null.ok = TRUE)
  
  meth <- if(is(spatial_grid, "sf")) 'mean' else 'average'
  
  area_polygon_for_cropping <- polygon_in_4326(spatial_grid)
  
  if(is.null(antimeridian)){
    antimeridian <- area_polygon_for_cropping |> 
      terra::vect() |> 
      terra::densify(interval = 1e4) |> 
      sf::st_as_sf() |> 
      check_antimeridian(sf::st_crs(4326))
  }
  
  if(is.null(bathymetry_data_filepath)){
    bathymetry <- get_gebco_bathymetry(area_polygon_for_cropping, path = path, antimeridian = antimeridian) |>  
      get_data_in_grid(spatial_grid = spatial_grid, dat = _, raw = raw, meth = meth, name = name, antimeridian = antimeridian)
  } else{
    bathymetry <- get_data_in_grid(spatial_grid = spatial_grid, dat = bathymetry_data_filepath, raw = raw, meth = meth, name = name, antimeridian = antimeridian) 
    }

  if(classify_bathymetry){
    
    depth_zones <- c("hadal", "abyssal", "lower_bathyal", "upper_bathyal", "continental_shelf" )
    
    bathymetry_cuts <- c(-12000, -6500, -3500, -800, -200, 10)
  
    
    reclass_var <- ifelse(above_sea_level_isNA, NA, 0)
    
    if(is(bathymetry, "sf")){
      grid_has_extra_cols <- if(ncol(spatial_grid)>1) TRUE else FALSE
      
      if(grid_has_extra_cols) extra_cols <- sf::st_drop_geometry(spatial_grid)

      bathymetry |> 
        dplyr::select(dplyr::all_of(name)) |> 
        dplyr::mutate(bathymetry = dplyr::case_when(bathymetry >=0 ~ reclass_var,
                                                    .default = as.numeric(bathymetry))) |>
        classify_layers(dat_breaks = bathymetry_cuts, classification_names = depth_zones) |> 
        (\(x) dplyr::select(x, (ncol(x)-1):1))() |> #reorder shallowest to deepest depth zones
        (\(x) if(grid_has_extra_cols) cbind(x, extra_cols) |> dplyr::relocate(colnames(extra_cols), .before = 1) else x)()

    }else{
      bathymetry |> 
        terra::classify(matrix(c(0, 1e4, reclass_var), ncol = 3), include.lowest = TRUE) |>
        classify_layers(dat_breaks = bathymetry_cuts, classification_names = depth_zones) |> 
        (\(x) terra::subset(x, terra::nlyr(x):1))() #reorder shallowest to deepest depth zones
    }
    
  }else{
    return(bathymetry)
  }
}
#This function extracts relief data for the area of interest from the GEBCO 2026 grid
#This is a helper function for get_bathymetry()

get_gebco_bathymetry <- function(area_polygon_for_cropping, path, antimeridian){
  #Get spatial indices of desired extent
  
  spat_ext <- terra::ext(area_polygon_for_cropping)
  
  min_x <- as.numeric(spat_ext[1]) |> round(2)
  max_x <- as.numeric(spat_ext[2]) |> round(2)
  min_y <- as.numeric(spat_ext[3]) |> round(2)
  max_y <- as.numeric(spat_ext[4]) |> round(2)
  
  # Get x extents of polygon left and right sides of the antimeridian 
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
  
  file_path <- file.path(path, file_name)
  
  if(file_name %in% list.files(path = path)) {
    message("Bathymetry data already downloaded, loading data from: ",
            file_path)
    return(terra::rast(file_path))  
  }
  
  #GEBCO data url
  gebco_url <- "https://dap.ceda.ac.uk/thredds/dodsC/bodc/gebco/global/gebco_2026/sub_ice_topography_bathymetry/netcdf/GEBCO_2026_sub_ice.nc"
  
  #open the connection to the remote netcdf file
  nc <- RNetCDF::open.nc(gebco_url)
  on.exit(RNetCDF::close.nc(nc))
  
  #get the possible lat and long values from the NetCDF file
  nc_lat_vals <- RNetCDF::var.get.nc(nc, "lat")
  nc_lon_vals <- RNetCDF::var.get.nc(nc, "lon")
  
  if(antimeridian){
    
    #Get left hand side of antimeridian
    file_path_left <- paste0("bathy_", min_x_left, "_", max_x_left, "_", min_y, "_", max_y, ".tif") 
    
    message("Grid or polygon crosses the antimeridian, getting bathymetry from the left hand side of the antimeridian")
    gebco_data_fetch(min_x_left, max_x_left, min_y, max_y, nc, file_path = file_path_left, nc_lat_vals, nc_lon_vals)
    
    #Get right hand side
    file_path_right <- paste0("bathy_", min_x_right, "_", max_x_right, "_", min_y, "_", max_y, ".tif") 
    
    message("Grid or polygon crosses the antimeridian, getting bathymetry from the right hand side of the antimeridian")
    gebco_data_fetch(min_x_right, max_x_right, min_y, max_y, nc, file_path_right, nc_lat_vals, nc_lon_vals)
    
    message("Merging the left and right hand side into a single raster")
    terra::merge(terra::rast(file_path_left), terra::rast(file_path_right), filename = file_path) 
    
  } else{
    gebco_data_fetch(min_x, max_x, min_y, max_y, nc, file_path, nc_lat_vals, nc_lon_vals)
  }
  
  terra::rast(file_path) |> 
    stats::setNames("elevation")
  
}

gebco_data_fetch <- function(min_x, max_x, min_y, max_y, nc, file_path, nc_lat_vals, nc_lon_vals){
  
  #Add or subtract 1 arc minute (4 steps in the index) to each coordinate to ensure we get the full extent
  
  index_min_lon <- which.min(abs(nc_lon_vals - min_x)) -4
  index_max_lon <- which.min(abs(nc_lon_vals - max_x)) +4
  index_min_lat <- which.min(abs(nc_lat_vals - min_y)) -4
  index_max_lat <- which.min(abs(nc_lat_vals - max_y)) +4
  
  #make sure we don't go out of the index range (due to the +/-2 adjustment)
  if(index_min_lon < 1) index_min_lon <- 1
  if(index_max_lon > length(nc_lon_vals)) index_max_lon <- length(nc_lon_vals)
  if(index_min_lat < 1) index_min_lat <- 1
  if(index_max_lat > length(nc_lat_vals)) index_max_lat <- length(nc_lat_vals)
  
  n_lon <- abs(index_max_lon - index_min_lon)
  
  n_lat <- abs(index_max_lat - index_min_lat)
  
  # From GEBCO website: "15 arc-second interval grid of 43200 rows x 86400 columns, giving 3,732,480,000 data points" (GEBCO 2026)
  # this can result in large file sizes and can quickly fill up memory, so download will be done in chunks and written straight to 
  # to disk 
  
  # set threshold at 15 million for cells in a chunk, c.f. Bermuda bathmetry is 3.3 million in GEBCO 2026 grid
  
  max_cells_at_a_time <- 15e6
  
  #how many rows of ncdf to read in a chunk, must be less than the total number of rows (n_lat)
  rows_in_chunk <- min(ceiling(max_cells_at_a_time/n_lon), n_lat) 
  
  # Initialize a local raster template on disk
  # Extent of raster defined by extracting min and max lat and lon from ncdf file using indexes
  rast_bounds <- c(nc_lon_vals[index_min_lon], nc_lon_vals[index_max_lon], nc_lat_vals[index_min_lat], nc_lat_vals[index_max_lat])
  
  local_rast <- terra::rast(crs = "EPSG:4326",
                            extent = rast_bounds,
                            nrows = n_lat,
                            ncols = n_lon)
  
  #define start of each chunk for reading, this will be relative to `index_min_lat` - 1
  row_index_for_ncdf_read <- seq(1, n_lat, by = rows_in_chunk)
  
  #define row index for chunk writing - this has to be in reverse order for terra
  # i.e. start writing the bottom rows in the raster, and work to the top, due to 
  # the difference in the NetCDF and terra file specs
  row_index_for_chunk_writing <- seq(n_lat, 1, by = -rows_in_chunk) - rows_in_chunk
  
  #make sure the final chunk is written at row 1 (don't go negative!)
  row_index_for_chunk_writing[row_index_for_chunk_writing<1] <- 1
  
  # Initialize the terra writing session
  read_write_info <- terra::writeStart(local_rast, filename = file_path, overwrite = TRUE)
  
  # Read from remote netcdf, write to Geotiff in chunks
  for (i in seq_along(row_index_for_ncdf_read)) {
    
    # How many rows to fetch in this block: avoids going past end of rows required (max is n_lat)
    rows_to_get <- min(rows_in_chunk, n_lat - row_index_for_ncdf_read[i] + 1)
    
    start_row <- index_min_lat + row_index_for_ncdf_read[i] - 1
    
    # ncdf4 reads datasets as [lon, lat] 
    # start: [lon_start, lat_start] | count: [lon_count, lat_count]
    # Read ALL longitudes (index_min_lon to n_lon) but only a chunk of latitudes (rows)
    chunk_data <- RNetCDF::var.get.nc(nc, 
                                      "elevation", 
                                      start = c(index_min_lon, start_row), 
                                      count = c(n_lon, rows_to_get)) 
    
    # NetCDF matrix is inverted relative to how terra expects it, so corrections is applied during
    # writing of values
    
    # Write this specific spatial slice directly to the hard drive
    terra::writeValues(local_rast, chunk_data[,ncol(chunk_data):1], row_index_for_chunk_writing[i], rows_to_get)
    
    # Housekeeping: free memory inside the loop
    rm(chunk_data)
    gc()
    
    message(sprintf("Downloaded and saved data chunk %d of %d", i, length(row_index_for_ncdf_read)))
    
  }
  
  terra::writeStop(local_rast)
  message("Finished! Data successfully streamed to ", file_path)
  
}
