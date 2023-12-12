test_that("return correct object for Bermuda - sf", {
  expect_s3_class(suppressMessages(suppressWarnings(get_geomorphology(area_polygon = get_area(area_name = "Bermuda")))), 
                  class = c("sf", "data.frame"))
})

test_that("return correct object for Bermuda - raster", {
  expect_s4_class(suppressMessages(suppressWarnings(get_geomorphology(planning_grid = get_planning_grid(area_polygon = get_area(area_name = "Bermuda"), 
                                                                      projection_crs = 'PROJCS["ProjWiz_Custom_Lambert_Azimuthal", GEOGCS["GCS_WGS_1984", DATUM["D_WGS_1984", SPHEROID["WGS_1984",6378137.0,298.257223563]], PRIMEM["Greenwich",0.0], UNIT["Degree",0.0174532925199433]], PROJECTION["Lambert_Azimuthal_Equal_Area"], PARAMETER["False_Easting",0.0], PARAMETER["False_Northing",0.0], PARAMETER["Central_Meridian",-64.5], PARAMETER["Latitude_Of_Origin",32], UNIT["Meter",1.0]]',
                                                                      resolution = 5000)))), 
                  class = c("SpatRaster"))
})
