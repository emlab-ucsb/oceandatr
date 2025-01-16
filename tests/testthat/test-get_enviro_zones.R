test_that("returns raw Bio-Oracle data - 11 layer raster", {
  expect_equal(terra::nlyr(get_enviro_zones(get_boundary(name = "Bermuda"), raw = TRUE, enviro_zones = FALSE)), 11)
})

test_that("returns gridded Bermuda Bio-Oracle data - raster", {
  set.seed(500)
  expect_s4_class(get_bermuda_grid()|> 
                    get_enviro_zones(raw = FALSE, enviro_zones = FALSE), class = "SpatRaster")
})

test_that("returns gridded Bermuda Bio-Oracle data - sf", {
  set.seed(500)
  expect_s3_class(get_bermuda_grid(output = "sf_square")|> 
                    get_enviro_zones(raw = FALSE, enviro_zones = FALSE), class = "sf")
})

test_that("returns gridded Bermuda envirozones - raster", {
  expect_s4_class(get_bermuda_grid()|> 
                    get_enviro_zones(raw = FALSE, enviro_zones = TRUE, num_clusters = 3), class = "SpatRaster")
})

test_that("returns gridded Kiribati envirozones - sf", {
  expect_s3_class(get_kiribati_grid(output = "sf_square") |>
                    get_enviro_zones(raw = FALSE, enviro_zones = TRUE, num_clusters = 3), class = "sf")
})

test_that("returns gridded Bermuda envirozones data with extra input columns - sf", {
  set.seed(500)
  expect_equal(get_bermuda_grid(output = "sf_square") |> 
                    dplyr::mutate(extracol1 = 1, extracol2 = 2, .before = 1) |>
                    get_enviro_zones(raw = FALSE, enviro_zones = TRUE, show_plots = TRUE) |>
                 ncol(), 6)
})

test_that("returns error because num_clusters is not a positive integer", {
  expect_error(get_enviro_zones(get_boundary(name = "Bermuda"), num_clusters = 0))
})

test_that("returns error because num_clusters is not an integer", {
  expect_error(get_enviro_zones(get_boundary(name = "Bermuda"), num_clusters = 1.5))
})

test_that("returns error because max_num_clusters is not an integer", {
  expect_error(get_enviro_zones(get_boundary(name = "Bermuda"), max_num_clusters = 10.5))
})

