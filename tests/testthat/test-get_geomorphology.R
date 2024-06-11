test_that("return raw data for Bermuda - sf", {
  expect_s3_class(get_geomorphology(spatial_grid = get_boundary(name = "Bermuda"), raw = TRUE), 
                  class = "sf")
})

test_that("return gridded data for Bermuda - raster", {
  expect_s4_class(get_geomorphology(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                                      crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs',
                                                                      resolution = 20000)), 
                  class = "SpatRaster")
})

test_that("return gridded data for Bermuda - sf", {
  expect_s3_class(get_geomorphology(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                            crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs',
                                                            resolution = 20000,
                                                            output = "sf_hex")), 
                  class = "sf")
})

test_that("return raw data for Kiribati - sf", {
  expect_s3_class(get_geomorphology(spatial_grid = get_boundary(name = "Kiribati", country_type = "sovereign"), raw = TRUE), 
                  class = "sf")
})

test_that("return gridded data for Kiribati  - raster", {
  expect_s4_class(get_geomorphology(spatial_grid = get_grid(get_boundary(name = "Kiribati", country_type = "sovereign"),
                                                            crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs',
                                                            resolution = 50000)), 
                  class = "SpatRaster")
})
