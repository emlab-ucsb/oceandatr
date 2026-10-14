# Internal helper for downloading gridded data subsets from an ERDDAP server
# (used for Bio-Oracle, https://erddap.bio-oracle.org/erddap/).
#
# ERDDAP griddap request format:
#   {base_url}griddap/{dataset_id}.nc?{variable}[(time_start):stride:(time_stop)][(lat_start):stride:(lat_stop)][(lon_start):stride:(lon_stop)]
# Dimensions must be given in the order they have in the dataset; for the
# Bio-Oracle datasets used here this is time, latitude, longitude.
# See https://erddap.bio-oracle.org/erddap/griddap/documentation.html

#' Download a subset of an ERDDAP gridded dataset as a NetCDF file
#'
#' @param base_url `character` ERDDAP base URL, ending in `/erddap/`
#' @param dataset_id `character` ERDDAP dataset ID
#' @param variable `character` name of the single variable to download
#' @param time `character` vector of length 2: start and stop times, in ISO
#'   8601 format, e.g. `"2010-01-01T00:00:00Z"`. Use the same value twice for a
#'   single time step
#' @param latitude `numeric` vector of length 2: min and max latitude
#' @param longitude `numeric` vector of length 2: min and max longitude
#' @param path `character` folder in which to save the file. Defaults to
#'   `tempdir()`. If a file for the same request already exists there, it is
#'   reused rather than downloaded again
#'
#' @return `character` path to the downloaded (or previously downloaded)
#'   NetCDF file
#' @noRd
get_erddap_griddap <- function(base_url, dataset_id, variable, time, latitude, longitude, path = NULL){
  
  # format numbers without scientific notation or rounding to few digits
  fmt_num <- function(x) format(x, digits = 15, scientific = FALSE, trim = TRUE)
  
  # square brackets are percent-encoded; parentheses and colons are fine as is
  dim_constraint <- function(from, to) paste0("%5B(", from, "):1:(", to, ")%5D")
  
  query <- paste0(
    variable,
    dim_constraint(time[1], time[2]),
    dim_constraint(fmt_num(latitude[1]), fmt_num(latitude[2])),
    dim_constraint(fmt_num(longitude[1]), fmt_num(longitude[2]))
  )
  
  url <- paste0(base_url, "griddap/", dataset_id, ".nc?", query)
  
  # file name encodes the whole request, so a cached file is only reused for
  # an identical request
  file_name <- paste0(
    gsub("[^A-Za-z0-9._-]", "_",
         paste(dataset_id, variable, time[1], time[2],
               fmt_num(latitude[1]), fmt_num(latitude[2]),
               fmt_num(longitude[1]), fmt_num(longitude[2]), sep = "_")),
    ".nc")
  
  path <- if(is.null(path)) tempdir() else path
  if(!dir.exists(path)) dir.create(path, recursive = TRUE)
  file_path <- file.path(path, file_name)
  
  if(file.exists(file_path)) return(file_path)
  
  # Download to a temporary name and only rename on success, so that an
  # interrupted download (e.g. user hits stop) can't leave a partial file that
  # a later call would treat as a complete cached file
  partial_path <- paste0(file_path, ".part")
  on.exit(unlink(partial_path), add = TRUE)
  
  oceandatr_download_file(url, partial_path, service_name = "Bio-Oracle ERDDAP")
  
  file.rename(partial_path, file_path)
  
  file_path
}