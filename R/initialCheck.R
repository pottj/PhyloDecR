initialCheck = function(inputData){

  # Step 0: check if inputData is in the right format (created by createInput())

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

  # check if one triple is missing completely (Lemma 1 of my master thesis)
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
