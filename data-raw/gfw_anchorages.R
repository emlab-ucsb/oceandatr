# The GFW anchorages data can be downloaded from the GFW data page (login required, but is free): https://globalfishingwatch.org/data-download/datasets/public-anchorages
#This datasets is big (~167, 000 rows) and finding distance from each of these points to cells in a grid will take too long on and too much memory for most computers. GFW identifies anchorages as anywhere vessels with AIS remain stationary for 12 hours or more, which can lead to many anchorages very close to each other, e.g. outside ports where vessels wait for docks to become available. Anchorages close together have the same names, so to reduce the number of anchorages, they are aggregated by iso3 code (country code) and label (name) and the mean longitude and latitude coordinates obtained to get one anchorage point per name in each country.
#To further reduce the number of points, anchorages within countries' land boundaries, e.g. along rivers, can be removed. I do this by buffering the Natural Earth land boundaries by 10km inland so as to avoid cutting off coastal anchorages that fall within the land boundary, due to inaccuracies in the Natural Earth land boundaries, e.g. for islands and other small scale coastlines, and then masking points that fall within the resulting polygons.

natural_earth_high_res <- rnaturalearth::ne_countries(scale = 10, returnclass = "sv") |> terra::aggregate()

natural_earth_high_res_shrunk <- terra::buffer(natural_earth_high_res, -1e4)

#read in most recent anchorages data. According to GFW, last update was 2023_11_1
anchorages_all <- read.csv("inst/extdata/named_anchorages_v2_20221206.csv") |>
  subset(!(lat < -90 | lat > 90 | lon < -180 | lon > 180)) #there is a point at longitude = 1001!

#aggregate anchorages to get the mean anchorage (coordinates) per unique label and iso3 code
anchorages_name_grouped <- anchorages_all |>
  aggregate(cbind(lon, lat) ~ label + iso3, data = _, FUN = function(x) mean(x)) |>
  terra::vect(crs = "epsg:4326") 

anchorages_name_grouped_masked_index <- terra::is.related(anchorages_name_grouped, natural_earth_high_res_shrunk, relation = "intersects")

anchorages_name_grouped_masked <- cbind(anchorages_name_grouped, anchorages_name_grouped_masked_index)

names(anchorages_name_grouped_masked) <- c("label", "iso3", "on_land")

anchorages_all <- anchorages_all |>
  terra::vect(crs = "epsg:4326") 

#map to check - cropped for small, complex area of Baltic coast. Toggle "y" on and off to see points
baltic_ext <- terra::ext(c(10, 40, 50, 60))

terra::plet(terra::crop(anchorages_name_grouped_masked, baltic_ext), "on_land", cex = 0.5) |> terra::points(terra::crop(anchorages_all, baltic_ext), col = "forestgreen", alpha = 1, cex =2) |> terra::lines(terra::crop(natural_earth_high_res, baltic_ext), "brown") |> terra::lines(terra::crop(natural_earth_high_res_shrunk, baltic_ext), "pink")
  
  #this checks that no anchorages with the same label (name assigned to it) cross the antimeridian - they don't. So we can safely group anchorages by label and 
   read.csv("inst/extdata/named_anchorages_v2_20221206.csv") |>
    subset(!(lat < -90 | lat > 90 | lon < -180 | lon > 180)) |>  #there is a point at longitude = 1001!
    #check for anchorages with same name that cross the antimeridian
    subset(lon > 160 | lon < -160) |> #points close to the antimeridian
    within(antimeridian_code <- ifelse(lon < -170, 1, 2))|> #similar to dplyr::mutate
    aggregate(antimeridian_code ~ label + iso3, data = _, FUN = function(x) length(unique(x))) |> #get unique number of antimeridian crossing codes for each label
    _[["antimeridian_code"]] |>
    unique() #only 1 antimeridian code per labelled anchorage, so none of the anchorages with the same label (name) have points on both sides of the antimeridian
   
  #save two datasets: one with all the anchorages, points only, and one with anchorages grouped by name with a column for the land mask (TRUE = point is over land)
   
anchorages_all |>
  terra::crds(df = TRUE) |>
  saveRDS("inst/extdata/anchorages_all.rds")

anchorages_name_grouped_masked[, "on_land"] |>
  terra::as.data.frame(geom = "XY") |>
  saveRDS("inst/extdata/anchorages_grouped.rds")
   
   

