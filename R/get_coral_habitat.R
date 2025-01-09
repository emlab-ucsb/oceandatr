#' Get coral habitat suitability data
#'
#' @description This function extracts coral habitat suitability and creates
#'   presence (1) or absence (0) grids for three groups of deep-water coral
#'   species: antipatharia, cold water corals, and octocorals.
#'
#' @details Habitat suitability data are from global Maxent species distribution
#'   models for the following species groups:
#' \itemize{
#' \item Antipatharia: The global extent of black coral habiatat suitability modelled using Maxent. The antipatharia habitat suitability is converted to a presence/absence map "by choosing a threshold value of habitat suitability based on the maximum sum of sensitivity and specificity (threshold mss = 0.23)" (Yesson et al. 2017). This threshold can be altered via the function input. Data from [Yesson et al. 2017](https://doi.org/10.1016/j.dsr2.2015.12.004).
#' \item Cold water corals: The global habitat suitability for five species of Scleractinia modelled using Maxent. Presence defined using Maxent values above the lowest 10 percent of values. Data from [Davies and Guinotte 2011](https://doi.org/10.1371/journal.pone.0018483).
#' \item Octocorals: The global habitat suitability modelled for 7 species of cold-water octocoral found deeper than 50m. Data from and described in [Yesson et al. 2012](https://doi.org/10.1111/j.1365-2699.2011.02681.x): "A consensus/summary map incorporating all seven octocoral suborders was constructed by generating binary presence/absence maps from the model outputs indicating areas of high suitability using a score threshold that maximized the sum of the specificity and sensitivity based on the validation data (Carroll, 2010). These binary layers were summed to generate a layer containing the number of octocoral suborders predicted to be present per cell."
#' }
#'
#' @inheritParams get_bathymetry
#' @param antipatharia_threshold `numeric` between 0 and 100; the threshold
#'   value for habitat suitability for antipatharia corals to be considered
#'   present (default is 22, as defined in Yesson et al., 2017)
#' @param octocoral_threshold `numeric` between 0 and 7; the threshold value for
#'   how many species (of 7) should be predicted present in an area for
#'   octocorals to be considered present (default is 2)
#'
#' @return If an `area_polygon` is supplied, a raster stack of coral habitat
#'   suitability data is returned; note this is the raw habitat suitability/ no.
#'   of species values. If a `spatial_grid` is supplied, a raster stack or `sf`
#'   of gridded coral habitat presence/ absence data is returned, depending on
#'   `spatial_grid` format.
#' @export
#'
#' @examples
#' # Get EEZ data first
#' bermuda_eez <- get_boundary(name = "Bermuda")
#' # Get raw coral habitat data
#' coral_habitat <- get_coral_habitat(spatial_grid = bermuda_eez, raw = TRUE)
#' terra::plot(coral_habitat)
#' # Get gridded coral habitat data
#' bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea
#' +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs',
#' resolution = 10000)
#' bermuda_coral_gridded <- get_coral_habitat(spatial_grid = bermuda_grid)
#' terra::plot(bermuda_coral_gridded)
get_coral_habitat <- function(spatial_grid = NULL, raw = FALSE, antipatharia_threshold = 22, octocoral_threshold = 2, antimeridian = NULL){
 
  check_grid(spatial_grid)
  
  is_sf_grid <- check_sf(spatial_grid)
  
  if(!raw){
    # Add errors if the thresholds are not correctly specified
    if(antipatharia_threshold < 0 | antipatharia_threshold > 100) { 
      stop("antipatharia_threshold must be between 0 and 100, as it represents the percent threshold of habitat suitability antipatharia to be considered present")
    }
    if(octocoral_threshold < 1 | octocoral_threshold > 7) { 
      stop("octocoral_threshold must be between 1 and 7, as it represents the number of octocoral species (out of 7) must be present in an area for octocorals as a whole to be considered present")
    }  
  }

  if(is_sf_grid){
    grid_has_extra_cols <- if(ncol(spatial_grid)>1) TRUE else FALSE
    
    if(grid_has_extra_cols) {
      extra_cols <- sf::st_drop_geometry(spatial_grid)
      
      spatial_grid <- spatial_grid %>%
        sf::st_geometry() %>%
        sf::st_sf()
    }
  }
  
  antipatharia_global <- system.file("extdata", "YessonEtAl_2016_Antipatharia.tif", package = "oceandatr", mustWork = TRUE) %>%
    terra::rast() %>%
    stats::setNames("antipatharia")

  meth <- if(is_sf_grid) "mean" else "average"

  antipatharia <- get_data_in_grid(spatial_grid = spatial_grid, dat = antipatharia_global, raw = raw, name = "antipatharia", meth = meth, antimeridian = antimeridian)
  rm(antipatharia_global)
  
  #same method for cold water corals and octocorals since these are integer values
  meth <- if(is_sf_grid) "mode" else "near"

  cold_corals_global <- system.file("extdata", "binary_grid_figure7.tif", package = "oceandatr", mustWork = TRUE) %>%
    terra::rast() %>%
    stats::setNames("cold_corals")

  cold_corals <- get_data_in_grid(spatial_grid = spatial_grid, dat = cold_corals_global, raw = raw, name = "cold_corals", meth = meth, antimeridian = antimeridian)
  rm(cold_corals_global)

  octocorals_global <- system.file("extdata", "YessonEtAl_Consensus.tif", package = "oceandatr", mustWork = TRUE) %>%
    terra::rast() %>%
    stats::setNames("octocorals")

  octocorals <- get_data_in_grid(spatial_grid = spatial_grid, dat = octocorals_global, raw = raw, name = "octocorals", meth = meth, antimeridian = antimeridian)
  rm(octocorals_global)

  if(raw){
    c(antipatharia, cold_corals, octocorals)
  }else{
   if(is_sf_grid){
     dplyr::bind_cols(antipatharia, sf::st_drop_geometry(cold_corals), sf::st_drop_geometry(octocorals)) %>%
       dplyr::mutate(antipatharia = dplyr::case_when(antipatharia < antipatharia_threshold ~ 0,
                                                  antipatharia >= antipatharia_threshold ~ 1),
                     octocorals = dplyr::case_when(octocorals < octocoral_threshold ~ 0,
                                                   octocorals >= octocoral_threshold ~1),
                     .keep = "unused") %>% 
       {if(grid_has_extra_cols) dplyr::bind_cols(extra_cols, .) %>% sf::st_set_geometry("geometry") else .} 
     
   } else{
     antipatharia <- antipatharia %>% 
       terra::classify(matrix(c(0, antipatharia_threshold, 0,
                                antipatharia_threshold, 101, 1),
                              ncol = 3, byrow = TRUE), 
                       right = FALSE)
     
     octocorals <- octocorals %>% 
       terra::classify(matrix(c(0, octocoral_threshold, 0,
                                octocoral_threshold, 9, 1),
                              ncol = 3, byrow = TRUE),
                       right = FALSE)
     
     c(antipatharia, cold_corals, octocorals)
   }
  }
}
