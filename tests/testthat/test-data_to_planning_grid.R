test_that("returns bermuda example of planning grid - raster", {
  expect_s4_class(suppressWarnings(data_to_planning_grid(planning_grid = get_planning_grid(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"), projection_crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 5000),
                        dat = system.file("extdata", "knolls.rds", package = "oceandatr", mustWork = TRUE) %>% readRDS())), 
                        class = "SpatRaster")
  
})

test_that("returns bermuda example of planning grid - sf", {
  expect_s3_class(suppressWarnings(data_to_planning_grid(area_polygon = get_area(area_name = "Bermuda", mregions_column = "territory1"), 
                                                         dat = system.file("extdata", "knolls.rds", package = "oceandatr", mustWork = TRUE) %>% readRDS())), 
                  class = "sf")
  
})

# Test failed
test_that("returns kiribati example (antimeridian example) of planning grid - raster", {
  expect_s4_class(suppressWarnings(data_to_planning_grid(planning_grid = get_planning_grid(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                                                                           projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', 
                                                                                           resolution = 5000),
                                                         dat = system.file("extdata", "knolls.rds", package = "oceandatr", mustWork = TRUE) %>% readRDS(), 
                                                         antimeridian = TRUE)), 
                  class = "SpatRaster")
  
})

test_that("returns kiribati example (antimeridian example) of planning grid - sf", {
  expect_s3_class(suppressWarnings(data_to_planning_grid(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1"), 
                                                         dat = system.file("extdata", "knolls.rds", package = "oceandatr", mustWork = TRUE) %>% readRDS(), 
                                                         antimeridian = TRUE)), 
                  class = "sf")
  
})
