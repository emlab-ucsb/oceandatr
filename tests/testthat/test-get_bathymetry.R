test_that("returns Bermuda classified depths", {
  expect_s4_class(get_bathymetry(get_boundary(name = "Bermuda"), raw = TRUE), class = "SpatRaster")
})

test_that("returns raw Kiribati data", {
  expect_s4_class(get_bathymetry(get_boundary(name = "Kiribati", country_type = "sovereign"), raw = TRUE, classify_bathymetry = FALSE), class = "SpatRaster")
})

test_that("returns gridded Bermuda depth classes", {
  expect_s4_class(get_bathymetry(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                                   crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                   resolution = 20000)), class = "SpatRaster")
})

test_that("returns Kiribati gridded depth classes", {
  expect_s4_class(get_bathymetry(spatial_grid = get_grid(boundary =  get_boundary(name = "Kiribati", country_type = "sovereign"), 
                                                                  crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                                   resolution = 50000)),
                  class = "SpatRaster")
})

test_that("returns gridded Bermuda depth classes", {
  expect_s3_class(get_bathymetry(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                         crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                         resolution = 20000,
                                                         output = "sf_hex")), class = "sf")
})