test_that("returns raw knolls data for Bermuda - sf", {
  expect_s3_class(suppressWarnings(get_knolls(spatial_grid = get_boundary(name = "Bermuda"), raw = TRUE)), 
                  class = "sf")
})

test_that("returns gridded Bermuda data - raster", {
  expect_s4_class(suppressWarnings(get_knolls(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                                                crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                                resolution = 10000))), 
                  class = "SpatRaster")
})

test_that("returns raw data for Kiribati - sf", {
  expect_s3_class(suppressWarnings(get_knolls(spatial_grid = get_boundary(name = "Kiribati", country_type = "sovereign"), 
                                              raw = TRUE, 
                                              antimeridian = TRUE)), 
                  class = "sf")
})

test_that("returns gridded data for Kiribati - sf", {
  expect_s3_class(suppressWarnings(get_knolls(spatial_grid = get_grid(boundary = get_boundary(name = "Kiribati", country_type = "sovereign"), 
                                                                                crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                                                resolution = 50000, 
                                                                      output = "sf_hex"), 
                                              antimeridian = TRUE)), 
                  class = "sf")
})
