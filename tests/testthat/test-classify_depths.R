test_that("returns SpatRaster object (no planning grid)", {
  expect_equal(class(classify_depths(get_bathymetry(get_area(area_name = "Bermuda")))), class(terra::rast(nrows=1, ncols=1, xmin=0, xmax=1)))
})

test_that("returns SpatRaster object (planning grid)", {
  expect_equal(class(classify_depths(get_bathymetry(get_area(area_name = "Bermuda")), 
                                     planning_grid = get_planning_grid(area_polygon = bermuda_eez, 
                                                                       projection_crs = 'PROJCS["ProjWiz_Custom_Lambert_Azimuthal", GEOGCS["GCS_WGS_1984", DATUM["D_WGS_1984", SPHEROID["WGS_1984",6378137.0,298.257223563]], PRIMEM["Greenwich",0.0], UNIT["Degree",0.0174532925199433]], PROJECTION["Lambert_Azimuthal_Equal_Area"], PARAMETER["False_Easting",0.0], PARAMETER["False_Northing",0.0], PARAMETER["Central_Meridian",-64.5], PARAMETER["Latitude_Of_Origin",32], UNIT["Meter",1.0]]',
                                                                       resolution_km = 5))), 
               class(terra::rast(nrows=1, ncols=1, xmin=0, xmax=1)))
})

test_that("returns error, bathymetry raster is not a raster", { 
  expect_error(classify_depths(bathymetry_raster = get_area(area_name = "Bermuda")))
})

test_that("returns error, planning grid is not a raster or sf object", { 
  expect_error(classify_depths(get_bathymetry(get_area(area_name = "Bermuda")), 
                               planning_grid = "none"))
})
