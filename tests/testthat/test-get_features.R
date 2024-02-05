test_that("returns bermuda example", {
  expect_type(suppressWarnings(get_features(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"))), 
                  type = "list")
})

test_that("returns kiribati example", {
  expect_type(suppressWarnings(get_features(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                                      antimeridian = TRUE)), type = "list")
})

test_that("returns bermuda example - gridded", {
  expect_s4_class(suppressWarnings(get_features(spatial_grid = get_grid(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"), 
                                                                                        projection_crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                                        resolution = 5000))),
                  class = "SpatRaster")
})

# Test failed
test_that("returns kiribati example - gridded", {
  expect_s4_class(suppressWarnings(get_features(spatial_grid = get_grid(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                                                                        projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                                                        resolution = 5000), 
                                                      antimeridian = TRUE)), 
                  class = "SpatRaster")
})
