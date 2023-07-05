#' Get an a shapefile for the area of interest
#' 
#' This uses the `mrp_get` function from the `mregions2` package to retrieve an area object (e.g. an EEZ) from Marine Regions (https://marineregions.org/gazetteer.php). You can filter using any column available in the `mregions2` database. To see all possible column names and codes, specify `show_options` = TRUE when you run the function. 
#'
#' @param area_name string; the name of the country or area that you would like to query for; must match a name in `mregions2` for the `mregions_column` selected
#' @param query_type string; the area type that you would like to query for; some options include "eez", "high_seas", "ecoregions". Run `mregions2::mrp_list` to see the full list of data_product options. (default is "eez")
#' @param mregions_column string; the name of the column in `mregions2` that you would like to query to find the area corresponding to `area_name` (default is "territory1")
#' @param show_value_options logical; whether to show all of the value options associated with your `mregions_column` selection that are available in `mregions2`; running this will not return a spatial object (default is FALSE)
#' @param show_column_options logical; whether to show all of the `mregions_column` options that are available in `mregions2`; running this will not return a spatial object (default is FALSE)
#'
#' @return if `show_options` = FALSE, returns the sf object of the area of interest; if `show_value_options` or `show_column_options` == TRUE, a named list will be returned. Names in the list correspond to options for `mregions_column` and values correspond to options for `area_name`
#' @export
#'
#' @examples 
#' # Show all possible column names 
#' get_area(show_column_options = TRUE)
#' # Show all possible EEZ areas
#' get_area(show_value_options = TRUE)
#' # Show all possible options
#' get_area(show_column_options = TRUE, show_value_options = TRUE)
#' # Get EEZ area just for Bermuda
#' get_area(area_name = "Bermuda")
#' # Get EEZ areas for Kiribati (iso_ter1 = KIR)
#' get_area(area_name = "KIR", mregions_column = "iso_ter1")
get_area <- function(area_name, query_type = "eez", mregions_column = "territory1", show_value_options = FALSE, show_column_options = FALSE){
  if(show_column_options) { 
    cols_available <- mregions2::mrp_colnames(query_type)$colname
    if(!show_value_options) { 
      return(list("mregions_column" = cols_available))
    } else { 
      message("Please be patient, this may take some time.")
      cols_available <- cols_available[!grepl("geom|area", cols_available)]
      all_options <- lapply(cols_available, function(x){mregions2::mrp_col_distinct(query_type, x)})
      names(all_options) <- cols_available
      return(all_options)
    }
  } else if (!show_column_options & show_value_options) { 
    if(is.null(mregions_column)) { stop("Please supply an mregions_column argument")}
    value_list <- list(mregions2::mrp_col_distinct(query_type, mregions_column))
    names(value_list) <- mregions_column
    return(value_list)
    } else { 
  eez <- eval(parse(text = paste0("mregions2::mrp_get(\"", query_type, "\", cql_filter = \"", mregions_column, " = '", area_name, "'\")")))
  return(eez)
  } 
}
