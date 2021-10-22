#' @title Algorithm to find fixing taxa
#' @description Split data to input and unresolved quadruples and try for each unresolved one if a fixing taxon can be found.
#' @param data Data.table as constructed by create input + count and fixing taxon. All possible quadruples given the taxon set with status information (quadruple as input available, quadruple not in input = unresolved, quadruples already solved = resolved). In addition, all four triples possible by each quadruple are listed. For resolved quadruples, used fixing taxon and round of resolvement is listed.
#' @param verbose Logical parameter if message should be printed; default F
#' @return The same data.table is returned, with updated status, fixing taxon & round
#' @details Details to the algorithm can be found in the paper LINK
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname myAlgorithm
#' @export
#' @importFrom foreach foreach
#' @importFrom foreach "%do%"
#' @importFrom data.table ":="
myAlgorithm<-function(data,verbose = F){
  # data = data2

  # Step 0: check if input is ok
  expectedNames = c("taxa1","taxa2","taxa3","taxa4","quadruple",
                    "triple1","triple2","triple3","triple4",
                    "status","round","fixingTaxa")
  stopifnot(names(data) %in% expectedNames)
  stopifnot(class(data$taxa1) == "integer")
  round_old = max(data$round)

  # Step 1: split quadruples in resolved and unresolved ones
  data_solved = data[status != "unresolved"]
  data_unresolved = data[status == "unresolved"]

  # Step 2: check every unresolved quadruple for fixing taxon
  myTab = foreach::foreach(i = 1:dim(data_unresolved)[1]) %do%{
    # i=1

    # Step 2.1: get all triples for unresolved quadruple
    triples_CQ<-data_unresolved[i,c("triple1","triple2","triple3","triple4")]
    triples_CQ = unique(unlist(triples_CQ))

    # Step 2.2: check overlap with resolved triples
    vgl1<-is.element(data_solved$triple1,triples_CQ)
    vgl2<-is.element(data_solved$triple2,triples_CQ)
    vgl3<-is.element(data_solved$triple3,triples_CQ)
    vgl4<-is.element(data_solved$triple4,triples_CQ)

    # Step 2.3: get resolved quadruples that contain at least one of the four tested triples
    filt<-vgl1 | vgl2 | vgl3 | vgl4
    data_pos<-data_solved[filt,]

    if(dim(data_pos)[1]==0){
      # Step 2.5: return best taxa, taxa count & unresolved quadruple
      res = data.table::data.table(unres_quad = data_unresolved[i,quadruple],
                                   best_fixTaxa = 0,
                                   count = 0)
    }else{
      # Step 2.4: search for possible fixing taxa
      # using only taxa in data_pos, which are not in the unresolved quadruple
      # Count the most common taxa only!
      taxa_pos = unlist(data_pos[,c("taxa1","taxa2","taxa3","taxa4")])
      taxa_unresolved = unique(unlist(data_unresolved[i,c("taxa1","taxa2","taxa3","taxa4")]))
      taxa_pos2 = taxa_pos[!is.element(taxa_pos,taxa_unresolved)]
      tab = data.table::data.table(taxa_ID = taxa_pos2)
      tab2 = tab[,.N, by=taxa_ID]
      tab3 = tab2[N == max(N),]
      if(dim(tab3)[1]>1){tab3 = tab3[1,]}

      # Step 2.5: return best taxa, taxa count & unresolved quadruple
      res = data.table::data.table(unres_quad = data_unresolved[i,quadruple],
                                   best_fixTaxa = tab3$taxa_ID,
                                   count = tab3$N)

    }

    res
  }
  myTab = data.table::rbindlist(myTab)
  myTab

  # Step 3: if count of taxa >=4 it can be considered a fixing taxon, and the quadruple is resolved
  stopifnot(myTab$unres_quad == data_unresolved$quadruple)
  filt = myTab$count>=4
  data_unresolved[filt,status := "resolved"]
  data_unresolved[filt,fixingTaxa := myTab[filt,best_fixTaxa]]
  data_unresolved[filt,round := round + 1]
  data_unresolved

  # Step 4: return data
  data3 = rbind(data_solved,data_unresolved)
  table(data3$status)
  tab4<-data3[,.N,by=status]
  n_unresolved_new = tab4[status == "unresolved",N]
  if (length(n_unresolved_new)==0){n_unresolved_new = 0}
  n_unresolved_old = dim(data_unresolved)[1]
  n_diff = n_unresolved_old - n_unresolved_new
  round_new = max(data3$round)
  if(round_new == round_old){round_new = round_new + 1}

  if(verbose == T){message("In round #",round_new,", ",n_diff," quadruples could be resolved ...")}
  return(data3)
}
