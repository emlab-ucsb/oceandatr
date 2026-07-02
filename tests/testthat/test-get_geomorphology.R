test_that("return raw data for Bermuda - sf", {
  expect_s3_class(get_geomorphology(spatial_grid = get_bermuda_eez(), raw = TRUE), 
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

test_that("return raw data for Fiji - sf", {
  expect_s3_class(get_geomorphology(spatial_grid = get_fiji_eez(), raw = TRUE), 
                  class = "sf")
})

test_that("return gridded data for Fiji  - raster", {
  expect_s4_class(get_geomorphology(spatial_grid = get_fiji_grid()), 
                  class = "SpatRaster")
})
