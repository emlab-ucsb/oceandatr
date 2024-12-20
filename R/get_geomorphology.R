#' Get seafloor geomorphology data
#' 
#' @description Get geomorphological data for a spatial grid or polygon
#' 
#' @details Geomorphological features are from the [Harris et al. 2014](https://doi.org/10.1016/j.margeo.2014.01.011) dataset, available at [https://www.bluehabitats.org](https://www.bluehabitats.org). Data is included in this package, except depth classification features which can be created using `get_bathymetry()` and seamounts which can be retrieved from a more recent dataset using `get_seamounts()`. List of features:
#' 
#' \itemize{
#' \item Abyssal hills
#' \item Abyssal plains
#' \item Basins: 
#'    \itemize{
#'    \item large basins of seas and oceans
#'    \item major ocean basins
#'    \item perched on the shelf
#'    \item perched on the slope
#'    \item small basins of seas and oceans
#'    }
#' \item Bridges
#' \item Canyons:
#'    \itemize{
#'    \item blind
#'    \item shelf incising
#'    } 
#' \item Escarpments
#' \item Fans
#' \item Glacial troughs
#' \item Guyots
#' \item Plateaus
#' \item Ridges
#' \item Rift valleys
#' \item Rises
#' \item Shelf valleys:
#'    \itemize{
#'    \item large shelf valleys and glacial troughs
#'    \item moderate size
#'    \item small
#'    }
#' \item Sills
#' \item Spreading ridges
#' \item Terraces
#' \item Trenches
#' \item Troughs
#' }
#'
#' @inheritParams get_bathymetry
#'
#' @return For gridded data, a multi-layer raster object, or an `sf` object with geomorphology class in each column, depending on the `spatial_grid` format. If `raw = TRUE` an `sf` object with each row as a different geomorphological feature.
#' @export
#'
#' @examples
#' # Grab EEZ data first 
#' bermuda_eez <- get_boundary(name = "Bermuda")
#' # Get geomorphology for the EEZ
#' bermuda_geomorph <- get_geomorphology(spatial_grid = bermuda_eez, raw = TRUE)
#' plot(bermuda_geomorph)
#' # Get geomorphological features in spatial_grid
#' bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 20000)
#' geomorph_gridded <- get_geomorphology(spatial_grid = bermuda_grid)
get_geomorphology <- function(spatial_grid = NULL, raw = FALSE, antimeridian = NULL){
  
  check_grid(spatial_grid)
  
  meth <- if(check_raster(spatial_grid)) 'near' else 'mode'
  
  sf::sf_use_s2(FALSE)
  suppressWarnings(
    geomorph_data <- system.file("extdata/geomorphology", package = "oceandatr") %>% 
      list.files() %>% 
      system.file("extdata/geomorphology", ., package = "oceandatr") %>% 
      lapply(readRDS) %>% 
      do.call(rbind, .) %>%
      get_data_in_grid(spatial_grid = spatial_grid, dat = ., raw = raw, meth = meth, feature_names = "geomorph_type", antimeridian = antimeridian)
  )
  
  sf::sf_use_s2(TRUE)
  
  return(geomorph_data)
}
