# Get seafloor geomorphology data

Get geomorphological data for a spatial grid or polygon

## Usage

``` r
get_geomorphology(spatial_grid = NULL, raw = FALSE, antimeridian = NULL)
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

- antimeridian:

  Does `spatial_grid` span the antimeridian? If so, this should be set
  to `TRUE`, otherwise set to `FALSE`. If set to `NULL` (default) the
  function will try to check if `spatial_grid` spans the antimeridian
  and set this appropriately.

## Value

For gridded data, a multi-layer raster object, or an `sf` object with
geomorphology class in each column, depending on the `spatial_grid`
format. If `raw = TRUE` an `sf` object with each row as a different
geomorphological feature.

## Details

Geomorphological features are from the [Harris et al.
2014](https://doi.org/10.1016/j.margeo.2014.01.011) dataset, available
at <https://www.bluehabitats.org>. Data is included in this package,
except depth classification features which can be created using
[`get_bathymetry()`](https://emlab-ucsb.github.io/oceandatr/reference/get_bathymetry.md)
and seamounts which can be retrieved from a more recent dataset using
[`get_seamounts()`](https://emlab-ucsb.github.io/oceandatr/reference/get_seamounts.md).
List of features:

- Abyssal hills

- Abyssal plains

- Basins:

  - large basins of seas and oceans

  - major ocean basins

  - perched on the shelf

  - perched on the slope

  - small basins of seas and oceans

- Bridges

- Canyons:

  - blind

  - shelf incising

- Escarpments

- Fans

- Glacial troughs

- Guyots

- Plateaus

- Ridges

- Rift valleys

- Rises

- Shelf valleys:

  - large shelf valleys and glacial troughs

  - moderate size

  - small

- Sills

- Spreading ridges

- Terraces

- Trenches

- Troughs

## Examples

``` r
# Grab EEZ data first 
bermuda_eez <- get_boundary(name = "Bermuda")
#> Cache is fresh. Reading: /tmp/RtmpdNEaSn/eez-2205f12f/eez.shp
#> (Last Modified: 2026-01-20 04:56:54.657319)
# Get geomorphology for the EEZ
bermuda_geomorph <- get_geomorphology(spatial_grid = bermuda_eez, raw = TRUE)
#> Spherical geometry (s2) switched off
#> although coordinates are longitude/latitude, st_intersection assumes that they
#> are planar
#> Spherical geometry (s2) switched on
# Get geomorphological features in spatial_grid
bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 20000)
geomorph_gridded <- get_geomorphology(spatial_grid = bermuda_grid) %>% remove_empty_layers() #helper function to remove data layers that are all zero or NA values
#> Spherical geometry (s2) switched off
#> although coordinates are longitude/latitude, st_intersection assumes that they
#> are planar
#> Spherical geometry (s2) switched on
plot(geomorph_gridded)
#> Error: [`[`] the index SpatRaster can only have one layer
```
