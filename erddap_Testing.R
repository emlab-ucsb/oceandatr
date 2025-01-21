#bathymetry data retrieval via ERDDAP server

library(rerddap)

#search all servers for ETOPO data
etopo_datasets <- global_search(query = 'ETOPO', server_list = servers()$url, which_service = "griddap")

# check ETOPO 2022 datasets (all others are older)
#oceanwatch datasets are all 0-360 longitude
info(datasetid = 'ETOPO_2022_v1_15s', url = "https://oceanwatch.pifsc.noaa.gov/erddap/")
info(datasetid = 'ETOPO_2022_v1_30s', url = "https://oceanwatch.pifsc.noaa.gov/erddap/")
info(datasetid = 'ETOPO_2022_v1_60s', url = "https://oceanwatch.pifsc.noaa.gov/erddap/")

etopo2022_dataset_info <- info(datasetid = 'ETOPO_2022_v1_15s', url = "https://coastwatch.pfeg.noaa.gov/erddap/")
etopo2022_360_dataset_info <- info(datasetid = 'ETOPO_2022_v1_15s_Lon0360', url = "https://coastwatch.pfeg.noaa.gov/erddap/")

berm_grid <- spatialgridr::get_boundary("Bermuda")
kir_grid <- spatialgridr::get_boundary("Kiribati", country_type = "sovereign")

bathymetry_from_erddap <- function(grid, antimeridian){
  
  erddap_info <- if(antimeridian) etopo2022_360_dataset_info else etopo2022_dataset_info
  b_box <- if(antimeridian) sf::st_shift_longitude(grid) |> sf::st_bbox() else sf::st_bbox(grid)
  
  bathy <- griddap(erddap_info, 
                   latitude = c(floor(b_box[["ymin"]]), ceiling(b_box[["ymax"]])),
                   longitude = c(floor(b_box[["xmin"]]), ceiling(b_box[["xmax"]])), 
                   store = memory())
  
  terra::rast(bathy$summary$filename)
}

start_time <- Sys.time()
berm_bathy <- bathymetry_from_erddap(berm_grid, FALSE)
end_time <- Sys.time() - start_time

start_time <- Sys.time()
berm_bathy_old <- oceandatr::get_bathymetry(berm_grid, raw = TRUE, classify_bathymetry = FALSE, resolution = 0.25)
end_time_old <- Sys.time() - start_time

start_time <- Sys.time()
kir_bathy <- bathymetry_from_erddap(kir_grid, TRUE)
end_time_kir <- Sys.time() - start_time

start_time <- Sys.time()
kir_bathy_old <- oceandatr::get_bathymetry(kir_grid, raw = TRUE, classify_bathymetry = FALSE, resolution = 0.25, antimeridian = TRUE)
end_time_old_kir <- Sys.time() - start_time

#note that lat and long ranges are slightly less than 90 and 180, so will have
#to add a catch to reduce max/ min values to within those ranges: see lines 242 on in get_enviro_zones
etopo2022_dataset_info

#this crashed?? maybe too large a file
bathy_old <- oceandatr::get_bathymetry(kiribati, raw = TRUE, classify_bathymetry = FALSE, resolution = , antimeridian = TRUE, download_timeout = 999)
