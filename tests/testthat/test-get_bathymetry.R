test_that("returns bermuda example", {
  expect_s4_class(get_bathymetry(get_area(area_name = "Bermuda")), class = "SpatRaster")
})

test_that("returns kiribati example", {
  expect_s4_class(get_bathymetry(get_area(area_name = "KIR", mregions_column = "iso_ter1")), class = "SpatRaster")
})

test_that("returns bermuda example - gridded", {
  expect_s4_class(get_bathymetry(planning_grid = get_planning_grid(area_polygon = get_area(area_name = "Bermuda"), 
                                                                   projection_crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                   resolution = 5000)), class = "SpatRaster")
})

test_that("returns kiribati example - gridded", {
  expect_s4_class(get_bathymetry(planning_grid = get_planning_grid(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                                                   projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                                   resolution = 5000)),
                  class = "SpatRaster")
})

