#' Create environmental zones for area of interest
#'
#' @description This function gets [Bio-Oracle](https://bio-oracle.org/)
#'   environmental data for the spatial grid and can then create environmental
#'   zones, using k-means clustering. The idea for the clustering comes from
#'   Magris et al. [2020](https://doi.org/10.1111/ddi.13183). The number of
#'   environmental zones can be specified directly, using `num_clusters`, but
#'   the function can also find the 'optimal' number of clusters using the
#'   `NbClust()` from the `NbClust` package.
#'
#' @details The environmental data used in the clustering are all sea surface
#'   measurements over the period 2010 - 2020:
#' \itemize{
#' \item Chlorophyll concentration (mean, mg/ m3)
#' \item Dissolved oxygen concentration (mean)
#' \item Nitrate concentration (mean, mmol/ m3)
#' \item pH (mean)
#' \item Phosphate concentration (mean, mmol/ m3)
#' \item total Phytoplankton (primary productivity; mean, mmol/ m3)
#' \item Salinity (mean)
#' \item Sea surface temperature (max, degree C)
#' \item Sea surface temperature (mean, degree C)
#' \item Sea surface temperature (min, degree C)
#' \item Silicate concentration (mean, mmol/ m3)
#' }
#'
#'   For full details of the Bio-Oracle data see [Assis et al.
#'   2024](https://onlinelibrary.wiley.com/doi/10.1111/geb.13813).
#'
#'   When the number of planning units/ cells for clustering exceeds ~ 10,000,
#'   the amount of computer memory required to find the optimal number of
#'   clusters using `NbClust::NbClust()` exceeds 10GB, so repeated sampling is
#'   used to find a consensus number of clusters. Sensible defaults for
#'   `NbClust()` are provided, namely `sample_size = 5000`, `num_samples = 5`,
#'   `max_num_clusters = 6` but can be customised if desired, though see the
#'   parameter descriptions below for some words of warning. Parallel processing
#'   is offered by specifying `num_cores` >1 (must be an integer), though the
#'   package `parallel` must be installed (it is included in most R
#'   installations). To find the number of available cores on your systems run
#'   `parallel::detectCores()`.
#'
#' @inheritParams get_bathymetry
#' @param raw `logical` if TRUE, `spatial_grid` should be an `sf` polygon, and
#'   the raw Bio-Oracle environmental data in that polygon(s) will be returned,
#'   unless `enviro_zones = TRUE`, in which case the raw data will be
#'   classified into environmental zones
#' @param enviro_zones `logical` if TRUE, environmental zones will be
#'   created. If FALSE the gridded Bio-Oracle data will be returned
#' @param show_plots `logical`; whether to show boxplots for each environmental
#'   variable in each environmental zone (default is FALSE)
#' @param num_clusters `numeric`; the number of environmental zones to cluster
#'   the data into - to be used when a clustering algorithm is not necessary
#'   (default is NULL)
#' @param max_num_clusters `numeric`; the maximum number of environmental
#'   zones to try when using the clustering algorithm (default is 6)
#' @param sample_size `numeric`; default is 5000. Larger sample sizes will
#'   quickly consume memory (>10GB) so should be used with caution.
#' @param num_samples `numeric`; default is 5, which resulted in good consensus
#'   on the optimal number of clusters in testing.
#' @param num_cores `numeric`; default 1. Multi-core sampling is supported if
#'   the package `parallel` is installed, but be aware that increasing the
#'   number of cores will also increase the memory required.
#'
#' @return If `enviro_zones = FALSE`, Bio-Oracle data in the `spatial_grid`
#'   supplied, or the original Bio-Oracle data cropped and masked to the grid if
#'   `raw = TRUE`. If `enviro_zones = TRUE` a multi-layer raster or an `sf`
#'   object with one environmental zone in each column/ layer is returned,
#'   depending on the `spatial_grid` format. If `enviro_zones = TRUE` and `raw
#'   = TRUE` (in which case `spatial_grid` should be an `sf` polygon), the raw
#'   Bio-Oracle data is classified into environmental zones.
#'
#' @export
#' 
#' @examples
#' # Get EEZ data first 
#' bermuda_eez <- get_boundary(name = "Bermuda")
#' # Get raw Bio-Oracle environmental data for Bermuda
#' enviro_data <- get_enviro_zones(spatial_grid = bermuda_eez, raw = TRUE, enviro_zones = FALSE)
#' terra::plot(enviro_data)
#' # Get gridded Bio-Oracle data for Bermuda:
#' bermuda_grid <- get_grid(boundary = bermuda_eez, crs = '+proj=laea +lon_0=-64.8108333 +lat_0=32.3571917 +datum=WGS84 +units=m +no_defs', resolution = 20000)
#' 
#' enviro_data_gridded <- get_enviro_zones(spatial_grid = bermuda_grid, raw = FALSE, enviro_zones = FALSE)
#' terra::plot(enviro_data_gridded)
#' 
#' # Get 3 environmental zones for Bermuda
#' 
#' #set seed for reproducibility in the sampling to find optimal number of clusters
#' set.seed(500)
#' bermuda_enviro_zones <- get_enviro_zones(spatial_grid = bermuda_grid, raw = FALSE, enviro_zones = TRUE, num_clusters = 3)
#' terra::plot(bermuda_enviro_zones)
#' # Can also create environmental zones from the raw Bio-Oracle data using setting raw = TRUE and enviro_zones = TRUE. In this case, the `spatial_grid` should be a polygon of the area you want the data for
#' bermuda_enviro_zones2 <- get_enviro_zones(spatial_grid = bermuda_eez, raw = TRUE, enviro_zones = TRUE, num_clusters = 3)
#' terra::plot(bermuda_enviro_zones2)

get_enviro_zones <- function(spatial_grid = NULL, raw = FALSE, enviro_zones = TRUE, show_plots = FALSE, num_clusters = NULL, max_num_clusters = 6, antimeridian = NULL, sample_size = 5000, num_samples = 5, num_cores = 1){
  
  rlang::check_installed("biooracler", reason = "to get Bio-Oracle data using `get_enviro_zones()`", action = function(pkg, ...) remotes::install_github("bio-oracle/biooracler"))
  
  check_grid(spatial_grid)
  
  meth <- if(check_sf(spatial_grid)) 'mean' else 'average'
  
  # Add error for cluster numbers
  if(!is.null(num_clusters)) {
    if(num_clusters < 1){ stop("num_clusters must be greater than 1 or NULL")}
    if(!all.equal(num_clusters, round(num_clusters))){ stop("num_clusters must be a whole number")}} 
  if(max_num_clusters < 1) { 
    stop("max_num_clusters must be greater than 1")}
  if(!all.equal(max_num_clusters, round(max_num_clusters))){ stop("max_num_clusters must be a whole number")}
  
  if(num_cores > 1 & !rlang::is_installed("parallel")){
    rlang::check_installed("parallel", reason = "to use multiple cores for clustering.")
  }
  
  #set extra columns aside - only need this is it a spatial grid, so added nrow() check to remove the need for this step if only raw data is required and using an sf polygon with one row
  if(check_sf(spatial_grid) & nrow(spatial_grid) > 1){
    grid_has_extra_cols <- if(ncol(spatial_grid)>1) TRUE else FALSE
    
    if(grid_has_extra_cols) {
      extra_cols <- sf::st_drop_geometry(spatial_grid)
      spatial_grid <- spatial_grid %>% 
        sf::st_geometry() %>% 
        sf::st_sf()
    }
  }
  
  enviro_data <- get_enviro_data(spatial_grid = spatial_grid) %>% 
    get_data_in_grid(spatial_grid = spatial_grid, dat = ., raw = raw, meth = meth)
  
 if(!enviro_zones){
   return(enviro_data)
  }else{
    
    df_for_clustering <- if(check_sf(enviro_data)) sf::st_drop_geometry(enviro_data) %>% as.data.frame() %>% .[stats::complete.cases(.),] else terra::as.data.frame(enviro_data, na.rm = NA)
    
    if(sample_size > nrow(df_for_clustering)) sample_size <- nrow(df_for_clustering)
    
   if(is.null(num_clusters)){
      message("This could take several minutes")
      #setting index = "all" results in large memory usage and long runtime (I haven't run to completion after >1hr), for the moment, setting the index to "hartigan" which is the same algorithm (Hartigan-Wong) used by the kmeans() function used below
     
     n_df_rows <- nrow(df_for_clustering)
     
     df_sample <- lapply(rep(sample_size, num_samples), function(x) df_for_clustering[sample.int(n_df_rows, x),])
     
     if(num_cores > 1 & rlang::is_installed("parallel")){
       
       if(Sys.info()["sysname"]=="Windows"){
         cluster <- parallel::makePSOCKcluster(num_cores)
         best_no_clusts <- parallel::parLapply(cluster, df_sample, function(x) NbClust::NbClust(data = x, method = "kmeans", max.nc = max_num_clusters,  index = "hartigan") %>% .[[2]] %>% .["Number_clusters"]) %>% 
           unlist()
         
       }else{
         best_no_clusts <- parallel::mclapply(df_sample, function(x) NbClust::NbClust(data = x, method = "kmeans", max.nc = max_num_clusters,  index = "hartigan") %>% .[[2]] %>% .["Number_clusters"], mc.cores = num_cores) %>% 
           unlist()
       }
     }else{
       best_no_clusts <- sapply(df_sample, function(x) NbClust::NbClust(data = x, method = "kmeans", max.nc = max_num_clusters,  index = "hartigan") %>% .[[2]] %>% .["Number_clusters"])
     }
     uniq_values_clusters <- unique(best_no_clusts)
     
     num_clusters <- uniq_values_clusters[which.max(tabulate(match(best_no_clusts, uniq_values_clusters)))]
     
      }
    #k-means clustering for specific number of clusters
    clust_result <- stats::kmeans(x = df_for_clustering, centers = num_clusters, nstart = 10)
    clust_partition <- clust_result$cluster
    
    if(show_plots) {
      enviro_zones_boxplot(clust_partition, df_for_clustering)
      enviro_zones_pca(clust_partition, df_for_clustering)
    }
    
    if(check_sf(enviro_data)){
      enviro_zone_cols <- stats::model.matrix(~ as.factor(clust_partition) - 1) %>% 
        as.data.frame() %>%   
        stats::setNames(paste0("enviro_zone_", 1:ncol(.))) %>% 
        dplyr::mutate(row_id = as.numeric(names(clust_partition)))
      
      sf::st_geometry(enviro_data) %>% 
        sf::st_sf() %>% 
        dplyr::mutate(row_id = 1:nrow(.)) %>% 
        dplyr::left_join(enviro_zone_cols, by = dplyr::join_by(row_id)) %>% 
        dplyr::select(-row_id) %>% 
        {if(grid_has_extra_cols) cbind(., extra_cols) %>% dplyr::relocate(colnames(extra_cols), .before = 1) else .}
      
    }else{
      #create environmental zones raster, filled with NAs to start with
      enviro_zones <- terra::rast(enviro_data, nlyrs=1, vals = NA, names = "enviro_zone")
      
      #set cluster ids in raster - subset for only raster values that are non-NA
      enviro_zones[as.numeric(names(clust_partition))] <- clust_partition
      
      enviro_zones %>% 
        terra::segregate() %>% 
        stats::setNames(paste0("enviro_zone_", names(.)))
    }
  }
}

get_enviro_data <- function(spatial_grid = NULL){
  
  #for details of how I got the dataset info see "data-raw/biooracle_download_setup.R"
  biooracle_datasets_info <- structure(
    list(
      dataset_id = c(
        "chl_baseline_2000_2018_depthsurf",
        "o2_baseline_2000_2018_depthsurf",
        "no3_baseline_2000_2018_depthsurf",
        "thetao_baseline_2000_2019_depthsurf",
        "thetao_baseline_2000_2019_depthsurf",
        "thetao_baseline_2000_2019_depthsurf",
        "ph_baseline_2000_2018_depthsurf",
        "po4_baseline_2000_2018_depthsurf",
        "so_baseline_2000_2019_depthsurf",
        "si_baseline_2000_2018_depthsurf",
        "phyc_baseline_2000_2020_depthsurf"
      ),
      variables = c(
        "chl_mean",
        "o2_mean",
        "no3_mean",
        "thetao_min",
        "thetao_mean",
        "thetao_max",
        "ph_mean",
        "po4_mean",
        "so_mean",
        "si_mean",
        "phyc_mean"
      )
    ),
    class = "data.frame",
    row.names = c(NA, -11L)
  )
  
  polygon4326 <- polygon_in_4326(spatial_grid)
  
  grid_bbox <- sf::st_bbox(polygon4326)
  
  #queries to the ERDDAP server where Bio-Oracle is hosted only allow coordinates -89.975 to 89.975, and -179.975 to 179.975, e.g: https://erddap.bio-oracle.org/erddap/info/tas_baseline_2000_2020_depthsurf/index.html
  x_min <- if(grid_bbox["xmin"][[1]] < -179.975) -179.975 else grid_bbox["xmin"][[1]]
  x_max <- if(grid_bbox["xmax"][[1]] > 179.975) 179.975 else grid_bbox["xmax"][[1]]
  
  y_min <- if(grid_bbox["ymin"][[1]] < -89.975) -89.975 else grid_bbox["ymin"][[1]]
  y_max <- if(grid_bbox["ymax"][[1]] > 89.975) 89.975 else grid_bbox["ymax"][[1]]
  
  
  constraints <- list(time = c('2010-01-01T00:00:00Z', '2010-01-01T00:00:00Z'),
                      latitude = c(y_min, y_max),
                      longitude = c(x_min, x_max))
  
  biooracle_data <- list()
  
  for(i in 1:nrow(biooracle_datasets_info)){
    biooracle_data[[i]] <- biooracler::download_layers(dataset_id = biooracle_datasets_info$dataset_id[i], variables = biooracle_datasets_info$variables[i], constraints = constraints)
  }
  
  biooracle_data <- terra::rast(biooracle_data) %>%
    stats::setNames(c("Chlorophyll", "Dissolved_oxygen", "Nitrate", "Minimum_temp", "Mean_temp", "Max_temp", "pH", "Phosphate", "Salinity", "Silicate", "Phytoplankton"))
  
  terra::crs(biooracle_data) <- "epsg:4326"
  return(biooracle_data)
}

enviro_zones_boxplot <- function(enviro_zone, enviro_data){
  #compare values in each environmental zone
  enviro_zones_df <- cbind(enviro_zone, enviro_data) 

  graphics::par(mfrow = c(3,4))
  for (i in 2:ncol(enviro_zones_df)) {
    eval(parse(text = paste0("boxplot(`", colnames(enviro_zones_df[i]), "` ~ enviro_zone, data = enviro_zones_df, col = palette.colors(n = ", max(enviro_zone), ", palette = 'Dark2'))")))
  }
  graphics::par(mfrow = c(1,1))
}

enviro_zones_pca <- function(enviro_zone, enviro_data){
  pca_df <- stats::prcomp(enviro_data, scale. = TRUE, center = TRUE) %>% 
    .[["x"]] %>% 
    as.data.frame()

  pca_df$enviro_zone <- enviro_zone
  
  plot(x = pca_df$PC1, y = pca_df$PC2, col = pca_df$enviro_zone, xlab = "PC1", ylab = "PC2", pch = 4, cex = 0.6)
  graphics::legend("bottomright", legend = unique(pca_df$enviro_zone), col = unique(pca_df$enviro_zone), pch = 4, cex = 1, title = "Enviro zone")
}
