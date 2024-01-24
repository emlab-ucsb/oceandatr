test_that("return planning grid for bermuda - raster", {
  expect_s4_class(get_planning_grid(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"), 
                                    projection_crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                    resolution = 5000), 
                  class = "SpatRaster")
})

test_that("return planning grid for bermuda - sf square", {
  expect_s3_class(get_planning_grid(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"), 
                                    projection_crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                    option = "sf_square", 
                                    resolution = 5000), 
                  class = "sf")
})

test_that("return planning grid for bermuda - sf hex", {
  expect_s3_class(get_planning_grid(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"), 
                                    projection_crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', 
                                    option = "sf_hex", 
                                    resolution = 5000), 
                  class = "sf")
})

test_that("return planning grid for kiribati - raster", {
  expect_s4_class(get_planning_grid(area_polygon =  get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                    projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                    resolution = 5000), 
                  class = "SpatRaster")
})



test_that("return planning grid for kiribati - sf square", {
  expect_s3_class(get_planning_grid(area_polygon =  get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                    projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                    option = "sf_square", 
                                    resolution = 5000), 
                  class = "sf")
})



test_that("return planning grid for kiribati - raster", {
  expect_s3_class(get_planning_grid(area_polygon =  get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                    projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                    option = "sf_hex", 
                                    resolution = 5000), 
                  class = "sf")
})
