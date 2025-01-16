test_that("returns gridded Bermuda distance to shore - raster", {
  expect_s4_class(suppressWarnings(get_dist(spatial_grid = get_bermuda_grid())), 
                  class = "SpatRaster")
})

test_that("returns gridded distance to shore for Kiribati - sf", {
  expect_s3_class(suppressWarnings(get_dist(spatial_grid = get_kiribati_grid(output = "sf_hex"))), 
                  class = "sf")
})

test_that("returns gridded distance to port for Kiribati - raster", {
  expect_s3_class(suppressWarnings(get_dist(spatial_grid = get_kiribati_grid(output = "sf_hex"), dist_to = "ports")), 
                  class = "sf")
})

test_that("returns port point data for Bermuda", {
  expect_s3_class(suppressWarnings(get_dist(spatial_grid = get_boundary(name = "Bermuda"), dist_to = "ports", raw = TRUE)),
                  class = "sf")
})

