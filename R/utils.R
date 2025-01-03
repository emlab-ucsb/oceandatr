# A file of little functions that we use across the board. 

#' Check a spatial grid is supplied and in raster or sf format
#'
#' @param spatial_grid
#'
#' @noRd
check_grid <- function(spatial_grid) {
  if (is.null(spatial_grid)) {
    stop("a spatial grid must be supplied")
  } else if (!(class(spatial_grid)[1] %in% c("RasterLayer", "SpatRaster", "sf"))) {
    stop("spatial_grid must be a raster or sf object")
  }
}

#' Check if spatial objects have same crs
#'
#' @param sp1 raster or sf
#' @param sp2 raster or sf
#'
#' @return `logical` TRUE crs' match, FALSE if they don't
#' @noRd
check_matching_crs <- function(sp1, sp2){
  ifelse(sf::st_crs(sp1) == sf::st_crs(sp2), TRUE, FALSE)
}

#' Check if sf object spans the antimeridian
#'
#' @param sf_object
#'
#' @return `logical` TRUE if it does span the antimeridian, FALSE if it doesn't
#' @noRd
check_antimeridian <- function(sf_object, dat){
  if(sf::st_crs(sf_object) != sf::st_crs(4326)){
    b_box <- sf::st_transform(sf_object, 4326) %>%
      sf::st_bbox()
  } else{
    b_box <- sf::st_bbox(sf_object)
  }
  
  if(round(b_box$xmin) == -180 & round(b_box$xmax) == 180 & sf::st_crs(dat) == sf::st_crs(4326)){
    TRUE
  } else if (round(b_box$xmin) == -180 & round(b_box$xmax) == 180 & sf::st_crs(dat) != sf::st_crs(4326)){
    message("Your area polygon or grid crosses the antimeridian, but your data are not in long-lat (EPSG 4326) format. This may result in problems when cropping and gridding data, if the data are not in a suitable local projection.")
    FALSE
  } else FALSE
}

#' Check if object is a raster
#'
#' @param sp
#'
#' @return `logical` TRUE if raster, else FALSE
#' @noRd
check_raster <- function(sp){
  if(class(sp)[1] %in% c("RasterLayer", "SpatRaster")){
    return(TRUE)
  }else{
    return(FALSE)
  }
}

#' Check if object is sf
#'
#' @param sp
#'
#' @return TRUE if sf, else FALSE
#' @noRd
check_sf <- function(sp){
  if(class(sp)[1] == "sf"){
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
      terra::segregate() %>%
      {if(!is.null(classification_names)) stats::setNames(., classification_names[as.numeric(names(.))]) else .} 
    
  } else{
    dat %>%
      dplyr::mutate(classification = cut(.[[1]], dat_breaks, labels = classification_names, include.lowest = TRUE),
                    classification = droplevels(.data$classification),
                    value = 1,
                    .after = 1) %>%
      tidyr::pivot_wider(names_from = "classification", values_from = "value", values_fill = 0) %>%
      dplyr::select(3:ncol(.), 2) #put classification before geometry and drop original values
  }
}
#' Get an sf polygons in lonlat (EPSG 4326) from terra or sf input object
#'
#' @param spatial_grid 
#'
#' @return `sf` polygons
#'
#' @noRd
polygon_in_4326 <-
  function(spatial_grid) {
    crs_is_4326 <- check_matching_crs(spatial_grid, 4326)
      if (check_raster(spatial_grid)) {
        spatial_grid %>%
          terra::as.polygons() %>%
          {
            if (crs_is_4326)
              .
            else
              terra::project(., "epsg:4326")
          } %>%
          sf::st_as_sf() %>% 
          sf::st_union() %>%
          sf::st_sf() %>% 
          sf::st_wrap_dateline() %>% 
          {if(sf::st_is_valid(.)) . else sf::st_make_valid(.)}
      } else{
        spatial_grid %>%
          {if (crs_is_4326) . else sf::st_transform(., 4326)} %>% 
          sf::st_union() %>% 
          sf::st_sf() %>% 
          sf::st_wrap_dateline() %>% 
          {if(sf::st_is_valid(.)) . else sf::st_make_valid(.)}
      }
  }

#' Remove empty layers in raster or columns with all zeroes in sf
#'
#' @param dat `sf` or raster object
#'
#' @return `sf` or raster depending on input
#'
#' @noRd
remove_empty_layers <- function(dat){
  if(check_sf(dat)){
    dat %>% 
      dplyr::select(which(!colSums(sf::st_drop_geometry(dat), na.rm = TRUE) %in% 0))
  }else{
    dat %>% 
    terra::subset(which(terra::global(dat, "sum", na.rm = TRUE) >0))  
  }
}

# Helper functions for tests

#' Get a grid for Bermuda's EEZ in local equal area projection
#'
#' @param resolution `numeric` grid cell width in kilometres
#' @param output `character` the desired output format, either "raster", "sf_square" (vector), or "sf_hex" (vector); default is "raster"
#'
#' @returns Grid for Bermuda's EEZ in local equal area projection and specified format and cell size
#'
#' @noRd
bermuda_grid <- function(resolution = 20, output = "raster") {
  get_grid(boundary = get_boundary(name = "Bermuda"), 
           crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs',
           resolution = resolution*1e3, 
           output = output)
}

#' Get a grid for Kiribati's EEZ in local equal area projection
#'
#' @param resolution `numeric` grid cell width in kilometres
#' @param output `character` the desired output format, either "raster", "sf_square" (vector), or "sf_hex" (vector); default is "raster"
#'
#' @returns Grid for Kiribati's EEZ in local equal area projection and specified format and cell size
#'
#' @noRd
kiribati_grid <- function(resolution = 50, output = "raster") {
  get_grid(boundary = get_boundary(name = "Kiribati", country_type = "sovereign"),
           crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
           resolution = resolution*1e3, 
           output = output)
}
