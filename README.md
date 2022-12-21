
<!-- README.md is generated from README.Rmd. Please edit that file -->

# offshoredatr

<!-- badges: start -->
<!-- badges: end -->

Offshoredatr aims to provide simple functions for creating data for
conducting a spatial conservation prioritization for large scale areas
of the ocean, specifically offshore areas.

## Installation

You can install the development version of offshoredatr from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("emlab-ucsb/offshoredatr")
```

## Example of usage

``` r
#load libraries needed
library(offshoredatr)
library(sf)
#> Linking to GEOS 3.8.0, GDAL 3.0.4, PROJ 6.3.1; sf_use_s2() is TRUE
library(raster)
#> Loading required package: sp
library(tmap)
```

### Obtain an EEZ for an area of interest

This function pulls data for EEZs from the [Marine
Gazetteer](https://marineregions.org/gazetteer.php) using the
`mregions2` R package; the function is just a wrapper to make the
process a bit simpler. It’s very basic at the moment and will fail if it
doesn’t find an EEZ that matches the `country_name` specified, which is
not necessarily the same as the country name you would expect!

TO DO: make the name matching fuzzy

``` r
bermuda_eez <- get_eez(country_name = "bermudian")

#plot to check we have Bermuda's EEZ
tm_shape(bermuda_eez) +
  tm_polygons(col = "lightblue") +
  tm_graticules(lines = FALSE)
```

<img src="man/figures/README-area of interest-1.png" width="100%" />

# Choose a CRS

Best practice is to use a local, equal area projection for all
geospatial data for use in the prioritization. Finding a suitable
projection can be tricky, but [projection
wizard](https://projectionwizard.org) provides a handy tool. Standard
projections used for countries can also be found at <https://epsg.io/>
by searching with country name.

The bounding box coordinates for the area of interest can be used to
generate the coordinate reference system (CRS) on [projection
wizard](https://projectionwizard.org)

``` r
sf::st_bbox(bermuda_eez)
#>      xmin      ymin      xmax      ymax 
#> -68.91706  28.90577 -60.70480  35.80855
```

The coordinates above should be entered as the ‘Geographic extent’ and
the map should then have a box drawn around the bounding box of the area
of interest. The projection can then be copied and pasted from the
pop-up box when clicking on ‘WKT’. The projeciton needs to be placed in
quotation marks as follows:

``` r
projection <- 'PROJCS["ProjWiz_Custom_Lambert_Azimuthal",
 GEOGCS["GCS_WGS_1984",
  DATUM["D_WGS_1984",
   SPHEROID["WGS_1984",6378137.0,298.257223563]],
  PRIMEM["Greenwich",0.0],
  UNIT["Degree",0.0174532925199433]],
 PROJECTION["Lambert_Azimuthal_Equal_Area"],
 PARAMETER["False_Easting",0.0],
 PARAMETER["False_Northing",0.0],
 PARAMETER["Central_Meridian",-64.5],
 PARAMETER["Latitude_Of_Origin",32],
 UNIT["Meter",1.0]]'
```

### Get a planning grid for the area of interest

A planning grid is needed for spatial prioritization. This divides the
area of interest into grid cells. The `planning_grid` function will
return a planning grid for the specified area of interest (polygon),
projected into the coordinate refernce system specified, at the cell
resolution specified in kilometres.

``` r
planning_grid <- get_planning_grid(area_polygon = bermuda_eez, projection_crs = projection, resolution_km = 5)

#project the eez into same projection as planning grid for plotting
bermuda_eez_projected <- st_transform(bermuda_eez, crs = projection)

#plot the planning grid
tm_shape(bermuda_eez_projected) +
  tm_borders() +
  tm_shape(planning_grid) +
  tm_raster(title = "Planning grid") + 
  tm_graticules(lines = FALSE)
```

<img src="man/figures/README-planning grid-1.png" width="100%" />

The raster covers Bermuda’s EEZ. The grid cells would be too small to
see if we plotted them, but here is a coarser grid (lower resolution)
visualized so we can see what the grid cells look like.

``` r
planning_grid_coarse <- get_planning_grid(area_polygon = bermuda_eez, projection_crs = projection, resolution_km = 20)

tm_shape(bermuda_eez_projected) +
  tm_borders() +
  tm_shape(rasterToPolygons(planning_grid_coarse, dissolve = FALSE)) +
  tm_borders() +
  tm_graticules(lines = FALSE)
```

<img src="man/figures/README-planning grid cells-1.png" width="100%" />

### Get geomorphological data for area of interest

Now we have our planning grid, we can get data for this area of
interest. The first type of data we will get is geomorpological
features. These data come from [Harris et al. 2014, Geomorphology of the
Oceans](https://doi.org/10.1016/j.margeo.2014.01.011) and are available
for download from <https://www.bluehabitats.org>. The features that are
suggested as major habitats for inclusion in no-take MPAs by [Ceccarelli
et al. 2021](https://doi.org/10.3389/fmars.2021.634574) are included in
this package, so it is not necessary to download them.

``` r
geomorphology <- get_geomorphology(area_polygon = bermuda_eez, planning_grid = planning_grid)

tm_shape(geomorphology) +
  tm_raster(palette = "sienna2", title = "Geomorphology") +
  tm_shape(bermuda_eez_projected) +
  tm_borders() +
  tm_graticules(lines = FALSE)
```

<img src="man/figures/README-geomorphology-1.png" width="100%" />
