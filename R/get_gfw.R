#' Get data from Global Fishing Watch
#'
#' @description Global Fishing Watch (GFW) provides data on apparent fishing effort (hours) at 0.01 degree spatial resolution, based on automatic identification system (AIS) broadcasts from vessels. Data is principally for larger vessel (> 24m in length); less than 1% of vessels <12 m length are represented in the data (see [GFW website](https://globalfishingwatch.org/dataset-and-code-fishing-effort/) for detailed information). This function is primarily a wrapper for the [`gfwr` package](https://github.com/GlobalFishingWatch/gfwr) function `get_raster()`, but allows the user to return multiple years of data in a summarized and gridded format. An API key is required to retrieve GFW data; see the package website for instructions on how to get and save one (free).
#' 
#' @param spatial_grid `sf` or `terra::rast()` grid, e.g. created using `get_grid()`. Alternatively, if raw data is required, an `sf` polygon can be provided, e.g. created using `get_boundary()`, and set `raw = TRUE`.
#' @param raw `logical` if TRUE, `spatial_grid` can be an `sf` polygon, and the raw GFW data, in tibble format, is returned for a bounding box covering the polygon +/-1 degree. The bounding box is expanded to ensure that the entire polygon has data coverage once the point data is rasterized. This data will not be summarised, i.e. `summarise` is ignored.
#' @param resolution `string` either `"HIGH"` = 0.01 degree spatial resolution, or `"LOW"`  = 0.1.
#' @param start_year `numeric` must be 2012 or more recent year. Note that GFW added data from Spire and Orbcomm AIS providers in 2017, so data from 2017 is likely to have greater spatial and temporal coverage ([Welch et al. 2022](https://doi.org/10.1126/sciadv.abq2109)). 
#' @param end_year `numeric` any year between 2012 and the current year
#' @param group_by `string` can be `"geartype"`, `"flag"`, or `"location"`. 
#' @param summarise `string` can be `"total_annual_effort"`; the sum of all fishing effort for all years, from `start_year` to `end_year` at each location is returned, grouped by `group_by`; or `"mean_total_annual_effort"`; the mean of the annual sums of fishing effort for all years at each location is returned, grouped by `group_by`.
#' @param key `string` Authorization token. Can be obtained with gfw_auth() function. See `gfwr` [website](https://github.com/GlobalFishingWatch/gfwr?tab=readme-ov-file#authorization) for details on how to request a token.
#'
#' @return For gridded data, a `terra::rast()` or `sf` object, depending on the `spatial_grid` format. If `raw = TRUE`, non-summarised data in `tibble` format is returned for the polygon area direct from the GFW query `gfwr::get_raster()`.
#' @export
#'
#' @examplesIf nchar(Sys.getenv("GFW_TOKEN"))>0
#' #get mean total annual fishing effort for Bermuda for the years 2022-2023
#' #first get a grid for Bermuda
#' bermuda_grid <- get_boundary(name = "Bermuda") %>% get_grid(resolution = 0.1, crs = 4326)
#' 
#' bermuda_gfw_effort <- get_gfw(spatial_grid = bermuda_grid, start_year = 2022)
#' 
#' #plot the data
#' terra::plot(bermuda_gfw_effort)
#' 
#' #get total fishing effort for each gear type in Fiji's EEZ for 2022
#' fiji_grid <- get_boundary(name = "Fiji") %>% get_grid(resolution = 1e4, crs = "+proj=tcea +lon_0=178 +datum=WGS84 +units=m +no_defs", output = "sf_square")
#' 
#' fiji_gfw_effort <- get_gfw(spatial_grid = fiji_grid, start_year = 2022, end_year = 2022, group_by = "geartype", summarise = "total_annual_effort")
#' 
#' plot(fiji_gfw_effort, border = FALSE)
#' 
#' #quantile is better for viewing the fishing effort distribution due to the long tail of values
#' plot(fiji_gfw_effort[1], border= FALSE, breaks = "quantile")
get_gfw <- function(spatial_grid = NULL, raw = FALSE, resolution = "LOW", start_year = 2018, end_year = 2023, group_by = "location", summarise = "mean_total_annual_effort", key = gfwr::gfw_auth()){
  
  current_year <- as.numeric(format(Sys.Date(), "%Y"))
  
  if(end_year > current_year) stop('"end_year" must be ', current_year, " or before.")
  
  if(start_year < 2012) stop("The first available year of Global Fishing Watch data is 2012")
  
  number_years <- end_year - start_year + 1
  
  if(group_by == "location") gfw_group <- "GEARTYPE" else gfw_group <- toupper(group_by)
  
  gfw_shape <- spatial_grid %>%
    polygon_in_4326() %>%
    sf::st_buffer(dist = 0.5) %>% 
    sf::st_wrap_dateline()
  
  #create unique filename for caching - assumes that bounding box can be used to distinguish different spatial queries
  bounding_box <- sf::st_bbox(spatial_grid)
  file_name <- paste("gfwdata_x1", bounding_box[[1]], "y1", bounding_box[[2]], "x2", bounding_box[[3]], "y2", bounding_box[[4]], gfw_group, start_year, end_year, resolution, ".rds", sep = "_")
  
  if(file_name %in% list.files(path = tempdir())) {
    message("GFW data already downloaded, using cached version", 
            sep = "")
    fishing_effort <- readRDS(file.path(tempdir(), file_name))
  } else{
    fishing_effort <- lapply(start_year:end_year, function(yr){
      gfwr::get_raster(spatial_resolution = resolution,
                       temporal_resolution = 'YEARLY',
                       group_by = gfw_group,
                       start_date = paste0(yr, "-01-01"),
                       end_date = paste0(yr, "-12-31"),
                       region = gfw_shape,
                       region_source = 'USER_SHAPEFILE',
                       key = key)
    }) 
    fishing_effort <- do.call(dplyr::bind_rows, fishing_effort)
    
    saveRDS(fishing_effort, file = file.path(tempdir(), file_name))
  }
  
  if(raw){
    return(fishing_effort)
  } 
    grouping_vars <- c("Lon", "Lat", "Time Range") %>% 
      {if(group_by == "location") . else c(., tolower(group_by))} 

    annual_effort <- fishing_effort %>% 
      dplyr::group_by(dplyr::across(dplyr::all_of(grouping_vars))) %>% 
      dplyr::summarise(total_annual_effort = sum(`Apparent Fishing Hours`, na.rm = TRUE)) %>% 
      dplyr::ungroup()  

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
                           dat = ., 
                           meth = if(check_sf(spatial_grid)) "mean" else "average")

}