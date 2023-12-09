test_that("options for columns matches mregions2", {
  expect_equal(get_area(show_column_options = TRUE), list("mregions_column" = mregions2::mrp_colnames("eez")$colname))
})

test_that("options for values matches mregions2", {
  expect_equal(get_area(show_value_options = TRUE), list("territory1" = mregions2::mrp_col_distinct("eez", "territory1")))
})

test_that("all options match mregions2", {
  expect_equal(get_area(show_value_options = TRUE, show_column_options = TRUE), 
               { cols_available <- mregions2::mrp_colnames("eez")$colname
                 cols_available <- cols_available[!grepl("geom|area", cols_available)]
                 all_options <- lapply(cols_available, function(x){mregions2::mrp_col_distinct("eez", x)})
                 names(all_options) <- cols_available
                 all_options })
})

test_that("bermuda example", { 
  expect_s3_class(get_area("Bermuda"), class = c("sf", "tbl_df", "tbl", "data.frame"))
})

test_that("kiribati example", { 
  expect_s3_class(get_area(area_name = "KIR", mregions_column = "iso_ter1"), class = c("sf", "tbl_df", "tbl", "data.frame"))
})

