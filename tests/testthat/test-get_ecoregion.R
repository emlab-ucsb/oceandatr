test_that("returns raw MEOW data for Bermuda - sf", {
  expect_s3_class(get_ecoregion(spatial_grid = get_boundary(name = "Bermuda"), raw = TRUE), class = "sf")
})

test_that("returns 6 ecoregions for Kiribati - sf", {
  expect_equal(get_ecoregion(spatial_grid = get_boundary(name = "Kiribati", country_type = "sovereign"), raw = TRUE, antimeridian = TRUE) |> nrow(),
               expected = 6)
})

test_that("returns Bermuda gridded data - raster", {
  expect_s4_class(get_ecoregion(spatial_grid = get_bermuda_grid(), type = "MEOW"), class = "SpatRaster")
})

test_that("returns Bermuda gridded data for no data - raster", {
  expect_s4_class(get_ecoregion(spatial_grid = get_bermuda_grid(), type = "LME"), class = "SpatRaster")
})

test_that("returns gridded data for Kiribati - sf", {
  expect_s3_class(get_ecoregion(spatial_grid = get_kiribati_grid(output = "sf_square"), type = "Longhurst"),
                  class = "sf")
})

test_that("returns extra columns as well as empty data for sf grid", {
  expect_equal(get_bermuda_grid(output = "sf_square") |> 
                 dplyr::mutate(extracol1 = 1, extracol2 = 2, .before = 1) |> 
                 get_ecoregion(type = "LME") |>
                 ncol(), 4)
})
