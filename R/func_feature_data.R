#create features dataframe

func_feature_data <- function(targets_decimal, feature_data, seamount_data, locked_out_data){
  # calculate feature data
  feature_targets_df <-
    ## initialize data with the name and total amount of each feature
    ## note we use seamount_raster here because we want to set targets
    ## based on overall distribution of seamounts (not each one separately)
    raster::stack(feature_data, setNames(seamount_data, "seamount")) %>%
    raster::cellStats(sum, na.rm = TRUE) %>%
    {tibble(id = seq_along(.), name = names(.), total = unname(.))} %>%
    ## set targets, let's use 20% as an example
    mutate(rel_target = targets_decimal) %>%
    ## now compute the targets as absolute values
    ## (this is needed because we have spatial overlaps in the planning unit
    ## data, so if we gave prioritizr relative targets then it wouldn't
    ## calculate the percentages correctly)
    mutate(abs_target = rel_target * total) %>% 
    #add the locked-out data column manually because we want to set the absolute target as a number
    bind_rows(tibble(id = nrow(.)+1,
                     name = "locked_out",
                     total = cellStats(locked_out_data, sum, na.rm = TRUE),
                     rel_target = NA_real_,
                     abs_target = 0.5))
  
  return(feature_targets_df)
}