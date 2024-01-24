test_that("returns bermuda example - sf", {
  expect_s3_class(suppressWarnings(get_seamounts_buffered(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"), 
                                                          buffer = 30000)), class = "sf")
})

test_that("returns kiribati example - sf", {
  expect_s3_class(suppressWarnings(get_seamounts_buffered(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                                          buffer = 30000, 
                                                          antimeridian = TRUE)), class = "sf")
})

test_that("returns bermuda example - raster", {
  expect_s4_class(suppressWarnings(get_seamounts_buffered(planning_grid = get_planning_grid(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"), 
                                                                                        projection_crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                                        resolution = 5000), 
                                                          buffer = 30000)),
                  class = "SpatRaster")
})

test_that("returns kiribati example - raster", {
  expect_s4_class(suppressWarnings(get_seamounts_buffered(planning_grid = get_planning_grid(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                                                                        projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                                                        resolution = 5000), 
                                                          buffer = 30000, 
                                                          antimeridian = TRUE)), 
                  class = "SpatRaster")
})
