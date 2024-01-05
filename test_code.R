devtools::load_all()

#Bermuda
ber_proj_wiz <- "+proj=laea +lon_0=-64.8220825 +lat_0=32.2530756 +datum=WGS84 +units=m +no_defs"

bermuda_eez <- get_area("Bermuda")
planning_rast_ber <- get_planning_grid(bermuda_eez, projection_crs = ber_proj_wiz)
planning_sf_ber <- get_planning_grid(bermuda_eez, projection_crs = ber_proj_wiz, option = "sf_square")

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

ber_knolls <- get_knolls(area_polygon = bermuda_eez)
plot(sf::st_geometry(ber_knolls))

ber_knolls_pu_ras <- get_knolls(planning_grid = planning_rast_ber)
terra::plot(ber_knolls_pu_ras)

ber_knolls_pu_sf <- get_knolls(planning_grid = planning_sf_ber)
plot(ber_knolls_pu_sf, border = F)

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
plot(ber_seamounts_pu_sf, border = F)

ber_seamounts_buffered <- get_seamounts_buffered(area_polygon = bermuda_eez, buffer = 0.25)
plot(sf::st_geometry(bermuda_eez))
plot(ber_seamounts_buffered, add=T)

ber_seamounts_buffered_pu_ras <- get_seamounts_buffered(planning_grid = planning_rast_ber, buffer = 30000)
terra::plot(ber_seamounts_buffered_pu_ras)
terra::lines(terra::vect(bermuda_eez %>% sf::st_transform(sf::st_crs(ber_seamounts_buffered_pu_ras))))

ber_seamounts_buffered_pu_sf <- get_seamounts_buffered(planning_grid = planning_sf_ber, buffer = 30000)
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

ber_feature_set_rast <- get_features(planning_grid = planning_rast_ber, enviro_clusters = 3)
terra::plot(ber_feature_set_rast)

ber_feature_set_sf <- get_features(planning_grid = planning_sf_ber, enviro_clusters = 3)
plot(ber_feature_set_sf, border=F)
##################################################################
#Maldives
mld_eez <- get_area("Maldives")
planning_rast_mld <- get_planning_grid(mld_eez, projection_crs = "+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs", resolution = 5000)
planning_sf_mld <- get_planning_grid(mld_eez, projection_crs = "+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs", resolution = 5000, option = "sf_square")



#########################################################
#Fiji
fiji_crs <- "+proj=laea +lon_0=-181.8896484 +lat_0=-17.73775 +datum=WGS84 +units=m +no_defs"

fiji_eez <- get_area("Fiji")
planning_rast_fiji <- get_planning_grid(fiji_eez, projection_crs = fiji_crs, resolution = 20e3)
planning_sf_fiji <- get_planning_grid(fiji_eez, projection_crs = fiji_crs, resolution = 20e3, option = "sf_square")


fiji_bathy <- get_bathymetry(fiji_eez, classify_bathymetry = FALSE)
terra::plot(fiji_bathy %>% terra::rotate(left = FALSE) %>% terra::trim())

fiji_bathy_pu_ras <- get_bathymetry(planning_grid = planning_rast_fiji, classify_bathymetry = T)
terra::plot(fiji_bathy_pu_ras)

fiji_knolls <- get_knolls(area_polygon = fiji_eez)
plot(fiji_knolls %>% sf::st_shift_longitude())

fiji_knolls_pu_ras <- get_knolls(planning_grid = planning_rast_fiji)
terra::plot(fiji_knolls_pu_ras)

fiji_knolls_pu_sf <- get_knolls(planning_grid = planning_sf_fiji)
plot(fiji_knolls_pu_sf, border = F)

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
plot(fiji_geomorph_pu_sf, border = F, max.plot = 15)

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

fiji_feature_set_rast <- get_features(planning_grid = planning_rast_fiji, enviro_clusters = 3, antimeridian = TRUE)
terra::plot(fiji_feature_set_rast)

fiji_feature_set_sf <- get_features(planning_grid = planning_sf_fiji, enviro_clusters = 3)
plot(fiji_feature_set_sf, border=F)
##############################################################

#Kiribati

kir_eez <- get_area(area_name = "KIR", mregions_column = "iso_ter1")

planning_rast_kir <- get_planning_grid(area_polygon = kir_eez, 
                                   projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', resolution = 10000)

planning_sf_kir <- get_planning_grid(area_polygon = kir_eez, projection_crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs', resolution = 10000, option = "sf_hex")

kir_bathy <- get_bathymetry(kir_eez, classify_bathymetry = FALSE)
terra::plot(kir_bathy %>% terra::rotate(left = FALSE) %>% terra::trim())

#porblem is in raster_to_planmning_grid
#this helps: planning_grid %>% 
# terra::as.polygons() %>% 
#   sf::st_as_sf() %>% sf::st_transform(sf::st_crs(dat)) %>% sf::st_shift_longitude() %>% plot()

kir_bathy_pu_ras <- get_bathymetry(planning_grid = planning_rast_kir, classify_bathymetry = T)
terra::plot(kir_bathy_pu_ras)

kir_bathy_pu_sf <- get_bathymetry(planning_grid = planning_sf_kir, classify_bathymetry = T)
plot(kir_bathy_pu_sf, border = FALSE)

kir_corals <- get_coral_habitat(area_polygon = kir_eez)
terra::plot(kir_corals %>% terra::rotate(left = FALSE) %>% terra::trim())

kir_corals_pu_ras <- get_coral_habitat(planning_grid = planning_rast_kir) 
terra::plot(kir_corals_pu_ras)

kir_corals_pu_sf <- get_coral_habitat(planning_grid = planning_sf_kir)
plot(kir_corals_pu_sf, border = F)

kir_geomorph <- get_geomorphology(area_polygon = kir_eez)
plot(kir_geomorph %>% sf::st_shift_longitude())

kir_geomorph_pu_ras <- get_geomorphology(planning_grid = planning_rast_kir)
terra::plot(kir_geomorph_pu_ras)

kir_geomorph_pu_sf <- get_geomorphology(planning_grid = planning_sf_kir)
plot(kir_geomorph_pu_sf, border = F, max.plot = 15)

kir_seamounts <- get_seamount_peaks(area_polygon = kir_eez)
plot(sf::st_geometry(kir_eez) %>% sf::st_shift_longitude())
plot(sf::st_geometry(kir_seamounts) %>% sf::st_shift_longitude(), pch = 2, col = "brown4", add=T)

kir_seamounts_pu_ras <- get_seamount_peaks(planning_grid = planning_rast_kir)
terra::plot(kir_seamounts_pu_ras)

kir_seamounts_pu_sf <- get_seamount_peaks(planning_grid = planning_sf_kir)
plot(kir_seamounts_pu_sf, border = F)

kir_seamounts_buffered <- get_seamounts_buffered(area_polygon = kir_eez, buffer = 0.5)
plot(sf::st_geometry(kir_eez) %>% sf::st_shift_longitude())
plot(kir_seamounts_buffered %>% sf::st_shift_longitude(), add=T)

kir_seamounts_buffered_pu_ras <- get_seamounts_buffered(planning_grid = planning_rast_kir, buffer = 3e4)
terra::plot(kir_seamounts_buffered_pu_ras)
terra::lines(terra::vect(kir_eez %>% sf::st_transform(sf::st_crs(kir_seamounts_buffered_pu_ras))))

kir_seamounts_buffered_pu_sf <- get_seamounts_buffered(planning_grid = planning_sf_kir, buffer = 3e4)
plot(kir_seamounts_buffered_pu_sf, border = F)

kir_enviro_data <- get_enviro_regions(area_polygon = kir_eez, raw_data = TRUE)
terra::plot(kir_enviro_data %>% terra::rotate(left=FALSE) %>% terra::trim())

kir_enviro_data_sf_grid <- get_enviro_regions(planning_grid = planning_sf_kir, raw_data = TRUE)

kir_enviro_data_rast_pu <- get_enviro_regions(planning_grid = planning_rast_kir, raw_data = TRUE)
terra::plot(kir_enviro_data_rast_pu)

kir_enviro_data_sf_pu <- get_enviro_regions(planning_grid = planning_sf_kir, raw_data = TRUE)
plot(kir_enviro_data_sf_pu, border = FALSE)

kir_enviro_regions_rast_pu <- get_enviro_regions(planning_grid = planning_rast_kir, num_clusters = 3)
terra::plot(kir_enviro_regions_rast_pu)

kir_enviro_regions_sf_pu <- get_enviro_regions(planning_grid = planning_sf_kir, num_clusters = 3)
plot(kir_enviro_regions_sf_pu, border = F)

kir_feature_set_rast <- get_features(planning_grid = planning_rast_kir, enviro_clusters = 3, antimeridian = TRUE)
terra::plot(kir_feature_set_rast)

kir_feature_set_sf <- get_features(planning_grid = planning_sf_kir, enviro_clusters = 3)
plot(kir_feature_set_sf, border=F)