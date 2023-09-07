#check either or planning grid/ area polygon are provided

check_grid_or_polygon <- function(planning_grid, area_polygon){
  if(is.null(area_polygon) & is.null(planning_grid)){
    stop("an area polygon or planning grid must be supplied")
  }
  
  if(!is.null(area_polygon) & !is.null(planning_grid)){
    stop("please supply either an area polygon or a planning grid, not both")
  }  
}
