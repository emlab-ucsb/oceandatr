#' Get an EEZ for a country of interest
#' 
#' This uses the `mr_gaz_records_by_name` and `mr_gaz_record` functions from the `mregions2` package to retrieve an EEZ object from the Marine Gazeeter (https://marineregions.org/gazetteer.php). Note that the EEZ name is often different to the country name, e.g. use "Bermudian" to get Bermuda's EEZ; see https://marineregions.org/gazetteer.php?p=search for a list of EEZ names
#'
#' @param country_name The name of the EEZ of interest
#'
#' @return The EEZ as an sf object
#' @export
#'
#' @examples get_eez("bermudian")
get_eez <- function(country_name){
  eez_mrgid <- mregions2::mr_gaz_records_by_name(country_name) %>% 
    dplyr::filter(status != "deleted") %>% 
    dplyr::filter(placeType == "EEZ") %>% 
    #still might be multiple EEZ entries, so filtering for the one with the greatest spatial coverage which should be the complete EEZ
    dplyr::slice(which.min(minLatitude)) %>% 
    dplyr::pull(MRGID)
  
  eez <- mregions2::mr_gaz_record(eez_mrgid)
  
  return(eez)
}