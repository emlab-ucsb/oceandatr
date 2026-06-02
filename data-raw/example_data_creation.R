#creating small datasets for use in package examples

#retrieve Kiribati EEZ from marineregions - to have an EEZ that crosses the antimeridian

kir_eez <- mregions2::mrp_get("eez", cql_filter = "iso_ter1 = 'KIR'") |>
  dplyr::select(sovereign1)

#retrieve Samoan EEZ - small EEZ that doesn't cross the antimeridian but almost within the same extent as Kiribati

samoa_eez <- mregions2::mrp_get("eez", cql_filter = "territory1 = 'Samoa'") |>
  dplyr::select(sovereign1)

#get polygon of both EEZs
poly_samoa_kir <- rbind(samoa_eez |> sf::st_cast(to = "MULTIPOLYGON"), kir_eez)

#get LHS of antimeridan polygon extent

lhs_polygon <- poly_samoa_kir |>
  sf::st_crop(xmin = 0, ymin = as.numeric(sf::st_bbox(poly_samoa_kir)$ymin), xmax = 180, ymax = as.numeric(sf::st_bbox(poly_samoa_kir)$ymax))

rhs_polygon <- poly_samoa_kir |>
  sf::st_crop(xmin = -180, ymin = as.numeric(sf::st_bbox(poly_samoa_kir)$ymin), xmax = 0, ymax = as.numeric(sf::st_bbox(poly_samoa_kir)$ymax))

#get ridges base polygon extent just for extent of the Samoa and Kiribati EEZs
ridges <- system.file("extdata/geomorphology", "ridges.rds", package = "oceandatrsets", mustWork = TRUE) |>
  readRDS()

rbind(sf::st_crop(ridges, lhs_polygon), sf::st_crop(ridges, rhs_polygon)) |>
  saveRDS("inst/extdata/ridges_pacific.rds")

#get some coral data

system.file("extdata/cold_coral.tif", package = "oceandatrsets", mustWork = TRUE) |>
  terra::rast() |>
  terra::crop(poly_samoa_kir) |>
  terra::writeRaster("inst/extdata/cold_coral_pacific.tif", gdal = c("COMPRESS=ZSTD", "PREDICTOR=2", "ZSTD_LEVEL=22", "NUM_THREADS=10"), datatype = "INT1U")

#use original abyssal classification data from Harris et al. 2014 dataset, available at https://www.bluehabitats.org.

abyss_data_path_temp <- "data-raw/abyss/Abyssal_Classification.shp"
abyssal_classes <- sf::read_sf(abyss_data_path_temp)

sf::sf_use_s2(FALSE)
rbind(sf::st_crop(abyssal_classes, lhs_polygon), sf::st_crop(abyssal_classes, rhs_polygon)) |>
  sf::st_cast(to = "MULTIPOLYGON") |>
  saveRDS("inst/extdata/abyssal_classes_pacific.rds")
sf::sf_use_s2(TRUE)
