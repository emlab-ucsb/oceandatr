test_that("returns raw knolls data for Bermuda - sf", {
  expect_s3_class(suppressWarnings(get_knolls(spatial_grid = get_boundary(name = "Bermuda"), raw = TRUE)), 
                  class = "sf")
})

test_that("returns gridded Bermuda data - raster", {
  expect_s4_class(suppressWarnings(get_knolls(spatial_grid = get_bermuda_grid())), 
                  class = "SpatRaster")
})

test_that("returns raw data for Kiribati - sf", {
  expect_s3_class(suppressWarnings(get_knolls(spatial_grid = get_boundary(name = "Kiribati", country_type = "sovereign"), 
                                              raw = TRUE, 
                                              antimeridian = TRUE)), 
                  class = "sf")
})

test_that("returns gridded data for Kiribati - sf", {
  expect_s3_class(suppressWarnings(get_knolls(spatial_grid = get_kiribati_grid(output = "sf_hex"), 
                                              antimeridian = TRUE)), 
                  class = "sf")
})
