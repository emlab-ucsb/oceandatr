test_that("returns raw Bio-Oracle data as raster with 11 layers", {
  expect_equal(terra::nlyr(get_enviro_regions(get_boundary(name = "Bermuda"), raw = TRUE, enviro_regions = FALSE)), 11)
})

test_that("returns gridded Bermuda Bio-Oracle data - sf", {
  expect_s3_class(get_enviro_regions(get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                       crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                       resolution = 20000, 
                                                       output = "sf_square"), raw = FALSE, enviro_regions = FALSE), class = "sf")
})

test_that("returns Bermuda enviro regions using raw Bio-Oracle data", {
  expect_equal(terra::nlyr(get_enviro_regions(spatial_grid = get_boundary(name = "Bermuda"), raw = TRUE, num_clusters = 3)), 3)
})

test_that("returns enviro regions as raster with 3 layers - kiribati", {
  expect_equal(terra::nlyr(get_enviro_regions(get_boundary(name = "Kiribati", country_type = "sovereign"), num_clusters = 3, 
                                              antimeridian = TRUE)), 3)
})

test_that("returns enviro regions as raster with 3 layers - bermuda gridded", {
  expect_equal(terra::nlyr(get_enviro_regions(spatial_grid = get_grid(boundary = get_boundary(name = "Bermuda"), 
                                                                                crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                                resolution = 10000),
                                              num_clusters = 3)), 3)
})

test_that("returns enviro regions as raster with 3 layers - kiribati", {
  expect_equal(terra::nlyr(get_enviro_regions(spatial_grid = get_grid(boundary = get_boundary(name = "Kiribati", country_type = "sovereign"), 
                                                                                crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                                                resolution = 50000),
                                              antimeridian = TRUE, 
                                              num_clusters = 3)), 3)
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

