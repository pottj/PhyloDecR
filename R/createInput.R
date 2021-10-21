#' @title Create Input for PhyloDecR Package
#' @description The function takes a .txt file with taxon lists (quadruples or more) and transforms them to target format (only quadruples, numbered, ordered)
#' @param fn Path to .txt file containing the taxon list. Taxa within can be numbers or characters. If the taxon lists have different length, missing entries will be filled with NA (if input is numeric) or "" (if input are characters).
#' @param sepSym Character or symbol used to separate the taxa, e.g. "_" or ","
#' @return The output is a list containing the 5 data sets:
#'
#' * input_raw: data as given in the .txt file.
#' * input_quadruples: interim result, data transformed into quadruples only
#' * input_ordered: data transformed to quadruples, and taxa ID forced to numeric and ordered hierarchically
#' * data: all possible quadruples given the taxon set with status information (quadruple as input available, quadruple not in input = unresolved). In addition, all four triples possible by each quadruple are listed
#' * taxa: data table used for transformation, taxaID denotes the original input taxaID (as in input_raw & input_quadruples), NR is the ordered number of this taxon (as in input_ordered & data)
#'
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso
#'  \code{\link[data.table]{setDTthreads}},\code{\link[data.table]{fread}},\code{\link[data.table]{data.table-package}},\code{\link[data.table]{setorder}},\code{\link[data.table]{as.data.table}},\code{\link[data.table]{rbindlist}},\code{\link[data.table]{copy}}
#'  \code{\link[foreach]{foreach}}
#' @rdname createInput
#' @export
#' @importFrom data.table setDTthreads fread data.table setorder as.data.table rbindlist copy
#' @importFrom foreach foreach
createInput<-function(fn, sepSym){
  # fn = "../../2103_FischerPaper/Beispiele/example_Fischer_1.txt"
  # sepSym = ","

  # Step 0: load data
  data.table::setDTthreads(1)
  quad_neu<-data.table::fread(fn,sep=sepSym, fill=T,header=F)

  # Step 1: count columns & rows
  nCol = dim(quad_neu)[2]
  nRow = dim(quad_neu)[1]
  UniqueTaxa = unique(unlist(quad_neu))
  UniqueTaxa = UniqueTaxa[!is.na(UniqueTaxa)]
  UniqueTaxa = UniqueTaxa[UniqueTaxa != ""]
  myTrafoMatrix = data.table::data.table(taxaID = UniqueTaxa)
  names(myTrafoMatrix) = "taxaID"
  data.table::setorder(myTrafoMatrix,taxaID)
  myTrafoMatrix[,NR:=1:dim(myTrafoMatrix)[1]]

  stopifnot(nCol>=4)
  message("Input contains ",nRow," trees with ",dim(myTrafoMatrix)[1]," different taxa. The biggest tree has ",nCol," taxa.")

  # Step 2: get quadrupel format
  # if there are more than 4 taxa, I can assume that all
  # possible quadruples are known.
  # All those quadruples are hence added to the input data

  myData = foreach::foreach(j = 1:nRow)%do%{
    # j=1
    myRow = quad_neu[j,]

    UniqueTaxa2= unique(unlist(myRow))
    UniqueTaxa2 = UniqueTaxa2[!is.na(UniqueTaxa2)]
    UniqueTaxa2 = UniqueTaxa2[UniqueTaxa2 != ""]
    myTrafoMatrix2 = data.table::data.table(taxaID = UniqueTaxa2)
    names(myTrafoMatrix2) = "taxaID"
    data.table::setorder(myTrafoMatrix2,taxaID)
    myTrafoMatrix2[,NR:=1:dim(myTrafoMatrix2)[1]]

    all_quadruples<-t(combn(dim(myTrafoMatrix2)[1],4))
    all_quadruples<-data.table::as.data.table(all_quadruples)
    names(all_quadruples) = c("taxa1","taxa2","taxa3","taxa4")

    all_quadruples2 = all_quadruples

    for(k in dim(myTrafoMatrix2)[1]:1){
      # k=4
      filt = all_quadruples2 == myTrafoMatrix2[k,NR]
      all_quadruples2[filt] = myTrafoMatrix2[k,taxaID]
    }
    all_quadruples2
  }
  myData = data.table::rbindlist(myData)

  # Step 3: force numeric & ordered taxa
  myData2 = myData
  for(k in dim(myTrafoMatrix)[1]:1){
    # k=4
    filt = myData2 == myTrafoMatrix[k,taxaID]
    myData2[filt] = myTrafoMatrix[k,NR]
  }
  myData2
  myData2[,quadruple := paste(taxa1,taxa2,taxa3,taxa4,sep="_")]

  # Step 4: get all possible quadruples given the number of input taxa
  n = dim(myTrafoMatrix)[1]
  all_quadruples<-t(combn(n,4))
  colnames(all_quadruples)<-c("taxa1","taxa2","taxa3","taxa4")
  all_quadruples<-as.data.frame(all_quadruples)

  # Step 5: get overview table with all taxa, triple and quadruples
  all_quadruples[,quadruple := paste(taxa1,taxa2,taxa3,taxa4,sep="_")]
  all_quadruples[,triple1 := paste(taxa1,taxa2,taxa3,sep="_")]
  all_quadruples[,triple2 := paste(taxa1,taxa2,taxa4,sep="_")]
  all_quadruples[,triple3 := paste(taxa1,taxa3,taxa4,sep="_")]
  all_quadruples[,triple4 := paste(taxa2,taxa3,taxa4,sep="_")]

  data_all<-data.table::copy(all_quadruples)

  filt = is.element(data_all$quadruple,myData2$quadruple)
  table(filt)
  data_all[filt,status:="input"]
  data_all[!filt,status:="unresolved"]

  # return input as list
  myResults<-list(input_raw = quad_neu,
                  input_quadruples = myData,
                  input_ordered = myData2,
                  data = data_all,
                  taxa = myTrafoMatrix)
  return(myResults)
}
