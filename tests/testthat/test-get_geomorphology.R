test_that("return correct object for Bermuda - sf", {
  expect_s3_class(suppressMessages(suppressWarnings(get_geomorphology(area_polygon = get_area(area_name = "Bermuda")))), 
                  class = "sf")
})

test_that("return correct object for Bermuda - raster", {
  expect_s4_class(suppressMessages(suppressWarnings(get_geomorphology(planning_grid = get_planning_grid(area_polygon = get_area(area_name = "Bermuda"), 
                                                                      projection_crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs',
                                                                      resolution = 5000)))), 
                  class = "SpatRaster")
})

test_that("return correct object for Kiribati - sf", {
  expect_s3_class(suppressMessages(suppressWarnings(get_geomorphology(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1")))), 
                  class = "sf")
})

# Test failed
test_that("return correct object for Kiribati - raster", {
  expect_s4_class(suppressMessages(suppressWarnings(get_geomorphology(planning_grid = get_planning_grid(get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                                                                                        projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs',
                                                                                                        resolution = 5000)))), 
                  class = "SpatRaster")
})
