test_that("return raw data for Bermuda - sf", {
  expect_s3_class(get_geomorphology(spatial_grid = get_boundary(name = "Bermuda"), raw = TRUE), 
                  class = "sf")
})

test_that("return gridded data for Bermuda - raster", {
  expect_s4_class(get_geomorphology(spatial_grid = get_bermuda_grid()), 
                  class = "SpatRaster")
})

test_that("return gridded data for Bermuda - sf", {
  expect_s3_class(get_geomorphology(spatial_grid = get_bermuda_grid(output = "sf_hex")), 
                  class = "sf")
})

test_that("return raw data for Kiribati - sf", {
  expect_s3_class(get_geomorphology(spatial_grid = get_boundary(name = "Kiribati", country_type = "sovereign"), raw = TRUE), 
                  class = "sf")
})

test_that("return gridded data for Kiribati  - raster", {
  expect_s4_class(get_geomorphology(spatial_grid = get_kiribati_grid()), 
                  class = "SpatRaster")
})
