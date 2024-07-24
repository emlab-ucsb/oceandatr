#' Get data from Global Fishing Watch
#'
#' @description
#' 
#' 
#' @param spatial_grid 
#' @param raw 
#' @param name 
#' @param resolution 
#' @param start_year `numeric` must be 2012 or more recent year. Note that GFW added data from Spire and Orbcomm AIS providers in 2017, so data from 2017 is likely to have greater spatial and temporal coverage [Welch et al. 2022](https://doi.org/10.1126/sciadv.abq2109). 
#' @param end_year 
#' @param group_by 
#'
#' @return
#' @export
#'
#' @examples
#' #get mean total annual fishing effort for Bermuda for the years 2022-2023
#' #first get a grid for Bermuda
#' bermuda_grid <- get_boundary(name = "Bermuda") %>% get_grid(resolution = 0.1, crs = 4326)
#' 
#' bermuda_gfw_effort <- get_gfw(spatial_grid = bermuda_grid, raw = TRUE, start_year = 2022)
#' 
#' #plot the data
#' terra::plot(bermuda_gfw_effort)
get_gfw <- function(spatial_grid = NULL, raw = FALSE, name = "GFW_fishing_effort", resolution = "LOW", start_year = 2018, end_year = 2023, group_by = "location", summarise = "mean_total_annual_effort"){
  
  current_year <- as.numeric(format(Sys.Date(), "%Y"))
  
  if(end_year > current_year) stop('"end_year" must be ', current_year, " or before.")
  
  if(start_year < 2012) stop("The first available year of Global Fishing Watch data is 2012")
  
  number_years <- end_year - start_year + 1
  
  if(group_by == "location") gfw_group <- "GEARTYPE" else gfw_group <- toupper(group_by)
  
  grid_bbox <- spatial_grid %>% 
    polygon_in_4326() %>% 
    sf::st_bbox()
  
  # we need to expand the bbox because GFW retrieves cell centroids within the polygon provided, but this can result in some areas within the polygon not being fully covered by data, e.g. if the nearest cell centroid to the polygon boundary is just outside
  gfw_shape <- sf::st_bbox(c(xmin = as.numeric(grid_bbox$xmin)-1, ymin = as.numeric(grid_bbox$ymin)-1, xmax = as.numeric(grid_bbox$xmax)+1, ymax = as.numeric(grid_bbox$ymax)+1)) %>% 
    sf::st_as_sfc() %>% 
    sf::st_sf()
  
  
  fishing_effort <- lapply(start_year:end_year, function(yr){
    gfwr::get_raster(spatial_resolution = resolution,
                     temporal_resolution = 'YEARLY',
                     group_by = gfw_group,
                     start_date = paste0(yr, "-01-01"),
                     end_date = paste0(yr, "-12-31"),
                     region = gfw_shape,
                     region_source = 'USER_SHAPEFILE')
  })
  
  fishing_effort <- do.call(dplyr::bind_rows, fishing_effort)
  
  if(raw){
    return(fishing_effort)
  } 
  
    grouping_vars <- c("Lat", "Lon", "Time Range") %>% 
      {if(group_by == "location") . else c(., tolower(group_by))} 

    annual_effort <- fishing_effort %>% 
      dplyr::group_by(dplyr::across(dplyr::all_of(grouping_vars))) %>% 
      dplyr::summarise(total_annual_effort = sum(`Apparent Fishing Hours`, na.rm = TRUE)) %>% 
      dplyr::ungroup() %>% 
      dplyr::relocate(Lon, .before = 1) 
    
    if(summarise == "total_annual_effort"){
      if(group_by == "location"){
        final_effort <- annual_effort %>% 
          tidyr::pivot_wider(names_from = "Time Range",
                             values_from = total_annual_effort) 
        
      }else{
        final_effort <- annual_effort %>% 
          tidyr::pivot_wider(names_from = dplyr::all_of(c(group_by, "Time Range")),
                             values_from = total_annual_effort) 
      }
    } else{
      mean_total_effort <- annual_effort %>% 
        dplyr::group_by(., dplyr::across(-c("Time Range", total_annual_effort))) %>%
        dplyr::summarise(mean_total_annual_effort = sum(total_annual_effort, na.rm = TRUE)/number_years) %>% #calculate mean manually to ensure that years that have NA catch in a cell are still included in the denominator
        dplyr::ungroup()
      
      if(group_by == "location"){
        final_effort <- mean_total_effort
        
      }else{
        final_effort <- mean_total_effort %>% 
          tidyr::pivot_wider(names_from = dplyr::all_of(group_by),
                             values_from = mean_total_annual_effort)
      }
    }
    
    final_effort %>% 
      terra::rast(type = "xyz", crs = "epsg:4326") %>% 
        # terra::subst(NA, 0.01) %>% #too many zero cost value cells leads to prioritization of too much area because they are 'free'
          get_data_in_grid(spatial_grid = spatial_grid,
                           dat = .)

}