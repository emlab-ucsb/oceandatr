# There are aggregate points by country (iso code) and label
#original anchorages downloaded from GFW data page: https://globalfishingwatch.org/data-download/datasets/public-anchorages
library(magrittr)
test <-read.csv("inst/extdata/named_anchorages_v2_20221206.csv") |>
  subset(!(lat < -90 | lat > 90 | lon < -180 | lon > 180)) %>%  #there is a point at longitude = 1001!
  aggregate(by = list(Name = .[,"label"], Country_code = .[, "iso3"]), FUN = mean) %>% 
  {.[, c("Name", "Country_code", "lon", "lat")]} %>% 
  dplyr::mutate(lon = dplyr::case_when(lon < 0 ~ lon+360,
                                       .default = lon)) |>
  terra::vect(crs = "epsg:4326") |>
 # terra::crop(c(-180, -170, -90,90)) |>
  terra::plot("Country_code")
  saveRDS("inst/extdata/gfw_anchorages.rds")
  
  read.csv("inst/extdata/named_anchorages_v2_20221206.csv") |>
    subset(!(lat < -90 | lat > 90 | lon < -180 | lon > 180)) %>%  #there is a point at longitude = 1001!
    dplyr::mutate(lon = dplyr::case_when(lon < 0 ~ lon+360,
                                         .default = lon)) |>
    subset(lon > 175 & lon < 185) |>
    write.csv("../../Downloads/anchorages_360_anitmerid.csv")