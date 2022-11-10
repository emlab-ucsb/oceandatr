## code to prepare `Geomorphology` dataset goes here

library(sf)
library(dplyr)
library(raster)
#library(usethis)

#write the geomorphological data from Harris et al. 2014 to rda objects so they can be easily packaged with code releases. Write each file separately as combined they will exceed the 100Mb Github limit. Only including data that is needed for prioritization, i.e. not depth classifications which are done separately using bathymetry data.

#working paths
sys_path <- ifelse(Sys.info()["sysname"]=="Windows", "G:/Shared drives/",ifelse(Sys.info()["sysname"]=="Linux", "/home/jason/Documents/Gdrive_sync/emlab_shared/", "~/Google Drive/Shared drives/"))
# Path to our emLab's data folder
emlab_data_path <- paste0(sys_path,"emlab/data")

geomorph_files <- list.files(path = file.path(emlab_data_path, "global-seafloor-geomorphology"), full.names = TRUE, pattern = '\\.shp$') %>% 
  #Remove features not suggested for prioritization in Ceccarelli et al. 2021 Table 5. Want to include Shelf_valleys, hence removal of specific shelf strings
  {.[-grep("Abyss|Hadal|Seamounts|Shelf_Classification|Shelf\\.|Slope", .)]}

sf_use_s2(FALSE)


for (file_name in geomorph_files) {
  feature_name <- gsub(pattern =  ".shp",replacement =  "", basename(file_name))
  
  geomorph_sf_object <- st_read(file_name) %>%
    st_make_valid()
  
  #change all columns names to lower case - there are both "Type" and "type" fields
  names(geomorph_sf_object) <- tolower(names(geomorph_sf_object))
  
  if(any(grepl("type", names(geomorph_sf_object)))) {
    for (geomorph_type in unique(geomorph_sf_object$type)) {
      geomorph_sf_object %>% 
        filter(type == geomorph_type) %>% 
        st_union() %>% 
        st_as_sf() %>% 
        saveRDS(file = file.path("inst/extdata", paste0(feature_name, "_", geomorph_type, ".rds")))
        # assign(paste0(feature_name, "_", geomorph_type), ., pos = 1)
        # 
        # do.call("use_data", list(as.name(paste0(feature_name, "_", geomorph_type)), overwrite = TRUE))
    } 
  } else{
    geomorph_sf_object %>%  
      st_union() %>% 
      st_as_sf() %>% 
      saveRDS(file = file.path("inst/extdata", paste0(feature_name, ".rds")))
      # assign(feature_name, ., pos = 1)
      # 
      # do.call("use_data", list(as.name(feature_name), overwrite = TRUE))
  }
}
