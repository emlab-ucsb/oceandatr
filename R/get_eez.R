#' Get an EEZ for a country of interest
#' 
#' This uses the `mrp_get` function from the `mregions2` package to retrieve an EEZ object from Marine Regions (https://marineregions.org/gazetteer.php). For a full list of EEZs available, use `marineregions2::mrp_col_unique("eez", "territory1")`
#'
#' @param country_name The name of the EEZ of interest
#'
#' @return The EEZ as an sf object
#' @export
#'
#' @examples get_eez("Bermuda")
get_eez <- function(country_name){
  eez <- eval(parse(text = paste0("mregions2::mrp_get(\"eez\", cql_filter = \"territory1 = '", country_name, "'\")")))
  
  return(eez)
}