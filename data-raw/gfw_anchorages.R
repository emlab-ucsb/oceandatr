#retain only the points from the GFW anchorages data.
#original anchorages downloaded from GFW data page: https://globalfishingwatch.org/data-download/datasets/public-anchorages
(read.csv("inst/extdata/named_anchorages_v2_20221206.csv"))[,c("lon", "lat")] |>
  dplyr::filter(!(lat < -90 | lat > 90 | lon < -180 | lon > 180)) |>#there is a point at longitude = 1001!
  saveRDS("inst/extdata/gfw_anchorages.rds")
  