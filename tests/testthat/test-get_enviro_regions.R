test_that("returns enviro regions as raster with 3 layers - bermuda", {
  expect_equal(terra::nlyr(get_enviro_regions(get_area(area_name = "Bermuda", mregions_column = "territory1"), num_clusters = 3)), 3)
})

test_that("returns enviro regions as raster with 3 layers - kiribati", {
  expect_equal(terra::nlyr(get_enviro_regions(get_area(area_name = "KIR", mregions_column = "iso_ter1"), num_clusters = 3, 
                                              antimeridian = TRUE)), 3)
})

test_that("returns enviro regions as raster with 3 layers - bermuda gridded", {
  expect_equal(terra::nlyr(get_enviro_regions(spatial_grid = get_grid(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"), 
                                                                                projection_crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                                resolution = 5000),
                                              num_clusters = 3)), 3)
})

test_that("returns enviro regions as raster with 3 layers - kiribati", {
  expect_equal(terra::nlyr(get_enviro_regions(spatial_grid = get_grid(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                                                                projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                                                resolution = 5000),
                                              antimeridian = TRUE, 
                                              num_clusters = 3)), 3)
})

test_that("returns raw data as raster with 12 layers", {
  expect_equal(terra::nlyr(get_enviro_regions(get_area(area_name = "Bermuda", mregions_column = "territory1"), raw_data = TRUE)), 12)
})

test_that("returns error because num_clusters is not a positive integer", {
  expect_error(get_enviro_regions(get_area(area_name = "Bermuda", mregions_column = "territory1"), num_clusters = 0))
})

test_that("returns error because num_clusters is not an integer", {
  expect_error(get_enviro_regions(get_area(area_name = "Bermuda", mregions_column = "territory1"), num_clusters = 1.5))
})

test_that("returns error because max_num_clusters is not an integer", {
  expect_error(get_enviro_regions(get_area(area_name = "Bermuda", mregions_column = "territory1"), max_num_clusters = 10.5))
})

