test_that("returns knolls in bermuda - sf", {
  expect_s3_class(suppressWarnings(get_knolls(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"))), 
                  class = "sf")
})

test_that("returns knolls in bermuda - gridded", {
  expect_s4_class(suppressWarnings(get_knolls(spatial_grid = get_grid(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"), 
                                                                                projection_crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                                                                resolution = 5000))), 
                  class = "SpatRaster")
})

test_that("returns knolls in kiribati - sf", {
  expect_s3_class(suppressWarnings(get_knolls(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                              antimeridian = TRUE)), 
                  class = "sf")
})

# Test failing... 
test_that("returns knolls in kiribati - gridded", {
  expect_s4_class(suppressWarnings(get_knolls(spatial_grid = get_grid(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                                                                projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                                                resolution = 5000), 
                                              antimeridian = TRUE)), 
                  class = "SpatRaster")
})
