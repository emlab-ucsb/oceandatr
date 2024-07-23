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
get_gfw <- function(spatial_grid = NULL, raw = FALSE, name = "GFW_fishing_effort", resolution = "LOW", start_year = 2018, end_year = 2023, group_by = "location"){
  
  current_year <- as.numeric(format(Sys.Date(), "%Y"))
  
  if(end_year > current_year) stop('"end_year" must be ', current_year, " or before.")
  
  if(start_year < 2012) stop("The first available year of Global Fishing Watch data is 2012")
  
  number_years <- end_year - start_year + 1
  
  grid_bbox <- spatial_grid %>% 
    polygon_in_4326() %>% 
    sf::st_bbox()
  
  #at the moment we need to expand the bbox because GFW rounds to nearest grid line, which can crop off part of the polygon: 
  gfw_shape <- sf::st_bbox(c(xmin = as.numeric(region_bbox$xmin)-1, ymin = as.numeric(region_bbox$ymin)-1, xmax = as.numeric(region_bbox$xmax)+1, ymax = as.numeric(region_bbox$ymax)+1)) %>% 
    sf::st_as_sfc() %>% 
    sf::st_sf()
  
  
  fishing_effort <- lapply(start_year:end_year, function(yr){
    gfwr::get_raster(spatial_resolution = resolution,
                     temporal_resolution = 'YEARLY',
                     group_by = 'GEARTYPE',
                     start_date = paste0(yr, "-01-01"),
                     end_date = paste0(yr, "-12-31"),
                     region = gfw_shape,
                     region_source = 'USER_SHAPEFILE')
  })
  
  fishing_effort <- do.call(dplyr::bind_rows, fishing_effort)
  
  if(raw){
    return(fishing_effort)
  } else{
    fishing_effort %>% 
      dplyr::group_by(Lat, Lon, `Time Range`) %>% 
      dplyr::summarise(total_effort = sum(`Apparent Fishing Hours`, na.rm = TRUE)) %>% 
      dplyr::ungroup() %>%
      dplyr::group_by(Lat, Lon) %>% 
      dplyr::summarise(mean_total_annual_effort = sum(total_effort, na.rm = TRUE)/no_years) %>% #calculate mean manually to ensure that years that have NA catch in a cell are still included in the denominator
      dplyr::ungroup() %>% 
      dplyr::select("Lon", "Lat", "mean_total_annual_effort") %>%
      terra::rast(type = "xyz", crs = "epsg:4326") %>% 
      #terra::subst(NA, 0.01) %>% #too many zero cost value cells leads to prioritization of too much area because they are 'free'
      get_data_in_grid(spatial_grid = spatial_grid,
                       dat = .,
                       name = name)
  }
  

}