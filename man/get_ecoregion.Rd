% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_ecoregion.R
\name{get_ecoregion}
\alias{get_ecoregion}
\title{Get ecoregions}
\usage{
get_ecoregion(
  spatial_grid = NULL,
  raw = FALSE,
  type = "MEOW",
  antimeridian = NULL
)
}
\arguments{
\item{spatial_grid}{\code{sf} or \code{terra::rast()} grid, e.g. created using
\code{get_grid()}. Alternatively, if raw data is required, an \code{sf} polygon can
be provided, e.g. created using \code{get_boundary()}, and set \code{raw = TRUE}.}

\item{raw}{\code{logical} if TRUE, \code{spatial_grid} should be an \code{sf} polygon, and
the raw data in that polygon(s) will be returned}

\item{type}{\code{character} which ecoregion type is required? Default is
\verb{\\"MEOW\\"} (Marine Ecosystems of the World); other possible values are
\verb{\\"Longhurst\\"}, \verb{\\"LME\\"}, and \verb{\\"meso\\"}}

\item{antimeridian}{Does \code{spatial_grid} span the antimeridian? If so, this
should be set to \code{TRUE}, otherwise set to \code{FALSE}. If set to \code{NULL}
(default) the function will try to check if \code{spatial_grid} spans the
antimeridian and set this appropriately.}
}
\value{
For gridded data, a multi-layer raster object, or an \code{sf} object
depending on the \code{spatial_grid} format. If \code{raw = TRUE} an \code{sf} object of
the Ecoregion.
}
\description{
Gets ecoregion data for a spatial grid or polygon
}
\details{
The Following ecoregions can be obtained:
\itemize{
\item Marine Ecosystems of the World \href{https://www.worldwildlife.org/publications/marine-ecoregions-of-the-world-a-bioregionalization-of-coastal-and-shelf-areas}{dataset}
\item \href{https://www.sciencedirect.com/book/9780124555211/ecological-geography-of-the-sea?via=ihub=}{Longhurst Provinces}
\item \href{http://geonode.iwlearn.org/layers/geonode:lmes}{Large Marine Ecosystems of the World}
\item \href{https://www.sciencedirect.com/science/article/pii/S0967063717301437?via\%3Dihub}{Mesopelagic Ecoregions}

All data are downloaded via the \href{https://marineregions.org/sources.php}{Marine Regions website}
}
}
\examples{
#' # Get EEZ data first
bermuda_eez <- get_boundary(name = "Bermuda")
# Get Marine Ecoregions of the World data
ecoregions <- get_ecoregion(spatial_grid = bermuda_eez, raw = TRUE)
# Get Longhurst Provinces in a spatial grid
bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 20000)
longhurst_gridded <- get_ecoregion(spatial_grid = bermuda_grid, type = "Longhurst")
}
