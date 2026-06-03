test_that("returns gridded Bermuda depth classes", {
  expect_s4_class(get_bathymetry(spatial_grid = get_bermuda_grid()), class = "SpatRaster")
})

test_that("returns Kiribati gridded depth classes", {
  expect_s4_class(get_bathymetry(spatial_grid = get_kiribati_grid()),
                  class = "SpatRaster")
})

#allow for variation of resolution in depth data - expect greater than 6 columns
test_that("returns extra columns as well as depth classes for sf grid", {
  expect_gte(get_bermuda_grid(resolution = 10, output = "sf_square") |> 
                 dplyr::mutate(extracol1 = 1, extracol2 = 2, .before = 1) |> 
                 get_bathymetry() |>
                 ncol(), 6)
})
