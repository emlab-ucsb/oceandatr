test_that("returns knolls in bermuda", {
  expect_s3_class(suppressWarnings(get_knolls(area_polygon = get_area(area_name = "Bermuda"))), 
                  class = "sf")
})

test_that("returns knolls in kiribati", {
  expect_s3_class(suppressWarnings(get_knolls(area_polygon = get_area(area_name = "KIR", mregions_column = "iso_ter1"))), 
                  class = "sf")
})
