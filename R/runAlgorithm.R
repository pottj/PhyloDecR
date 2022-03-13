#' @title Running algorithm to find fixing taxa in a loop
#' @description Testing the input data stepwise for fixing taxa and check if the whole set can be resolved or not
#' @param data Data.table as constructed by create input. All possible quadruples given the taxon set with status information (quadruple as input available, quadruple not in input = unresolved). In addition, all four triples possible by each quadruple are listed.
#' @param verbose Logical parameter if message should be printed; default F
#' @return The same data.table is returned, with updated status, fixing taxon & round of resolvement.
#' @details Details to the algorithm can be found in the paper LINK
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname runAlgorithm
#' @export
runAlgorithm<-function(data, verbose = F){
  # data = myResults$data
  # verbose = T

  # Step 0: check if input is ok
  expectedNames = c("taxa1","taxa2","taxa3","taxa4","quadruple",
                    "triple1","triple2","triple3","triple4","status")
  stopifnot(names(data) %in% expectedNames)
  stopifnot(class(data$taxa1) == "integer")

  x = table(data$status)
  n = data$taxa4[dim(data)[1]]

  if(verbose == T){message("Using ",as.numeric(x[1])," of ",dim(data)[1], " quadruples as input for algorithm (",n," unique taxa). \n This leaves ", as.numeric(x[2])," quadruples unsolved.")}

  # Step 1: Define solved and unsolved quadruples from input data
  data2<-data.table::copy(data)
  green_quadruples<-data2[status=="input",]
  cross_quadruples<-data2[status=="unresolved",]

  # Step 2: Start repeat loop with myAlgorithm (check for fixing taxon)
  #   check each CQ and change status if resolved
  #   repeat algorithm until all quads are resolved or no changes anymore
  #   (in each round, at least one CQ has to be solved)
  #   (if index > dim, then there was at least one round
  #     in which no CQ could be solved)
  # then the set cannot be decisive

  index=0
  data2[,round := 0]
  data2[,fixingTaxa := 0]
  repeat{
    data2=myAlgorithm(data = data2,
                      roundnumber = index,
                      verbose = verbose)
    index=index+1
    data2

    # Loop should stop if there are no new resolved quadruples or no unresolved quadruples
    check1 = (sum(data2$round == index) == 0)
    check2 = (sum(data2$status == "unresolved") == 0)
    if (check1 | check2){
      break
    }
  }

  # Step 3: return data and result
  if(verbose == T){
    if (sum(data2$status == "unresolved") ==0){
      print("PHYLOGENETICALLY DECISIVE")
    }else{
      print("NOT RESOLVABLE VIA THIS ALGORITHM, MAYBE A SECOND FIXING TAXON IS NEEDED")
    }
  }


  return(data2)

}
