#' @title Perform some initial checks
#' @description Three checks, according to my master thesis
#' @param data Input data created by createInput()
#' @return Results of the three checks (OK or not OK)
#' @details See master thesis, Lemma 1, Theorem 5 & 6
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso
#'  \code{\link[data.table]{as.data.table}}
#' @rdname initialCheck
#' @export
#' @importFrom data.table as.data.table
initialCheck = function(data){
  # data = myResults$data

  # Step 0: check if data is in the right format (created by createInput())
  expectedNames = c("taxa1","taxa2","taxa3","taxa4","quadruple",
                    "triple1","triple2","triple3","triple4","status")
  stopifnot(names(data) %in% expectedNames)
  stopifnot(class(data$taxa1) == "integer")
  dummy1<-unique(data$taxa1)
  dummy2<-data$taxa4[dim(data)[1]]
  stopifnot(max(dummy1)+3 == dummy2)

  # Check 1: Input size (see master thesis, Theorem 5 or conjecture)
  # if  < als 4 aus (n-1), dann npd
  cross_quadruples<-data[status=="unresolved",]
  green_quadruples<-data[status=="input",]
  n = dummy2

  input_length<-dim(green_quadruples)[1]
  if (input_length < choose(n-1,3)){
    comment1 = "CHECK 1 NOT OK - NOT RESOLVABLE VIA THIS ALGORITHM"
  }else{comment1 = "CHECK 1 OK - input is not too small ..."}
  print(comment1)

  # Check 2: Triple coverage (see master thesis, Lemma 1)
  all_triple_taxa<-t(combn(n,3))
  all_triple_taxa<-data.table::as.data.table(all_triple_taxa)
  names(all_triple_taxa) = c("taxa1","taxa2","taxa3")
  all_triple_taxa[,triple := paste(taxa1,taxa2,taxa3,sep="_")]

  all_triple_taxa[,count:=0]
  all_triple_taxa[triple %in% green_quadruples$triple1,count:=count + 1]
  all_triple_taxa[triple %in% green_quadruples$triple2,count:=count + 1]
  all_triple_taxa[triple %in% green_quadruples$triple3,count:=count + 1]
  all_triple_taxa[triple %in% green_quadruples$triple4,count:=count + 1]

  end_check2<-min(all_triple_taxa$count)
  if(end_check2<0){
    comment2 ="CHECK 2 NOT OK - NOT PHYLOGENETICALLY DECISIVE"
  }else{comment2 = "CHECK 2 OK - all triples are at least one time there"}
  print(comment2)

  # Check 3: Tuple coverage (see master thesis, Theorem 6)
  all_tuple_taxa<-t(combn(n,2))
  all_tuple_taxa<-as.data.frame(all_tuple_taxa)
  tuple_h<-vector(mode="numeric",length=dim(all_tuple_taxa)[1])
  for (i in 1:dim(all_tuple_taxa)[1]){
    #i=1
    tab1<-all_tuple_taxa[i,1] == green_quadruples[,c(1,2,3,4)] |
      all_tuple_taxa[i,2] == green_quadruples[,c(1,2,3,4)]
    dim(tab1)
    tab2<-vector(mode="numeric",length=dim(tab1)[1])
    for(j in 1:dim(tab1)[1]){
      tab2[j]<-sum(tab1[j,]==TRUE)
    }
    tuple_h[i]<-sum(tab2==2)
  }
  check2<-tuple_h<=(n-4)
  end_check2<-sum(check2==TRUE)
  if (end_check2>0){
    comment3 = "CHECK 3 NOT OK - NOT PHYLOGENETICALLY DECISIVE"
  }else{comment3 = "CHECK 3 OK - all tuples are often enough available"}
  print(comment3)

  return(c(comment1,comment2,comment3))
}
