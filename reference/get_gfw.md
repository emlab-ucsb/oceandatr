# Get data from Global Fishing Watch

Global Fishing Watch (GFW) provides data on apparent fishing effort
(hours) at 0.01 degree spatial resolution, based on automatic
identification system (AIS) broadcasts from vessels. Data is principally
for larger vessel (\> 24m in length); less than 1% of vessels \<12 m
length are represented in the data (see [GFW
website](https://globalfishingwatch.org/dataset-and-code-fishing-effort/)
for detailed information). This function is primarily a wrapper for the
[`gfwr` package](https://github.com/GlobalFishingWatch/gfwr) function
`get_raster()`, but allows the user to return multiple years of data in
a summarized and gridded format. An API key is required to retrieve GFW
data; see the package website for instructions on how to get and save
one (free).

## Usage

``` r
get_gfw(
  spatial_grid = NULL,
  raw = FALSE,
  resolution = "LOW",
  start_year = 2018,
  end_year = 2023,
  group_by = "location",
  summarise = "mean_total_annual_effort",
  key = gfwr::gfw_auth()
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

  `logical` if TRUE, `spatial_grid` can be an `sf` polygon, and the raw
  GFW data, in tibble format, is returned for a bounding box covering
  the polygon +/-1 degree. The bounding box is expanded to ensure that
  the entire polygon has data coverage once the point data is
  rasterized. This data will not be summarised, i.e. `summarise` is
  ignored.

- resolution:

  `string` either `"HIGH"` = 0.01 degree spatial resolution, or `"LOW"`
  = 0.1.

- start_year:

  `numeric` must be 2012 or more recent year. Note that GFW added data
  from Spire and Orbcomm AIS providers in 2017, so data from 2017 is
  likely to have greater spatial and temporal coverage ([Welch et al.
  2022](https://doi.org/10.1126/sciadv.abq2109)).

- end_year:

  `numeric` any year between 2012 and the current year

- group_by:

  `string` can be `"geartype"`, `"flag"`, or `"location"`.

- summarise:

  `string` can be `"total_annual_effort"`; the sum of all fishing effort
  for all years, from `start_year` to `end_year` at each location is
  returned, grouped by `group_by`; or `"mean_total_annual_effort"`; the
  mean of the annual sums of fishing effort for all years at each
  location is returned, grouped by `group_by`.

- key:

  `string` Authorization token. Can be obtained with gfw_auth()
  function. See `gfwr`
  [website](https://github.com/GlobalFishingWatch/gfwr?tab=readme-ov-file#authorization)
  for details on how to request a token.

## Value

For gridded data, a
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
or `sf` object, depending on the `spatial_grid` format. If `raw = TRUE`,
non-summarised data in `tibble` format is returned for the polygon area
direct from the GFW query
[`gfwr::get_raster()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_renamed.html).

## Examples

``` r
if (FALSE) { # nchar(Sys.getenv("GFW_TOKEN")) > 0
#get mean total annual fishing effort for Bermuda for the years 2022-2023
#first get a grid for Bermuda
bermuda_grid <- get_boundary(name = "Bermuda") %>% get_grid(resolution = 0.1, crs = 4326)

bermuda_gfw_effort <- get_gfw(spatial_grid = bermuda_grid, start_year = 2022)

#plot the data
terra::plot(bermuda_gfw_effort)

#get total fishing effort for each gear type in Fiji's EEZ for 2022
fiji_grid <- get_boundary(name = "Fiji") %>% get_grid(resolution = 1e4, crs = "+proj=tcea +lon_0=178 +datum=WGS84 +units=m +no_defs", output = "sf_square")

fiji_gfw_effort <- get_gfw(spatial_grid = fiji_grid, start_year = 2022, end_year = 2022, group_by = "geartype", summarise = "total_annual_effort")

plot(fiji_gfw_effort, border = FALSE)

#quantile is better for viewing the fishing effort distribution due to the long tail of values
plot(fiji_gfw_effort[1], border= FALSE, breaks = "quantile")
}
```
