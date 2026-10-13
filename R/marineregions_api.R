# Internal helpers for querying the Marine Regions WFS API directly.
#
# These replace the {mregions2} package (mrp_get() and mrp_col_unique()),
# which was a fairly heavy dependency for what amounts to a couple of WFS
# GetFeature requests against https://geo.vliz.be/geoserver. See
# https://marineregions.org/sources.php and the "seas_oceans"/"meso" ecoregion
# handling in get_ecoregion.R, which already used this pattern.
#
# See download_helpers.R for the shared connection/HTTP error handling
# (with_friendly_download_error(), oceandatr_user_agent) used here and by
# oceandatr's other get_*() functions.

#' Build a Marine Regions WFS GetFeature request URL
#'
#' @param namespace `character` WFS namespace/workspace, e.g. "MarineRegions"
#'   or "Ecoregions"
#' @param layer `character` WFS layer/type name, e.g. "eez", "goas"
#' @param cql_filter `character` optional CQL filter, e.g.
#'   `"sovereign1 = 'Australia'"`
#' @param propertyname `character` optional single property name to restrict
#'   the response to (used to fetch just one attribute column, with geometry
#'   omitted)
#'
#' @return `character` a full request URL
#' @noRd
mr_wfs_url <- function(namespace, layer, cql_filter = NULL, propertyname = NULL){

  url <- httr2::url_parse("https://geo.vliz.be/geoserver/wfs")
  url$query <- list(
    service = "wfs",
    version = "1.1.0",
    request = "GetFeature",
    typename = paste0(namespace, ":", layer),
    outputformat = "json",
    cql_filter = cql_filter,
    propertyname = propertyname
  )
  httr2::url_build(url)
}

#' Perform a Marine Regions WFS request, with informative errors
#'
#' In addition to the shared connection/HTTP error handling (see
#' [with_friendly_download_error()] in download_helpers.R), this also
#' handles a WFS-specific failure mode: GeoServer reports an invalid WFS
#' request (e.g. an unknown layer or column name) as an XML
#' `ows:ExceptionReport` body, but still with **HTTP 200**, regardless of
#' the requested outputformat - so a 200 status alone doesn't mean the
#' request succeeded, and this has to be checked for explicitly, or it
#' gets handed to `sf::st_read()`/`jsonlite::fromJSON()` downstream, which
#' fail with an unhelpful, unrelated-looking error.
#'
#' @param url `character` full request URL, from [mr_wfs_url()]
#'
#' @return `character` the response body (as text)
#' @noRd
mr_perform_request <- function(url){

  resp <- with_friendly_download_error(
    httr2::request(url) |>
      httr2::req_user_agent(oceandatr_user_agent) |>
      httr2::req_options(connecttimeout = 15) |>
      httr2::req_error(is_error = function(resp) FALSE) |>
      httr2::req_perform(),
    service_name = "the Marine Regions data service",
    service_url = "https://marineregions.org/"
  )

  if(httr2::resp_is_error(resp)){
    stop(
      "The Marine Regions data service returned HTTP ", httr2::resp_status(resp),
      " (", httr2::resp_status_desc(resp), ") for the request:\n", url,
      "\nThe service may be temporarily down; see https://marineregions.org/ ",
      "or try again later.",
      call. = FALSE
    )
  }

  body <- httr2::resp_body_string(resp)

  # GeoServer reports invalid WFS requests (e.g. an unknown layer or column
  # name) as an XML ows:ExceptionReport in the body, but still with HTTP 200,
  # regardless of the requested outputformat - so a 200 status alone doesn't
  # mean the request succeeded.
  if(grepl("^\\s*<\\?xml", body) && grepl("ExceptionReport", body, fixed = TRUE)){
    exception_text <- regmatches(
      body,
      regexpr("(?<=<ows:ExceptionText>).*?(?=</ows:ExceptionText>)", body, perl = TRUE)
    )
    stop(
      "The Marine Regions data service rejected the request: ",
      if(length(exception_text) > 0 && nzchar(exception_text)) exception_text else "unknown error",
      "\nRequest URL: ", url,
      call. = FALSE
    )
  }

  body
}

#' Get a Marine Regions data product
#'
#' Direct replacement for `mregions2::mrp_get()`. Downloads a Marine Regions
#' WFS layer (optionally filtered with a CQL filter) as an `sf` object.
#'
#' @param layer `character` WFS layer name, e.g. `"eez"`, `"eez_12nm"`,
#'   `"eez_24nm"`, `"goas"`, `"high_seas"`, `"longhurst"`, `"lme"`,
#'   `"ecoregions"`
#' @param namespace `character` WFS namespace. `"MarineRegions"` for all
#'   layers except the Marine Ecoregions of the World layer (`"ecoregions"`),
#'   which lives in the `"Ecoregions"` namespace
#' @param cql_filter `character` optional CQL filter string
#'
#' @return An `sf` object
#' @noRd
mr_get <- function(layer, namespace = "MarineRegions", cql_filter = NULL){

  url <- mr_wfs_url(namespace = namespace, layer = layer, cql_filter = cql_filter)
  body <- mr_perform_request(url)

  sf::st_read(body, quiet = TRUE, stringsAsFactors = FALSE)
}

#' Get the unique values of a column of a Marine Regions data product
#'
#' Direct replacement for `mregions2::mrp_col_unique()`. Requests just the
#' column of interest (geometry omitted) and returns its sorted unique
#' values.
#'
#' @param layer `character` WFS layer name
#' @param colname `character` column/attribute name to retrieve, e.g.
#'   `"territory1"`, `"sovereign1"`, `"name"`
#' @param namespace `character` WFS namespace, see [mr_get()]
#'
#' @return sorted vector of unique values in `colname`
#' @noRd
mr_col_unique <- function(layer, colname, namespace = "MarineRegions"){

  url <- mr_wfs_url(namespace = namespace, layer = layer, propertyname = colname)
  body <- mr_perform_request(url)

  resp <- jsonlite::fromJSON(body)

  if(length(resp$features) == 0) {
    stop("No features returned for layer '", layer, "', column '", colname, "'. ",
         "Check that both are valid for the Marine Regions WFS service.",
         call. = FALSE)
  }

  sort(unique(resp$features$properties[[colname]]))
}

