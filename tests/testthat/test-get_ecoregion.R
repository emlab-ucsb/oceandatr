test_that("returns raw MEOW data for Bermuda - sf", {
  expect_s3_class(get_ecoregion(spatial_grid = get_boundary(name = "Bermuda"), raw = TRUE), class = "sf")
})

test_that("returns 6 ecoregions for Kiribati - sf", {
  expect_equal(get_ecoregion(spatial_grid = get_boundary(name = "Kiribati", country_type = "sovereign"), raw = TRUE, antimeridian = TRUE) |> nrow(),
               expected = 6)
})

test_that("returns Bermuda gridded data - raster", {
  expect_s4_class(get_ecoregion(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                            crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                            resolution = 10000, 
                                                        output = "raster"), type = "MEOW"), class = "SpatRaster")
})

test_that("returns Bermuda gridded data for no data - raster", {
  expect_s4_class(get_ecoregion(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                        crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                        resolution = 10000, 
                                                        output = "raster"), type = "LME"), class = "SpatRaster")
})

test_that("returns gridded data for Kiribati - sf", {
  expect_s3_class(get_ecoregion(spatial_grid = get_grid(boundary = get_boundary(name = "Kiribati", country_type = "sovereign"),
                                                            crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs',
                                                            resolution = 50000, 
                                                          output = "sf_square"), type = "Longhurst"),
                  class = "sf")
})

test_that("returns extra columns as well as empty data for sf grid", {
  expect_equal(get_boundary(name = "Bermuda") |> 
                 get_grid(resolution = 10000, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', output = "sf_square") |> 
                 dplyr::mutate(extracol1 = 1, extracol2 = 2, .before = 1) |> 
                 get_ecoregion(type = "LME") |>
                 ncol(), 4)
})
