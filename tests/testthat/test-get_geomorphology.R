test_that("return list of 4 for Bermuda", {
  expect_equal(length(get_geomorphology(area_polygon = get_area(area_name = "Bermuda"))), 4)
})

test_that("return raster of 4 layers for Bermuda", {
  expect_equal(terra::nlyr(get_geomorphology(area_polygon = get_area(area_name = "Bermuda"), 
                                             planning_grid = get_planning_grid(area_polygon = bermuda_eez, 
                                                                               projection_crs = 'PROJCS["ProjWiz_Custom_Lambert_Azimuthal", GEOGCS["GCS_WGS_1984", DATUM["D_WGS_1984", SPHEROID["WGS_1984",6378137.0,298.257223563]], PRIMEM["Greenwich",0.0], UNIT["Degree",0.0174532925199433]], PROJECTION["Lambert_Azimuthal_Equal_Area"], PARAMETER["False_Easting",0.0], PARAMETER["False_Northing",0.0], PARAMETER["Central_Meridian",-64.5], PARAMETER["Latitude_Of_Origin",32], UNIT["Meter",1.0]]',
                                                                               resolution_km = 5))), 4)
})
