test_that("returns SpatRaster object - normal", {
  expect_equal(class(get_bathymetry(get_area(area_name = "Bermuda"))), class(terra::rast(nrows=1, ncols=1, xmin=0, xmax=1)))
})

test_that("returns SpatRaster object - antimeridian", {
  expect_equal(class(get_bathymetry(get_area(area_name = "KIR", mregions_column = "iso_ter1"), antimeridian = TRUE)), class(terra::rast(nrows=1, ncols=1, xmin=0, xmax=1)))
})

test_that("returns error - antimeridian", {
  expect_error(get_bathymetry(get_area(area_name = "KIR", mregions_column = "iso_ter1")))
})
