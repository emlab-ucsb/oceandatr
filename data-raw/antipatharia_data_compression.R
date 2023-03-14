#compress the original GeoTiff of antipatharia habitat suitability from Yesson et al. 2017: https://doi.org/10.1016/j.dsr2.2015.12.004
# need to compress to below 100MB to be able to push to Github
# compression options tested in "offshore-prioritization/scripts/antipatharia_compression_test.R"

library(raster)

#working paths
sys_path <- ifelse(Sys.info()["sysname"]=="Windows", "G:/Shared drives/",ifelse(Sys.info()["sysname"]=="Linux", "/home/jason/Documents/Gdrive_sync/emlab_shared/", "~/Google Drive/Shared drives/"))
# Path to our emLab's data folder
emlab_data_path <- paste0(sys_path,"emlab/data")

#want all data in memory otherwise it just writes a link
antipatharia <- readAll(raster(file.path(emlab_data_path, "antipatharia-distribution/YessonEtAl_DSR2_2016_AntipathariaHSM.tif")))

#this takes >1hr and uses >30GB memory
writeRaster(antipatharia, file.path("inst/extdata", "YessonEtAl_2016_Antipatharia.tif"), format = "GTiff", options = c("COMPRESS=ZSTD", "PREDICTOR=2", "ZSTD_LEVEL=22", "NUM_THREADS=10"), datatype = "INT1U")

gc()
