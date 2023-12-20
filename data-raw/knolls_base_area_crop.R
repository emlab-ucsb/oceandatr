## code to prepare knolls base areas dataset

library(sf)

#crop the knolls base area data from [Yesson et al. 2011](https://doi.org/10.1016/j.dsr.2011.02.004) to -180 to 180 extent. The original dataset has a Bounding box: xmin: -181.2542 ymin: -77.88693 xmax: 181.05 ymax: 85.17557

#working paths
data_file_path <- "temp_raw"

sf::st_read(file.path(data_file_path, "01_Data/KnollsBaseArea/KnollsBaseArea.shp")) |>
  sf::st_make_valid() |>
  sf::st_crop(xmin = -180, ymin = -78, xmax = 180, ymax = 86)

terra::vect(file.path(data_file_path, "01_Data/KnollsBaseArea/KnollsBaseArea.shp")) |>
  terra::normalize.longitude()