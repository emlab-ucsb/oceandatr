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
# GEBCO 2026 global terrain model (sub-ice topography/bathymetry) on the CEDA
# THREDDS OPeNDAP server
gebco_url <- "https://dap.ceda.ac.uk/thredds/dodsC/bodc/gebco/global/gebco_2026/sub_ice_topography_bathymetry/netcdf/GEBCO_2026_sub_ice.nc"
gebco_service_name <- "GEBCO bathymetry (CEDA THREDDS)"

# Start of the names of the files that downloaded data are saved to. This names the GEBCO release, so that files
# downloaded from one release are not used as if they were from another, and should be changed if files saved by 
# an earlier version of the code would be wrong (this was last changed when the position of the downloaded data 
# was corrected, see `gebco_data_fetch()`)
gebco_file_prefix <- "bathy_gebco2026_"

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
  
  file_name <- paste0(gebco_file_prefix, min_x, "_", max_x, "_", min_y, "_", max_y, ".tif")
  
  path <- if(is.null(path)) tempdir() else path
  
  file_path <- file.path(path, file_name)
  
  if(file_name %in% list.files(path = path)) {
    message("Bathymetry data already downloaded, loading data from: ",
            file_path)
    return(terra::rast(file_path))  
  }
  
  # The size of the grid is taken from the dataset itself, rather than being written into the code, and the
  # assumptions this function makes about the dataset are checked, so that if GEBCO changes the format of
  # the data, there is an error and not incorrect data
  gebco_grid <- opendap_array_info(gebco_url, "elevation", service_name = gebco_service_name)
  
  if(!identical(names(gebco_grid$dims), c("lat", "lon")) || !gebco_grid$type %in% c("Int16", "Int32")){
    stop("The GEBCO data are not in the format expected. Expected an integer variable `elevation` with dimensions [lat][lon], but it is ",
         gebco_grid$type, " ", paste0("[", names(gebco_grid$dims), "]", collapse = ""), ". ",
         "get_bathymetry() needs to be updated for the new GEBCO format.", call. = FALSE)
  }
  
  #get the lat and long values of the cells of the GEBCO grid
  gebco_lat_values <- opendap_read_values(gebco_url, "lat", n_values = gebco_grid$dims[["lat"]], type = "double", service_name = gebco_service_name)
  gebco_lon_values <- opendap_read_values(gebco_url, "lon", n_values = gebco_grid$dims[["lon"]], type = "double", service_name = gebco_service_name)
  
  # the data are processed on the assumption that latitude increases from the first to last row (south to north),
  # and that the cells are evenly spaced
  is_regular <- function(x) isTRUE(all(abs(diff(x) - (x[2] - x[1])) < 1e-8))
  
  if(is.unsorted(gebco_lat_values, strictly = TRUE) || is.unsorted(gebco_lon_values, strictly = TRUE) ||
     !is_regular(gebco_lat_values) || !is_regular(gebco_lon_values)){
    stop("The GEBCO data are not in the order and spacing expected (latitude and longitude increasing, evenly spaced). ",
         "get_bathymetry() needs to be updated for the new GEBCO format.", call. = FALSE)
  }
  
  if(antimeridian){
    
    #Get left hand side of antimeridian
    file_path_left <- file.path(path, paste0(gebco_file_prefix, min_x_left, "_", max_x_left, "_", min_y, "_", max_y, ".tif")) 
    
    message("Grid or polygon crosses the antimeridian, getting bathymetry from the left hand side of the antimeridian")
    gebco_data_fetch(min_x_left, max_x_left, min_y, max_y, file_path = file_path_left, gebco_lat_values, gebco_lon_values)
    
    #Get right hand side
    file_path_right <- file.path(path, paste0(gebco_file_prefix, min_x_right, "_", max_x_right, "_", min_y, "_", max_y, ".tif")) 
    
    message("Grid or polygon crosses the antimeridian, getting bathymetry from the right hand side of the antimeridian")
    gebco_data_fetch(min_x_right, max_x_right, min_y, max_y, file_path_right, gebco_lat_values, gebco_lon_values)
    
    message("Merging the left and right hand side into a single raster")
    terra::merge(terra::rast(file_path_left), terra::rast(file_path_right), filename = file_path) 
    
  } else{
    gebco_data_fetch(min_x, max_x, min_y, max_y, file_path, gebco_lat_values, gebco_lon_values)
  }
  
  terra::rast(file_path) |> 
    stats::setNames("elevation")
  
}

gebco_data_fetch <- function(min_x, max_x, min_y, max_y, file_path, gebco_lat_values, gebco_lon_values, max_cells_at_a_time = 5e6){
  
  #Add or subtract 1 arc minute (4 steps in the index) to each coordinate to ensure we get the full extent
  
  index_min_lon <- which.min(abs(gebco_lon_values - min_x)) -4
  index_max_lon <- which.min(abs(gebco_lon_values - max_x)) +4
  index_min_lat <- which.min(abs(gebco_lat_values - min_y)) -4
  index_max_lat <- which.min(abs(gebco_lat_values - max_y)) +4
  
  #make sure we don't go out of the index range (due to the +/-4 adjustment)
  if(index_min_lon < 1) index_min_lon <- 1
  if(index_max_lon > length(gebco_lon_values)) index_max_lon <- length(gebco_lon_values)
  if(index_min_lat < 1) index_min_lat <- 1
  if(index_max_lat > length(gebco_lat_values)) index_max_lat <- length(gebco_lat_values)
  
  # the number of columns and rows from index_min to index_max, including both of them. Including index_max is 
  # important where it is the last index of the GEBCO grid, i.e. when the area reaches 180 degrees longitude or 
  # 90 degrees latitude, as there is then no padding beyond it, so leaving it out would leave out the last 
  # column (or row) of the GEBCO grid
  n_lon <- index_max_lon - index_min_lon + 1
  
  n_lat <- index_max_lat - index_min_lat + 1
  
  # From GEBCO website: "15 arc-second interval grid of 43200 rows x 86400 columns, giving 3,732,480,000 data points" (GEBCO 2026)
  # this can result in large file sizes and can quickly fill up memory, so download will be done in chunks and written straight 
  # to disk 
  
  # `max_cells_at_a_time` is the threshold for cells in a chunk. It is 5 million by default, c.f. Bermuda bathymetry is 3.3 
  # million in GEBCO 2026 grid. Each chunk is a single download of about 4 bytes per cell (20 MB at 5 million cells). Smaller 
  # chunks mean that if a download fails, and has to be repeated, less data is downloaded again
  
  #how many rows of the GEBCO grid to read in a chunk, must not be more than the total number of rows (n_lat)
  rows_in_chunk <- min(ceiling(max_cells_at_a_time/n_lon), n_lat) 
  
  # Initialize a local raster template on disk
  # The lat and lon values of the GEBCO grid are the coordinates of the centres of its cells (the `node_offset` of 
  # the GEBCO data is 1, and the first latitude is -90 plus half a cell), but the extent of a raster is the outer 
  # edges of its cells. The raster has a column for each value at index_min_lon to index_max_lon, and a row for each 
  # value at index_min_lat to index_max_lat, so its extent starts half a cell before the first of those values, and 
  # ends half a cell after the last. Without allowing for this, the data are half a cell (7.5 arc-seconds, about 230 m) 
  # out of position. At the edges of the GEBCO grid this gives the exact edge, e.g. 180 degrees longitude
  lon_half_cell <- (gebco_lon_values[2] - gebco_lon_values[1]) / 2
  lat_half_cell <- (gebco_lat_values[2] - gebco_lat_values[1]) / 2
  
  rast_bounds <- c(gebco_lon_values[index_min_lon] - lon_half_cell, 
                   gebco_lon_values[index_max_lon] + lon_half_cell, 
                   gebco_lat_values[index_min_lat] - lat_half_cell, 
                   gebco_lat_values[index_max_lat] + lat_half_cell)
  
  local_rast <- terra::rast(crs = "EPSG:4326",
                            extent = rast_bounds,
                            nrows = n_lat,
                            ncols = n_lon)
  
  #define start of each chunk for reading, this will be relative to `index_min_lat` - 1
  row_index_for_reading <- seq(1, n_lat, by = rows_in_chunk)
  
  #define row index for chunk writing - this has to be in reverse order for terra
  # i.e. start writing the bottom rows in the raster, and work to the top, because the rows of the GEBCO grid
  # are in order from south to north, but the first row of a terra raster is the northernmost
  # (the first chunk read is the southernmost rows, which should be written to the last rows of the raster, i.e.
  # starting at row n_lat - rows_in_chunk + 1)
  row_index_for_chunk_writing <- seq(n_lat, 1, by = -rows_in_chunk) - rows_in_chunk + 1
  
  #make sure the final chunk is written at row 1 (don't go negative!)
  row_index_for_chunk_writing[row_index_for_chunk_writing<1] <- 1
  
  # Initialize the terra writing session
  read_write_info <- terra::writeStart(local_rast, filename = file_path, overwrite = TRUE)
  
  # If anything below fails partway through (e.g. the connection drops
  # after some chunks have already been written), file_path will exist on
  # disk but contain incomplete data. Since get_gebco_bathymetry() treats
  # any existing file of that name as a complete, previously-downloaded
  # cache, an incomplete file must not be left behind, or a failed
  # download would look "successful" and serve corrupt data next time.
  download_completed <- FALSE
  on.exit(if(!download_completed) unlink(file_path), add = TRUE)
  
  # Read from the remote GEBCO dataset, write to GeoTIFF in chunks
  for (i in seq_along(row_index_for_reading)) {
    
    # How many rows to fetch in this block: avoids going past end of rows required (max is n_lat)
    rows_to_get <- min(rows_in_chunk, n_lat - row_index_for_reading[i] + 1)
    
    start_row <- index_min_lat + row_index_for_reading[i] - 1
    
    # Read ALL longitudes (index_min_lon to n_lon) but only a chunk of latitudes (rows).
    # DAP2 constraints use zero based, inclusive indices, in the order of the dimensions of the 
    # dataset, which for GEBCO is [lat][lon]
    chunk_values <- opendap_read_values(
      gebco_url,
      constraint = sprintf("elevation.elevation[%d:%d][%d:%d]", 
                           start_row - 1, start_row + rows_to_get - 2, 
                           index_min_lon - 1, index_min_lon + n_lon - 2),
      n_values = n_lon * rows_to_get,
      type = "integer",
      service_name = sprintf("%s, data chunk %d of %d", gebco_service_name, i, length(row_index_for_reading))
    )
    
    # the values are in order with longitude varying fastest, so fill a matrix of [lon, lat] by column
    chunk_data <- matrix(chunk_values, nrow = n_lon, ncol = rows_to_get)
    rm(chunk_values)
    
    # The first column of `chunk_data` is the southernmost row, but terra expects the first row to be the
    # northernmost, so the order of the columns is reversed when the values are written
    
    # Write this specific spatial slice directly to the hard drive
    terra::writeValues(local_rast, chunk_data[,ncol(chunk_data):1], row_index_for_chunk_writing[i], rows_to_get)
    
    # Housekeeping: free memory inside the loop
    rm(chunk_data)
    gc()
    
    message(sprintf("Downloaded and saved data chunk %d of %d", i, length(row_index_for_reading)))
    
  }
  
  terra::writeStop(local_rast)
  download_completed <- TRUE
  message("Finished! Data successfully saved to ", file_path)
  
}
