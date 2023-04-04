#create dataframes for prioritization - including constraints to prioritize only whole seamounts or parts of seamounts if necessary to meet other targets

func_create_dataframes <- function(planning_raster_data, features_data, seamount_stack_data, cost_data, locked_out_data){
  
    # create grid-cell level planning unit data
  ## initialize data
  pu_grid_data <-
    ### add in indices for planning units in raster to be organized
    tibble(id = as.list(seq_len(ncell(planning_raster_data)))) %>%
    ### add in cost data - note using second layer of cost stack
    bind_cols(as_tibble(raster::as.data.frame(cost_data))) %>%
    ### add in feature data
    bind_cols(as_tibble(raster::as.data.frame(features_data))) %>%
    ### add in seamount data
    mutate(seamount = 0) %>% 
    ## add in locked-out data
    bind_cols(as_tibble(raster::as.data.frame(locked_out_data))) 
  
  ##################################################################
  
  # create sea mount-level planning unit data
  pu_sm_data <- lapply(names(seamount_stack_data), function(i) {
    ## initialize data for planning unit that corresponds to i'th sea mount
    curr_sm_pu <-
      ## add in indices for planning units in raster to be organized
      tibble(
        id = list(raster::Which(seamount_stack_data[[i]] > 0.5, cells = TRUE))
      ) %>%
      ## add in cost data - modified for multiple cost inputs
      bind_cols(
        raster::as.data.frame(cost_data * seamount_stack_data[[i]]) %>% 
          setNames(names(cost_data)) %>% 
          dplyr::summarize_all(sum, na.rm=TRUE)
      ) %>% 
      ## calculate total amount of each non-sea mount feature in i'th sea mount pu
      bind_cols(
        raster::as.data.frame(features_data * seamount_stack_data[[i]]) %>%
          setNames(names(features_data)) %>%
          dplyr::summarize_all(sum, na.rm = TRUE)
      ) %>%
      ## assign 1 to the i'th seamount pu if it overlaps a locked-out area
      bind_cols(
        raster::as.data.frame(locked_out_data * seamount_stack_data[[i]]) %>%
          #sum will be 1 if there is any overlap of the seamount area with locked-out area, else will be zero
          sum(na.rm = TRUE) %>% 
          #this assigns 1 to any seamount planning unit that has any locked-out area in it.
          {data.frame(locked_out = ifelse(. > 0, 1, 0))}
      ) %>% 
      ## add data for i'th seamount
      mutate(
        seamount = unname(
          raster::cellStats(seamount_stack_data[[i]], "sum", na.rm = TRUE)
        )
      )
    ## return data
    curr_sm_pu
  }) %>% do.call(what = bind_rows) %>% as_tibble() %>% 
    #move locked-out column to end
    relocate(locked_out, .after = last_col())

###############################################################

# merge sea mount-level data and grid-cell level data together
pu_data <- bind_rows(pu_grid_data, pu_sm_data)

###############################################################

## add in constraints to ensure that the solution won't select
## spatially overlapping grid-cell level and seamount-level planning units

start <- Sys.time()

#list to store all constraints
#constraints_list <- list()

constraints <- data.frame(test  = rep(0,nrow(pu_data)))

index <- 1

#notes JF: This makes a vector with a '1' for each combination of seamount level planning unit and grid-cell level planning unit that overlaps with that seamount. 
for (i in seq_len(nrow(pu_sm_data))) {
  print(paste0("Processing seamount ", i, " of ", nrow(pu_sm_data)))
  
  for (j in pu_sm_data$id[[i]]) {
    
    ### specify planning unit indices for constraints
    v <- rep(0, nrow(pu_data))      # initialize with zeros
    v[nrow(pu_grid_data) + i] <- 1  # specify seamount-level planning unit
    v[j] <- 1                       # specify grid cell-level planning unit
    
    #store the constraints vectors in a list
    #constraints_list[[index]] <- v
    constraints <- cbind(constraints, v)
    index <- index+1
  }
}

#make tibble with one columns for each constraint vector
#constraints <- bind_cols(constraints_list)

#remove dummy row
constraints <- constraints[, -1]

Sys.time()-start

#################################################################

#add the constraints as features to the planning data

pu_data_final <- constraints %>% 
  setNames(sprintf("constraint_%d", seq.int(1:ncol(.)))) %>% 
  bind_cols(pu_data, .)

return(pu_data_final)

################################################################
}
