test_that("returns gridded Bermuda distance to shore - raster", {
  expect_s4_class(suppressWarnings(get_dist(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                                      crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                      resolution = 10000))), 
                  class = "SpatRaster")
})

test_that("returns gridded distance to shore for Kiribati - sf", {
  expect_s3_class(suppressWarnings(get_dist(spatial_grid = get_grid(boundary = get_boundary(name = "Kiribati", country_type = "sovereign"), 
                                                                      crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                                      resolution = 50000, 
                                                                      output = "sf_hex"))), 
                  class = "sf")
})

test_that("returns gridded distance to port for Kiribati - raster", {
  expect_s3_class(suppressWarnings(get_dist(spatial_grid = get_grid(boundary = get_boundary(name = "Kiribati", country_type = "sovereign"), 
                                                                    crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                                    resolution = 50000, 
                                                                    output = "sf_hex"), dist_to = "ports")), 
                  class = "sf")
})

test_that("returns port point data for Bermuda", {
  expect_s3_class(suppressWarnings(get_dist(spatial_grid = get_boundary(name = "Bermuda"), dist_to = "ports", raw = TRUE)),
                  class = "sf")
})

