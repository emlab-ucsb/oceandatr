test_that("returns Bermuda raw peaks data - sf", {
  expect_s3_class(suppressWarnings(get_seamounts(spatial_grid = get_boundary(name = "Bermuda"), raw = TRUE, buffer = NULL)), class = "sf")
})

test_that("returns kiribati example - sf", {
  expect_s3_class(suppressWarnings(get_seamounts(spatial_grid = get_boundary(name = "Kiribati", country_type = "sovereign"), 
                                                      antimeridian = TRUE)), class = "sf")
})

test_that("returns bermuda example - raster", {
  expect_s4_class(suppressWarnings(get_seamounts(spatial_grid = get_grid(spatial_grid = get_boundary(name = "Bermuda", mregions_column = "territory1"), 
                                                                                        projection_crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                                        resolution = 20000))),
                  class = "SpatRaster")
})

test_that("returns kiribati example - raster", {
  expect_s4_class(suppressWarnings(get_seamounts(spatial_grid = get_grid(spatial_grid = get_boundary(name = "Kiribati", country_type = "sovereign"), 
                                                                                        projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                                                        resolution = 50000), 
                                                      antimeridian = TRUE)), 
                  class = "SpatRaster")
})

