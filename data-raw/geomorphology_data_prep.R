## code to prepare `Geomorphology` dataset goes here

library(sf)
library(dplyr)
#library(usethis)

#write the geomorphological data from Harris et al. 2014 to rds objects so they can be easily packaged with code releases. Write each file separately as combined they will exceed the 100Mb Github limit. Only including data that is needed for prioritization, i.e. not depth classifications which are done separately using bathymetry data.

#working paths
data_file_path <- "temp_raw/global-seafloor-geomorphology"

geomorph_files <- list.files(path = data_file_path, full.names = TRUE, pattern = '\\.shp$') %>% 
  #Remove features that are just classification of depths - will do this using latest GEBCO data. Want to include Shelf_valleys, hence removal of specific shelf strings. Removal classification of abyssal depths ("Abyss") but want to keep "Abyssal_Classification", hence the specific string.
  {.[-grep("Abyss\\.|Hadal|Seamounts|Shelf_Classification|Shelf\\.|Slope", .)]}

sf_use_s2(FALSE)

for (file_name in geomorph_files) {
  feature_name <- gsub(pattern =  ".shp",replacement =  "", basename(file_name))
  
  geomorph_sf_object <- st_read(file_name) %>%
    st_make_valid()
  
  #change all columns names to lower case - there are both "Type" and "type" fields
  names(geomorph_sf_object) <- tolower(names(geomorph_sf_object))
  
  if(any(grepl("type", names(geomorph_sf_object)))) {
    for (geomorph_type in unique(geomorph_sf_object$type)) {
      
      naming <- paste0(ifelse(feature_name == "Canyons", paste0("Canyons_", gsub(pattern = " ", replacement = "_", geomorph_type)), gsub(pattern = " ", replacement = "_", geomorph_type)))
      geomorph_sf_object %>% 
        filter(type == geomorph_type) %>% 
        st_union() %>% 
        st_as_sf() %>% 
        dplyr::mutate(geomorph_type = naming, .before = 1) %>% 
        st_set_geometry("geometry") %>% 
        saveRDS(file = file.path("inst/extdata/geomorphology", paste0(naming, ".rds")))
        # assign(paste0(feature_name, "_", geomorph_type), ., pos = 1)
        # 
        # do.call("use_data", list(as.name(paste0(feature_name, "_", geomorph_type)), overwrite = TRUE))
    } 
  } else if(feature_name == "Abyssal_Classification"){
    for(abyssal_class in c("Hills", "Plains")){ #only want Hill and Plains, not seamounts since these will come from more recent data
      geomorph_sf_object %>% 
        filter(class == abyssal_class) %>% 
        st_union() %>% 
        st_sf %>% 
        dplyr::mutate(geomorph_type = abyssal_class, .before = 1) %>% 
        saveRDS(file = file.path("inst/extdata/geomorphology", paste0("Abssyal_", abyssal_class, ".rds")))
    }
  } else{
    geomorph_sf_object %>%  
      st_union() %>% 
      st_as_sf() %>% 
      dplyr::mutate(geomorph_type = feature_name, .before = 1) %>% 
      st_set_geometry("geometry") %>% 
      saveRDS(file = file.path("inst/extdata/geomorphology", paste0(feature_name, ".rds")))
      # assign(feature_name, ., pos = 1)
      # 
      # do.call("use_data", list(as.name(feature_name), overwrite = TRUE))
  }
}
