test_that("returns enviro regions as raster with 3 layers", {
  expect_equal(terra::nlyr(get_enviro_regions(get_area(area_name = "Bermuda"), num_clusters = 3)), 3)
})

test_that("returns raw data as raster with 12 layers", {
  expect_equal(terra::nlyr(get_enviro_regions(get_area(area_name = "Bermuda"), raw_data = TRUE)), 12)
})

test_that("returns error because num_clusters is not a positive integer", {
  expect_error(get_enviro_regions(get_area(area_name = "Bermuda"), num_clusters = 0))
})

test_that("returns error because num_clusters is not an integer", {
  expect_error(get_enviro_regions(get_area(area_name = "Bermuda"), num_clusters = 1.5))
})

test_that("returns error because max_num_clusters is not an integer", {
  expect_error(get_enviro_regions(get_area(area_name = "Bermuda"), max_num_clusters = 10.5))
})

