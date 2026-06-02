#'Get boundaries for an area of interest
#'
#'Marine and land boundaries can be obtained.  For marine boundaries, the
#'`mrp_get` function from the `mregions2` package is used to retrieve the
#'boundary (e.g. an EEZ) from [Marine
#'Regions](https://marineregions.org/gazetteer.php). For land boundaries and the
#'"seas_oceans" type, the package
#'[`rnaturalearth`](https://github.com/ropensci/rnaturalearth/) is used.
#'
#'@param name `character` name of the country or region. If `NULL` all
#'  boundaries of `type` are returned. If an incorrect `name` is input, the user
#'  is given a list of valid names to chose from. Ignored for `type =
#'  "high_seas"`
#'@param type `character` the boundary type. Can be one of:
#' * `eez`: Exclusive Economic Zone (EEZ; 200nm). These EEZs differ slightly from the the [UN Convention on the Law of the Sea (UNCLOS)](https://www.un.org/depts/los/convention_agreements/texts/unclos/part5.htm) definition because the archipelagic waters and the internal waters of a country are included.
#' * `12nm`: 12 nautical miles zone (Territorial Seas), defined in [UNCLOS](https://www.un.org/Depts/los/convention_agreements/texts/unclos/part2.htm)
#' * `24nm`: 24 nautical miles zone (Contiguous Zone), defined in [UNCLOS](https://www.un.org/Depts/los/convention_agreements/texts/unclos/part2.htm)
#' * `ocean`: Global Oceans and Seas as compiled by the Flanders Marine Data Centre. Names are: "Arctic Ocean", "Baltic Sea", "Indian Ocean", "Mediterranean Region", "North Atlantic Ocean", "North Pacific Ocean", "South Atlantic Ocean", "South China and Easter Archipelagic Seas", "South Pacific Ocean", and "Southern Ocean".
#' * `high_seas`: as defined by the UN Law of the Sea: "all parts of the sea that are not included in the exclusive economic zone, in the territorial sea or in the internal waters of a State, or in the archipelagic waters of an archipelagic State". Note that `name` and `country_type` are not relevant for this query: only all High Seas areas can be downloaded.
#' * `country`: country boundaries from Natural Earth
#' * `seas_oceans`: Seas, oceans, bays, gulfs, inlets etc. as defined in the Natural Earth marine polygons
#'
#'  More details on the marine boundaries can be found on the [Marine Regions
#'  website](https://marineregions.org/sources.php), and for land boundaries
#'  (plus "seas_oceans"), the [Natural Earth
#'  website](https://www.naturalearthdata.com/features/). Note that data from
#'  Natural Earth is downlaoded at the highest resolution (1:10m).
#'
#'@param country_type `character` must be either `country` or `sovereign`;
#'  ignored for `type = "high_seas"`, `"ocean"` or `"seas_oceans"`. Some
#'  countries have many territories that it has jurisdiction over. For example,
#'  Australia, France and the U.K. have jurisdiction over many overseas islands.
#'  Using `sovereign` returns the main country and all the territories, whereas
#'  using `country` returns just the main country. More details about what is a
#'  country via the `rnaturalearth` package
#'  [vignette](https://cran.r-project.org/web/packages/rnaturalearth/vignettes/what-is-a-country.html)
#'
#'@return 'sf' polygon or multipolygon object of the boundary requested
#'@export
#'
#' @examples
#' #Marine boundary examples:
#' if(require("mregions2")){
#'australia_mainland_eez <- get_boundary(name = "Australia")
#'plot(australia_mainland_eez["geometry"])
#'
#'#this includes all islands that Australia has jurisdiction over:
#'australia_including_territories_eez <- get_boundary(name = "Australia", country_type = "sovereign")
#'plot(australia_including_territories_eez["geometry"])
#'
#' #South Atlantic Ocean area:
#' south_atlantic <- get_boundary(name = "South Atlantic Ocean", type = "ocean")
#'
#' plot(south_atlantic["geometry"])
#' }
#'
#' #Land boundary example:
#'if(require("rnaturalearth")){
#'australia_land <- get_boundary(name = "Australia", type = "country")
#'plot(australia_land["geometry"])
#'
#'#this includes all islands that Australia has jurisdiction over:
#'australia_land_and_territories <-
#'get_boundary(name = "Australia", type = "country", country_type = "sovereign")
#'plot(australia_land_and_territories["geometry"])
#'
#' #Sea boundary:
#' coral_sea <- get_boundary(name = "Coral Sea", type = "seas_oceans")
#' plot(coral_sea["geometry"])
#' }
#'
#'#
get_boundary <- function(name = "Australia", type = "eez", country_type = "country"){

  mregions_types <- c("eez", "12nm", "24nm", "ocean", "high_seas")
  mregions_types_lookup <- c("eez", "eez_12nm", "eez_24nm", "goas", "high_seas")

  rnaturalearth_type <- c("country", "seas_oceans")
  all_types <- c(mregions_types, rnaturalearth_type)

  country_types <- c("country", "sovereign")
  mregions_country_types_lookup <- c("territory1", "sovereign1")
  rnaturalearth_country_types_lookup <- c("countries", "sovereignty")

  checkmate::check_string(name, null.ok = TRUE)
  checkmate::assert_choice(type, choices = all_types)
  checkmate::assert_choice(country_type, c(country_types, "ocean", "high_seas", "seas_oceans"))

  if(type %in% mregions_types){
    query_type <- mregions_types_lookup[which(mregions_types == type)]

    if(type == "high_seas") return(mregions2::mrp_get("high_seas"))

    if(is.null(name)) {
      message("You have requested all ", type, " boundaries, the download will take several minutes.")
      return(mregions2::mrp_get(query_type))
    }
    mregions_country_type <- ifelse(type == "ocean", "name", mregions_country_types_lookup[which(country_types == country_type)])

    query_name_options <- mregions2::mrp_col_unique(query_type, mregions_country_type) |>
      sort()

    if(!(name %in% query_name_options)) {
      message("'name' is not a valid name. Please select one of the following: ")
      name <- utils::select.list(choices = query_name_options)
    }

    eval(parse(text = paste0("mregions2::mrp_get(\"", query_type, "\", cql_filter = \"", mregions_country_type, " = '", name, "'\")")))
  } else{
    if(is.null(name)) {
      message("You have requested all ", type, " boundaries.")
      if(type == "country") return(rnaturalearth::ne_countries(scale = 10, returnclass = "sf")) else{
        return(rnaturalearth::ne_download(scale = 10, type = "geography_marine_polys", category = "physical", returnclass = "sf"))
      }
    }

    if(type == "country") {
      rnaturalearth_country_type <- rnaturalearth_country_types_lookup[which(country_types == country_type)]
      query_name_options <- sort(rnaturalearthhires::countries10$ADMIN)
    } else{
      seas_oceans_data <- rnaturalearth::ne_download(scale = 10, type = "geography_marine_polys", category = "physical", returnclass = "sf")
      query_name_options <- sort(seas_oceans_data$name)
    }

    if(!(name %in% query_name_options)) {
      message("'name' is not a valid name. Please select one of the following: ")
      name <- utils::select.list(choices = query_name_options)
    }

    if(type == "country") rnaturalearth::ne_countries(scale = 10, type = rnaturalearth_country_type, country = name) else {
      seas_oceans_data[which(seas_oceans_data$name == name), ] #like dpyr filter, which() drops NA rows
    }
  }
}
