test_that("returns raw Bermuda data as list", {
  expect_type(suppressWarnings(get_features(spatial_grid = get_boundary(name = "Bermuda"), raw = TRUE, seamount_buffer = NULL)), 
                  type = "list")
})

test_that("returns gridded Bermuda features - raster", {
  expect_s4_class(suppressWarnings(get_features(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                                                        crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                                        resolution = 20000))),
                  class = "SpatRaster")
})

test_that("returns gridded Kiribati features - sf with extra cols", {
  expect_equal(suppressWarnings(get_boundary(name = "Kiribati", country_type = "sovereign") |>
                                     get_grid(crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs',
                                              resolution = 50000, 
                                              output = "sf_square") |>
                                     dplyr::mutate(extracol1 = 1, extracol2 = 2, .before = 1) |>
                                     get_features(antimeridian = TRUE) |>
                                  ncol()), 
               37)
})
