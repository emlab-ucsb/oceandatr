test_that("retrieving eez matches mregions2", {
  expect_equal(get_boundary(name = "Bermuda", type = "eez", country_type = "country"), mregions2::mrp_get("eez", cql_filter = "territory1 = 'Bermuda'"))
})

test_that("eez is sf object", {
  expect_s3_class(get_boundary(name = "Tonga", type = "eez", country_type = "sovereign"), "sf")
})

test_that("12nm is sf object", {
  expect_s3_class(get_boundary(name = "Bermuda", type = "12nm", country_type = "country"), "sf")
})

test_that("oceans is sf object", {
  expect_s3_class(get_boundary(name = "Indian Ocean", type = "ocean", country_type = "sovereign"), "sf")
})

test_that("retrieving a country matches rnaturalearth", {
  expect_equal(get_boundary(name = "Australia", type = "country", country_type = "country"), rnaturalearth::ne_countries(scale = 10, type = "countries", country = "Australia"))
})

test_that("country is sf object", {
  expect_s3_class(get_boundary(name = "France", type = "country", country_type = "sovereign"), "sf")
})

test_that("bermuda example, correct number of features", {
  expect_equal(nrow(get_boundary("Bermuda", type = "eez", country_type = "country")), 1)
  })

test_that("kiribati example, correct numner of features", {
  expect_equal(nrow(get_boundary(name = "Kiribati", type = "eez", country_type = "sovereign")),3)
})

test_that("sea_oceans returns sf object", {
  expect_s3_class(get_boundary(name = "Aegean Sea", type = "seas_oceans"),
                  "sf")
})
