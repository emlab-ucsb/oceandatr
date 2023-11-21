devtools::load_all()

#vector data
knolls <- system.file("extdata", "knolls.rds", package = "offshoredatr", mustWork = TRUE) %>%
  readRDS() %>% 
  sf::st_geometry()

#raster data
antipatharia <- system.file("extdata", "YessonEtAl_2016_Antipatharia.tif", package = "offshoredatr", mustWork = TRUE) %>% 
  terra::rast()

sst_mean <- system.file("extdata/bio_oracle/Sea_surface_temperature_(mean).tif", package = "offshoredatr", mustWork = TRUE) %>% 
  terra::rast()

#Bermuda
ber_proj_wiz <- "+proj=laea +lon_0=-64.8220825 +lat_0=32.2530756 +datum=WGS84 +units=m +no_defs"

bermuda_eez <- get_area("Bermuda")
planning_rast_ber <- get_planning_grid(bermuda_eez, projection_crs = ber_proj_wiz, resolution_km = 5)
planning_sf_ber <- get_planning_grid(bermuda_eez, projection_crs = ber_proj_wiz, resolution_km = 5, option = "sf_square")

ber_antipatharia <- data_to_planning_grid(area_polygon = bermuda_eez, dat = antipatharia)
terra::plot(ber_antipatharia)

ber_antipatharia_pu <- data_to_planning_grid(planning_grid = planning_rast_ber, dat = antipatharia)
terra::plot(ber_antipatharia_pu)

ber_antipatharia_pu_sf <- data_to_planning_grid(planning_grid = planning_sf_ber, dat = antipatharia)
plot(ber_antipatharia_pu_sf, border = FALSE)

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
##################################################################
#Maldives
mld_eez <- get_area("Maldives")
planning_rast_mld <- get_planning_grid(mld_eez, projection_crs = "+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs", resolution_km = 5)
planning_sf_mld <- get_planning_grid(mld_eez, projection_crs = "+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs", resolution_km = 5, option = "sf_square")


mld_antipatharia <- data_to_planning_grid(area_polygon = mld_eez, dat = antipatharia)
terra::plot(mld_antipatharia)

mld_antipatharia_pu <- data_to_planning_grid(planning_grid = planning_rast_mld, dat = antipatharia)
terra::plot(mld_antipatharia_pu)

mld_antipatharia_pu_sf <- data_to_planning_grid(planning_grid = planning_sf_mld, dat = antipatharia)
plot(mld_antipatharia_pu_sf, border = FALSE)

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

fiji_antipatharia <- data_to_planning_grid(area_polygon = fiji_eez, dat = antipatharia)
terra::plot(fiji_antipatharia %>% terra::rotate(left = FALSE) %>% terra::trim())

fiji_sst <- data_to_planning_grid(area_polygon = fiji_eez, dat = sst_mean, antimeridian = TRUE)
terra::plot(fiji_sst %>% terra::rotate(left = FALSE) %>% terra::trim())

fiji_antipatharia_pu <- data_to_planning_grid(planning_grid = planning_rast_fiji, dat = antipatharia, antimeridian = TRUE)
terra::plot(fiji_antipatharia_pu)

fiji_antipatharia_pu_sf <- data_to_planning_grid(planning_grid = planning_sf_fiji, dat = antipatharia, antimeridian = TRUE)
plot(fiji_antipatharia_pu_sf, border = FALSE)

fiji_knolls <- data_to_planning_grid(area_polygon = fiji_eez, dat = knolls)
plot(fiji_knolls |> sf::st_shift_longitude())

fiji_knoll_pu <- data_to_planning_grid(planning_grid = planning_rast_fiji, dat = knolls, antimeridian = TRUE)
terra::plot(fiji_knoll_pu)

fiji_knolls_pu_sf <- data_to_planning_grid(planning_grid = planning_sf_fiji, dat = knolls, antimeridian = TRUE)
plot(fiji_knolls_pu_sf, border = FALSE)

fiji_bathy <- get_bathymetry(fiji_eez, classify_bathymetry = FALSE)
terra::plot(fiji_bathy)

fiji_bathy_pu_ras <- get_bathymetry(planning_grid = planning_rast_fiji, classify_bathymetry = T)
terra::plot(fiji_bathy_pu_ras)

fiji_bathy_pu_sf <- get_bathymetry(planning_grid = planning_sf_fiji, classify_bathymetry = T)
plot(fiji_bathy_pu_sf, border = FALSE)

##############################################################

data_breaks <- c(0,5,8,14)

classification_names <- c("one", "two", "three")

r <- terra::rast(nrows=3, ncols = 3, xmin=0, xmax=3, ymin=0, ymax=3)

terra::values(r) <- c(0:4, 9:11, 14)

terra::plot(r)

#create a classification matrix
class_matrix <- data_breaks %>% 
  .[2:(length(.)-1)] %>% 
  rep(times = rep(2, times = length(.))) %>% 
  append(data_breaks[length(data_breaks)]) %>% 
  append(data_breaks[1], after = 0) %>% 
  matrix(ncol = 2, byrow = TRUE) %>% 
  cbind(c(1:nrow(.)))

rr <- terra::classify(r, class_matrix, include.lowest=TRUE) %>% 
  terra::segregate(other=NA) %>% 
  setNames(classification_names[as.numeric(names(.))])
terra::plot(rr)

data.frame(a = c(1:5, 9:12)) |>
  dplyr::mutate(b = cut(a, breaks = data_breaks, labels = c("one", "two", "three")))

terra::values(r) |>
  findInterval(data_breaks, left.open = TRUE)
  
ber_bathy_sf <- get_bathymetry(planning_grid = planning_sf_ber, classify_bathymetry = FALSE)

ber_bathy_sf %>% 
  dplyr::mutate(classification = cut(.[[1]], bathymetry_cuts, labels = depth_zones), 
                value = 1, 
                .before = 1) %>% 
  tidyr::pivot_wider(names_from = "classification", values_from = "value", values_fill = NA) %>% 
  dplyr::select(3:ncol(.), 2) %>% 
  dplyr::select((ncol(.)-1):1)
