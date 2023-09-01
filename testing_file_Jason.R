devtools::load_all()

bermuda_eez <- get_area("Bermuda")
aus_eez <- get_area("Australia")
fiji_eez <- get_area("Fiji")
fsm_eez <- get_area("Micronesia")

planning_rast_ber <- get_planning_grid(bermuda_eez, projection = 3770, resolution_km = 20)
planning_rast_aus <- get_planning_grid(aus_eez, projection_crs = "ESRI:54009", resolution_km = 20)
planning_rast_fiji <- get_planning_grid(fiji_eez, projection_crs = 3460, resolution_km = 20)
planning_rast_fsm <- get_planning_grid(fsm_eez, projection_crs = "ESRI:54009", resolution_km = 5)

depth_zones_ber <- get_bathymetry(planning_grid = planning_rast_ber)
depth_zones_aus <- get_bathymetry(planning_grid = planning_rast_aus)
depth_zones_fiji <- get_bathymetry(planning_grid = planning_rast_fiji)
depth_zones_fsm <- get_bathymetry(planning_grid = planning_rast_fsm)

terra::plot(depth_zones_ber) 
terra::plot(depth_zones_aus) 
terra::plot(depth_zones_fiji)
terra::plot(depth_zones_fsm)

#sf versions
planning_sf_ber <- get_planning_grid(bermuda_eez, projection = 3770, resolution_km = 20, option = "sf_square")
planning_sf_aus <- get_planning_grid(aus_eez, projection_crs = "ESRI:54009", resolution_km = 20, option = "sf_square")
planning_sf_fiji <- get_planning_grid(fiji_eez, projection_crs = 3460, resolution_km = 20, option = "sf_square")
planning_sf_fsm <- get_planning_grid(fsm_eez, projection_crs = "ESRI:54009", resolution_km = 5, option = "sf_square")

depth_zones_ber_sf <- get_bathymetry(planning_grid = planning_sf_ber)
depth_zones_aus_sf <- get_bathymetry(planning_grid = planning_sf_aus)
depth_zones_fiji_sf <- get_bathymetry(planning_grid = planning_sf_fiji)
depth_zones_fsm_sf <- get_bathymetry(planning_grid = planning_sf_fsm)

plot(depth_zones_ber_sf, border = NA)
plot(depth_zones_aus_sf, border=NA)
plot(depth_zones_fiji_sf, border=NA)
plot(depth_zones_fsm_sf, border=NA)

### Return the bathymetry, unclassified
bathy_aus <- get_bathymetry(planning_grid = planning_rast_aus, classify_bathymetry = FALSE)
bathy_aus_sf <- get_bathymetry(planning_grid = planning_sf_aus, classify_bathymetry = FALSE)

berm_enviro_zones <- get_enviro_regions(area_polygon = bermuda_eez, planning_grid = planning_rast_ber, max_num_clusters = 5)

fiji_enviro_zones <- get_enviro_regions(area_polygon = fiji_eez, planning_grid = planning_rast_fiji)

maldives_eez <- get_area("Maldives")
planning_rast_maldives <- get_planning_grid(maldives_eez, projection = "+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs", resolution_km = 10)

terra::ncell(planning_rast_maldives) # 11088 cells

start_time <- Sys.time()
mld_enviro_zones <- get_enviro_regions(area_polygon = maldives_eez, planning_grid = planning_rast_maldives)
difftime(Sys.time(), start_time)
#took ~34s
gc()

planning_rast_maldives <- get_planning_grid(maldives_eez, projection = "+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs", resolution_km = 7)
terra::ncell(planning_rast_maldives) # 22680 cells

start_time <- Sys.time()
mld_enviro_zones <- get_enviro_regions(area_polygon = maldives_eez, planning_grid = planning_rast_maldives)
difftime(Sys.time(), start_time)
#took ~4mins
gc()

#check it's a NbClust problem, not an issue with our function
mld_enviro_data <- get_enviro_data(area_polygon = maldives_eez, planning_grid = planning_rast_maldives)

start_time <- Sys.time()
mld_enviro_zones2 <- NbClust::NbClust(terra::as.data.frame(mld_enviro_data), max.nc = 8, index = "hartigan", method = "kmeans")
difftime(Sys.time(), start_time)
# took ~5mins
gc()

#######################################
## try alternative clustering with apclust
devtools::load_all()

library(apcluster)
maldives_eez <- get_area("Maldives")
planning_rast_maldives <- get_planning_grid(maldives_eez, projection = "+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs", resolution_km = 20)

terra::ncell(planning_rast_maldives) # 2772 cells

mld_enviro_data <- get_enviro_data(area_polygon = maldives_eez, planning_grid = planning_rast_maldives)

mld_enviro_data_frame <- terra::as.data.frame(mld_enviro_data)

start_time <- Sys.time()
clus_results <- apcluster(negDistMat(r=2), mld_enviro_data_frame, q=0)
difftime(Sys.time(), start_time)

clusters <- labels(clus_results, type = "enum")