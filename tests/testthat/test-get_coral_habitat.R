test_that("returns coral habitat layer with 3 species - bermuda", {
  expect_s4_class(get_coral_habitat(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1")), class = "SpatRaster")
})

# test_that("returns coral habitat layer with 3 species - kiribati", {
#   expect_s4_class(get_coral_habitat(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1")),
#                   class = "SpatRaster")
# })

test_that("returns coral habitat layer with 3 species - bermuda gridded", {
  expect_s4_class(get_coral_habitat(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                                      crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                      resolution = 10000)), class = "SpatRaster")
})

test_that("returns coral habitat layer with 3 species - kiribati gridded", {
  expect_s4_class(get_coral_habitat(spatial_grid = get_grid(boundary = get_area(area_name = "KIR", mregions_column = "iso_ter1"),
                                                      projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs',
                                                      resolution = 5000)),
                  class = "SpatRaster")
})

test_that("returns gridded data for Bermuda - sf", {
  expect_s3_class(get_coral_habitat(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                            crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                            resolution = 10000, 
                                                            output = "sf_square")), class = "sf")
})

test_that("returns error - antipatharia threshold too low", {
  expect_error(get_coral_habitat(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"), antipatharia_threshold = -1))
})

test_that("returns error - antipatharia threshold too high", {
  expect_error(get_coral_habitat(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"), antipatharia_threshold = 101))
})

test_that("returns error - octocoral threshold too low", {
  expect_error(get_coral_habitat(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"), octocoral_threshold = 0))
})

test_that("returns error - octocoral threshold too high", {
  expect_error(get_coral_habitat(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"), octocoral_threshold = 8))
})
