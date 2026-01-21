# Get a set of feature data for a spatial grid

This is a wrapper of
[`get_bathymetry()`](https://emlab-ucsb.github.io/oceandatr/reference/get_bathymetry.md),
`get_seamounts_buffered()`,
[`get_knolls()`](https://emlab-ucsb.github.io/oceandatr/reference/get_knolls.md),
[`get_geomorphology()`](https://emlab-ucsb.github.io/oceandatr/reference/get_geomorphology.md),
[`get_coral_habitat()`](https://emlab-ucsb.github.io/oceandatr/reference/get_coral_habitat.md),
and
[`get_enviro_zones()`](https://emlab-ucsb.github.io/oceandatr/reference/get_enviro_zones.md).
See the individual functions for details.

## Usage

``` r
get_features(
  spatial_grid = NULL,
  raw = FALSE,
  features = c("bathymetry", "seamounts", "knolls", "geomorphology", "corals",
    "enviro_zones"),
  seamount_buffer = 30000,
  antipatharia_threshold = 22,
  octocoral_threshold = 2,
  enviro_clusters = NULL,
  max_enviro_clusters = 6,
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
  raw feature data in that polygon(s) will be returned. Note that this
  will be a list object, since raster and `sf` data may be returned.

- features:

  a vector of feature names, can include: "bathymetry", "seamounts",
  "knolls", "geomorphology", "corals", "enviro_zones"

- seamount_buffer:

  `numeric`; the distance from the seamount peak to include in the
  output. Distance should be in the same units as the area_polygon or
  spatial_grid provided, use e.g.
  `sf::st_crs(spatial_grid, parameters = TRUE)$units_gdal` to check what
  units your planning grid or area polygon is in (works for raster as
  well as sf objects)

- antipatharia_threshold:

  `numeric` between 0 and 100; the threshold value for habitat
  suitability for antipatharia corals to be considered present (default
  is 22, as defined in Yesson et al., 2017)

- octocoral_threshold:

  `numeric` between 0 and 7; the threshold value for how many species
  (of 7) should be predicted present in an area for octocorals to be
  considered present (default is 2)

- enviro_clusters:

  `numeric`; the number of environmental zones to cluster the data
  into - to be used when a clustering algorithm is not necessary
  (default is NULL)

- max_enviro_clusters:

  `numeric`; the maximum number of environmental zones to try when using
  the clustering algorithm (default is 8)

- antimeridian:

  Does `spatial_grid` span the antimeridian? If so, this should be set
  to `TRUE`, otherwise set to `FALSE`. If set to `NULL` (default) the
  function will try to check if `spatial_grid` spans the antimeridian
  and set this appropriately.

## Value

If `raw = TRUE`, a list of feature data is returned (mixed raster and
`sf` objects). If a `spatial_grid` is supplied, a multi-layer raster or
`sf` object of gridded data is returned, depending on the `spatial_grid`
format.

## Examples

``` r
# Grab EEZ data first 
bermuda_eez <- get_boundary(name = "Bermuda")
#> Cache is fresh. Reading: /tmp/RtmpFboyUF/eez-2205f12f/eez.shp
#> (Last Modified: 2026-01-21 06:12:01.995016)
# Get raw data for Bermuda's EEZ
raw_data <- get_features(spatial_grid = bermuda_eez, raw = TRUE)
#> Getting depth zones...
#> Bathymetry data already downloaded, using cached version
#> Getting seamount data...
#> Spherical geometry (s2) switched off
#> although coordinates are longitude/latitude, st_intersection assumes that they
#> are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries
#> Warning: st_buffer does not correctly buffer longitude/latitude data
#> dist is assumed to be in decimal degrees (arc_degrees).
#> Spherical geometry (s2) switched on
#> Getting knoll data...
#> Spherical geometry (s2) switched off
#> although coordinates are longitude/latitude, st_intersection assumes that they
#> are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries
#> Spherical geometry (s2) switched on
#> Getting geomorphology data...
#> Getting coral data...
#> Getting environmental zones data... This could take several minutes
# Get feature data in a spatial grid
bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 20000)
#set seed for reproducibility in the get_enviro_zones() function
set.seed(500)
features_gridded <- get_features(spatial_grid = bermuda_grid)
#> Getting depth zones...
#> Bathymetry data already downloaded, using cached version
#> Getting seamount data...
#> Spherical geometry (s2) switched off
#> although coordinates are longitude/latitude, st_intersection assumes that they
#> are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries
#> Spherical geometry (s2) switched on
#> Getting knoll data...
#> Spherical geometry (s2) switched off
#> although coordinates are longitude/latitude, st_intersection assumes that they
#> are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries
#> Spherical geometry (s2) switched on
#> Getting geomorphology data...
#> Getting coral data...
#> Getting environmental zones data... This could take several minutes
terra::plot(features_gridded)
```
