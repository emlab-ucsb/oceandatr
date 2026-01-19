# Create environmental zones for area of interest

This function gets [Bio-Oracle](https://bio-oracle.org/) environmental
data for the spatial grid and can then create environmental zones, using
k-means clustering. The idea for the clustering comes from Magris et al.
[2020](https://doi.org/10.1111/ddi.13183). The number of environmental
zones can be specified directly, using `num_clusters`, but the function
can also find the 'optimal' number of clusters using the `NbClust()`
from the `NbClust` package.

## Usage

``` r
get_enviro_zones(
  spatial_grid = NULL,
  raw = FALSE,
  enviro_zones = TRUE,
  show_plots = FALSE,
  num_clusters = NULL,
  max_num_clusters = 6,
  antimeridian = NULL,
  sample_size = 5000,
  num_samples = 5,
  num_cores = 1
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
  raw Bio-Oracle environmental data in that polygon(s) will be returned,
  unless `enviro_zones = TRUE`, in which case the raw data will be
  classified into environmental zones

- enviro_zones:

  `logical` if TRUE, environmental zones will be created. If FALSE the
  gridded Bio-Oracle data will be returned

- show_plots:

  `logical`; whether to show boxplots for each environmental variable in
  each environmental zone (default is FALSE)

- num_clusters:

  `numeric`; the number of environmental zones to cluster the data
  into - to be used when a clustering algorithm is not necessary
  (default is NULL)

- max_num_clusters:

  `numeric`; the maximum number of environmental zones to try when using
  the clustering algorithm (default is 6)

- antimeridian:

  Does `spatial_grid` span the antimeridian? If so, this should be set
  to `TRUE`, otherwise set to `FALSE`. If set to `NULL` (default) the
  function will try to check if `spatial_grid` spans the antimeridian
  and set this appropriately.

- sample_size:

  `numeric`; default is 5000. Larger sample sizes will quickly consume
  memory (\>10GB) so should be used with caution.

- num_samples:

  `numeric`; default is 5, which resulted in good consensus on the
  optimal number of clusters in testing.

- num_cores:

  `numeric`; default 1. Multi-core sampling is supported if the package
  `parallel` is installed, but be aware that increasing the number of
  cores will also increase the memory required.

## Value

If `enviro_zones = FALSE`, Bio-Oracle data in the `spatial_grid`
supplied, or the original Bio-Oracle data cropped and masked to the grid
if `raw = TRUE`. If `enviro_zones = TRUE` a multi-layer raster or an
`sf` object with one environmental zone in each column/ layer is
returned, depending on the `spatial_grid` format. If
`enviro_zones = TRUE` and `raw = TRUE` (in which case `spatial_grid`
should be an `sf` polygon), the raw Bio-Oracle data is classified into
environmental zones.

## Details

The environmental data used in the clustering are all sea surface
measurements over the period 2010 - 2020:

- Chlorophyll concentration (mean, mg/ m3)

- Dissolved oxygen concentration (mean)

- Nitrate concentration (mean, mmol/ m3)

- pH (mean)

- Phosphate concentration (mean, mmol/ m3)

- total Phytoplankton (primary productivity; mean, mmol/ m3)

- Salinity (mean)

- Sea surface temperature (max, degree C)

- Sea surface temperature (mean, degree C)

- Sea surface temperature (min, degree C)

- Silicate concentration (mean, mmol/ m3)

For full details of the Bio-Oracle data see [Assis et al.
2024](https://onlinelibrary.wiley.com/doi/10.1111/geb.13813).

When the number of planning units/ cells for clustering exceeds ~
10,000, the amount of computer memory required to find the optimal
number of clusters using
[`NbClust::NbClust()`](https://rdrr.io/pkg/NbClust/man/NbClust.html)
exceeds 10GB, so repeated sampling is used to find a consensus number of
clusters. Sensible defaults for `NbClust()` are provided, namely
`sample_size = 5000`, `num_samples = 5`, `max_num_clusters = 6` but can
be customised if desired, though see the parameter descriptions below
for some words of warning. Parallel processing is offered by specifying
`num_cores` \>1 (must be an integer), though the package `parallel` must
be installed (it is included in most R installations). To find the
number of available cores on your systems run
[`parallel::detectCores()`](https://rdrr.io/r/parallel/detectCores.html).

## Examples

``` r
# Get EEZ data first 
bermuda_eez <- get_boundary(name = "Bermuda")
#> Cache is fresh. Reading: /tmp/RtmpdlopUN/eez-2205f12f/eez.shp
#> (Last Modified: 2026-01-19 06:03:00.701614)
# Get raw Bio-Oracle environmental data for Bermuda
enviro_data <- get_enviro_zones(spatial_grid = bermuda_eez, raw = TRUE, enviro_zones = FALSE)
#> Selected dataset chl_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/chl_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: chl_mean
#> Selected dataset o2_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/o2_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: o2_mean
#> Selected dataset no3_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/no3_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: no3_mean
#> Selected dataset thetao_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/thetao_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: thetao_min
#> Selected dataset thetao_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/thetao_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: thetao_mean
#> Selected dataset thetao_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/thetao_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: thetao_max
#> Selected dataset ph_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/ph_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: ph_mean
#> Selected dataset po4_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/po4_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: po4_mean
#> Selected dataset so_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/so_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: so_mean
#> Selected dataset si_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/si_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: si_mean
#> Selected dataset phyc_baseline_2000_2020_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/phyc_baseline_2000_2020_depthsurf.html
#> Selected 1 variables: phyc_mean
terra::plot(enviro_data)

# Get gridded Bio-Oracle data for Bermuda:
bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 20000)

enviro_data_gridded <- get_enviro_zones(spatial_grid = bermuda_grid, raw = FALSE, enviro_zones = FALSE)
#> Selected dataset chl_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/chl_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: chl_mean
#> Selected dataset o2_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/o2_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: o2_mean
#> Selected dataset no3_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/no3_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: no3_mean
#> Selected dataset thetao_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/thetao_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: thetao_min
#> Selected dataset thetao_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/thetao_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: thetao_mean
#> Selected dataset thetao_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/thetao_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: thetao_max
#> Selected dataset ph_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/ph_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: ph_mean
#> Selected dataset po4_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/po4_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: po4_mean
#> Selected dataset so_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/so_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: so_mean
#> Selected dataset si_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/si_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: si_mean
#> Selected dataset phyc_baseline_2000_2020_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/phyc_baseline_2000_2020_depthsurf.html
#> Selected 1 variables: phyc_mean
terra::plot(enviro_data_gridded)


# Get 3 environmental zones for Bermuda

#set seed for reproducibility in the sampling to find optimal number of clusters
set.seed(500)
bermuda_enviro_zones <- get_enviro_zones(spatial_grid = bermuda_grid, raw = FALSE, enviro_zones = TRUE, num_clusters = 3)
#> Selected dataset chl_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/chl_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: chl_mean
#> Selected dataset o2_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/o2_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: o2_mean
#> Selected dataset no3_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/no3_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: no3_mean
#> Selected dataset thetao_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/thetao_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: thetao_min
#> Selected dataset thetao_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/thetao_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: thetao_mean
#> Selected dataset thetao_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/thetao_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: thetao_max
#> Selected dataset ph_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/ph_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: ph_mean
#> Selected dataset po4_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/po4_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: po4_mean
#> Selected dataset so_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/so_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: so_mean
#> Selected dataset si_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/si_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: si_mean
#> Selected dataset phyc_baseline_2000_2020_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/phyc_baseline_2000_2020_depthsurf.html
#> Selected 1 variables: phyc_mean
terra::plot(bermuda_enviro_zones)

# Can also create environmental zones from the raw Bio-Oracle data using setting raw = TRUE and enviro_zones = TRUE. In this case, the `spatial_grid` should be a polygon of the area you want the data for
bermuda_enviro_zones2 <- get_enviro_zones(spatial_grid = bermuda_eez, raw = TRUE, enviro_zones = TRUE, num_clusters = 3)
#> Selected dataset chl_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/chl_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: chl_mean
#> Selected dataset o2_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/o2_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: o2_mean
#> Selected dataset no3_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/no3_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: no3_mean
#> Selected dataset thetao_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/thetao_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: thetao_min
#> Selected dataset thetao_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/thetao_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: thetao_mean
#> Selected dataset thetao_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/thetao_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: thetao_max
#> Selected dataset ph_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/ph_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: ph_mean
#> Selected dataset po4_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/po4_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: po4_mean
#> Selected dataset so_baseline_2000_2019_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/so_baseline_2000_2019_depthsurf.html
#> Selected 1 variables: so_mean
#> Selected dataset si_baseline_2000_2018_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/si_baseline_2000_2018_depthsurf.html
#> Selected 1 variables: si_mean
#> Selected dataset phyc_baseline_2000_2020_depthsurf.
#> Dataset info available at: http://erddap.bio-oracle.org/erddap/griddap/phyc_baseline_2000_2020_depthsurf.html
#> Selected 1 variables: phyc_mean
terra::plot(bermuda_enviro_zones2)
```
