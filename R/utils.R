# A file of little functions that we use across the board. 

# Function to return errors for incorrect planning_grid input
check_grid <- function(planning_grid) { 
  if(!is.null(planning_grid) & !(class(planning_grid)[1] %in% c("RasterLayer", "SpatRaster", "sf"))) { 
    stop("planning_grid must be a raster or sf object")}
}

# Function to return errors for incorrect area polygon input
check_area <- function(area_polygon) { 
  if(!is.null(area_polygon) & !(class(area_polygon)[1] == "sf")) { 
    stop("area_polygon must be an sf object")}
} 


# Function to split data that crosses the antimeridian into two parts
split_by_antimeridian <- function(data) {
  
  # Clip the data into two halves
  left_template <- terra::rast(xmin = -180, xmax = 0, ymin = -90, ymax = 90)
  right_template <- terra::rast(xmin = 0, xmax = 180, ymin = -90, ymax = 90)
  data_raster_left <- terra::trim(terra::crop(data, left_template))
  data_raster_right <- terra::trim(terra::crop(data, right_template))
  
  return(list(data_raster_left, data_raster_right))
} 

# Function to classify data layers
classify_layers <- function(dat, dat_breaks = NULL, classification_names = NULL){ 
  
  if(is.null(dat_breaks)) stop("Please supply data breaks")

  if(check_raster(dat)){
    #create a classification matrix
    class_matrix <- dat_breaks %>%
      .[2:(length(.) - 1)] %>%
      rep(times = rep(2, times = length(.))) %>%
      append(dat_breaks[length(dat_breaks)]) %>%
      append(dat_breaks[1], after = 0) %>%
      matrix(ncol = 2, byrow = TRUE) %>%
      cbind(c(1:nrow(.)))
  
      dat %>%
      terra::classify(class_matrix, include.lowest = TRUE) %>%
        terra::segregate(other=NA) %>%
        {if(!is.null(classification_names)) setNames(., classification_names[as.numeric(names(.))]) else .} 
      
  } else{
      dat %>%
        dplyr::mutate(classification = cut(.[[1]], dat_breaks, labels = classification_names, include.lowest = TRUE),
                      classification = droplevels(classification),
                      value = 1,
                      .after = 1) %>%
         tidyr::pivot_wider(names_from = "classification", values_from = "value", values_fill = NA) %>%
         dplyr::select(3:ncol(.), 2) #put classification before geometry and drop original values
  }
}

# Function to stitch outputs that cross the antimeridian back together
combine_antimeridian <- function(data, planning_grid, classification_names = NULL) { 
  if(is.null(planning_grid)) { 
    spatrast <- terra::sprc(data[[1]], data[[2]])
    output <- terra::merge(x)
    
    if(!is.null(classification_names)) {
      output <- output %>% 
        setNames(classification_names[classification_names %in% unique(c(names(data[[1]]), names(data[[2]])))])
    } 
  } else if(class(planning_grid)[1] %in% c("RasterLayer", "SpatRaster")) { 
    output <- terra::merge(data[[1]], data[[2]], na.rm = T)
    
    if(!is.null(classification_names)) { 
      output <- output %>% 
        setNames(classification_names[classification_names %in% unique(c(names(data[[1]]), names(data[[2]])))])
    }
  } else { 
    output <- dplyr::bind_rows(data[[1]], data[[2]]) %>% 
      dplyr::group_by(geometry) %>% 
      dplyr::summarise_all(mean, na.rm = TRUE) %>% 
      dplyr::ungroup() %>% 
      dplyr::relocate(geometry, .after = last_col())

    if(!is.null(classification_names)) { 
      output <- output %>% 
      dplyr::select(classification_names[classification_names %in% colnames(.)], geometry) %>% 
      dplyr::mutate_at(colnames(.)[1:(ncol(.)-1)], ~ifelse(is.nan(.), NA, .))
    } 
  }
  return(output)
}