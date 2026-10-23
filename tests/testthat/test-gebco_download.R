# A small area (about 0.25 x 0.25 degrees, i.e. about 60 x 60 cells) of the GEBCO grid, to test the download with
small_area <- function(){
  sf::st_as_sfc(sf::st_bbox(c(xmin = -64.90, xmax = -64.65, ymin = 32.20, ymax = 32.45), crs = 4326)) |>
    sf::st_sf()
}

# Coordinates of the centres of the cells of the GEBCO grid, and the value of a cell given its coordinates, read
# directly from the dataset (independently of how the raster is made)
gebco_coordinates <- function(){
  list(lat = opendap_read_values(gebco_url, "lat", n_values = 43200, type = "double", service_name = gebco_service_name),
       lon = opendap_read_values(gebco_url, "lon", n_values = 86400, type = "double", service_name = gebco_service_name))
}

gebco_value_at <- function(x, y, coordinates){
  ix <- which.min(abs(coordinates$lon - x))
  iy <- which.min(abs(coordinates$lat - y))
  opendap_read_values(gebco_url,
                      constraint = sprintf("elevation.elevation[%d:%d][%d:%d]", iy - 1, iy - 1, ix - 1, ix - 1),
                      n_values = 1, type = "integer", service_name = gebco_service_name)
}

# download the area as one chunk, or as several small chunks
download_gebco <- function(max_cells_at_a_time){
  path <- tempfile("gebco_test_")
  dir.create(path)
  coordinates <- gebco_coordinates()
  bbox <- sf::st_bbox(small_area())
  gebco_data_fetch(min_x = bbox[["xmin"]], max_x = bbox[["xmax"]], min_y = bbox[["ymin"]], max_y = bbox[["ymax"]],
                   file_path = file.path(path, "test.tif"),
                   gebco_lat_values = coordinates$lat, gebco_lon_values = coordinates$lon,
                   max_cells_at_a_time = max_cells_at_a_time)
  terra::rast(file.path(path, "test.tif"))
}

test_that("downloaded GEBCO raster is positioned so cells are centred on the GEBCO coordinates", {
  testthat::skip_if_offline()
  coordinates <- gebco_coordinates()
  bathymetry <- suppressMessages(download_gebco(max_cells_at_a_time = 5e6))

  # distance from the centre of each column / row to the nearest GEBCO longitude / latitude. If the raster was half
  # a cell out of position, this would be half a cell (about 0.002 degrees)
  distance_to_nearest <- function(x, grid) vapply(x, function(v) min(abs(grid - v)), numeric(1))

  expect_lt(max(distance_to_nearest(terra::xFromCol(bathymetry, seq_len(terra::ncol(bathymetry))), coordinates$lon)), 1e-8)
  expect_lt(max(distance_to_nearest(terra::yFromRow(bathymetry, seq_len(terra::nrow(bathymetry))), coordinates$lat)), 1e-8)
})

test_that("values are in the right place when the area is downloaded in several chunks", {
  testthat::skip_if_offline()
  coordinates <- gebco_coordinates()
  one_chunk <- suppressMessages(download_gebco(max_cells_at_a_time = 5e6))
  many_chunks <- suppressMessages(download_gebco(max_cells_at_a_time = 300))

  # with 300 cells per chunk, the number of rows in a chunk is
  rows_in_chunk <- ceiling(300 / terra::ncol(many_chunks))
  # the area needs several chunks, and the last chunk (the northernmost rows, the first in the raster) is a partial one
  expect_gte(ceiling(terra::nrow(one_chunk) / rows_in_chunk), 3)
  rows_in_last_chunk <- terra::nrow(one_chunk) %% rows_in_chunk
  expect_gt(rows_in_last_chunk, 0)
  
  expect_equal(dim(many_chunks), dim(one_chunk))
  expect_equal(as.vector(terra::ext(many_chunks)), as.vector(terra::ext(one_chunk)))
  expect_false(anyNA(terra::values(many_chunks)))
  expect_identical(terra::values(many_chunks), terra::values(one_chunk))

  # and the value of cells, including those in the first and last rows, and either side of where the chunks join, are
  # the same as the GEBCO value for the coordinates of the centre of the cell
  seams <- rows_in_last_chunk + rows_in_chunk * 0:2
  rows <- sort(unique(c(1, seams, seams + 1, terra::nrow(many_chunks) - 1, terra::nrow(many_chunks))))
  cols <- c(1, 10, terra::ncol(many_chunks))
  for(row in rows){
    for(col in cols){
      expect_equal(as.numeric(terra::values(many_chunks, row = row, nrows = 1)[col]),
                   as.numeric(gebco_value_at(terra::xFromCol(many_chunks, col), terra::yFromRow(many_chunks, row), coordinates)),
                   info = paste("row", row, "col", col))
    }
  }
})

test_that("downloaded data are saved to a file for the GEBCO release, and used again if it is already there", {
  testthat::skip_if_offline()
  path <- tempfile("gebco_test_")
  dir.create(path)
  area <- sf::st_geometry(small_area()) |> sf::st_sf()

  first <- suppressMessages(get_gebco_bathymetry(area, path = path, antimeridian = FALSE))
  expect_match(list.files(path), "^bathy_gebco2026_.*\\.tif$")
  expect_message(second <- get_gebco_bathymetry(area, path = path, antimeridian = FALSE), "already downloaded")
  expect_identical(as.numeric(terra::values(first)), as.numeric(terra::values(second)))
})

test_that("an area that crosses the antimeridian is downloaded all the way to it, with no gap in the data", {
  testthat::skip_if_offline()
  coordinates <- gebco_coordinates()
  path <- tempfile("gebco_test_")
  dir.create(path)

  # a small area either side of the antimeridian (as polygons are, split at it)
  area <- sf::st_sfc(
    sf::st_multipolygon(list(
      list(rbind(c(179.9, -17.5), c(180, -17.5), c(180, -17.4), c(179.9, -17.4), c(179.9, -17.5))),
      list(rbind(c(-180, -17.5), c(-179.9, -17.5), c(-179.9, -17.4), c(-180, -17.4), c(-180, -17.5)))
    )), crs = 4326) |>
    sf::st_sf()

  merged <- suppressMessages(get_gebco_bathymetry(area, path = path, antimeridian = TRUE))
  files <- list.files(path, full.names = TRUE)
  east <- terra::rast(grep("gebco2026_179\\.9_180_", files, value = TRUE))
  west <- terra::rast(grep("gebco2026_-180_-179\\.9_", files, value = TRUE))

  # each side reaches the antimeridian exactly
  expect_equal(terra::ext(east)[2][[1]], 180)
  expect_equal(terra::ext(west)[1][[1]], -180)

  # the first and last columns of the GEBCO grid are in the data, and have the right values
  expect_equal(terra::ncol(merged), 86400)
  rows <- c(1, 10, terra::nrow(merged))
  for(row in rows){
    y <- terra::yFromRow(merged, row)
    expect_equal(as.numeric(terra::values(merged, row = row, nrows = 1)[terra::ncol(merged)]),
                 as.numeric(gebco_value_at(coordinates$lon[86400], y, coordinates)), info = paste("last column, row", row))
    expect_equal(as.numeric(terra::values(merged, row = row, nrows = 1)[1]),
                 as.numeric(gebco_value_at(coordinates$lon[1], y, coordinates)), info = paste("first column, row", row))
  }
})

test_that("an area that reaches the north pole is downloaded all the way to it", {
  testthat::skip_if_offline()
  coordinates <- gebco_coordinates()
  path <- tempfile("gebco_test_")
  dir.create(path)
  file_path <- file.path(path, "pole.tif")

  suppressMessages(gebco_data_fetch(min_x = 0, max_x = 0.25, min_y = 89.8, max_y = 90, file_path = file_path,
                                    gebco_lat_values = coordinates$lat, gebco_lon_values = coordinates$lon))
  pole <- terra::rast(file_path)

  expect_equal(terra::ext(pole)[4][[1]], 90)
  # the top row is the last row of the GEBCO grid
  x <- terra::xFromCol(pole, 5)
  expect_equal(as.numeric(terra::values(pole, row = 1, nrows = 1)[5]),
               as.numeric(gebco_value_at(x, coordinates$lat[43200], coordinates)))
})
