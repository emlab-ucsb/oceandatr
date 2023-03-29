#function for extracting Bio-Oracle environmental data for an area using a polygon
# base case is using this list, but user can supply custom layer codes: "Chlorophyll Mean", "Dissolved oxygen Mean", "Nitrate Mean", "pH mean", "Phosphate Mean", "Phytoplankton Mean", "Primary productivity Mean", "Salinity Mean", "Silicate Mean", "Temperature Max", "Temperature Mean", "Temperature Min"
#returns a raster stack of data

#' Create environmental regions for area of interest
#'
#' @param area_polygon 
#' @param bo_layer_codes 
#' @param data_dir 
#'
#' @return
#' @export
#'
#' @examples
get_enviro_regions <- function(area_polygon,  planning_grid = NULL, show_plots = TRUE, raw_data = FALSE, num_clusters = NULL, max_num_clusters = 8){
  
  enviro_data <- get_enviro_data(area_polygon, planning_grid)
  
 if(raw_data){
   return(enviro_data)
  }
  else{
    if(is.null(num_clusters)){
      
      message("This could several minutes")
      #setting index = "all" results in large memory usage and long runtime (I haven't run to completion after >1hr), for the moment, setting the index to "hartigan" which is the same algorithm (Hartigan-Wong) used by the kmeans() function used below
      clust_results <- NbClust::NbClust(data = terra::as.data.frame(enviro_data, na.rm = NA), method = "kmeans", max.nc = max_num_clusters,  index = "hartigan")
      
      #create environmental regions raster, filled with NAs to start with
      enviro_regions <- terra::rast(enviro_data, nlyrs=1, vals = NA, names = "enviro_region")
      
      #set cluster ids in raster - subset for only raster values that are non-NA
      enviro_regions[as.numeric(names(clust_results$Best.partition))] <- clust_results$Best.partition
      
      if(show_plots){
        enviro_regions_boxplot(enviro_regions, enviro_data)
      }
      enviro_regions <- enviro_regions %>% 
        terra::segregate(other=NA)
      
      return(enviro_regions)
    }
    else{
      
      #k-means clustering for specific number of clusters
      kmean_result <- kmeans(x = terra::as.data.frame(enviro_data, na.rm = NA), centers = num_clusters, nstart = 10)
      
      #create clustered raster
      enviro_regions <- terra::rast(enviro_data, nlyrs=1, vals = NA, names = "enviro_region")
      
      #set cluster ids in raster - subset for only raster values that are non-NA
      enviro_regions[as.numeric(names(kmean_result$cluster))] <- kmean_result$cluster
      
      if(show_plots){
        enviro_regions_boxplot(enviro_regions, enviro_data)
      }
      
      enviro_regions <- enviro_regions %>% 
        terra::segregate(other=NA)
      
      return(enviro_regions)
    }
  }
}

get_enviro_data <- function(area_polygon, planning_grid){
  tif_list <- list.files(system.file("extdata", "bio_oracle", package = "offshoredatr", mustWork = TRUE), full.names = TRUE)
  
  enviro_data <- terra::rast(tif_list) %>% 
    terra::crop(area_polygon, mask = TRUE)
  
  if(is.null(planning_grid)){
    message("Data is not projected")
    return(enviro_data) 
  } 
  else{
    enviro_data <- enviro_data %>% 
      terra::project(planning_grid) %>% 
      terra::mask(planning_grid)
    
    return(enviro_data)
  }
}

enviro_regions_boxplot <- function(enviro_regions, enviro_data){
  #compare values in each environmental region
  enviro_regions_df <- c(enviro_regions, enviro_data) %>% 
    terra::as.data.frame() 
  
  par(mfrow = c(3,4))
  for (i in 2:ncol(enviro_regions_df)) {
    eval(parse(text = paste0("boxplot(`", colnames(enviro_regions_df[i]), "` ~ enviro_region, data = enviro_regions_df, col = palette.colors(n = ", max(enviro_regions_df$enviro_region), ", palette = 'Dark2'))")))
  }
  par(mfrow = c(1,1))
}