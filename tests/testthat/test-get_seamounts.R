test_that("returns Bermuda raw peaks data - sf points", {
  expect_s3_class(suppressWarnings(get_seamounts(spatial_grid = get_boundary(name = "Bermuda"), raw = TRUE, buffer = NULL)), class = "sf")
})

test_that("returns Bermuda raw peaks data buffered - sf", {
  expect_s3_class(suppressWarnings(get_seamounts(spatial_grid = get_boundary(name = "Bermuda"), 
                                                 raw = TRUE, 
                                                 buffer = 30000)), class = "sf")
})

test_that("returns Kiribati raw data - sf points", {
  expect_s3_class(suppressWarnings(get_seamounts(spatial_grid = get_boundary(name = "Kiribati", country_type = "sovereign"),
                                                 raw = TRUE, 
                                                 buffer = NULL,
                                                 antimeridian = TRUE)), class = "sf")
})

test_that("returns Kiribati raw peaks data buffered - sf", {
  expect_s3_class(suppressWarnings(get_seamounts(spatial_grid = get_boundary(name = "Kiribati", country_type = "sovereign"),
                                                 raw = TRUE, 
                                                 buffer = 50000, 
                                                 antimeridian = TRUE)), 
                  class = "sf")
})

test_that("returns buffered gridded Bermuda seamounts - raster", {
  expect_s4_class(suppressWarnings(get_seamounts(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                                         crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                         resolution = 20000),
                                                 raw = FALSE,
                                                 buffer = 30000)),
                  class = "SpatRaster")
})

test_that("returns buffered gridded Kiribati seamounts - raster", {
  expect_s4_class(suppressWarnings(get_seamounts(spatial_grid = get_grid(boundary = get_boundary(name = "Kiribati", country_type = "sovereign"), 
                                                                                        crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                                                        resolution = 50000),
                                   raw = FALSE, 
                                   buffer = 30000, 
                                   antimeridian = TRUE)), 
                  class = "SpatRaster")
})

test_that("returns buffered gridded Bermuda seamounts - sf", {
  expect_s3_class(suppressWarnings(get_seamounts(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                                         crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                         resolution = 20000, 
                                                                         output = "sf_square"),
                                                 raw = FALSE,
                                                 buffer = 30000)),
                  class = "sf")
})

test_that("returns buffered gridded Kiribati seamounts - sf", {
  expect_s3_class(suppressWarnings(get_seamounts(spatial_grid = get_grid(boundary = get_boundary(name = "Kiribati", country_type = "sovereign"), 
                                                                         crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                                         resolution = 50000,
                                                                         output = "sf_hex"),
                                                 raw = FALSE, 
                                                 buffer = 30000, 
                                                 antimeridian = TRUE)), 
                  class = "sf")
})