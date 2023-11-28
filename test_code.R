devtools::load_all()

#Bermuda
ber_proj_wiz <- "+proj=laea +lon_0=-64.8220825 +lat_0=32.2530756 +datum=WGS84 +units=m +no_defs"

bermuda_eez <- get_area("Bermuda")
planning_rast_ber <- get_planning_grid(bermuda_eez, projection_crs = ber_proj_wiz, resolution_km = 5)
planning_sf_ber <- get_planning_grid(bermuda_eez, projection_crs = ber_proj_wiz, resolution_km = 5, option = "sf_square")


ber_knolls <- data_to_planning_grid(area_polygon = bermuda_eez, dat = knolls)
plot(ber_knolls)

ber_knoll_pu <- data_to_planning_grid(planning_grid = planning_rast_ber, dat = knolls)
terra::plot(ber_knoll_pu)

ber_knolls_pu_sf <- data_to_planning_grid(planning_grid = planning_sf_ber, dat = knolls)
plot(ber_knolls_pu_sf, border = FALSE)

ber_bathy <- get_bathymetry(bermuda_eez, classify_bathymetry = FALSE)
terra::plot(ber_bathy)

ber_bathy_pu_ras <- get_bathymetry(planning_grid = planning_rast_ber, classify_bathymetry = TRUE)
terra::plot(ber_bathy_pu_ras)

ber_bathy_pu_sf <- get_bathymetry(planning_grid = planning_sf_ber, classify_bathymetry = TRUE)
plot(ber_bathy_pu_sf, border = FALSE)

ber_corals <- get_coral_habitat(area_polygon = bermuda_eez)
terra::plot(ber_corals)

ber_corals_pu_ras <- get_coral_habitat(planning_grid = planning_rast_ber) 
terra::plot(ber_corals_pu_ras)

ber_corals_pu_sf <- get_coral_habitat(planning_grid = planning_sf_ber)
plot(ber_corals_pu_sf, border = F)

ber_geomorph <- get_geomorphology(area_polygon = bermuda_eez)
plot(ber_geomorph)

ber_geomorph_pu_ras <- get_geomorphology(planning_grid = planning_rast_ber)
terra::plot(ber_geomorph_pu_ras)

ber_geomorph_pu_sf <- get_geomorphology(planning_grid = planning_sf_ber)
plot(ber_geomorph_pu_sf, border = F)

ber_seamounts <- get_seamount_peaks(area_polygon = bermuda_eez)
plot(sf::st_geometry(bermuda_eez))
plot(sf::st_geometry(ber_seamounts), pch = 2, col = "brown4", add=T)

ber_seamounts_pu_ras <- get_seamount_peaks(planning_grid = planning_rast_ber)
terra::plot(ber_seamounts_pu_ras)

ber_seamounts_pu_sf <- get_seamount_peaks(planning_grid = planning_sf_ber)
plot(sf::st_geometry(bermuda_eez))
plot(ber_seamounts_pu_sf, border = F)

ber_seamounts_buffered <- get_seamounts_buffered(area_polygon = bermuda_eez)
plot(sf::st_geometry(bermuda_eez))
plot(ber_seamounts_buffered, add=T)

ber_seamounts_buffered_pu_ras <- get_seamounts_buffered(planning_grid = planning_rast_ber)
terra::plot(ber_seamounts_buffered_pu_ras)
terra::lines(terra::vect(bermuda_eez %>% sf::st_transform(sf::st_crs(ber_seamounts_buffered_pu_ras))))

ber_seamounts_buffered_pu_sf <- get_seamounts_buffered(planning_grid = planning_sf_ber)
plot(ber_seamounts_buffered_pu_sf, border = F)

ber_enviro_data <- get_enviro_regions(area_polygon = bermuda_eez, raw_data = TRUE)

ber_enviro_data_rast_pu <- get_enviro_regions(planning_grid = planning_rast_ber, raw_data = TRUE)
terra::plot(ber_enviro_data_rast_pu)

ber_enviro_data_sf_pu <- get_enviro_regions(planning_grid = planning_sf_ber, raw_data = TRUE)
plot(ber_enviro_data_sf_pu, border = FALSE)

ber_enviro_regions_rast_pu <- get_enviro_regions(planning_grid = planning_rast_ber, num_clusters = 3, show_plots = T)
terra::plot(ber_enviro_regions_rast_pu)

ber_enviro_regions_sf_pu <- get_enviro_regions(planning_grid = planning_sf_ber, num_clusters = 3, show_plots = T)
plot(ber_enviro_regions_sf_pu, border = F)
##################################################################
#Maldives
mld_eez <- get_area("Maldives")
planning_rast_mld <- get_planning_grid(mld_eez, projection_crs = "+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs", resolution_km = 5)
planning_sf_mld <- get_planning_grid(mld_eez, projection_crs = "+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs", resolution_km = 5, option = "sf_square")


mld_knolls <- data_to_planning_grid(area_polygon = mld_eez, dat = knolls)
plot(mld_knolls)

mld_knoll_pu <- data_to_planning_grid(planning_grid = planning_rast_mld, dat = knolls)
terra::plot(mld_knoll_pu)
terra::lines(terra::vect(mld_eez) %>% terra::project("+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs"))

mld_knolls_pu_sf <- data_to_planning_grid(planning_grid = planning_sf_mld, dat = knolls)
plot(mld_knolls_pu_sf, border = FALSE)
#plot(mld_eez %>% sf::st_transform("+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs"), add=TRUE)


#########################################################
#Fiji
fiji_crs <- "+proj=laea +lon_0=-181.8896484 +lat_0=-17.73775 +datum=WGS84 +units=m +no_defs"

fiji_eez <- get_area("Fiji")
planning_rast_fiji <- get_planning_grid(fiji_eez, projection_crs = fiji_crs, resolution_km = 20)
planning_sf_fiji <- get_planning_grid(fiji_eez, projection_crs = fiji_crs, resolution_km = 20, option = "sf_square")


fiji_knolls <- data_to_planning_grid(area_polygon = fiji_eez, dat = knolls)
plot(fiji_knolls |> sf::st_shift_longitude())

fiji_knoll_pu <- data_to_planning_grid(planning_grid = planning_rast_fiji, dat = knolls, antimeridian = TRUE)
terra::plot(fiji_knoll_pu)

fiji_knolls_pu_sf <- data_to_planning_grid(planning_grid = planning_sf_fiji, dat = knolls, antimeridian = TRUE)
plot(fiji_knolls_pu_sf, border = FALSE)

fiji_bathy <- get_bathymetry(fiji_eez, classify_bathymetry = FALSE)
terra::plot(fiji_bathy %>% terra::rotate(left = FALSE) %>% terra::trim())

fiji_bathy_pu_ras <- get_bathymetry(planning_grid = planning_rast_fiji, classify_bathymetry = T)
terra::plot(fiji_bathy_pu_ras)

fiji_bathy_pu_sf <- get_bathymetry(planning_grid = planning_sf_fiji, classify_bathymetry = T)
plot(fiji_bathy_pu_sf, border = FALSE)

fiji_corals <- get_coral_habitat(area_polygon = fiji_eez)
terra::plot(fiji_corals %>% terra::rotate(left = FALSE) %>% terra::trim())

fiji_corals_pu_ras <- get_coral_habitat(planning_grid = planning_rast_fiji) 
terra::plot(fiji_corals_pu_ras)

fiji_corals_pu_sf <- get_coral_habitat(planning_grid = planning_sf_fiji)
plot(fiji_corals_pu_sf, border = F)

fiji_geomorph <- get_geomorphology(area_polygon = fiji_eez)
plot(fiji_geomorph %>% sf::st_shift_longitude())

fiji_geomorph_pu_ras <- get_geomorphology(planning_grid = planning_rast_fiji)
terra::plot(fiji_geomorph_pu_ras)

fiji_geomorph_pu_sf <- get_geomorphology(planning_grid = planning_sf_fiji)
plot(fiji_geomorph_pu_sf, border = F)

fiji_seamounts <- get_seamount_peaks(area_polygon = fiji_eez)
plot(sf::st_geometry(fiji_eez) %>% sf::st_shift_longitude())
plot(sf::st_geometry(fiji_seamounts) %>% sf::st_shift_longitude(), pch = 2, col = "brown4", add=T)

fiji_seamounts_pu_ras <- get_seamount_peaks(planning_grid = planning_rast_fiji)
terra::plot(fiji_seamounts_pu_ras)

fiji_seamounts_pu_sf <- get_seamount_peaks(planning_grid = planning_sf_fiji)
plot(fiji_seamounts_pu_sf, border = F)

fiji_seamounts_buffered <- get_seamounts_buffered(area_polygon = fiji_eez, buffer = 0.5)
plot(sf::st_geometry(fiji_eez) %>% sf::st_shift_longitude())
plot(fiji_seamounts_buffered %>% sf::st_shift_longitude(), add=T)

fiji_seamounts_buffered_pu_ras <- get_seamounts_buffered(planning_grid = planning_rast_fiji, buffer = 3e4)
terra::plot(fiji_seamounts_buffered_pu_ras)
terra::lines(terra::vect(fiji_eez %>% sf::st_transform(sf::st_crs(fiji_seamounts_buffered_pu_ras))))

fiji_seamounts_buffered_pu_sf <- get_seamounts_buffered(planning_grid = planning_sf_fiji, buffer = 3e4)
plot(fiji_seamounts_buffered_pu_sf, border = F)

fiji_enviro_data <- get_enviro_regions(area_polygon = fiji_eez, raw_data = TRUE)
terra::plot(fiji_enviro_data %>% terra::rotate(left=FALSE) %>% terra::trim())

fiji_enviro_data_sf_grid <- get_enviro_regions(planning_grid = planning_sf_fiji, raw_data = TRUE)

fiji_enviro_data_rast_pu <- get_enviro_regions(planning_grid = planning_rast_fiji, raw_data = TRUE)
terra::plot(fiji_enviro_data_rast_pu)

fiji_enviro_data_sf_pu <- get_enviro_regions(planning_grid = planning_sf_fiji, raw_data = TRUE)
plot(fiji_enviro_data_sf_pu, border = FALSE)

fiji_enviro_regions_rast_pu <- get_enviro_regions(planning_grid = planning_rast_fiji, num_clusters = 3)
terra::plot(fiji_enviro_regions_rast_pu)

fiji_enviro_regions_sf_pu <- get_enviro_regions(planning_grid = planning_sf_fiji, num_clusters = 3)
plot(fiji_enviro_regions_sf_pu, border = F)
##############################################################
