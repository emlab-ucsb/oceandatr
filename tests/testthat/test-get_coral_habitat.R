test_that("returns coral habitat layer with 3 species", {
  expect_equal(terra::nlyr(get_coral_habitat(area_polygon = get_area(area_name = "Bermuda"))), 3)
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