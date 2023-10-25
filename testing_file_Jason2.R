devtools::load_all()

bermuda_eez <- get_area("Bermuda")
planning_rast_ber <- get_planning_grid(bermuda_eez, projection = 3770, resolution_km = 5)
planning_sf_ber <- get_planning_grid(bermuda_eez, projection = 3770, resolution_km = 5, option = "sf_square")


knolls <- system.file("extdata", "knolls.rds", package = "offshoredatr", mustWork = TRUE) %>%
  readRDS() %>% 
  sf::st_geometry()

antipatharia <- system.file("extdata", "YessonEtAl_2016_Antipatharia.tif", package = "offshoredatr", mustWork = TRUE) %>% 
  terra::rast()

ber_antipatharia <- get_data(area_polygon = bermuda_eez, dat = antipatharia)
terra::plot(ber_antipatharia)

ber_antipatharia_pu <- get_data(planning_grid = planning_rast_ber, dat = antipatharia)
terra::plot(ber_antipatharia_pu)

ber_antipatharia_pu_sf <- get_data(planning_grid = planning_sf_ber, dat = antipatharia)
plot(ber_antipatharia_pu_sf, border = FALSE)

ber_knolls <- get_data(area_polygon = bermuda_eez, dat = knolls)
plot(ber_knolls)

ber_knoll_pu <- get_data(planning_grid = planning_rast_ber, dat = knolls)
terra::plot(ber_knoll_pu)

ber_knolls_pu_sf <- get_data(planning_grid = planning_sf_ber, dat = knolls)
plot(ber_knolls_pu_sf, border = FALSE)

#########################################################
fiji_eez <- get_area("Fiji")
planning_rast_fiji <- get_planning_grid(fiji_eez, projection_crs = 3460, resolution_km = 20)
planning_sf_fiji <- get_planning_grid(fiji_eez, projection_crs = 3460, resolution_km = 20, option = "sf_square")

fiji_antipatharia <- get_data(area_polygon = fiji_eez, dat = antipatharia)
terra::plot(fiji_antipatharia)

fiji_antipatharia_pu <- get_data(planning_grid = planning_rast_fiji, dat = antipatharia)
terra::plot(fiji_antipatharia_pu)

fiji_antipatharia_pu_sf <- get_data(planning_grid = planning_sf_fiji, dat = antipatharia)
plot(fiji_antipatharia_pu_sf, border = FALSE)

fiji_knolls <- get_data(area_polygon = fiji_eez, dat = knolls)
plot(fiji_knolls)

fiji_knoll_pu <- get_data(planning_grid = planning_rast_fiji, dat = knolls)
terra::plot(fiji_knoll_pu)

fiji_knolls_pu_sf <- get_data(planning_grid = planning_sf_fiji, dat = knolls)
plot(fiji_knolls_pu_sf, border = FALSE)
