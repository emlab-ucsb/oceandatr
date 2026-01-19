# Get ecoregions

Gets ecoregion data for a spatial grid or polygon

## Usage

``` r
get_ecoregion(
  spatial_grid = NULL,
  raw = FALSE,
  type = "MEOW",
  antimeridian = NULL
)
```

## Arguments

- spatial_grid:

  `sf` or
  [`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
  grid, e.g. created using
  [`get_grid()`](https://emlab-ucsb.github.io/spatialgridr/reference/get_grid.html).
  Alternatively, if raw data is required, an `sf` polygon can be
  provided, e.g. created using
  [`get_boundary()`](https://emlab-ucsb.github.io/spatialgridr/reference/get_boundary.html),
  and set `raw = TRUE`.

- raw:

  `logical` if TRUE, `spatial_grid` should be an `sf` polygon, and the
  raw data in that polygon(s) will be returned

- type:

  `character` which ecoregion type is required? Default is `\"MEOW\"`
  (Marine Ecosystems of the World); other possible values are
  `\"Longhurst\"`, `\"LME\"`, and `\"meso\"`

- antimeridian:

  Does `spatial_grid` span the antimeridian? If so, this should be set
  to `TRUE`, otherwise set to `FALSE`. If set to `NULL` (default) the
  function will try to check if `spatial_grid` spans the antimeridian
  and set this appropriately.

## Value

For gridded data, a multi-layer raster object, or an `sf` object
depending on the `spatial_grid` format. If `raw = TRUE` an `sf` object
of the Ecoregion.

## Details

The Following ecoregions can be obtained:

- Marine Ecosystems of the World
  [dataset](https://www.worldwildlife.org/publications/marine-ecoregions-of-the-world-a-bioregionalization-of-coastal-and-shelf-areas)

- [Longhurst
  Provinces](https://www.sciencedirect.com/book/9780124555211/ecological-geography-of-the-sea?via=ihub=)

- [Large Marine Ecosystems of the
  World](http://geonode.iwlearn.org/layers/geonode:lmes)

- [Mesopelagic
  Ecoregions](https://www.sciencedirect.com/science/article/pii/S0967063717301437?via%3Dihub)

  All data are downloaded via the [Marine Regions
  website](https://marineregions.org/sources.php)

## Examples

``` r
#' # Get EEZ data first
bermuda_eez <- get_boundary(name = "Bermuda")
#> Cache is fresh. Reading: /tmp/RtmpdlopUN/eez-2205f12f/eez.shp
#> (Last Modified: 2026-01-19 06:03:00.701614)
# Get Marine Ecoregions of the World data
ecoregions <- get_ecoregion(spatial_grid = bermuda_eez, raw = TRUE)
#> Spherical geometry (s2) switched off
#> although coordinates are longitude/latitude, st_intersection assumes that they
#> are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries
#> Spherical geometry (s2) switched on
# Get Longhurst Provinces in a spatial grid
bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 20000)
longhurst_gridded <- get_ecoregion(spatial_grid = bermuda_grid, type = "Longhurst")
#> Spherical geometry (s2) switched off
#> although coordinates are longitude/latitude, st_intersection assumes that they
#> are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries
#> Spherical geometry (s2) switched on
```
