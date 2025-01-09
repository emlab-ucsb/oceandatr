test_that("returns Bermuda classified depths", {
  expect_s4_class(get_bathymetry(get_boundary(name = "Bermuda"), raw = TRUE), class = "SpatRaster")
})

test_that("returns raw Kiribati data", {
  expect_s4_class(get_bathymetry(get_boundary(name = "Kiribati", country_type = "sovereign"), raw = TRUE, classify_bathymetry = FALSE), class = "SpatRaster")
})

test_that("returns gridded Bermuda depth classes", {
  expect_s4_class(get_bathymetry(spatial_grid = get_bermuda_grid()), class = "SpatRaster")
})

# test_that("returns Kiribati gridded depth classes", {
#   expect_s4_class(get_bathymetry(spatial_grid = kiribati_grid()),
#                   class = "SpatRaster")
# })

test_that("returns gridded Bermuda depth classes", {
  expect_s3_class(get_bathymetry(spatial_grid = get_bermuda_grid(output = "sf_hex")), class = "sf")
})

test_that("returns extra columns as well as depth classes for sf grid", {
  expect_equal(get_bermuda_grid(resolution = 10, output = "sf_square") |> 
                 dplyr::mutate(extracol1 = 1, extracol2 = 2, .before = 1) |> 
                 get_bathymetry() |>
                 ncol(), 7)
})