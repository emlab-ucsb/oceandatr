
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
if (!require(devtools)) install.packages("devtools")
devtools::install_github("emlab-ucsb/offshoredatr")
```

## Example of usage

``` r
#load offshoredatr package
library(offshoredatr)
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
bermuda_eez <- get_eez(country_name = "Bermuda")
#> Loading ISO 19139 XML schemas...
#> Loading ISO 19115 codelists...

#plot to check we have Bermuda's EEZ
plot(bermuda_eez[1], col = "lightblue", main=NULL, axes=TRUE)
```

<img src="man/figures/README-area of interest-1.png" width="800" />

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
projected into the coordinate reference system specified, at the cell
resolution specified in kilometres.

``` r
planning_grid <- get_planning_grid(area_polygon = bermuda_eez, projection_crs = projection, resolution_km = 5)

#project the eez into same projection as planning grid for plotting
bermuda_eez_projected <- bermuda_eez %>% 
  sf::st_transform(crs = projection) %>% 
  sf::st_geometry()

#plot the planning grid
plot(planning_grid, col = "gold3", main = NULL, axes = FALSE, legend = FALSE)
plot(bermuda_eez_projected, add=TRUE)
```

<img src="man/figures/README-planning grid-1.png" width="800" />

The raster covers Bermuda’s EEZ. The grid cells would be too small to
see if we plotted them, but here is a coarser grid (lower resolution)
visualized so we can see what the grid cells look like.

``` r
planning_grid_coarse <- get_planning_grid(area_polygon = bermuda_eez, projection_crs = projection, resolution_km = 20)

plot(bermuda_eez_projected, main = NULL, axes = FALSE)
plot(raster::rasterToPolygons(planning_grid_coarse, dissolve = FALSE), add=TRUE)
```

<img src="man/figures/README-planning grid cells-1.png" width="800" />

### Get bathymetry

Now we have our planning grid, we can get data for this area of
interest. A key piece of data is bathymetry. If the user has downloaded
data for the area of interest from the [GEBCO
website](https://www.gebco.net), they can pass the file path to this
function and it will crop and rasterize the data using the supplied
planning grid. If no file path is provided, the function will extract
bathymetry data for the area from the [ETOPO 2022 Global Relief
model](https://www.ncei.noaa.gov/products/etopo-global-relief-model)
using a function borrowed from the `marmap` package.

``` r
bathymetry <- get_bathymetry(area_polygon = bermuda_eez, planning_grid = planning_grid, keep = FALSE)
#> Querying NOAA database ...
#> This may take seconds to minutes, depending on grid size
#> x1 = -68.9 y1 = 28.9 x2 = -60.7 y2 = 35.8 ncell.lon = 492 ncell.lat = 414

plot(bathymetry, col = hcl.colors(n=255, "Blues"), main = NULL, axes = FALSE) 
plot(bermuda_eez_projected, add=TRUE)
```

<img src="man/figures/README-bathymetry-1.png" width="800" />

### Depth classification

The ocean can be classified into 5 depth zones:

- 0 - 200m: Epipelagic zone
- 200 - 1000m: Mesopelagic zone
- 1000 - 4000m: Bathypelagic zone
- 4000 - 6000m: Abyssopelagic zone
- 6000m+: Hadopelagic zone

We can use these depth zone definitions to classify the bathymetry we
just obtained into depth zones based on the ocean floor depths.

``` r
depth_zones <- classify_depths(bathymetry, planning_grid)
#> Warning in raster::projectRaster(., to = planning_grid): input and ouput crs
#> are the same

plot(depth_zones, col = "navyblue", axes = FALSE, legend = FALSE, addfun = function(){plot(bermuda_eez_projected, add=TRUE)})
```

<img src="man/figures/README-depth classification-1.png" width="800" />

### Get geomorphological data

The seafloor has its own mountains, plains and other geomorphological
features just as on land. These data come from [Harris et al. 2014,
Geomorphology of the
Oceans](https://doi.org/10.1016/j.margeo.2014.01.011) and are available
for download from <https://www.bluehabitats.org>. The features that are
suggested as major habitats for inclusion in no-take MPAs by [Ceccarelli
et al. 2021](https://doi.org/10.3389/fmars.2021.634574) are included in
this package, so it is not necessary to download them.

``` r
geomorphology <- get_geomorphology(area_polygon = bermuda_eez, planning_grid = planning_grid)

plot(geomorphology, col = "sienna2", axes = FALSE, legend = FALSE, addfun = function(){plot(bermuda_eez_projected, add=TRUE)})
```

<img src="man/figures/README-geomorphology-1.png" width="800" />

## Get knolls data

Knolls are another geomorphological feature, which are ‘small’
seamounts, classified as seamounts between 200 and 1000m higher than the
surrounding seafloor [Morato et
al. 2008](https://doi.org/10.3354/meps07268). Data are the knoll base
area data from [Yesson et
al. 2011](https://doi.org/10.1016/j.dsr.2011.02.004).

``` r
knolls <- get_knolls(area_polygon = bermuda_eez, planning_grid = planning_grid)

plot(knolls, col = "grey40", main = NULL, axes = FALSE, legend = FALSE)
plot(bermuda_eez_projected, add=TRUE)
```

<img src="man/figures/README-knolls-1.png" width="800" />

## Get seamount areas

Seamounts, classified as peaks at least 1000m higher than the
surrounding seafloor [Morato et
al. 2008](https://doi.org/10.3354/meps07268). These data are from
[Yesson et al. 2021](https://doi.org/10.14324/111.444/ucloe.000030).
Each peak is buffered to the distance specified in the function call (in
units of kilometres)

``` r
seamounts <- get_seamounts_buffered(area_polygon = bermuda_eez, planning_grid = planning_grid, buffer_km = 30)

plot(seamounts, col = "saddlebrown", main = NULL, axes = FALSE, legend = FALSE)
plot(bermuda_eez_projected, add=TRUE)
```

<img src="man/figures/README-seamounts-1.png" width="800" />

## Habitat suitability models

Retrieve habitat suitability data for 3 deep water coral groups: \*
Antipatharia:

``` r
coral_habitat <- get_coral_habitat(area_polygon = bermuda_eez) %>% 
  #function returns the raw data in EPSG 4326; project to local crs for plotting
  projectRaster(crs = crs(planning_grid))
#> [1] "Antipatharia data done"
#> [1] "Cold water coral data done"
#> [1] "Octocoral data done"

#show the seamounts areas on the plot: coral habitat is often on seamounts which are shallower than surrounding ocean floor
plot_add <- function(){
  plot(bermuda_eez_projected, border = "grey40", add=TRUE) 
  plot(rasterToPolygons(seamounts, dissolve = TRUE), col = NA, border = "red", add=TRUE)
  }

plot(coral_habitat, col = hcl.colors(n=100, "cividis"), axes = FALSE, addfun = plot_add)
```

<img src="man/figures/README-coral habitat-1.png" width="800" />
