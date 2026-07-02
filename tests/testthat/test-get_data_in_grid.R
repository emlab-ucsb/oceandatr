test_that("returns Bermuda example of gridded data - raster", {
  expect_s4_class(suppressWarnings(get_data_in_grid(spatial_grid = get_bermuda_grid(),
                                                    dat = readRDS(system.file("extdata/geomorphology", "ridges.rds", package = "oceandatrsets", mustWork = TRUE)))),
                        class = "SpatRaster")

})

test_that("returns Bermuda example of raw data  - sf", {
  expect_s3_class(suppressWarnings(get_data_in_grid(spatial_grid = get_bermuda_eez(),
                                                    dat = readRDS(system.file("extdata/geomorphology", "ridges.rds", package = "oceandatrsets")),
                                                    raw = TRUE)),
                  class = "sf")

})


test_that("returns fiji example (antimeridian example) of gridded data - raster", {
  expect_s4_class(suppressWarnings(get_data_in_grid(spatial_grid = get_fiji_grid(),
                                                    dat = terra::rast(system.file("extdata", "cold_coral.tif", package = "oceandatrsets")),
                                                    antimeridian = TRUE, 
                                                    meth = "near")),
                  class = "SpatRaster")

})

test_that("returns fiji example (antimeridian example) of raw data - sf", {
  expect_s3_class(suppressWarnings(get_data_in_grid(spatial_grid = get_fiji_eez(),
                                                    dat = readRDS(system.file("extdata/geomorphology", "ridges.rds", package = "oceandatrsets")),
                                                    raw = TRUE,
                                                    antimeridian = TRUE)),
                  class = "sf")

})

test_that("returns samoa example of multi-column sf gridded data - sf", {
  expect_s3_class(suppressWarnings(get_data_in_grid(spatial_grid = get_grid(boundary = get_boundary(name = "Samoa", type = "eez", country_type = "country"),
                                                    crs = '+proj=laea +lon_0=-172.5 +lat_0=0 +datum=WGS84 +units=m +no_defs',
                                                    resolution = 10000,
                                                    output = "sf_square"),
                                                    dat = readRDS(system.file("extdata", "abyssal_classes_pacific.rds", package = "oceandatr")),
                                                    feature_names = "Class")),
                  class = "sf")

})
