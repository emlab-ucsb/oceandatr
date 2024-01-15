test_that("returns coral habitat layer with 3 species - bermuda", {
  expect_s4_class(get_coral_habitat(area_polygon = get_area(area_name = "Bermuda")), class = "SpatRaster")
})

test_that("returns coral habitat layer with 3 species - kiribati", {
  expect_s4_class(get_coral_habitat(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1")),
                  class = "SpatRaster")
})

test_that("returns coral habitat layer with 3 species - bermuda gridded", {
  expect_s4_class(get_coral_habitat(planning_grid = get_planning_grid(area_polygon = get_area(area_name = "Bermuda"), 
                                                                      projection_crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                      resolution = 5000)), class = "SpatRaster")
})

# Test failed
test_that("returns coral habitat layer with 3 species - kiribati gridded", {
  expect_s4_class(planning_grid = get_coral_habitat(get_planning_grid(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                                      projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                      resolution = 5000)),
                  class = "SpatRaster")
})

test_that("returns error - antipatharia threshold too low", {
  expect_error(get_coral_habitat(area_polygon = get_area(area_name = "Bermuda"), antipatharia_threshold = -1))
})

test_that("returns error - antipatharia threshold too high", {
  expect_error(get_coral_habitat(area_polygon = get_area(area_name = "Bermuda"), antipatharia_threshold = 101))
})

test_that("returns error - octocoral threshold too low", {
  expect_error(get_coral_habitat(area_polygon = get_area(area_name = "Bermuda"), octocoral_threshold = 0))
})

test_that("returns error - octocoral threshold too high", {
  expect_error(get_coral_habitat(area_polygon = get_area(area_name = "Bermuda"), octocoral_threshold = 8))
})