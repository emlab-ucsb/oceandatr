#generic get data function

data_to_planning_grid <- function(area_polygon = NULL, planning_grid = NULL, dat = NULL, meth = NULL, name = NULL, sf_col_layer_names = NULL, antimeridian = NULL){
  if(is.null(dat)){
    stop("Please provide some input data")
  }
  check_grid_or_polygon(planning_grid, area_polygon)
  check_area(area_polygon)
  check_grid(planning_grid)
  
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