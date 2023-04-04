#create manual targets for prioritization

func_targets <- function(feature_targets_data, seamount_data){
  
  #calculate number of constraints - there is one for each seamount planning unit
  constraints_number <- cellStats(seamount_data, sum, na.rm = TRUE)
  
  # add constraints features to feature data which contains target
  
  feature_data_w_constraints <- tibble(id = seq(from = nrow(feature_targets_data)+1, to = (nrow(feature_targets_data) + constraints_number), by = 1), total = 2) %>% 
    mutate(name = sprintf("constraint_%d", id-nrow(feature_targets_data)), .after = id) %>% 
    mutate(rel_target = NA_real_,
           abs_target = 1) %>% 
    bind_rows(feature_targets_data, .)
  
  #create targets dataframe for manual targets
  
  #these targets are absolute and the targets for the features are all >=, i.e. have to meet or exceed the target, whereas the constrain targets are all <= 1, which means you cannot select the same planning unit at the grid cell level and seamount level planning grid, i.e. you can't select both the seamount and then select grid-cells that overlap the seamount, only one or the other.
  
  manual_targets <- tibble(feature = feature_data_w_constraints$name,
                           type = "absolute",
                           #add locked-out out sense to be less than
                           sense = c(rep(">=", nrow(feature_targets_data)-1), "<=", rep("<=", constraints_number)),
                           target = c(pull(feature_targets_data, abs_target), rep(1, constraints_number)))
  
  return(manual_targets)
}