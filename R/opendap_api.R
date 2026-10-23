# Internal helpers for reading data from an OPeNDAP (DAP2) server using httr2,
# used to download GEBCO bathymetry from the CEDA THREDDS server in
# get_bathymetry().
#
# Why not RNetCDF::var.get.nc()? When reading from an OPeNDAP URL, RNetCDF uses
# the netcdf-c library's own HTTP client. If a data response is cut short (for
# example by an "HTTP/2 framing layer" stream error, which large downloads from
# the CEDA server intermittently suffer from), netcdf-c prints
#   Error:curl error: Stream error in the HTTP/2 framing layer
#   Error:DAP DATADDS packet is apparently too short
# to the console but then returns *successfully*, with the part of the data that
# was not received filled with zeros. No R error is raised, so nothing in R can
# detect it (including `tryCatch()`), and the incomplete chunk is silently
# written to the output as a band of 0 m elevation.
#
# The helpers here make the same requests with httr2 instead, so that:
# * a response that is cut short is an error, which is retried, and the length
#   of every response is checked against what was requested, so incomplete data
#   can never be returned
# * HTTP/1.1 is used, which avoids HTTP/2 stream errors altogether
# * a transfer that stalls is stopped, rather than waiting forever
#
# See https://docs.opendap.org/index.php/DAP2:_Data_Response_Format for the
# format of the response to a DAP2 data request (".dods"): a text header
# (the dataset descriptor), the line "Data:", then the values in XDR format: a
# big-endian count of values (repeated twice) followed by the values, each
# 4 bytes for integer types (including Int16, which is padded to 32 bits) or 8
# bytes for Float64. Multi-dimensional arrays are stored with the last
# dimension varying fastest.

#' Signal an error from the OPeNDAP helpers
#'
#' @param message `character` error message
#' @param transient `logical` if `TRUE` the error class includes
#'   `oceandatr_transient_error`, meaning the same request may succeed if it is
#'   tried again (connection failure, response cut short, server error). If
#'   `FALSE`, retrying would not help (e.g. an invalid request)
#'
#' @noRd
opendap_abort <- function(message, transient = FALSE){
  stop(structure(
    class = c(if(transient) "oceandatr_transient_error", "error", "condition"),
    list(message = message, call = NULL)
  ))
}

#' Make a request to an OPeNDAP server and return the response body
#'
#' @param url `character` full request URL
#' @param service_name `character` human-readable name of the service for
#'   messages
#' @param service_url `character` URL shown in connection error messages
#' @param stall_timeout `numeric` seconds. A transfer is stopped if the transfer
#'   rate stays below 1 kB/s for this long. There is deliberately no limit on
#'   the total time a transfer can take, as long as data keeps arriving
#'
#' @return `raw` vector, the response body
#' @noRd
opendap_request_raw <- function(url, service_name, service_url = url, stall_timeout = 120){

  resp <- tryCatch(
    with_friendly_download_error(
      httr2::request(url) |>
        httr2::req_user_agent(oceandatr_user_agent) |>
        # http_version = 2 is libcurl's CURL_HTTP_VERSION_1_1, i.e. force HTTP/1.1
        httr2::req_options(connecttimeout = 15,
                           http_version = 2L,
                           low_speed_limit = 1000,
                           low_speed_time = stall_timeout) |>
        httr2::req_error(is_error = function(resp) FALSE) |>
        httr2::req_perform(),
      service_name = service_name,
      service_url = service_url
    ),
    error = function(e) opendap_abort(conditionMessage(e), transient = TRUE)
  )

  if(httr2::resp_is_error(resp)){
    status <- httr2::resp_status(resp)
    # DAP2 servers report errors as text: Error { code = 2; message = "..."; };
    server_msg <- tryCatch(httr2::resp_body_string(resp), error = function(e) "")
    server_msg <- trimws(gsub("\\s+", " ", substr(server_msg, 1, 400)))

    opendap_abort(
      paste0(service_name, " returned HTTP ", status, " (", httr2::resp_status_desc(resp),
             ") for the request:\n", url,
             if(nzchar(server_msg)) paste0("\nServer message: ", server_msg) else ""),
      transient = status >= 500
    )
  }

  httr2::resp_body_raw(resp)
}

#' Extract the values from the body of an OPeNDAP data response
#'
#' Checks that the response is complete and is what was asked for. A response
#' that is cut short is flagged as a transient error (trying again may work). A
#' response that has a different number of values than requested is not, as it
#' means the dataset is not what the code expects, and trying again won't help.
#'
#' @param body `raw` response body from [opendap_request_raw()]
#' @param n_values `numeric` number of values that were requested
#' @param type `character` `"integer"` for Int16/Int32 variables or `"double"`
#'   for Float64
#'
#' @return `integer` or `numeric` vector of length `n_values`. For arrays, values
#'   are in the order the last dimension varies fastest
#' @noRd
opendap_parse_values <- function(body, n_values, type = c("integer", "double")){

  type <- match.arg(type)
  bytes_per_value <- if(type == "integer") 4L else 8L

  data_marker <- charToRaw("\nData:\n")
  marker_start <- grepRaw(data_marker, body, fixed = TRUE)

  if(length(marker_start) == 0){
    start_of_response <- trimws(gsub("\\s+", " ", rawToChar(body[seq_len(min(300, length(body)))])))
    # a response that starts like a dataset descriptor but ends before the data was cut short
    opendap_abort(paste0("The response was not a DAP2 data response. Start of response: ", start_of_response),
                  transient = startsWith(start_of_response, "Dataset {"))
  }

  # position of the first byte of the data, after the 'Data:' line
  data_start <- marker_start + length(data_marker)

  if(length(body) < data_start + 7){
    opendap_abort("incomplete data received: the response ended before the data started", transient = TRUE)
  }

  # the number of values is given twice, before the values
  counts <- readBin(body[data_start:(data_start + 7)], what = "integer", n = 2, size = 4, endian = "big")

  if(counts[1] != counts[2] || counts[1] != n_values){
    opendap_abort(sprintf(paste0("the server has %s values for this request but %s were expected. ",
                                 "The dataset may have changed since this version of the package was written"),
                          format(counts[1], big.mark = ",", scientific = FALSE),
                          format(n_values, big.mark = ",", scientific = FALSE)))
  }

  expected_length <- data_start - 1 + 2 * 4 + n_values * bytes_per_value

  if(length(body) != expected_length){
    opendap_abort(
      sprintf("incomplete data received: expected %s bytes but received %s (%.1f%%)",
              format(expected_length, big.mark = ",", scientific = FALSE),
              format(length(body), big.mark = ",", scientific = FALSE),
              100 * length(body) / expected_length),
      transient = TRUE)
  }

  con <- rawConnection(body, "rb")
  on.exit(close(con), add = TRUE)
  seek(con, where = data_start - 1 + 8)

  readBin(con, what = type, n = n_values, size = bytes_per_value, endian = "big")
}

#' Run a download function, trying again if it fails because of a transient error
#'
#' Only errors flagged as transient (see [opendap_abort()]) are retried;
#' any other error is raised immediately.
#'
#' @param fun function with no arguments that does the download
#' @param max_attempts `numeric` maximum number of times to try
#' @param wait function of the attempt number that gives the seconds to wait
#'   before trying again
#' @param description `character` what is being downloaded, for messages
#' @param service_name `character` name of the service, for the error message
#' @param service_url `character` URL of the service, for the error message
#'
#' @return the value returned by `fun`
#' @noRd
opendap_retry <- function(fun, max_attempts = 3, wait = function(attempt) 2^attempt,
                          description, service_name, service_url){

  for(attempt in seq_len(max_attempts)){

    result <- tryCatch(fun(), error = function(e) e)

    if(!inherits(result, "error")) return(result)

    # errors that retrying won't help with
    if(!inherits(result, "oceandatr_transient_error")) stop(result)

    reason <- conditionMessage(result) |>
      sub("(?s)^.*Underlying error: ", "", x = _, perl = TRUE) |>
      gsub("\\s+", " ", x = _) |>
      substr(1, 250)

    if(attempt == max_attempts){
      stop(
        "Could not download data from ", service_name, " (", service_url, ") after ",
        max_attempts, " attempts.\n",
        "Please check your internet connection, and that the service is not ",
        "blocked by a firewall, VPN, or proxy, and is not currently down.\n",
        "Underlying error: ", reason,
        call. = FALSE
      )
    }

    message(description, " failed: ", reason, "\nTrying again (attempt ", attempt + 1, " of ", max_attempts, ")")
    Sys.sleep(wait(attempt))
  }
}

#' Read values from an OPeNDAP (DAP2) dataset
#'
#' @param dataset_url `character` URL of the dataset, e.g. ending in `.nc`
#' @param constraint `character` DAP2 constraint expression for the data
#'   wanted, e.g. `"lat"`, or `"elevation.elevation[0:9][100:199]"` for the
#'   first 10 rows and the 100th to 199th columns of a grid. Indices are zero
#'   based and, unlike in R, inclusive of the last index
#' @param n_values `numeric` the number of values the constraint selects
#' @param type `character` `"integer"` or `"double"`
#' @param service_name `character` human-readable name of the service, for
#'   messages (also used to describe what is being downloaded if it has to be
#'   tried again)
#' @param service_url `character` URL shown in connection error messages
#' @param max_attempts `numeric` how many times to try the request, if it fails
#'   because of a connection problem, a server error, or because the response
#'   was incomplete
#' @param stall_timeout `numeric` see [opendap_request_raw()]
#' @param wait function of the attempt number giving seconds to wait before
#'   trying again
#'
#' @return `integer` or `numeric` vector of the values requested
#' @noRd
opendap_read_values <- function(dataset_url, constraint, n_values, type = c("integer", "double"),
                                service_name, service_url = dataset_url,
                                max_attempts = 3, stall_timeout = 120, wait = function(attempt) 2^attempt){

  type <- match.arg(type)

  url <- paste0(dataset_url, ".dods?", gsub("]", "%5D", gsub("[", "%5B", constraint, fixed = TRUE), fixed = TRUE))

  opendap_retry(
    function() opendap_parse_values(
      opendap_request_raw(url, service_name = service_name, service_url = service_url, stall_timeout = stall_timeout),
      n_values = n_values, type = type),
    max_attempts = max_attempts,
    wait = wait,
    description = service_name,
    service_name = service_name,
    service_url = service_url
  )
}

#' Get the type and dimensions of an array variable of an OPeNDAP dataset
#'
#' Read from the dataset descriptor (DDS), a small text response, so that the
#' size of a dataset doesn't have to be written into the code, and so that the
#' assumptions that the code makes about the dataset can be checked.
#'
#' @param dataset_url `character` URL of the dataset, e.g. ending in `.nc`
#' @param variable `character` name of the variable, e.g. `"elevation"`
#' @inheritParams opendap_read_values
#'
#' @return `list` with `type` (e.g. `"Int16"`) and `dims`, a named integer
#'   vector of the size of each dimension, in the order they are in the dataset,
#'   e.g. `c(lat = 43200, lon = 86400)`
#' @noRd
opendap_array_info <- function(dataset_url, variable, service_name, service_url = dataset_url,
                               max_attempts = 3, wait = function(attempt) 2^attempt){

  dds <- opendap_retry(
    function() rawToChar(opendap_request_raw(paste0(dataset_url, ".dds"), service_name, service_url)),
    max_attempts = max_attempts, wait = wait,
    description = service_name, service_name = service_name, service_url = service_url)

  # e.g. "Int16 elevation[lat = 43200][lon = 86400];"
  declaration <- regmatches(
    dds,
    regexec(paste0("\\b(Byte|U?Int16|U?Int32|Float32|Float64)\\s+", variable, "((?:\\[[^]]+\\])+)\\s*;"), dds, perl = TRUE)
  )[[1]]

  if(length(declaration) == 0){
    stop(service_name, " has no variable called '", variable, "' (or it is not an array). ",
         "The dataset may have changed since this version of the package was written.", call. = FALSE)
  }

  dimensions <- regmatches(declaration[3], gregexpr("\\[[^]]+\\]", declaration[3]))[[1]] |>
    gsub("[][ ]", "", x = _)

  list(type = declaration[2],
       dims = stats::setNames(as.integer(sub("^.*=", "", dimensions)), sub("=.*$", "", dimensions)))
}
