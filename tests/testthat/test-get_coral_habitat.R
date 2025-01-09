test_that("returns raw data for Bermuda", {
  expect_s4_class(get_coral_habitat(spatial_grid = get_boundary(name = "Bermuda"), raw = TRUE), class = "SpatRaster")
})

# test_that("check raw raster data has 3 layers", {
#   expect_equal(get_coral_habitat(spatial_grid = get_boundary(name = "Kiribati", country_type = "sovereign"), raw = TRUE, antimeridian = TRUE) |> terra::nlyr(),
#                expected = 3)
# })

test_that("returns Bermuda gridded data - raster", {
  expect_s4_class(get_coral_habitat(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                                      crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                      resolution = 10000)), class = "SpatRaster")
})

test_that("returns gridded data for Kiribati - raster", {
  expect_s4_class(get_coral_habitat(spatial_grid = get_grid(boundary = get_boundary(name = "Kiribati", country_type = "sovereign"),
                                                      crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs',
                                                      resolution = 50000)),
                  class = "SpatRaster")
})

test_that("returns gridded data for Bermuda - sf", {
  expect_s3_class(get_coral_habitat(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                            crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                            resolution = 10000, 
                                                            output = "sf_square")), class = "sf")
})

test_that("returns extra columns as well as coral data for sf grid", {
  expect_equal(get_boundary(name = "Bermuda") |> 
                 get_grid(resolution = 10000, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', output = "sf_square") |> 
                 dplyr::mutate(extracol1 = 1, extracol2 = 2, .before = 1) |> 
                 get_coral_habitat() |>
                 ncol(), 6)
})

test_that("returns error - antipatharia threshold too low", {
  expect_error(get_coral_habitat(spatial_grid = get_boundary(name = "Bermuda"), antipatharia_threshold = -1))
})

test_that("returns error - antipatharia threshold too high", {
  expect_error(get_coral_habitat(spatial_grid = get_boundary(name = "Bermuda"), antipatharia_threshold = 101))
})

test_that("returns error - octocoral threshold too low", {
  expect_error(get_coral_habitat(spatial_grid = get_boundary(name = "Bermuda"), octocoral_threshold = 0))
})

test_that("returns error - octocoral threshold too high", {
  expect_error(get_coral_habitat(spatial_grid = get_boundary(name = "Bermuda"), octocoral_threshold = 8))
})
