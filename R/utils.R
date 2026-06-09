# A file of little functions that we use across the board. 


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
#' @param sf_object to check
#'
#' @return `logical` TRUE if it does span the antimeridian, FALSE if it doesn't
#' @noRd
check_antimeridian <- function(sf_object, dat){
  if(sf::st_crs(sf_object) != sf::st_crs(4326)){
    b_box <- sf::st_transform(sf_object, 4326) |>
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

#' If input is character, read in from file pointed to, assuming it is a common
#' vector or raster file format
#'
#' @param dat for reading
#'
#' @return `sf` or `terra::rast` format data
#' @noRd
data_from_filepath <- function(dat){
    
    ext <- tools::file_ext(dat)
    nm <- basename(dat)

    if (ext %in% c("tif", "tiff", "grd", "gri")) {
      print("Data is in raster format")
      terra::rast(dat)
    } else if (ext %in% c("shp", "gpkg")) {
      print("Data is in vector format")
      sf::read_sf(dat)
    } else
        stop(nm, " does not appear to be in one of the common spatial data formats, try reading it directly using e.g. `terra::rast()` or `sf::st_read()`")
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
  
  if(is(dat, "SpatRaster")){
    #create a classification matrix
    class_matrix <- dat_breaks[2:(length(dat_breaks) - 1)] |> 
      (\(x) rep(x, times = rep(2, times = length(x))))() |> 
      append(dat_breaks[length(dat_breaks)]) |> 
      append(dat_breaks[1], after = 0) |> 
      matrix(ncol = 2, byrow = TRUE) |> 
      (\(x) cbind(x, c(1:nrow(x))))()
    
    dat |> 
      terra::classify(class_matrix, include.lowest = TRUE) |>
      terra::segregate() |> 
      (\(x) if(!is.null(classification_names)) stats::setNames(x, classification_names[as.numeric(names(x))]) else x)() 
    
  } else{
    
    dat$classification <- cut(dat[[1]], dat_breaks, labels = classification_names, include.lowest = TRUE) |> droplevels()
    dat$value <- 1
    
    dat_wide <- tidyr::pivot_wider(dat, names_from = "classification", values_from = "value", values_fill = 0, names_sort = TRUE) 
    
    return(dplyr::select(dat_wide, 3:ncol(dat_wide), 2)) #put classification before geometry and drop original values
  }
}
#' Get an sf polygon in lonlat (EPSG 4326) from terra or sf input object
#' 
#' @param spatial_grid `sf` or raster
#'
#' @return `sf` polygons
#'
#' @noRd
polygon_in_4326 <-
  function(spatial_grid) {
    crs_is_4326 <- check_matching_crs(spatial_grid, 4326)
      if (is(spatial_grid, "SpatRaster")) {
        spatial_grid |> 
          terra::as.polygons() |> 
          (\(x) if(crs_is_4326) x else terra::project(x, "epsg:4326"))() |> 
          sf::st_as_sf() |> 
          sf::st_union() |>
          sf::st_sf() |> 
          sf::st_wrap_dateline() |>  
          (\(x) if(sf::st_is_valid(x)) x else sf::st_make_valid(x))()
      } else{
        spatial_grid |> 
          (\(x) if(crs_is_4326) x else sf::st_transform(x, 4326))() |>  
          sf::st_union() |> 
          sf::st_sf() |> 
          sf::st_wrap_dateline() |> 
          (\(x) if(sf::st_is_valid(x)) x else sf::st_make_valid(x))()
      }
  }

#' Remove empty layers in spatial object
#'
#' @description
#' Removes any layers (`terra::rast` object) or columns (`sf` object) that are all zero or NA 
#' 
#' @param dat `sf` or `terra::rast` object
#'
#' @return `sf` or `terra::rast` depending on input
#'
#' @export
remove_empty_layers <- function(dat){
  if(is(dat, "sf")){
    column_sums <- colSums(sf::st_drop_geometry(dat), na.rm = TRUE)
    
    if(sum(column_sums) == 0){
      stop("Only NAs and/ or zeroes in sf object")
    }else dplyr::select(dat, which(!column_sums %in% 0))
    
  }else{
    index_true_false  <- (terra::global(dat, "sum", na.rm = TRUE) >0)
    
    if(all(index_true_false %in% c(NA, FALSE))) {
      stop("Only NAs and/ or zeroes in raster")
    } else terra::subset(dat, which(index_true_false))  
  }
}

# Helper functions for tests

#' Get a grid for Bermuda's EEZ in local equal area projection
#'
#' @param resolution `numeric` grid cell width in kilometres
#' @param output `character` the desired output format, either "raster",
#'   "sf_square" (vector), or "sf_hex" (vector); default is "raster"
#'
#' @returns Grid for Bermuda's EEZ in local equal area projection and specified
#'   format and cell size
#' 
#' @noRd
get_bermuda_grid <- function(resolution = 20, output = "raster") {
  get_grid(boundary = get_boundary(name = "Bermuda"), 
           crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs',
           resolution = resolution*1e3, 
           output = output)
}

#' Get a grid for Kiribati's EEZ in local equal area projection
#'
#' @param resolution `numeric` grid cell width in kilometres
#' @param output `character` the desired output format, either "raster",
#'   "sf_square" (vector), or "sf_hex" (vector); default is "raster"
#'
#' @returns Grid for Kiribati's EEZ in local equal area projection and specified
#'   format and cell size
#' 
#' @noRd
get_kiribati_grid <- function(resolution = 50, output = "raster") {
  get_grid(boundary = get_boundary(name = "Kiribati", country_type = "sovereign"),
           crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
           resolution = resolution*1e3, 
           output = output,
           touches = TRUE
          )
}
