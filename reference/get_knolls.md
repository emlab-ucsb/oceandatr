# Get knolls base areas

Get knolls base area data in a spatial grid or polygon

## Usage

``` r
get_knolls(
  spatial_grid = NULL,
  raw = FALSE,
  name = "knolls",
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

- name:

  `string`; name of raster or column in sf object that is returned

- antimeridian:

  Does `spatial_grid` span the antimeridian? If so, this should be set
  to `TRUE`, otherwise set to `FALSE`. If set to `NULL` (default) the
  function will try to check if `spatial_grid` spans the antimeridian
  and set this appropriately.

## Value

For gridded data, a
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
or `sf` object, depending on the `spatial_grid` format. If `raw = TRUE`
an `sf` object crop and intersected with the polygon supplied.

## Details

Knolls are small seamounts; seamounts with peaks 200-1000 m higher than
the surrounding seafloor [(Morato et al.,
2008)](https://doi.org/10.3354/meps07268). The knolls base area data is
from [Yesson et al. 2011](https://doi.org/10.1016/j.dsr.2011.02.004)

## Examples

``` r
# Get EEZ data first 
bermuda_eez <- get_boundary(name = "Bermuda")
#> Cache is fresh. Reading: /tmp/RtmpFboyUF/eez-2205f12f/eez.shp
#> (Last Modified: 2026-01-21 06:12:01.995016)
# Get raw knolls data for Bermuda's EEZ
knolls <- get_knolls(spatial_grid= bermuda_eez, raw = TRUE)
#> Spherical geometry (s2) switched off
#> although coordinates are longitude/latitude, st_intersection assumes that they
#> are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries
#> Spherical geometry (s2) switched on
# Get gridded knolls data: first create a grid
bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 10000)
knolls_gridded <- get_knolls(spatial_grid = bermuda_grid)
#> Spherical geometry (s2) switched off
#> although coordinates are longitude/latitude, st_intersection assumes that they
#> are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries
#> Spherical geometry (s2) switched on
```
