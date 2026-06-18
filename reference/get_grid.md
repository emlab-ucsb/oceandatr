# Create a spatial grid

Creates a spatial grid, in
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
of `sf` format, for areas within the boundaries provided

## Usage

``` r
get_grid(boundary, resolution = 5000, crs, output = "raster", touches = FALSE)
```

## Arguments

- boundary:

  `sf` object with boundary of the area(s) you want a grid for, e.g an
  EEZ or country. Boundaries can be obtained using
  [`get_boundary()`](https://emlab-ucsb.github.io/oceandatr/reference/get_boundary.md)

- resolution:

  `numeric`; the desired grid cell resolution in same units (usually
  metres or degrees) as `crs`:
  `sf::st_crs(crs, parameters = TRUE)$units_gdal`

- crs:

  a coordinate reference system: `numeric` (e.g. EPSG code `4326`),
  `character` (e.g. `"+proj=longlat +datum=WGS84 +no_defs"`), or object
  of class `sf` or `sfc`. This is passed to
  [`sf::st_crs()`](https://r-spatial.github.io/sf/reference/st_crs.html)

- output:

  `character` the desired output format, either `"raster"`,
  `"sf_square"` (vector), or `"sf_hex"` (vector); default is `"raster"`

- touches:

  `logical`. If `TRUE` all cells touched by the `boundary` will be
  included, and if `FALSE` only cells whose center point (centroid)
  falls within the `boundary` are included. Default is `FALSE`.

## Value

A spatial grid in `output` format requested with `resolution` and `crs`
provided

## Details

For a
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
format grid, each cell within the boundary is set to value 1, whereas
cells outside are NA. For `sf` grids, the grid covers the boundary area
and cells can be square (`output = "sf_square"`) or hexagonal
(`output = "sf_hex"`). By default only cells whose centroids fall within
the `boundary` are included in the grid. To include cells that touch the
`boundary` use `touches = TRUE`.
[`sf::st_make_grid()`](https://r-spatial.github.io/sf/reference/st_make_grid.html)
is used to create `sf` grids. The default ordering of this grid type is
from bottom to top, left to right. In contrast, the
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
grid is ordered from top to bottom, left to right. To preserve
consistency across the data types, we have reordered `sf` grids to also
fill from top to bottom, left to right.

## Examples

``` r
# use get_boundary() to get a polygon of Samoa's Exclusive Economic Zone
samoa_eez <- get_boundary(name = "Samoa")
#> Cache is fresh. Reading: /tmp/Rtmp0bPw6w/eez-d0aa43d6/eez.shp
#> (Last Modified: 2026-06-18 07:05:27.579559)
# You need a suitable coordinate reference system (crs) for your area of interest,
# https://projectionwizard.org is useful for this purpose. For spatial planning,
# equal area projections are normally best.

samoa_projection <- '+proj=laea +lon_0=-172.5 +lat_0=0 +datum=WGS84 +units=m +no_defs'

# Create a grid with 5 km (5000 m) resolution covering the `samoa_eez`
# in a projection specified by `crs`.
samoa_grid <- get_grid(boundary = samoa_eez, resolution = 5000, crs = samoa_projection)
```
