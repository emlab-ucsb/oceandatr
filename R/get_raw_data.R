#' Crop and mask/ intersect data
#'
#' @description
#' Called by `data_to_planning_grid` when needed
#' 
#' @param area_polygon `sf` polygon to crop/ mask/ intersect with
#' @param dat `terra::rast()` or `sf` data
#' @param meth `string` name of method to use for raster projection if data is raster
#' @param matching_crs `logical` TRUE if `area_polygon` and `dat` have the same crs
#' @param antimeridian `logical` TRUE if cropping area crosses the antimeridian
#'
#' @return `terra::rast()` or `sf` 
#' @noRd
get_raw_data <- function(area_polygon, dat, meth, matching_crs, antimeridian){
  area_polygon <- area_polygon %>% 
    sf::st_geometry() %>% 
    sf::st_as_sf()
  
  if(check_raster(dat)){
    if(matching_crs){
      dat %>% 
        terra::crop(sf::st_as_sf(area_polygon), mask = TRUE)
    }else{
      area_polygon %>% 
        sf::st_transform(sf::st_crs(dat)) %>%
        sf::st_as_sf() %>% 
        {if(antimeridian) terra::crop(terra::rotate(dat, left = FALSE), sf::st_shift_longitude(.)) else terra::crop(dat, .)} %>% 
        terra::project(terra::crs(area_polygon), method = meth) %>% 
        terra::mask(., area_polygon)
    }
  }else{
    if(matching_crs){
      dat %>% 
        sf::st_intersection(sf::st_geometry(area_polygon)) %>%
        {if(antimeridian) sf::st_wrap_dateline(.) else .}
        
    }else{
      if(antimeridian){
        area_polygon %>% 
          sf::st_transform(sf::st_crs(dat)) %>% 
          sf::st_shift_longitude() %>% 
          sf::st_intersection(dat %>% sf::st_shift_longitude()) %>% 
          sf::st_wrap_dateline() %>% 
          sf::st_transform(sf::st_crs(area_polygon))
      }else{
        area_polygon %>% 
          sf::st_transform(sf::st_crs(dat)) %>% 
          sf::st_intersection(dat, sf::st_geometry(.)) %>% 
          sf::st_transform(sf::st_crs(area_polygon))        
      }
    }
  }
}