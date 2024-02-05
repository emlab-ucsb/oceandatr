# A file of little functions that we use across the board. 

#' Check planning grid or area polygon input is supplied and is in correct format
#'
#' @param spatial_grid sf or raster planning grid
#' @param area_polygon sf object 
#'
#' @noRd
check_grid_or_polygon <- function(spatial_grid, area_polygon) {
  if (is.null(area_polygon) & is.null(spatial_grid)) {
    stop("an area polygon or planning grid must be supplied")
  } else if (!is.null(area_polygon) & !is.null(spatial_grid)) {
    stop("please supply either an area polygon or a planning grid, not both")
  } else if (!is.null(spatial_grid) &
             !(class(spatial_grid)[1] %in% c("RasterLayer", "SpatRaster", "sf"))) {
    stop("spatial_grid must be a raster or sf object")
  } else if (!is.null(area_polygon) &
             !(class(area_polygon)[1] == "sf")) {
    stop("area_polygon must be an sf object")
  }
}


#' Check if area polygon or planning grid crs is same as data crs
#'
#' @param area_polygon sf object
#' @param spatial_grid raster or sf 
#' @param dat raster or sf
#'
#' @return `logical` TRUE crs' match, FALSE if they don't
#' @noRd
check_matching_crs <- function(area_polygon, spatial_grid, dat){
  if(is.null(spatial_grid)){
    ifelse(sf::st_crs(area_polygon) == sf::st_crs(dat), TRUE, FALSE) 
  }else{
    ifelse(sf::st_crs(spatial_grid) == sf::st_crs(dat), TRUE, FALSE)
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
      {if(!is.null(classification_names)) stats::setNames(., classification_names[as.numeric(names(.))]) else .} 
    
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
  function(area_polygon, spatial_grid, matching_crs) {
    if (!is.null(spatial_grid)) {
      if (check_raster(spatial_grid)) {
        spatial_grid %>%
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
        spatial_grid %>%
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