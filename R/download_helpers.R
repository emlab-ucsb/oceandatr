# Shared helpers for downloading data from external services (Marine
# Regions, GEBCO/CEDA, Bio-Oracle/ERDDAP, Natural Earth, World Port Index,
# Global Fishing Watch), used by get_boundary(), get_ecoregion(),
# get_bathymetry(), get_dist(), and get_enviro_zones(). Centralising this
# here means every download in the package fails in the same, informative
# way: a quick, clear error if the service can't be reached at all, and a
# clear error (including the HTTP status where relevant) if the service
# returns an error - rather than each function surfacing whatever raw,
# often quite technical, error its own underlying tool (httr2, RNetCDF or
# utils::download.file) happens to throw.
#
# Only the *connection* step (DNS lookup + TCP/TLS handshake) is time
# limited (`connecttimeout`); there is deliberately no limit on total
# transfer time, since some of the datasets used by oceandatr are large
# and can legitimately take a long time to download once a connection is
# established.

oceandatr_user_agent <- "oceandatr (https://github.com/emlab-ucsb/oceandatr)"

#' Run a download/request expression, with a consistent, friendlier error
#'
#' Wraps an expression that performs a download or API request, catching
#' any error and re-throwing it with a consistent, more actionable message
#' that names the service involved, while preserving the underlying error
#' for debugging. Use this to wrap the specific call that does the network
#' I/O (e.g. a single `httr2::req_perform()`, `RNetCDF::open.nc()`, or
#' `RNetCDF::var.get.nc()` call), not a large block of unrelated code.
#'
#' @param expr expression that performs the download/request
#' @param service_name `character` short human-readable name of the
#'   service, shown in the error message, e.g. `"GEBCO bathymetry (CEDA
#'   THREDDS)"`
#' @param service_url `character` the URL being requested, shown in the
#'   error message so the user can check it themselves (e.g. in a browser)
#'
#' @return the result of evaluating `expr`, if successful
#' @noRd
with_friendly_download_error <- function(expr, service_name, service_url){
  tryCatch(
    expr,
    error = function(e){
      stop(
        "Could not download data from ", service_name, " (", service_url, ").\n",
        "Please check your internet connection, and that the service is not ",
        "blocked by a firewall, VPN, or proxy, and is not currently down.\n",
        "Underlying error: ", conditionMessage(e),
        call. = FALSE
      )
    }
  )
}

#' Download a file from a URL to disk, with connection/HTTP error checking
#'
#' Common replacement for `utils::download.file()` used across oceandatr's
#' `get_*()` functions. Uses `httr2` so that download failures get the
#' same informative error handling as the rest of the package: a quick,
#' clear error if the host can't be reached, and a clear error, including
#' the HTTP status, if the server returns an error - regardless of how
#' large the file is or how long the download takes (only the connection
#' step has a time limit, not the full transfer).
#'
#' @param url `character` file URL to download
#' @param destfile `character` file path to save the downloaded file to
#' @param service_name `character` human-readable service name, used in
#'   error messages, e.g. `"Natural Earth"`
#'
#' @return `character` `destfile`, invisibly, on success
#' @noRd
oceandatr_download_file <- function(url, destfile, service_name = "the remote server"){
  
  resp <- with_friendly_download_error(
    httr2::request(url) |>
      httr2::req_user_agent(oceandatr_user_agent) |>
      httr2::req_options(connecttimeout = 15) |>
      httr2::req_error(is_error = function(resp) FALSE) |>
      httr2::req_perform(path = destfile),
    service_name = service_name,
    service_url = url
  )
  
  if(httr2::resp_is_error(resp)){
    # On an HTTP error the response body (an HTML/text/JSON error page) has
    # been written to destfile. Read the start of it so any message from the
    # server can be reported, then delete it so it isn't left behind looking
    # like data.
    server_msg <- tryCatch(
      paste(readLines(destfile, n = 10, warn = FALSE), collapse = " "),
      error = function(e) ""
    )
    unlink(destfile)
    # ERDDAP servers report errors as: message="..." 
    erddap_msg <- regmatches(server_msg, regexpr('(?<=message=").*?(?=";)', server_msg, perl = TRUE))
    if(length(erddap_msg) > 0) server_msg <- erddap_msg
    server_msg <- trimws(substr(server_msg, 1, 500))
    stop(
      service_name, " returned HTTP ", httr2::resp_status(resp),
      " (", httr2::resp_status_desc(resp), ") for the request:\n", url,
      if(nzchar(server_msg)) paste0("\nServer message: ", server_msg) else "",
      if(httr2::resp_status(resp) >= 500) "\nThe service may be temporarily down; try again later." else "",
      call. = FALSE
    )
  }
  
  if(!file.exists(destfile) || file.info(destfile)$size == 0){
    unlink(destfile)
    stop("Download from ", service_name, " (", url, ") appears to have failed: ",
         "no data was written to disk.", call. = FALSE)
  }
  
  invisible(destfile)
}
