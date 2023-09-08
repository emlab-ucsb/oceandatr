#generic get data function

get_data <- function(planning_grid = NULL, area_polygon = NULL, dat = NULL, meth = NULL, name = NULL, sf_col_names = NULL){
  if(is.null(dat)){
    stop("Please provide some input data")
  }
  check_grid_or_polygon(planning_grid, area_polygon)
  check_area(area_polygon)
  check_grid(planning_grid)
  
  dat <- data_from_filepath(dat)
  
  matching_crs <- ifelse(sf::st_crs(aoi) == sf::st_crs(dat), TRUE, FALSE)
  
  if(check_raster(planning_grid)){
  if(!is.null(meth)){
    meth <- meth
  } else if(all(unique(as.numeric(terra::values(dat))) %in% c(0,1,NA,NaN))){
    meth <- 'near'
  } else{
    meth <- 'average'
  }
  }
  
  if(!is.null(area_polygon)){
    raw_data_masked <- get_raw_data(area_polygon, dat, meth, matching_crs)
    return(raw_data_masked)
  }
  
  ras_to_planning_grid(dat, planning_grid, matching_crs, meth, name)
  
}