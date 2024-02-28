get_ecoregion <- function(area_polygon = NULL, spatial_grid = NULL, type = "MEOW", antimeridian = NULL){
  
  check_grid_or_polygon(spatial_grid, area_polygon)
  
  if(type == "MEOW"){
    type <- "ecoregions"
    col_name <- "ecoregion"
  }
  marine_ecoregions <- mregions2::mrp_get(type)
  
  get_data_in_grid(area_polygon = area_polygon, spatial_grid = spatial_grid, dat = marine_ecoregions, name = type, antimeridian = antimeridian, sf_col_layer_names = col_name)
}