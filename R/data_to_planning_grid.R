#' Get gridded or cropped data from input data
#'
#' @param area_polygon `sf` polygon
#' @param planning_grid `sf` or `terra::rast()` planning grid
#' @param dat `sf` or `terra::rast()` data to be gridded/ cropped
#' @param meth `character` method to use for for gridding/ resampling/ reprojecting raster data. If NULL (default), function checks if data values are binary (all 0, 1, NA, or NaN) in which case method is set to "mode" for sf output or "near" for raster output. If data is non-binary, method is set to "average" for sf output or "mean" for raster output. Note that different methods are used for sf and raster as `exactextractr::exact_extract()` is used for gridding to sf planning grid, whereas `terra::project()`/`terra::resample()` is used for transforming/ gridding raster data.
#' @param name `character` to name the data output
#' @param sf_col_layer_names `character` vector; name(s) of columns that contain the data to be gridded/ cropped in `sf` input data; defaults to first column
#' @param antimeridian `logical` can be set to true if the data to be extracted crosses the antimeridian and is in lon-lat (EPSG:4326) format
#'
#' @return `sf` or `terra::rast()` object; cropped and intersected data in same format as `dat` if  an `area_polygon` is provided. `sf` or `terra::rast()` planning gridded data depending on the format of the planning grid provided
#' 
#' @export
#'
#' @examples
data_to_planning_grid <- function(area_polygon = NULL, planning_grid = NULL, dat = NULL, meth = NULL, name = NULL, sf_col_layer_names = NULL, antimeridian = NULL){
  if(is.null(dat)){
    stop("Please provide some input data")
  }
  check_grid_or_polygon(planning_grid, area_polygon)
  
  dat <- data_from_filepath(dat)
  
  matching_crs <- check_matching_crs(area_polygon, planning_grid, dat)
  
  antimeridian <- if(is.null(antimeridian)){
    sf_object <- if(is.null(planning_grid)) area_polygon else{
      if(check_sf(planning_grid)) planning_grid else terra::as.polygons(planning_grid) %>% sf::st_as_sf()
    }
    check_antimeridian(sf_object)
  } else antimeridian

#setting method for resampling, projecting, etc. a raster - should be 'near' for binary raster otherwise end up with non-binary values
#previously checking for unique values 0,1,NA, NaN but this is time consuming for global raster so get user to define if binary or not

  raster_cell_no_threshold <- 1e4
  
  if(!is.null(meth)){
    meth <- meth
  } else if(check_raster(dat)){
      meth <- dat %>% 
        #take a sample if it is a large raster, and assume that no more than 50% of cells are NA otherwise this will fail
        {if(terra::ncell(dat)> raster_cell_no_threshold) terra::spatSample(., size = raster_cell_no_threshold/2, na.rm = TRUE) else terra::values(.)} %>% 
        unlist() %>% 
        unique() %>% 
        {if(all(. %in% c(0,1,NA,NaN))) {
          if(check_raster(planning_grid)) 'near' else 'mode'
        } else {
            if(check_raster(planning_grid)) 'average' else 'mean'
          }
    }
  }

  if(!is.null(area_polygon)){
    get_raw_data(area_polygon, dat, meth, matching_crs, antimeridian)
    
  } else if(check_raster(dat)){
    ras_to_planning_grid(dat, planning_grid, matching_crs, meth, name, antimeridian)
    } else {
    sf_to_planning_grid(dat, planning_grid, matching_crs, name, sf_col_layer_names, antimeridian)
  }
  
}