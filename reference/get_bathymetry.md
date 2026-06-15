# Get bathymetry data

Get bathymetry data from the GEBCO 2026 global terrain model. If data
are already downloaded locally, the user can specify the file path of
the dataset. Data can be classified into depth zones by setting
`classify_bathymetry = TRUE`

## Usage

``` r
get_bathymetry(
  spatial_grid = NULL,
  raw = FALSE,
  classify_bathymetry = TRUE,
  above_sea_level_isNA = FALSE,
  name = "bathymetry",
  bathymetry_data_filepath = NULL,
  path = NULL,
  antimeridian = NULL
)
```

## Arguments

- spatial_grid:

  `sf` or
  [`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
  grid, e.g. created using
  [`get_grid()`](https://emlab-ucsb.github.io/oceandatr/reference/get_grid.md).
  Alternatively, if raw data is required, an `sf` polygon can be
  provided, e.g. created using
  [`get_boundary()`](https://emlab-ucsb.github.io/oceandatr/reference/get_boundary.md),
  and set `raw = TRUE`.

- raw:

  `logical` if TRUE, `spatial_grid` should be an `sf` polygon, and the
  raw data in that polygon(s) will be returned

- classify_bathymetry:

  `logical`; whether to classify the bathymetry into depth zones.
  Original bathymetry data can be classified if `raw = TRUE` and
  `spatial_grid` is an `sf` polygon.

- above_sea_level_isNA:

  `logical`; whether to set bathymetry (elevation) data values that are
  above sea level (i.e. greater than or equal to zero) to `NA` (`TRUE`)
  or zero (`FALSE`)

- name:

  `string`; name of raster or column in sf object that is returned

- bathymetry_data_filepath:

  `string`; the file path (including file name and extension) where
  bathymetry raster data are saved locally

- path:

  `string`; the folder path where you would like to save the bathymetry
  data. Defaults to [`tempdir()`](https://rdrr.io/r/base/tempfile.html).
  If you are downloading data for large areas (e.g. whole oceans), we
  strongly recommend you set your own path to save to.

- antimeridian:

  Does `spatial_grid` span the antimeridian? If so, this should be set
  to `TRUE`, otherwise set to `FALSE`. If set to `NULL` (default) the
  function will try to check if `spatial_grid` spans the antimeridian
  and set this appropriately.

## Value

If `classify_bathymetry = FALSE`, bathymetry data in the `spatial_grid`
supplied, or in the original raster file resolution if `raw = TRUE`. If
`classify_bathymetry = TRUE` a multi-layer raster or an `sf` object with
one zone in each column is returned, depending on the `spatial_grid`
format. If `classify_bathymetry = TRUE` and `raw = TRUE` (in which case
`spatial_grid` should be an `sf` polygon), the raw raster bathymetry
data is classified into depth zones.

## Details

Extracts bathymetry data for an `area_polygon`, or if a `spatial_grid`
is supplied, gridded bathymetry is returned.

Data can be classified into depth zones by setting
`classify_bathymetry = TRUE`. Depths are classified as follows:

- Continental Shelf: 0 - 200 m depth

- Upper Bathyal: 200 - 800 m depth

- Lower Bathyal: 800 - 3500 m depth

- Abyssal: 3500 - 6500 m depth

- Hadal: 6500+ m depth

If the user has downloaded bathymetry data for the area of interest, for
example from GEBCO (https://www.gebco.net), they can pass the file path
to this function in `bathymetry_data_filepath`. If no file path is
provided, the function will extract bathymetry data for the area from
the GEBCO 2026 global terrain model (sub-ice) from the Natural
Environment Research Council's (NERC) Centre for Environmental Data
Analysis (CEDA) (https://data.ceda.ac.uk/bodc/gebco/global/gebco_2026).

## Examples

``` r
# Get EEZ data first
bermuda_eez <- get_boundary(name = "Bermuda")
# Get raw bathymetry data, not classified into depth zones
bathymetry <- get_bathymetry(spatial_grid = bermuda_eez, 
                             raw = TRUE, 
                             classify_bathymetry = FALSE)
#> Downloaded and saved data chunk 1 of 1
#> Finished! Data successfully streamed to /tmp/Rtmpk2b9ku/bathy_-68.92_-60.7_28.91_35.81.tif
terra::plot(bathymetry)

# Get depth zones in spatial_grid

#equal area projection for Bermuda
bermuda_crs <- '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs'

bermuda_grid <- get_grid(boundary = bermuda_eez, 
                         crs = bermuda_crs, 
                         resolution = 10000)
                         
depth_zones <- get_bathymetry(spatial_grid = bermuda_grid)
#> Downloaded and saved data chunk 1 of 1
#> Finished! Data successfully streamed to /tmp/Rtmpk2b9ku/bathy_-68.94_-60.68_28.9_35.81.tif
terra::plot(depth_zones)


#It is also possible to get the raw bathymetry data in gridded format by setting raw = FALSE
# and classify_bathymetry = FALSE
  
gridded_bathymetry <- get_bathymetry(spatial_grid = bermuda_grid, 
                                     classify_bathymetry = FALSE)
#> Bathymetry data already downloaded, loading data from: /tmp/Rtmpk2b9ku/bathy_-68.94_-60.68_28.9_35.81.tif
                                     
terra::plot(gridded_bathymetry)
```
