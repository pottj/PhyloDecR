#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param c PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname myAlgorithm
#' @export
myAlgorithm<-function(c){
  # a = alt_green
  # b = alt_cross
  # c = all_quads

  filt_unresolved<-c$status == "unresolved"
  b<-c[filt_unresolved,]
  a<-c[!filt_unresolved,]
  y<-vector(mode="numeric",length=dim(b)[1])
  for (i in c(1:dim(b)[1])){
    triples_CQ<-t(b[i,c(6,7,8,9)]);
    vgl1<-is.element(a$triple1,triples_CQ);
    vgl2<-is.element(a$triple2,triples_CQ);
    vgl3<-is.element(a$triple3,triples_CQ);
    vgl4<-is.element(a$triple4,triples_CQ);
    filt<-vgl1 | vgl2 | vgl3 | vgl4 ;
    pos<-a[filt,];
    x<-c(pos$taxa1,pos$taxa2,pos$taxa3,pos$taxa4);
    filt_x1<- x == b[i,2];
    filt_x2<- x == b[i,3];
    filt_x3<- x == b[i,4];
    filt_x4<- x == b[i,5];
    filt_x<- filt_x1 | filt_x2 | filt_x3 | filt_x4;
    x1<-x[!filt_x];
    y[i]<-max(table(x1))
  }
  for (j in c(1:dim(b)[1])){
    if (y[j]>=4){
      b[j,10]<-"resolved"
    }
  }
  filt_res<-b$status == "resolved";
  c<-rbind(a,b)
  return(c)
}
