# Saved copies of country exclusive economic zone boundaries. Two EEZs:
# 1. Bermuda - small, simple EEZ to ensure quick processing
# 2. Fiji - crosses antimeridian, so checks antimeridian crossing functionality works

oceandatr::get_boundary("Bermuda") |> 
  saveRDS("inst/extdata/bermua_eez.rds")

oceandatr::get_boundary("Fiji") |> 
  saveRDS("inst/extdata/fiji_eez.rds")
#creating small datasets for use in package examples

# Data for use in grid_data.Rmd examples

#retrieve Samoan EEZ - small EEZ that doesn't cross the antimeridian,
#but is close to Fiji, the other EEZ we will use

samoa_eez <- mregions2::mrp_get("eez", cql_filter = "territory1 = 'Samoa'")[, "sovereign1"]

fiji_eez <- readRDS(system.file("extdata", "fiji_eez.rds", package = "oceandatr"))[, "sovereign1"]

#get polygon of both EEZs, shift so longitude is 0-360
poly_samoa_fiji <- rbind(samoa_eez |> sf::st_cast(to = "MULTIPOLYGON"), fiji_eez) |> 
  sf::st_shift_longitude()

#use original abyssal classification data from Harris et al. 2014 dataset, available at https://www.bluehabitats.org.

abyss_data_path_temp <- "data-raw/abyss/Abyssal_Classification.shp"

sf::sf_use_s2(FALSE)
sf::read_sf(abyss_data_path_temp) |> 
  sf::st_break_antimeridian(lon = 180) |> 
  sf::st_shift_longitude() |> 
  sf::st_crop(poly_samoa_fiji) |> 
  sf::st_cast(to = "MULTIPOLYGON") |> 
  sf::st_wrap_dateline() |> #get long back to -180 to 180
  sf::st_cast(to = "MULTIPOLYGON") |> 
  saveRDS("inst/extdata/abyssal_classes_pacific.rds")
sf::sf_use_s2(TRUE)

