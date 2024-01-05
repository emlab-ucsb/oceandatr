## code to prepare knolls base areas dataset

#crop the knolls base area data from [Yesson et al. 2011](https://doi.org/10.1016/j.dsr.2011.02.004) to -180 to 180 extent. The original dataset has a Bounding box: xmin: -181.2542 ymin: -77.88693 xmax: 181.05 ymax: 85.17557

#working paths
data_file_path <- "temp_raw/01_Data/KnollsBaseArea/KnollsBaseArea.shp"

sf::st_read(data_file_path) |>
  geojsonsf::sf_geojson() |>
  rmapshaper::ms_clip(bbox = c(-180, -78, 180, 86)) |>
  geojsonsf::geojson_sf() |>
  dplyr::select(PEAKID, DEPTH, HEIGHT, LONG, LAT, AREA2D, FILTER) |>
  saveRDS("inst/extdata/knolls.rds")
