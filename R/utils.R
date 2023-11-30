# A file of little functions that we use across the board. 

#' Check planning grid or area polygon input is supplied and is in correct format
#'
#' @param planning_grid sf or raster planning grid
#' @param area_polygon sf object 
#'
#' @noRd
check_grid_or_polygon <- function(planning_grid, area_polygon) {
  if (is.null(area_polygon) & is.null(planning_grid)) {
    stop("an area polygon or planning grid must be supplied")
  } else if (!is.null(area_polygon) & !is.null(planning_grid)) {
    stop("please supply either an area polygon or a planning grid, not both")
  } else if (!is.null(planning_grid) &
             !(class(planning_grid)[1] %in% c("RasterLayer", "SpatRaster", "sf"))) {
    stop("planning_grid must be a raster or sf object")
  } else if (!is.null(area_polygon) &
             !(class(area_polygon)[1] == "sf")) {
    stop("area_polygon must be an sf object")
  }
}


#' Check if area polygon or planning grid crs is same as data crs
#'
#' @param area_polygon sf object
#' @param planning_grid raster or sf 
#' @param dat raster or sf
#'
#' @return `logical` TRUE crs' match, FALSE if they don't
#' @noRd
check_matching_crs <- function(area_polygon, planning_grid, dat){
  if(is.null(planning_grid)){
    ifelse(sf::st_crs(area_polygon) == sf::st_crs(dat), TRUE, FALSE) 
  }else{
    ifelse(sf::st_crs(planning_grid) == sf::st_crs(dat), TRUE, FALSE)
  } 
}

#' Check if sf object spans the antimeridian
#'
#' @param sf_object 
#'
#' @return `logical` TRUE if it does span the antimeridian, FALSE if it doesn't
#' @noRd
check_antimeridian <- function(sf_object){
  if(sf::st_crs(sf_object) != sf::st_crs(4326)){
    b_box <- sf::st_transform(sf_object, 4326) %>% 
      sf::st_bbox()
  } else{
    b_box <- sf::st_bbox(sf_object) 
  }
  
  if(round(b_box$xmin) == -180 & round(b_box$xmax) == 180){
    TRUE
  } else{
    FALSE
  }
}

#' Check if data is a raster
#'
#' @param dat 
#'
#' @return `logical` TRUE if raster, else FALSE
#' @noRd
check_raster <- function(dat){
  if(class(dat)[1] %in% c("RasterLayer", "SpatRaster")){
    return(TRUE)
  }else{
    return(FALSE)
  }
}

#' Check if data is sf 
#'
#' @param dat 
#'
#' @return TRUE if sf, else FALSE
#' @noRd
check_sf <- function(dat){
  if(class(dat)[1] == "sf"){
    return(TRUE)
  }else{
    return(FALSE)
  }
}

#' If input is character, read in from file pointed to, assuming it is a common vector or raster file format
#'
#' @param dat 
#'
#' @return `sf` or `terra::rast` format data
#' @noRd
data_from_filepath <- function(dat){
  ## First deal with whether the input is a file or a dataset
  if (class(dat)[1] == "character") { # If a file, we need to load the data
    
    ext <- tools::file_ext(dat)
    nm <- basename(dat) 
    if (ext %in% c("tif", "tiff", "grd", "gri")) {
      print("Data is in raster format")
      dat <- terra::rast(dat)
    } else if (ext %in% c("shp", "gpkg")) {
      print("Data is in vector format")
      dat <- sf::read_sf(dat)
    }
  }
  return(dat) 
}

#' Classify sf or raster data based on data breaks provided
#'
#' @param dat data to classify
#' @param dat_breaks ordered data breaks
#' @param classification_names names for the classes in same order as `dat_breaks`
#'
#' @return `sf` or `terra::rast` object depending on input
#' @noRd
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
area_polygon_lonlat <-
  function(area_polygon, planning_grid, matching_crs) {
    if (!is.null(planning_grid)) {
      if (check_raster(planning_grid)) {
        planning_grid %>%
          terra::as.polygons() %>%
          {
            if (matching_crs)
              .
            else
              terra::project(., "epsg:4326")
          } %>%
          sf::st_as_sf() %>% 
          {if(sf::st_is_valid(.)) . else sf::st_make_valid(.)}
      } else{
        planning_grid %>%
          {
            if (matching_crs)
              .
            else
              sf::st_transform(., 4326)
          }
      }
    } else{
      area_polygon %>%
        sf::st_geometry() %>%
        sf::st_as_sf() %>%
        {
          if (matching_crs)
            .
          else
            sf::st_transform(., 4326)
        }
    }
  }

#Probably don't need the following functions, but keeping them for the moment just in cases....

# Function to split data that crosses the antimeridian into two parts
split_by_antimeridian <- function(data) {
  
  # Clip the data into two halves
  left_template <- terra::rast(xmin = -180, xmax = 0, ymin = -90, ymax = 90)
  right_template <- terra::rast(xmin = 0, xmax = 180, ymin = -90, ymax = 90)
  data_raster_left <- terra::trim(terra::crop(data, left_template))
  data_raster_right <- terra::trim(terra::crop(data, right_template))
  
  return(list(data_raster_left, data_raster_right))
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