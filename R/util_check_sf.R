#check if object is sf
check_sf <- function(dat){
  if(class(dat)[1] == "sf"){
    return(TRUE)
  }else{
    return(FALSE)
  }
}