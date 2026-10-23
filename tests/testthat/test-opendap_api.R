# A DAP2 data response for a variable of 3 values, as the server would send it: the dataset descriptor, a line
# 'Data:', the number of values (twice), then the values, all big-endian
dods_header <- "Dataset {\n    Int16 x[x = 3];\n} test;\nData:\n"

make_dods <- function(values, type = "integer"){
  c(charToRaw(dods_header),
    writeBin(rep(length(values), 2L), raw(), size = 4, endian = "big"),
    if(type == "integer") writeBin(as.integer(values), raw(), size = 4, endian = "big")
    else writeBin(as.double(values), raw(), size = 8, endian = "big"))
}

is_transient <- function(e) inherits(e, "oceandatr_transient_error")

test_that("values are read from a data response, including negative Int16 values", {
  values <- c(-4870L, 12L, 0L, 32767L, -32768L)
  expect_identical(opendap_parse_values(make_dods(values), n_values = 5, type = "integer"), values)
})

test_that("double values are read from a data response", {
  values <- c(-89.99791667, 0.5, 89.99791667)
  expect_equal(opendap_parse_values(make_dods(values, "double"), n_values = 3, type = "double"), values)
})

test_that("a response that is cut short anywhere is an error that is worth trying again", {
  body <- make_dods(1:5)
  header_length <- length(charToRaw(dods_header))
  for(cut_at in c(20, header_length, header_length + 5, header_length + 15, length(body) - 1)){
    error <- expect_error(opendap_parse_values(body[seq_len(cut_at)], n_values = 5), "incomplete|not a DAP2")
    expect_true(is_transient(error), info = paste("cut at byte", cut_at))
  }
})

test_that("a different number of values to that expected is an error that is not worth trying again", {
  error <- expect_error(opendap_parse_values(make_dods(1:5), n_values = 6), "dataset may have changed")
  expect_false(is_transient(error))
})

test_that("a response that is not a data response is an error that is not worth trying again", {
  error <- expect_error(
    opendap_parse_values(charToRaw("Error {\n code = 2;\n message = \"not found\";\n};"), n_values = 5),
    "not a DAP2 data response")
  expect_false(is_transient(error))
  expect_error(opendap_parse_values(charToRaw("<html>502 Bad Gateway</html>"), n_values = 5), "not a DAP2 data response")
})

test_that("a download that fails with a transient error is tried again", {
  attempts <- 0
  expect_message(
    result <- opendap_retry(function(){ attempts <<- attempts + 1; if(attempts < 3) opendap_abort("cut short", transient = TRUE) else "data" },
                            wait = function(attempt) 0, description = "chunk 2", service_name = "svc", service_url = "url"),
    "Trying again")
  expect_equal(result, "data")
  expect_equal(attempts, 3)
})

test_that("a download that fails with a permanent error is not tried again", {
  attempts <- 0
  expect_error(
    opendap_retry(function(){ attempts <<- attempts + 1; opendap_abort("bad request") },
                  wait = function(attempt) 0, description = "chunk 2", service_name = "svc", service_url = "url"),
    "bad request")
  expect_equal(attempts, 1)
})

test_that("an error says how many attempts were made when a download keeps failing", {
  attempts <- 0
  expect_error(
    suppressMessages(opendap_retry(function(){ attempts <<- attempts + 1; opendap_abort("cut short", transient = TRUE) },
                                   max_attempts = 3, wait = function(attempt) 0, description = "chunk 2",
                                   service_name = "the GEBCO service", service_url = "https://example.com")),
    "the GEBCO service.*after 3 attempts")
  expect_equal(attempts, 3)
})

test_that("the size and type of GEBCO grid are read from the dataset", {
  testthat::skip_if_offline()
  info <- opendap_array_info(gebco_url, "elevation", service_name = gebco_service_name)
  expect_true(info$type %in% c("Int16", "Int32"))
  expect_identical(names(info$dims), c("lat", "lon"))
  expect_true(all(info$dims > 1000))
})

test_that("a variable that is not in the dataset is an error", {
  testthat::skip_if_offline()
  expect_error(opendap_array_info(gebco_url, "not_a_variable", service_name = gebco_service_name), "no variable called")
})

test_that("the request for GEBCO values of the wrong size is an error, and isn't tried again", {
  testthat::skip_if_offline()
  # 4 values are in this part of the grid
  expect_identical(length(opendap_read_values(gebco_url, "elevation.elevation[9999:10000][9999:10000]", 4, "integer", gebco_service_name)), 4L)
  expect_error(opendap_read_values(gebco_url, "elevation.elevation[9999:10000][9999:10000]", 5, "integer", gebco_service_name),
               "dataset may have changed")
})
