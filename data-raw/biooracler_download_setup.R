library(biooracler)

#https://github.com/bio-oracle/biooracler/tree/master

data_list <- list_layers(simplify = F)

baseline_data <- data_list[grep(pattern = "baseline", data_list$dataset_id),]

baseline_data_surf <-  baseline_data[grepl("depthsurf", baseline_data$dataset_id),]

baseline_data_surf$title

info_layer(baseline_data_surf$dataset_id[8])

dataset_id <- baseline_data_surf$dataset_id[8] #ocean temp

berm <- spatialgridr::get_boundary(name = "Bermuda")
berm_grid <- spatialgridr::get_grid(boundary = berm, resolution = 10000, crs = 3770)

polygon4326 <- oceandatr:::polygon_in_4326(berm_grid, FALSE)

grid_bbox <- sf::st_bbox(polygon4326)

time <- c('2010-01-01T00:00:00Z', '2010-01-01T00:00:00Z') # without the time constraint you get 2 time periods: 2000 and 2010, note 2010 is mean for 2010 - 2020: https://bio-oracle.org/downloads-to-email.php
latitude <- c(as.numeric(grid_bbox["ymin"]), as.numeric(grid_bbox["ymax"]))
longitude <- c(as.numeric(grid_bbox["xmin"]), as.numeric(grid_bbox["xmax"]))

constraints <- list(time, latitude, longitude)
names(constraints) <- c("time", "latitude", "longitude")

variables <- c("thetao_min", "thetao_mean", "thetao_max")

layers <- download_layers(dataset_id = dataset_id, variables = variables, constraints = constraints, fmt = "raster")

terra::plot(layers)
