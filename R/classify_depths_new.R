classify_depths <- function(input_data){

  depth_zone_names <- c("epipelagic", "mesopelagic", "bathypelagic", "abyssopelagic", "hadopelagic")
  
  bathymetry_matrix <- matrix(c(-200, Inf, 1, 
                                -1000, -200, 2,
                                -4000, -1000, 3,
                                -6000, -4000, 4,
                                -12000, -6000, 5), ncol = 3, byrow = TRUE)
  
  
  if(class(input_data)[1] == "sf"){
    classified_depths <- input_data %>% 
      sf::st_drop_geometry() %>% 
      dplyr::mutate(depth_zone = cut(bathymetry, breaks = c(rev(bathymetry_matrix[,1]), Inf), labels = rev(depth_zone_names)), .before = 1) %>% 
      cbind(as.data.frame(model.matrix(~depth_zone+0, as.data.frame(.)))) %>% 
      dplyr::select(-depth_zone, -bathymetry) %>% 
      dplyr::select(dplyr::where(~sum(.) !=0)) %>% 
      dplyr::rename_with(~gsub("depth_zone", "", .x), dplyr::starts_with("depth")) %>% 
      dplyr::select(names(.)[match(names(.), depth_zone_names)]) %>% 
      dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~replace(., . == 0, NA))) %>% 
      cbind(sf::st_geometry(input_data)) %>% 
      sf::st_as_sf()
  } else{
    classified_depths <- input_data %>% 
      terra::classify(bathymetry_matrix, 
                      include.lowest = TRUE) %>% 
      terra::segregate(other=NA) %>% 
      setNames(depth_zone_names[as.numeric(names(.))])
  }
  return(classified_depths)
}