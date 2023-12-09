test_that("returns SpatRaster object - normal", {
  expect_s4_class(get_bathymetry(get_area(area_name = "Bermuda")), class = c("SpatRaster"))
})

test_that("returns SpatRaster object - antimeridian", {
  expect_s4_class(get_bathymetry(get_area(area_name = "KIR", mregions_column = "iso_ter1")), class = c("SpatRaster"))
})
