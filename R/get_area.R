#' Get an a shapefile for the area of interest
#' 
#' This uses the `mrp_get` function from the `mregions2` package to retrieve an area object from Marine Regions (https://marineregions.org/gazetteer.php). You can filter using any column available in the `mregions2` database. To see all possible column names and codes, specify `show_options` = TRUE when you run the function. 
#'
#' @param query_type string; the area type that you would like to query for; some options include "eez", "high_seas", "ecoregions" (default is "eez")
#' @param area_name string; the name of the country or area that you would like to query for; must match a name in `mregions2` for the `mregions_column` selected
#' @param mregions_column string; the name of the column in `mregions2` that you would like to query to find the area corresponding to `area_name` (defaut is "territory1")
#' @param show_options logical; whether to show all of the options available in `mregions2` or not; running this will not query `mregions2` (default is FALSE)
#'
#' @return if `show_options` = FALSE, returns the sf object of the area of interest; if `show_options` = TRUE, a named list will be returned. Names in the list correspond to options for `mregions_column` and values correspond to options for `area_name`
#' @export
#'
#' @examples 
#' # Show all possible EEZ areas
#' get_area(show_options = TRUE)
#' # Get EEZ area just for Bermuda
#' get_area(area_name = "Bermuda")
#' # Get EEZ areas for Kiribati (iso_ter1 = KIR)
#' get_area(area_name = "KIR", mregions_column = "iso_ter1")
get_area <- function(query_type = "eez", area_name, mregions_column = "territory1", show_options = FALSE){
  if(show_options) { 
    cols_available <- mregions2::mrp_colnames(query_type)$column_name
    cols_available <- cols_available[!grepl("geom|area", cols_available)]
    all_options <- purrr::map(.x = cols_available, 
                              .f = ~{mregions2::mrp_col_distinct(query_type, .x)})
    names(all_options) <- cols_available
    return(all_options)
  } else { 
  eez <- eval(parse(text = paste0("mregions2::mrp_get(\"", query_type, "\", cql_filter = \"", mregions_column, " = '", area_name, "'\")")))
  return(eez)
  } 
}
