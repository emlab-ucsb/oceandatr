test_that("returns Bermuda raw peaks data - sf points", {
  expect_s3_class(suppressWarnings(get_seamounts(spatial_grid = get_bermuda_eez(), raw = TRUE, buffer = NULL)), class = "sf")
})

test_that("returns Bermuda raw peaks data buffered - sf", {
  expect_s3_class(suppressWarnings(get_seamounts(spatial_grid = get_bermuda_eez(), 
                                                 raw = TRUE, 
                                                 buffer = 30000)), class = "sf")
})

test_that("returns Fiji raw data - sf points", {
  expect_s3_class(suppressWarnings(get_seamounts(spatial_grid = get_fiji_eez(),
                                                 raw = TRUE, 
                                                 buffer = NULL,
                                                 antimeridian = TRUE)), class = "sf")
})

test_that("returns Fiji raw peaks data buffered - sf", {
  expect_s3_class(suppressWarnings(get_seamounts(spatial_grid = get_fiji_eez(),
                                                 raw = TRUE, 
                                                 buffer = 50000, 
                                                 antimeridian = TRUE)), 
                  class = "sf")
})

test_that("returns buffered gridded Bermuda seamounts - raster", {
  expect_s4_class(suppressWarnings(get_seamounts(spatial_grid = get_bermuda_grid(),
                                                 raw = FALSE,
                                                 buffer = 30000)),
                  class = "SpatRaster")
})

test_that("returns buffered gridded Fiji seamounts - raster", {
  expect_s4_class(suppressWarnings(get_seamounts(spatial_grid = get_fiji_grid(),
                                   raw = FALSE, 
                                   buffer = 30000, 
                                   antimeridian = TRUE)), 
                  class = "SpatRaster")
})

test_that("returns buffered gridded Bermuda seamounts - sf", {
  expect_s3_class(suppressWarnings(get_seamounts(spatial_grid = get_bermuda_grid(output = "sf_square"),
                                                 raw = FALSE,
                                                 buffer = 30000)),
                  class = "sf")
})

test_that("returns buffered gridded Fiji seamounts - sf", {
  expect_s3_class(suppressWarnings(get_seamounts(spatial_grid = get_fiji_grid(output = "sf_hex"),
                                                 raw = FALSE, 
                                                 buffer = 30000, 
                                                 antimeridian = TRUE)), 
                  class = "sf")
})