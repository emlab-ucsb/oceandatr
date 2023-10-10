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
plot(ber_knolls_pu_sf)

