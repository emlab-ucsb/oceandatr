test_that("returns raw Bio-Oracle data - 11 layer raster", {
  expect_equal(terra::nlyr(get_enviro_regions(get_boundary(name = "Bermuda"), raw = TRUE, enviro_regions = FALSE)), 11)
})

test_that("returns gridded Bermuda Bio-Oracle data - raster", {
  expect_s4_class(get_boundary(name = "Bermuda") |> 
                    get_grid(crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                             resolution = 20000)|> 
                    get_enviro_regions(raw = FALSE, enviro_regions = FALSE), class = "SpatRaster")
})

test_that("returns gridded Bermuda Bio-Oracle data - sf", {
  expect_s3_class(get_boundary(name = "Bermuda") |> 
                    get_grid(crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                             resolution = 20000,
                             output = "sf_square")|> 
                    get_enviro_regions(raw = FALSE, enviro_regions = FALSE), class = "sf")
})

test_that("returns gridded Bermuda enviroregions - raster", {
  expect_s4_class(get_boundary(name = "Bermuda") |> 
                    get_grid(crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                             resolution = 20000,
                             output = "raster")|> 
                    get_enviro_regions(raw = FALSE, enviro_regions = TRUE, num_clusters = 3), class = "SpatRaster")
})

test_that("returns gridded Kiribati enviroregions - sf", {
  expect_s3_class(get_boundary(name = "Kiribati", country_type = "sovereign") |> 
                    get_grid(crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                             resolution = 50000,
                             output = "sf_square") |>
                    get_enviro_regions(raw = FALSE, enviro_regions = TRUE, num_clusters = 3), class = "sf")
})

test_that("returns gridded Bermuda enviroregions data with extra input columns - sf", {
  expect_equal(get_boundary(name = "Bermuda") |> 
                    get_grid(crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                             resolution = 20000,
                             output = "sf_square") |> 
                    dplyr::mutate(extracol1 = 1, extracol2 = 2, .before = 1) |>
                    get_enviro_regions(raw = FALSE, enviro_regions = TRUE, show_plots = TRUE) |>
                 ncol(), 6)
})

test_that("returns error because num_clusters is not a positive integer", {
  expect_error(get_enviro_regions(get_boundary(name = "Bermuda"), num_clusters = 0))
})

test_that("returns error because num_clusters is not an integer", {
  expect_error(get_enviro_regions(get_boundary(name = "Bermuda"), num_clusters = 1.5))
})

test_that("returns error because max_num_clusters is not an integer", {
  expect_error(get_enviro_regions(get_boundary(name = "Bermuda"), max_num_clusters = 10.5))
})

