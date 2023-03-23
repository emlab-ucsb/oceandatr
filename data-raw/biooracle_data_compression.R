#Download the Bio-Oracle data using the package `sdmpredictors` and compress to make file sizes as small as possible. Compression options tested in "offshore-prioritization/scripts/antipatharia_compression_test.R"

#Following layers are downloaded: "Chlorophyll Mean", "Dissolved oxygen Mean", "Nitrate Mean", "pH mean", "Phosphate Mean", "Phytoplankton Mean", "Primary productivity Mean", "Salinity Mean", "Silicate Mean", "Temperature Max", "Temperature Mean", "Temperature Min"

library(terra)
library(sdmpredictors)
library(dplyr)

options(timeout = 60*5)

bo_layer_codes <- c("BO22_chlomean_ss", "BO22_dissoxmean_ss", "BO22_nitratemean_ss", "BO22_phosphatemean_ss", "BO22_ppmean_ss", "BO22_salinitymean_ss", "BO22_silicatemean_ss", "BO22_tempmax_ss", "BO22_tempmean_ss", "BO22_tempmin_ss")

start_time <- Sys.time()

enviro_data <- sdmpredictors::load_layers(layercodes = bo_layer_codes, datadir = tempdir()) %>% 
  terra::rast()

#approx. 21 mins on 2023-3-23
download_time <- Sys.time() - start_time

enviro_data_names <- sdmpredictors::list_layers() %>% 
  filter(layer_code %in% bo_layer_codes) %>% 
  select(name) %>%
  mutate(name = gsub(" ", "_", name)) %>% 
  pull()

names(enviro_data) <- enviro_data_names

for (i in 1:terra::nlyr(enviro_data)) {
  terra::writeRaster(enviro_data[[i]], paste0("inst/extdata/bio_oracle/", names(enviro_data[[i]]), ".tif"), filetype = "GTiff", gdal = c("COMPRESS=ZSTD", "PREDICTOR=2", "ZSTD_LEVEL=22", "NUM_THREADS=10"), datatype = "FLT4S", overwrite = TRUE)
}

gc()
