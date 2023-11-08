devtools::load_all()

#vector data
knolls <- system.file("extdata", "knolls.rds", package = "offshoredatr", mustWork = TRUE) %>%
  readRDS() %>% 
  sf::st_geometry()

#raster data
antipatharia <- system.file("extdata", "YessonEtAl_2016_Antipatharia.tif", package = "offshoredatr", mustWork = TRUE) %>% 
  terra::rast()

#Bermuda
ber_proj_wiz <- 4326#"+proj=laea +lon_0=-64.8220825 +lat_0=32.2530756 +datum=WGS84 +units=m +no_defs"

bermuda_eez <- get_area("Bermuda")
planning_rast_ber <- get_planning_grid(bermuda_eez, projection_crs = ber_proj_wiz, resolution_km = 5)
planning_sf_ber <- get_planning_grid(bermuda_eez, projection_crs = ber_proj_wiz, resolution_km = 5, option = "sf_square")

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

##################################################################
#Maldives
mld_eez <- get_area("Maldives")
planning_rast_mld <- get_planning_grid(mld_eez, projection_crs = "+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs", resolution_km = 5)
planning_sf_mld <- get_planning_grid(mld_eez, projection_crs = "+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs", resolution_km = 5, option = "sf_square")


mld_antipatharia <- get_data(area_polygon = mld_eez, dat = antipatharia)
terra::plot(mld_antipatharia)

mld_antipatharia_pu <- get_data(planning_grid = planning_rast_mld, dat = antipatharia)
terra::plot(mld_antipatharia_pu)

mld_antipatharia_pu_sf <- get_data(planning_grid = planning_sf_mld, dat = antipatharia)
plot(mld_antipatharia_pu_sf, border = FALSE)

mld_knolls <- get_data(area_polygon = mld_eez, dat = knolls)
plot(mld_knolls)

mld_knoll_pu <- get_data(planning_grid = planning_rast_mld, dat = knolls)
terra::plot(mld_knoll_pu)
terra::lines(terra::vect(mld_eez) %>% terra::project("+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs"))

mld_knolls_pu_sf <- get_data(planning_grid = planning_sf_mld, dat = knolls)
plot(mld_knolls_pu_sf, border = FALSE)
plot(mld_eez %>% sf::st_transform("+proj=cea +lon_0=73.1558817 +datum=WGS84 +units=m +no_defs"), add=TRUE)




#########################################################
#Fiji

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

##############################################################

#checking out what raster to planning grid is doing for raster output

terra::plot(fiji_antipatharia %>% terra::rotate() %>% terra::trim())

test <- planning_rast_fiji %>%
  terra::as.polygons() %>% 
  terra::project(terra::crs(antipatharia)) %>% 
  terra::rotate(normalize = TRUE) %>% 
  terra::crop(antipatharia, ., snap = 'out') %>% 
  terra::trim() %>% 
  #terra::plot()
  terra::project("+proj=moll +lon_0=180 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m no_defs", method = 'average') %>%
  terra::mask(planning_rast_fiji %>% terra::project("+proj=moll +lon_0=180 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m no_defs")) %>% 
  plot()
  setNames(name)

fiji_extent_antipatharia <- planning_rast_fiji %>% 
  terra::as.polygons() %>% 
  terra::project(terra::crs(antipatharia)) %>% 
  terra::rotate(normalize  = TRUE) %>% 
  antimeridian_l_r_bbox() %>% 
  lapply(., function(x) plot(x))
  sf::st_as_sf() %>% 
  sf::st_geometry() %>% 
  sf::st_break_antimeridian() %>% 
  sf::st_crop(sf::st_bbox(c(xmin = -180, ymin = -90, xmax = 0, ymax = 90))) %>% 
  plot()
  
  "+proj=moll +lon_0=180 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m no_defs"