#boundary matrix creation

func_bnd_mat <- function(planning_raster_data, seamount_pu_ids){
  #try creating boundary matrix based on Jeff's recommendation of creating an sf object with all pu data
  
  pu_grid_sf <- rasterToPolygons(planning_raster_data, na.rm=FALSE) %>% 
    st_as_sf() %>% 
    dplyr::select(-1)
  
  pu_sf <-
    pu_grid_sf %>%
    bind_rows(
      lapply(seamount_pu_ids, function(i) {
        st_sf(layer = 1, geometry = st_union(pu_grid_sf[i, , drop = FALSE]))
      }) %>%
        do.call(what = bind_rows) %>%
        dplyr::select(-layer)
    )
  
  return(boundary_matrix(pu_sf, str_tree = TRUE))
}
