
# Threshold and percentils (0.25,0.5,0.75,0.95)
# Nivells: basal-threshold-baix-0.25-moderat-0.5-mitj?-0.75-alt-0.95-molt alt

EpiLevels<-function(df,desired.quantiles=c(.25,.50,.75,.95)){ # df ?s un excel on les columnes son les temporades
  alinement<-c(0)
  df.0<-df
  for(i in 1:length(df)){alinement[i]<-which(df[,i]==max(df[,i]))}
  deletions<-alinement-min(alinement)
  for (i in 1:length(df)){if(deletions[i]>0){df[,i]<-c(df[-seq(0,deletions[i]),i],rep(0,deletions[i]))}}
  mean_evol<-rowMeans(df) # mitjana de totes les files (generem doncs una onada promig)
  didt<-diff(mean_evol)
  first_local_maximum<-which(didt>=3)[1] # punt d'inici és quan tripliquem el creixement
  threshold<-mean_evol[first_local_maximum]
  
  cases_for_percentiles<-mean_evol[seq(first_local_maximum,which(mean_evol==max(mean_evol)))]
  percentils<-quantile(cases_for_percentiles,desired.quantiles)
  M1<-matrix(c(threshold,percentils))
  rownames(M1)<-as.character(c('threshold',desired.quantiles))
  colnames(M1)<-'Value'
  
  # PLOTS
  library(ggplot2)
  library(reshape2)
  library(patchwork)
  df1<-data.frame(mean_evol=mean_evol)
  df1$didt<-c(didt,0)
  df1$setmana<-seq(1,length(df1[,1]))
  
  coeff<-0.2
  g1<-ggplot(df1,aes(x=setmana))+
    geom_line(aes(y=mean_evol),color='lightblue3')+
    geom_line(aes(y=didt/coeff),color='black',alpha=0.7)+
    theme_classic()+
    geom_vline(xintercept = first_local_maximum,lty='dashed')+
    labs(x='time')+
    geom_hline(yintercept = M1[2],size=0.7,color='darkgreen',lty='dashed')+
    geom_hline(yintercept = M1[3],size=0.7,color='darkgoldenrod2',lty='dashed')+
    geom_hline(yintercept = M1[4],size=0.7,color='red',lty='dashed')+
    geom_hline(yintercept = M1[5],size=0.7,color='darkred',lty='dashed')+
    scale_y_continuous(
      name = 'Averaged',
      sec.axis = sec_axis(~.*coeff, name="dIdt")
    )
  df3<-melt(df.0)
  df3$time<-rep(seq(1,length(df[,1])),length(df))
  g2<-ggplot(df3,aes(x=time,y=value,color=variable))+
    geom_line()+
    theme_classic()+
    geom_vline(xintercept = first_local_maximum,lty='dashed')+
    labs(x='time')+
    geom_hline(yintercept = M1[2],size=0.7,color='darkgreen',lty='dashed')+
    geom_hline(yintercept = M1[3],size=0.7,color='darkgoldenrod2',lty='dashed')+
    geom_hline(yintercept = M1[4],size=0.7,color='red',lty='dashed')+
    geom_hline(yintercept = M1[5],size=0.7,color='darkred',lty='dashed')
  
  g3<-g1+g2
  return(list(M1,g3))
}
if(require(xlsx) == F)
  install.packages("xlsx")
library(xlsx)
numero_fulla_excel = 6 #6 i 14
dades = read.xlsx("C:/Users/A. Perramon Malavez/OneDrive - Universitat Politècnica de Catalunya/Escritorio/BIOCOM-SC/PhD Marató/SISAP/incidencies_setmanals.xlsx", sheetIndex = numero_fulla_excel)

EpiLevels(dades)

