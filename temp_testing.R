library(oceandatr)
library(magrittr)
library(sf)

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

#raster
boundaries <- mapply(get_boundary, name = states, country_type = country_type, SIMPLIFY = FALSE) 

boundaries$pacific_hs <- pacific_hs

grids <- boundaries %>% 
  mapply(get_grid, ., resolution = resolutions, crs = prjs, SIMPLIFY = FALSE)


for (i in 1:length(grids)) terra::plot(grids[[i]])

dists_shore <- lapply(grids,get_dist_shore, inverse = TRUE)

for (i in 1:length(dists_shore)) terra::plot(dists_shore[[i]])

#sf
grids_sf <- boundaries  %>% 
  mapply(get_grid, ., resolution = resolutions, crs = prjs, output = "sf_square", SIMPLIFY = FALSE)

for (i in 1:length(grids_sf)) plot(grids_sf[[i]])

dists_shore_sf <- lapply(grids_sf,get_dist_shore, inverse = TRUE)

for (i in 1:length(dists_shore_sf)) plot(dists_shore_sf[[i]], border = F)

#wpi ports distance

dist_ports_ras <- lapply(grids, FUN = function(x) get_dist(spatial_grid = x, inverse = FALSE))

for (i in 1:length(dist_ports_ras)) terra::plot(dist_ports_ras[[i]])
