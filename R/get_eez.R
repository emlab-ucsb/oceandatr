#' Get an EEZ for a country of interest
#' 
#' This uses the `mrp_get` function from the `mregions2` package to retrieve an EEZ object from Marine Regions (https://marineregions.org/gazetteer.php). You can filter using any column available in the `mregions2` database. To see all possible column names and codes, specify `show_options` = TRUE when you run the function. 
#'
#' @param query_type string; the area type that you would like to query for; some options include "eez", "high seas", "ecoregions" (default is "eez")
#' @param area_name string; the name of the country or area that you would like to query for; must match a name in `mregions2` for the `mregions_column` selected
#' @param mregions_column string; the name of the column in `mregions2` that you would like to query to find the area corresponding to `area_name` (defaut is "territory1")
#' @param show_options logical; whether to show all of the options available in `mregions2` or not; running this will not query `mregions2` (default is FALSE)
#'
#' @return the EEZ as an sf object if `show_options` = FALSE; if `show_options` = TRUE, an sf object with all possible options are returned
#' @export
#'
#' @examples 
#' # Show all possible EEZ areas
#' get_eez(show_options = TRUE)
#' # Get EEZ area just for Bermuda
#' get_eez("Bermuda")
#' # Get EEZ areas for Kiribati (iso_ter1 = KIR)
#' get_eez(area_name = "KIR", mregions_column = "iso_ter1")
get_eez <- function(query_type = "eez", area_name, mregions_column = "territory1", show_options = FALSE){
  if(show_options) { 
    message("Please be patient, this may take some time.")
    return(mregions2::mrp_get(query_type))
  } else { 
  eez <- eval(parse(text = paste0("mregions2::mrp_get(\"", query_type, "\", cql_filter = \"", mregions_column, " = '", area_name, "'\")")))
  return(eez)
  } 
}
