library(magrittr)
library(sf)

devtools::load_all()
states <- c("Bermuda", "Micronesia", "Kiribati")

country_type <- c("country", "country", "sovereign")

prjs <- list('+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs',

             
                          3832, 
             '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs',
             '+proj=cea +lon_0=145 +lat_ts=3 +datum=WGS84 +units=m +no_defs')

resolutions <- c(1e4, 2e4, 5e4, 1e4)

#get a Pacific high seas polygon
sf_use_s2(FALSE)
pacific_hs <- get_boundary(type = "high_seas") %>% 
  st_crop(c(xmin = 135, xmax = 155, ymin = 0, ymax = 6)) %>% 
  st_sf()
sf_use_s2(TRUE)

#raster distance to shore
boundaries <- mapply(get_boundary, name = states, country_type = country_type, SIMPLIFY = FALSE) 

boundaries$pacific_hs <- pacific_hs

grids <- boundaries %>% 
  mapply(get_grid, ., resolution = resolutions, crs = prjs, SIMPLIFY = FALSE)


for (i in 1:length(grids)) terra::plot(grids[[i]])

dists_shore <- lapply(grids, FUN = function(x) get_dist(x, ports = F))

for (i in 1:length(dists_shore)) terra::plot(dists_shore[[i]])

#sf grid distance to shore
grids_sf <- boundaries  %>% 
  mapply(get_grid, ., resolution = resolutions, crs = prjs, output = "sf_square", SIMPLIFY = FALSE)

for (i in 1:length(grids_sf)) plot(grids_sf[[i]])

dists_shore_sf <- lapply(grids_sf, FUN = function(x) get_dist(x, ports = F, inverse = F))

for (i in 1:length(dists_shore_sf)) plot(dists_shore_sf[[i]], border = F)

#wpi ports distance

dist_ports_ras <- list()
run_times <- c()

for(i in 1:length(grids)){
  start_time <- Sys.time()
  dist_ports_ras[[i]] <- get_dist(spatial_grid = grids[[i]], inverse = FALSE)
  run_times[i] <- Sys.time() - start_time
}

for (i in 1:length(dist_ports_ras)) terra::plot(dist_ports_ras[[i]])

#sf wpi ports
dist_ports_sf <- list()
run_times_sf <- c()

for(i in 1:length(grids_sf)){
  start_time <- Sys.time()
  dist_ports_sf[[i]] <- get_dist(spatial_grid = grids_sf[[i]], inverse = FALSE)
  run_times_sf[i] <- Sys.time() - start_time
}

for (i in 1:length(dist_ports_sf)) plot(dist_ports_sf[[i]], border = F)

#check Pacfic ports distance look right
sf_use_s2(FALSE)
countries <- rnaturalearth::countries110 |>
  st_crop(c(xmin = 125, xmax = 165, ymin = -10, ymax = 16)) |>
  terra::vect() |>
  terra::project(prjs[[4]])

sf_use_s2(TRUE)
pacific_ports_dist <- get_dist(terra::rast(extent = terra::ext(countries), crs = prjs[[4]], resolution = 1e4, vals = 1), inverse = FALSE)

ports_wpi <- utils::read.csv(file.path(tempdir(), "wpi_ports.csv")) %>% 
  sf::st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326) |>
  st_transform(st_crs(prjs[[4]]))


terra::plot(dist_ports_ras[[4]], ext = terra::ext(countries))
terra::lines(countries)
terra::points(ports_wpi)

terra::plot(pacific_ports_dist)
terra::lines(countries)
terra::points(ports_wpi)
#check the Pacific High seas distance to port calculations look right
terra::plot(dist_ports_ras[[4]], add =T)

#gfw ports distance

dist_ports_ras_gfw <- list()
run_times_ras_gfw <- c()

for(i in 1:length(grids)){
  i <- 1
  start_time <- Sys.time()
  dist_ports_ras_gfw[[i]] <- get_dist(spatial_grid = grids[[i]], inverse = FALSE, ports_data = "gfw")
  run_times_ras_gfw[i] <- Sys.time() - start_time
}

for (i in 1:length(dist_ports_ras_gfw)) terra::plot(dist_ports_ras_gfw[[i]])



