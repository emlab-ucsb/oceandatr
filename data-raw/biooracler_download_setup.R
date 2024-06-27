library(biooracler)
#documenting how I got the info for which datasets to download from Bio-Oracle using the biooracler package, and testing the loop I will use in the package

#https://github.com/bio-oracle/biooracler/tree/master

#NOTE: if there are no latitude and longitude constraints to the biooracler::download_layers() call, the global dataset will be returned

#############################################################
#OCENDATR: Get info on all the data for inclusion in oceandatr
#############################################################
#list all layers available
data_list <- list_layers(simplify = F)

#get only the baseline data, as opposed to predictions under climate change
baseline_data <- data_list[grep(pattern = "baseline", data_list$dataset_id),]

#get only the surface data set (mean and max depth data are also available)
baseline_data_surf <-  baseline_data[grepl("depthsurf", baseline_data$dataset_id),]

#see all baseline data 
baseline_data_surf$title

data_subset_index <- c(2,5,7,8,9,10,12,17,19)
dataset_subset <- baseline_data_surf[data_subset_index,]

#use this to get a list with each element containing the variables that can be pulled for each dataset
dataset_info <- lapply(dataset_subset$dataset_id, FUN = info_layer)

variable_names_means <- sapply(dataset_info, FUN = function(x) x[[1]][4,1])

#to get variable units:
variable_info <- sapply(dataset_info, function(x) x[[2]][7])

#create a dataframe with all the info needed to loop over and download the 10 datasets required

dataset_info_df <- data.frame(dataset_id = c(dataset_subset$dataset_id[1:3], rep(dataset_subset$dataset_id[4], 3), dataset_subset$dataset_id[5:9]),
                              variables = c(variable_names_means[1:3], "thetao_min", variable_names_means[4], "thetao_max", variable_names_means[5:9]))

#to dump the dataframe structure to copy into the get_enviro_regions() function:
dput(dataset_info_df)

#test download for Bermuda
berm <- spatialgridr::get_boundary(name = "Bermuda")
berm_grid <- spatialgridr::get_grid(boundary = berm, resolution = 10000, crs = 3770)

devtools::load_all()
polygon4326 <- oceandatr:::polygon_in_4326(berm_grid)

grid_bbox <- sf::st_bbox(polygon4326)

# without the time constraint you get 2 time periods: 2000 and 2010, note 2010 is mean for 2010 - 2020: https://bio-oracle.org/downloads-to-email.php
constraints <- list(time = c('2010-01-01T00:00:00Z', '2010-01-01T00:00:00Z'),
                    latitude = c(as.numeric(grid_bbox["ymin"]), as.numeric(grid_bbox["ymax"])),
                    longitude = c(as.numeric(grid_bbox["xmin"]), as.numeric(grid_bbox["xmax"])))

berm_layers <- list()

for(i in 1:nrow(dataset_info_df)){
  berm_layers[[i]] <- download_layers(dataset_id = dataset_info_df$dataset_id[i], variables = dataset_info_df$variables[i], constraints = constraints)
}

berm_ras <- terra::rast(berm_layers)

terra::plot(berm_ras, fun = function(x) terra::lines(berm))

#test download for Kiribati

kir <- spatialgridr::get_boundary(name = "Kiribati",  country_type = "sovereign")
kir_grid <- spatialgridr::get_grid(boundary = kir, resolution = 50000, crs = '+proj=laea +lon_0=-159.609375 +lat_0=0 +datum=WGS84 +units=m +no_defs')

polygon4326 <- oceandatr:::polygon_in_4326(kir_grid)

grid_bbox <- sf::st_bbox(polygon4326)

constraints <- list(time = c('2010-01-01T00:00:00Z', '2010-01-01T00:00:00Z'),
                    latitude = c(as.numeric(grid_bbox["ymin"]), as.numeric(grid_bbox["ymax"])),
                    longitude = c(as.numeric(grid_bbox["xmin"]), as.numeric(grid_bbox["xmax"])))

kir_layers <- list()

for(i in 1:nrow(dataset_info_df)){
  kir_layers[[i]] <- download_layers(dataset_id = dataset_info_df$dataset_id[i], variables = dataset_info_df$variables[i], constraints = constraints)
}

kir_ras <- terra::rast(kir_layers)

kir_ras |>
  terra::crop(kir, mask = TRUE) |>
  terra::rotate() |>
  terra::trim() |>
  terra::plot() 
