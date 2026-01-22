# Get seamounts

Get seamounts data in a spatial grid or polygon

## Usage

``` r
get_seamounts(
  spatial_grid = NULL,
  raw = FALSE,
  buffer = NULL,
  name = "seamounts",
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

- buffer:

  `numeric`; the distance from the seamount peak to include in the
  output. Distance should be in the same units as the spatial_grid, use
  e.g. `sf::st_crs(spatial_grid, parameters = TRUE)$units_gdal` to check
  units. If buffering raw data, units are metres, unless
  [`sf::sf_use_s2()`](https://r-spatial.github.io/sf/reference/s2.html)
  is set to `FALSE`, in which case the units are degrees.

- name:

  `string`; name of raster or column in sf object that is returned

- antimeridian:

  Does `spatial_grid` span the antimeridian? If so, this should be set
  to `TRUE`, otherwise set to `FALSE`. If set to `NULL` (default) the
  function will try to check if `spatial_grid` spans the antimeridian
  and set this appropriately.

## Value

For buffered seamounts as gridded data, a
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
or `sf` object, depending on the `spatial_grid` format. If `raw = TRUE`
and `buffer = NULL` an `sf` POINT geometry object of seamount peaks
within the polygon provided. If `raw = TRUE` and `buffer` is not `NULL`
an `sf` polygon geometry object of buffered seamount peaks within the
polygon provided. Note: at present, it is not possible to return gridded
seamount peaks: https://github.com/emlab-ucsb/oceandatr/issues/48

## Details

Seamounts are classified as peaks at least 1000m higher than the
surrounding seafloor [Morato et al.
2008](https://doi.org/10.3354/meps07268). The seamounts peak dataset is
from [Yeson et al. 2021](https://doi.org/10.14324/111.444/ucloe.000030).
[Morato et al. 2010](https://doi.org/10.1073/pnas.0910290107) found that
seamounts have higher biodiversity within 30 - 40 km of the peak. To
enable this radius of higher biodiversity to be included in conservation
planning, the `buffer` argument can be set, so that each seamount peak
is buffered to the radius specified

## Examples

``` r
# Get EEZ data first 
bermuda_eez <- get_boundary(name = "Bermuda")
#> Cache is fresh. Reading: /tmp/RtmpxryWDx/eez-2205f12f/eez.shp
#> (Last Modified: 2026-01-22 04:48:58.369191)
# Get raw seamounts data
seamount_peaks <- get_seamounts(spatial_grid = bermuda_eez, raw = TRUE)
#> Spherical geometry (s2) switched off
#> although coordinates are longitude/latitude, st_intersection assumes that they
#> are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries
#> Spherical geometry (s2) switched on
plot(seamount_peaks["Depth"])

# Get gridded seamount data
bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 10000)
#buffer seamounts to a distance of 30 km (30,000 m)
seamounts_gridded <- get_seamounts(spatial_grid = bermuda_grid, buffer = 30000)
#> Spherical geometry (s2) switched off
#> although coordinates are longitude/latitude, st_intersection assumes that they
#> are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries
#> Spherical geometry (s2) switched on
terra::plot(seamounts_gridded)
```
