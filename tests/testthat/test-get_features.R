test_that("returns raw Bermuda data as list", {
  expect_type(suppressWarnings(get_features(spatial_grid = get_bermuda_eez(), raw = TRUE, seamount_buffer = NULL)), 
                  type = "list")
})

test_that("returns gridded Bermuda features - raster", {
  set.seed(500)
  expect_s4_class(suppressWarnings(get_features(spatial_grid = get_bermuda_grid())),
                  class = "SpatRaster")
})
