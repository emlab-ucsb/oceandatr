test_that("returns raw Bermuda data as list", {
  expect_type(suppressWarnings(get_features(spatial_grid = get_boundary(name = "Bermuda"), raw = TRUE, seamount_buffer = NULL)), 
                  type = "list")
})

test_that("returns gridded Bermuda features - raster", {
  set.seed(500)
  expect_s4_class(suppressWarnings(get_features(spatial_grid = get_bermuda_grid())),
                  class = "SpatRaster")
})

test_that("returns gridded Kiribati features - sf with extra cols", {
  set.seed(1234)
  expect_equal(suppressWarnings(get_kiribati_grid(output = "sf_square") |>
                                     dplyr::mutate(extracol1 = 1, extracol2 = 2, .before = 1) |>
                                     get_features(antimeridian = TRUE) |>
                                  ncol()), 
               41)
})
