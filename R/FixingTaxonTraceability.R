#' @title Algorithm to test for fixing taxon traceability
#' @description Testing the input data stepwise for fixing taxa and check if the whole set can be resolved or not. The algorithm follows strictly the Mathematica template from Mareike Fischer by checking each green quadruple if it can be used to solve a red one. There are two counters: first a simple counter adding up all solved quadruples (green + newGreens). If this reaches the maximal number of quadruples, the while loops stops. Second, I use a count to track the number of while and for loops used.
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
#' @seealso
#'  \code{\link[data.table]{copy}}
#'  \code{\link[foreach]{foreach}}
#' @rdname FixingTaxonTraceability
#' @export
#' @importFrom data.table copy
#' @importFrom foreach foreach
FixingTaxonTraceability<-function(data, verbose = F){
  # data = test$data
  # verbose = T

  # Step 0: check if input is ok
  expectedNames = c("taxa1","taxa2","taxa3","taxa4","quadruple",
                    "triple1","triple2","triple3","triple4","status")
  stopifnot(names(data) %in% expectedNames)
  stopifnot(class(data$taxa1) == "integer")
  data2 = data.table::copy(data)
  data2[,round := 0]
  data2[,counter := 0]
  data2[,fixingTaxa := 0]

  # Step 1: define parameters
  X = unique(unlist(data2[,c("taxa1","taxa2","taxa3","taxa4")]))
  n = length(X)
  maxCounter = choose(n,4)
  newGreens = data2[status =="input",]
  allGreens = data2[status =="input",]
  counter = dim(newGreens)[1]
  count = 0
  data_unresolved = data2[status !="input",]

  if(verbose == T){
    message("Using ",dim(newGreens)[1],
            " of ",dim(data2)[1],
            " quadruples as input for algorithm (",
            n," unique taxa). \n This leaves ",
            dim(data2)[1] - dim(newGreens)[1] ," quadruples unsolved.")
    }

  # Step 2: While loop
  while(counter < maxCounter & dim(newGreens)[1]!=0){
    quad = newGreens[1,]
    a = quad[,taxa1]
    b = quad[,taxa2]
    c = quad[,taxa3]
    d = quad[,taxa4]
    inputTaxa = c(a,b,c,d)
    X2 = X[!is.element(X,inputTaxa)]

    myTab = foreach::foreach(i = 1:length(X2))%do%{
      # i=2
      x = X2[i]
      test_quad1 = c(b,c,d,x)
      test_quad1 = test_quad1[order(test_quad1)]
      test_quad1 = paste(test_quad1,collapse="_")
      test_quad2 = c(a,c,d,x)
      test_quad2 = test_quad2[order(test_quad2)]
      test_quad2 = paste(test_quad2,collapse="_")
      test_quad3 = c(a,b,d,x)
      test_quad3 = test_quad3[order(test_quad3)]
      test_quad3 = paste(test_quad3,collapse="_")
      test_quad4 = c(a,b,c,x)
      test_quad4 = test_quad4[order(test_quad4)]
      test_quad4 = paste(test_quad4,collapse = "_")

      data_pos = allGreens[is.element(quadruple,c(test_quad1,test_quad2,test_quad3,test_quad4))]

      if(dim(data_pos)[1]==3){
        filt = is.element(data_unresolved$quadruple,c(test_quad1,test_quad2,test_quad3,test_quad4))
        if(data_unresolved[filt,status] == "unresolved"){
          data_unresolved[filt,status := "resolved"]
          data_unresolved[filt,round := count + 1]
          data_unresolved[filt,counter := counter + 1]
          resolvedTaxa = data_unresolved[filt,c(taxa1,taxa2,taxa3,taxa4)]
          FT = inputTaxa[!is.element(inputTaxa,resolvedTaxa)]
          data_unresolved[filt,fixingTaxa := FT]
          newGreens = rbind(newGreens,data_unresolved[filt,])
          allGreens = rbind(allGreens,data_unresolved[filt,])
          data_unresolved = data_unresolved[!filt]
          counter = counter + 1
        }
      }
      count = count + 1
    }

    # get new green and new count
    newGreens = newGreens[!is.element(quadruple,quad),]


  }
  count
  counter


  # Step 3: Check result
  if(verbose == T){
    message("It took ",count," steps to come to a conclusion ...")
  }

  if(verbose == T){
      if(counter == maxCounter){
        message("Fixing taxon traceable! \n     Hence also phylogenetic decisive!")
      }else{
        message("Not all quadruples can be resolved via fixing taxa - please increase input data! \n     You can check the input partly resolved data for next steps")
      }
  }
  finData = rbind(allGreens,data_unresolved)
  finData[maxCounter,round := count]
  return(finData)

}
