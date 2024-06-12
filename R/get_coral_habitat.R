#' Get coral habitat suitability data
#' 
#' @description This function extracts coral habitat suitability and creates presence (1) or absence (0) grids for three groups of deep-water coral species: antipatharia, cold water corals, and octocorals. 
#' 
#' @details Habitat suitability data are from global Maxent species distribution models for the following species groups: 
#' \itemize{
#' \item Antipatharia: The global extent of black coral habiatat suitability modelled using Maxent. The antipatharia habitat suitability is converted to a presence/absence map "by choosing a threshold value of habitat suitability based on the maximum sum of sensitivity and specificity (threshold mss = 0.23)" (Yesson et al. 2017). This threshold can be altered via the function input. Data from [Yesson et al. 2017](https://doi.org/10.1016/j.dsr2.2015.12.004).
#' \item Cold water corals: The global habitat suitability for five species of Scleractinia modelled using Maxent. Presence defined using Maxent values above the lowest 10 percent of values. Data from [Davies and Guinotte 2011](https://doi.org/10.1371/journal.pone.0018483).
#' \item Octocorals: The global habitat suitability modelled for 7 species of cold-water octocoral found deeper than 50m. Data from and described in [Yesson et al. 2012](https://doi.org/10.1111/j.1365-2699.2011.02681.x): "A consensus/summary map incorporating all seven octocoral suborders was constructed by generating binary presence/absence maps from the model outputs indicating areas of high suitability using a score threshold that maximized the sum of the specificity and sensitivity based on the validation data (Carroll, 2010). These binary layers were summed to generate a layer containing the number of octocoral suborders predicted to be present per cell."
#' }
#' 
#' @param spatial_grid `sf` or `terra::rast()` grid, e.g. created using `get_grid()`. Alternatively, if raw data is required, an `sf` polygon can be provided, e.g. created using `get_boundary()`, and set `raw = TRUE`.
#' @param raw `logical` if TRUE, `spatial_grid` should be an `sf` polygon, and the raw coral data in that polygon(s) will be returned
#' @param antipatharia_threshold `numeric` between 0 and 100; the threshold value for habitat suitability for antipatharia corals to be considered present (default is 22, as defined in Yesson et al., 2017)
#' @param octocoral_threshold `numeric` between 0 and 7; the threshold value for how many species (of 7) should be predicted present in an area for octocorals to be considered present (default is 2)
#' @param antimeridian Does `spatial_grid` span the antimeridian? If so, this should be set to `TRUE`, otherwise set to `FALSE`. If set to `NULL` (default) the function will try to check if data spans the antimeridian and set this appropriately.
#'
#' @return If an `area_polygon` is supplied, a raster stack of coral habitat suitability data is returned; note this is the raw habitat suitability/ no. of species values. If a `spatial_grid` is supplied, a raster stack or `sf` of gridded coral habitat presence/ absence data is returned, depending on `spatial_grid` format.
#' @export
#'
#' @examples
#' # Get EEZ data first 
#' bermuda_eez <- get_boundary(name = "Bermuda")
#' # Get raw coral habitat data
#' coral_habitat <- get_coral_habitat(spatial_grid = bermuda_eez, raw = TRUE)
#' # Get gridded coral habitat data
#' bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 10000)
#' bermuda_coral_gridded <- get_coral_habitat(spatial_grid = bermuda_grid)
get_coral_habitat <- function(spatial_grid = NULL, raw = FALSE, antipatharia_threshold = 22, octocoral_threshold = 2, antimeridian = NULL){
 
  check_grid(spatial_grid)
  
  if(!raw){
    # Add errors if the thresholds are not correctly specified
    if(antipatharia_threshold < 0 | antipatharia_threshold > 100) { 
      stop("antipatharia_threshold must be between 0 and 100, as it represents the percent threshold of habitat suitability antipatharia to be considered present")
    }
    if(octocoral_threshold < 1 | octocoral_threshold > 7) { 
      stop("octocoral_threshold must be between 1 and 7, as it represents the number of octocoral species (out of 7) must be present in an area for octocorals as a whole to be considered present")
    }  
  }
  
  # Data message 
  # report_message <- function(coral_data) { 
  #   if (terra::global(eval(as.name(coral_data)), "sum", na.rm = TRUE) < 1) { 
  #     message(paste0("No ", gsub("_", " ", coral_data), "in area of interest. Processing output..."))
  #   } else {
  #     message(paste0("Data found for ", gsub("_", " ", coral_data), ". Processing output...")) 
  #   }
  # }

  antipatharia_global <- system.file("extdata", "YessonEtAl_2016_Antipatharia.tif", package = "oceandatr", mustWork = TRUE) %>%
    terra::rast() %>%
    stats::setNames("antipatharia")

  meth <- if(check_sf(spatial_grid)) "mean" else "average"

  antipatharia <- get_data_in_grid(spatial_grid = spatial_grid, dat = antipatharia_global, name = "antipatharia", meth = meth, antimeridian = antimeridian)
  rm(antipatharia_global)
  
  #same method for cold water corals and octocorals since these are integer values
  meth <- if(check_sf(spatial_grid)) "mode" else "near"

  cold_corals_global <- system.file("extdata", "binary_grid_figure7.tif", package = "oceandatr", mustWork = TRUE) %>%
    terra::rast() %>%
    stats::setNames("cold_corals")

  cold_corals <- get_data_in_grid(area_polygon = area_polygon, spatial_grid = spatial_grid, dat = cold_corals_global, name = "cold_corals", meth = meth, antimeridian = antimeridian)
  rm(cold_corals_global)

  octocorals_global <- system.file("extdata", "YessonEtAl_Consensus.tif", package = "oceandatr", mustWork = TRUE) %>%
    terra::rast() %>%
    stats::setNames("octocorals")

  octocorals <- get_data_in_grid(area_polygon = area_polygon, spatial_grid = spatial_grid, dat = octocorals_global, name = "octocorals", meth = meth, antimeridian = antimeridian)
  rm(octocorals_global)

  if(!is.null(area_polygon)){
    c(antipatharia, cold_corals, octocorals) %>% 
      terra::subset(which(terra::global(., "sum", na.rm = TRUE) >0))
  }else{
    antipatharia_breaks <- c(0, antipatharia_threshold, 100)
    antipatharia_class_names <- c(NA, "antipatharia_coral")
    
    cold_corals_breaks <- c(0, 0.5, 1.1)
    cold_corals_class_names <- c(NA, "cold_coral")
    
    octocoral_breaks <- c(0, octocoral_threshold, 8)
    octocoral_class_names <- c(NA, "octocoral")
    
    antipatharia <- classify_layers(dat = antipatharia, dat_breaks = antipatharia_breaks, classification_names = antipatharia_class_names)

    cold_corals <- classify_layers(dat = cold_corals, dat_breaks = cold_corals_breaks, classification_names = cold_corals_class_names) 

    octocorals <- classify_layers(dat = octocorals, dat_breaks = octocoral_breaks, classification_names = octocoral_class_names) 
    
    coral_layer_names <- c(antipatharia_class_names[2], cold_corals_class_names[2], octocoral_class_names[2])

    if(check_raster(antipatharia)){
      c(antipatharia, cold_corals, octocorals) %>%
        {if(any(names(.) %in% coral_layer_names)) . else stop("No coral habitat within the planning grid.")} %>% 
        terra::subset(which(names(.) %in% coral_layer_names)) %>% 
        terra::subset(which(terra::global(., "sum", na.rm = TRUE) >0))
    }else{
      cbind(antipatharia, sf::st_drop_geometry(cold_corals), sf::st_drop_geometry(octocorals)) %>% 
        {if(any(colnames(.) %in% coral_layer_names))  dplyr::select(., tidyselect::any_of(coral_layer_names)) else stop("No coral habitat within the planning grid.")}%>% 
        sf::st_sf()
    }
  }
}
