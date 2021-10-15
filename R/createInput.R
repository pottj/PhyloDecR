#' @title Create Input for my package
#' @description Take a .txt file with quadruples and to some pre-checks of the data
#' @param fn Name of my file to be transformed
#' @param sepSym Character or symbol used to separate the taxa
#' @return The output is a list containing the input data (sep = "_"), all possible combinations given the input taxa with there input status (quadruple as input available, quadruple not in input = unresolved), total number of taxa in the input data, and resulting comments in the three checks.
#' @details
#' * Check 1: check if input number of quadruples is too small (must be more than (n-1) choose 4)
#' * Check 2: check if one triple is missing completely (all triples must occure at least once)
#' * Check 3: check if one tuple is too rare
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname createInput
#' @export
createInput<-function(fn, sepSym){
  # fn = "../../2103_FischerPaper/_archive/quadruple_check2.txt"
  # sepSym = "_"
  data.table::setDTthreads(1)

  # load data
  quad_neu<-data.table::fread(fn,header=F,sep=sepSym)
  colnames(quad_neu)<-c("taxa1","taxa2","taxa3","taxa4")
  input<-paste(quad_neu$taxa1,quad_neu$taxa2,quad_neu$taxa3,quad_neu$taxa4,sep="_")
  x<-c(quad_neu$taxa1,quad_neu$taxa2,quad_neu$taxa3,quad_neu$taxa4)
  y<-unique(x)
  n<-length(y)

  # get all possible quadruples given the number of input taxa
  all_quadruples<-t(combn(n,4))
  colnames(all_quadruples)<-c("taxa1","taxa2","taxa3","taxa4")
  all_quadruples<-as.data.frame(all_quadruples)

  # get overview table with all taxa, triple and quadruples
  quadruple<-paste(all_quadruples$taxa1,all_quadruples$taxa2,all_quadruples$taxa3,all_quadruples$taxa4,sep="_")
  triple1<-paste(all_quadruples$taxa1,all_quadruples$taxa2,all_quadruples$taxa3,sep="_")
  triple2<-paste(all_quadruples$taxa1,all_quadruples$taxa2,all_quadruples$taxa4,sep="_")
  triple3<-paste(all_quadruples$taxa1,all_quadruples$taxa3,all_quadruples$taxa4,sep="_")
  triple4<-paste(all_quadruples$taxa2,all_quadruples$taxa3,all_quadruples$taxa4,sep="_")

  data_all<-cbind(quadruple,all_quadruples,triple1,triple2,triple3,triple4)
  data.table::setDT(data_all)

  # check if input is too small
  # if  < als 4 aus (n-1), dann npd
  vgl0<-is.element(data_all$quadruple,input)
  table(vgl0)
  cross_quadruples<-data_all[!vgl0,]
  green_quadruples<-data_all[vgl0,]

  data_all[vgl0,status:="input"]
  data_all[!vgl0,status:="unresolved"]

  input_length<-dim(green_quadruples)[1]
  if (input_length < choose(n-1,4)){
    comment1 = "CHECK 1 NOT OK - NOT RESOLVABLE VIA THIS ALGORITHM"
  }else{comment1 = "CHECK 1 OK - input is not too small ..."}
  print(comment1)

  # check if one triple is missing completly
  all_triple_taxa<-t(combn(n,3))
  all_triple_taxa<-as.data.frame(all_triple_taxa)
  triple_h<-vector(mode="numeric",length=dim(all_triple_taxa)[1])
  for (i in 1:dim(all_triple_taxa)[1]){
    tab1<-all_triple_taxa[i,1] == green_quadruples[,c(2,3,4,5)] |
      all_triple_taxa[i,2] == green_quadruples[,c(2,3,4,5)] |
      all_triple_taxa[i,3] == green_quadruples[,c(2,3,4,5)]
    dim(tab1)
    tab2<-vector(mode="numeric",length=dim(tab1)[1])
    for(j in 1:dim(tab1)[1]){
      tab2[j]<-sum(tab1[j,]==TRUE)
    }
    triple_h[i]<-sum(tab2==3)
  }
  check1<-triple_h==0
  end_check1<-sum(check1==TRUE)
  if(end_check1>0){
    comment2 ="CHECK 2 NOT OK - NOT PHYLOGENETICALLY DECISIVE"
  }else{comment2 = "CHECK 2 OK - all triples are at least one time there"}
  print(comment2)

  # check if one tuple is too rare
  all_tuple_taxa<-t(combn(n,2))
  all_tuple_taxa<-as.data.frame(all_tuple_taxa)
  tuple_h<-vector(mode="numeric",length=dim(all_tuple_taxa)[1])
  for (i in 1:dim(all_tuple_taxa)[1]){
    tab1<-all_tuple_taxa[i,1] == green_quadruples[,c(2,3,4,5)] |
      all_tuple_taxa[i,2] == green_quadruples[,c(2,3,4,5)]
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

  # return input as list
  myResults<-list(input = input,
                  data = data_all,
                  taxa = y,
                  comments= c(comment1, comment2, comment3))
  return(myResults)
}
