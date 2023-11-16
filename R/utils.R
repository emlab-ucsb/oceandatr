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
classify_layers <- function(data, planning_grid = NULL, classification_matrix = NULL, classification_names = NULL){ 
  #data passed in is already cropped to planning grid, then data is:
  # 1. Projected to same crs as planning grid
  # 2. If there is a classification matrix it is classified and if there is a 
  
  # Project
  projected_raster <- if(is.null(planning_grid)) {
    data
  } else if(check_raster(planning_grid)) { 
    data %>%
      terra::project(planning_grid)
  } else { 
    data %>%
      terra::project(terra::crs(planning_grid))
  }
  
  if(!is.null(classification_matrix)) { 
    classification <- projected_raster %>% 
      terra::classify(classification_matrix, include.lowest = TRUE)
    
    if(is.null(planning_grid)) { 
      stack_out <- classification %>% 
        terra::segregate(other=NA)
      
      if(!is.null(classification_names)){ 
        stack_out <- stack_out %>%  
          setNames(classification_names[as.numeric(names(.))])
      } 
    } else if(check_raster(planning_grid)) { 
      stack_out <- classification %>% 
          terra::mask(planning_grid) %>% 
          terra::segregate(other=NA)
  
      if(!is.null(classification_names)){ 
        stack_out <- stack_out %>%  
          setNames(classification_names[as.numeric(names(.))])
      } 
    }
  } else { 
      classification <- projected_raster 
    
      if(is.null(planning_grid)) { 
        stack_out <- classification %>% 
          terra::segregate(other=NA)
      } else if(check_raster(planning_grid)) { 
        stack_out <- classification %>% 
          terra::mask(planning_grid)
      } 
  }

  if(!is.null(planning_grid) & !check_raster(planning_grid)) { 
    classification_vec <- exactextractr::exact_extract(classification, planning_grid, 
                                                       function(value, cov_frac) 
                                                         ifelse(length(value) > 0, 
                                                                max(value[cov_frac == max(cov_frac)]), 
                                                                NA))
    stack_out <- 
      planning_grid %>% 
      cbind(data.frame("classification" = classification_vec))
    
    if(!is.null(classification_names)) { 
      stack_out <- stack_out %>% 
        dplyr::mutate(value = 1, 
                      classification = classification_names[classification_vec]) %>% 
        tidyr::pivot_wider(names_from = "classification", values_from = "value", values_fn = ~mean(.x, na.rm = T)) %>% 
        dplyr::rename(geometry = x) %>% 
        dplyr::select(classification_names[sort(unique(classification_vec))], geometry)
    } else { 
      stack_out <- stack_out %>% 
        dplyr::mutate(value = 1) %>% 
        tidyr::pivot_wider(names_from = "classification", values_from = "value", values_fn = ~mean(.x, na.rm = T)) %>% 
        dplyr::rename(geometry = x) %>% 
        dplyr::select(as.character(sort(unique(classification_vec[!is.na(classification_vec)]))), geometry)
    }
  }
  
  return(stack_out)
  
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