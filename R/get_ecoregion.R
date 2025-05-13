#' Get ecoregions
#'
#' @description Gets ecoregion data for a spatial grid or polygon
#'
#' @details The Following ecoregions can be obtained:
#' * Marine Ecosystems of the World [dataset](https://www.worldwildlife.org/publications/marine-ecoregions-of-the-world-a-bioregionalization-of-coastal-and-shelf-areas)
#' * [Longhurst Provinces](https://www.sciencedirect.com/book/9780124555211/ecological-geography-of-the-sea?via=ihub=)
#' * [Large Marine Ecosystems of the World](http://geonode.iwlearn.org/layers/geonode:lmes)
#' * [Mesopelagic Ecoregions](https://www.sciencedirect.com/science/article/pii/S0967063717301437?via%3Dihub)
#'
#'   All data are downloaded via the [Marine Regions
#'   website](https://marineregions.org/sources.php)
#'
#' @inheritParams get_bathymetry
#' @param type `character` which ecoregion type is required? Default is
#'   `\"MEOW\"` (Marine Ecosystems of the World); other possible values are
#'   `\"Longhurst\"`, `\"LME\"`, and `\"meso\"`
#'
#' @return For gridded data, a multi-layer raster object, or an `sf` object
#'   depending on the `spatial_grid` format. If `raw = TRUE` an `sf` object of
#'   the Ecoregion.
#' @export
#'
#' @examples
#' #' # Get EEZ data first
#' bermuda_eez <- get_boundary(name = "Bermuda")
#' # Get Marine Ecoregions of the World data
#' ecoregions <- get_ecoregion(spatial_grid = bermuda_eez, raw = TRUE)
#' # Get Longhurst Provinces in a spatial grid
#' bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 20000)
#' longhurst_gridded <- get_ecoregion(spatial_grid = bermuda_grid, type = "Longhurst")
get_ecoregion <- function(spatial_grid = NULL, raw = FALSE, type = "MEOW", antimeridian = NULL){
  
  rlang::check_installed("mregions2", reason = "to get Ecoregions data using `get_ecoregion()`", action = function(pkg, ...) remotes::install_github("lifewatch/mregions2"))
  
  check_grid(spatial_grid)
  
  no_sf_cols <- if(check_sf(spatial_grid)) ncol(spatial_grid)-1
  
  marine_ecoregions <- NULL
  
  if(type == "MEOW"){
    type <- "ecoregions"
    col_name <- "ecoregion"
  } else if(type == "Longhurst"){
    type <- "longhurst"
    col_name <- "provdescr"
  } else if(type == "LME"){
    type <- "lme"
    col_name <- "lme_name"
  } else if(type == "meso"){
    marine_ecoregions <- sf::st_read("https://geo.vliz.be/geoserver/wfs?request=getfeature&service=wfs&version=1.1.0&typename=MarineRegions:mesopelagiczones&outputformat=json")
    col_name <- "provname"
  }else message("type must be one of MEOW, Longhurst, LME or meso.")

  if(is.null(marine_ecoregions))  marine_ecoregions <- mregions2::mrp_get(type)
  
  sf::sf_use_s2(FALSE)
 ecoregion_data <- get_data_in_grid(spatial_grid = spatial_grid, dat = marine_ecoregions, raw = raw, antimeridian = antimeridian, feature_names = col_name)
 
 if(!raw){
   if(check_sf(ecoregion_data)){
     ecoregion_data <- ecoregion_data %>% 
       remove_empty_layers() %>% 
       {if((ncol(.)-no_sf_cols) >1) . else dplyr::mutate(., ecoregion = 0, .after = no_sf_cols)}
   }else{
     if(sum(terra::global(ecoregion_data, "sum", na.rm = TRUE)$sum)>0){
        ecoregion_data <- remove_empty_layers(ecoregion_data)
     }else{
       ecoregion_data <- spatial_grid %>% 
         terra::subst(1, 0) %>% 
         setNames("ecoregion")
     }
   }
 }
  sf::sf_use_s2(TRUE)
  return(ecoregion_data)
}