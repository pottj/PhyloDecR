#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param data PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname runAlgorithm
#' @export
runAlgorithm<-function(data){
  data=myResults$data
  head(data)

  # define solved and unsolved quadruples
  table(data$status)
  data2<-copy(data)
  green_quadruples<-data2[status=="input",]
  cross_quadruples<-data2[status=="unresolved",]

  # In my loop I do overwrite the orignal data. Hence I want to save it here
  alt_green<-green_quadruples
  alt_cross<-cross_quadruples
  all_quads<-rbind(alt_green,alt_cross)

  # Start Loop
  # check each CQ and change status if resolved
  # repeat algorithm until all quads are resolved or all CQ have been tested
  # in each round, at least one CQ has to be solved
  # if index > dim, then there was at least one round in which no CQ could be solved
  # then the set cannot be decisive

  index=0
  repeat{all_quads=myAlgorithm(all_quads);
  index=index+1;
  print(index);
  print(sum(all_quads$status == "unresolved"));
  if ((sum(all_quads$status == "unresolved") ==0) | index >= dim(alt_cross)[1])
    break}

  if (sum(all_quads$status == "unresolved") ==0){print("PHYLOGENETICALLY DECISIVE")}
  if (index >= dim(alt_cross)[1]){print("NOT RESOLVABLE VIA THIS ALGORITHM, MAYBE A SECOND FIXING TAXON IS NEEDED")}

  return(all_quads)

}
