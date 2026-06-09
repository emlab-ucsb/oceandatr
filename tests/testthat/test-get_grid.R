test_that("return grid for Samoa - raster", {
  expect_s4_class(get_grid(boundary = get_boundary(name = "Samoa", type = "eez", country_type = "country"),
                                    crs = '+proj=laea +lon_0=-172.5 +lat_0=0 +datum=WGS84 +units=m +no_defs',
                                    resolution = 10000),
                  class = "SpatRaster")
})

test_that("return grid for Samoa - sf square", {
  expect_s3_class(get_grid(boundary = get_boundary(name = "Samoa", type = "eez", country_type = "country"),
                                    crs = '+proj=laea +lon_0=-172.5 +lat_0=0 +datum=WGS84 +units=m +no_defs',
                                    output = "sf_square",
                                    resolution = 10000),
                  class = "sf")
})

test_that("return grid for Samoa - sf hex", {
  expect_s3_class(get_grid(boundary = get_boundary(name = "Samoa", type = "eez", country_type = "country"),
                                    crs = '+proj=laea +lon_0=-172.5 +lat_0=0 +datum=WGS84 +units=m +no_defs',
                                    output = "sf_hex",
                                    resolution = 10000),
                  class = "sf")
})

test_that("return grid for kiribati - raster", {
  expect_s4_class(get_grid(boundary =  get_boundary(name = "Kiribati", type = "eez", country_type = "sovereign"),
                                    crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs',
                                    resolution = 50000),
                  class = "SpatRaster")
})



test_that("return planning grid for kiribati - sf square", {
  expect_s3_class(get_grid(boundary =  get_boundary(name = "Kiribati", type = "eez", country_type = "sovereign"),
                                    crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs',
                                    output = "sf_square",
                                    resolution = 50000),
                  class = "sf")
})



test_that("return planning grid for kiribati - raster", {
  expect_s3_class(get_grid(boundary =  get_boundary(name = "Kiribati", type = "eez", country_type = "sovereign"),
                                    crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs',
                                    output = "sf_hex",
                                    resolution = 50000),
                  class = "sf")
})
