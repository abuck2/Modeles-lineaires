setwd("/home/axel/Documents/Modèles_linéaires/")
automobile<-read.csv("automobileclean.csv")

library(xtable)
library(pastecs)
automobilenum <- automobile[,c("symboling","normalizedlosses","wheelbase","length","width","height","curbweight","enginesize","bore","stroke",
                               "compressionratio","horsepower","peakrpm","citympg","highwaympg","price")]
statdescauto<-t(stat.desc(automobilenum,T,T))
statdescauto<- statdescauto[,c("mean","std.dev","median","min","max")]
xtable(statdescauto)
autocrosstable<-xtabs(~aspiration+fueltype, data=automobile)
xtable(autocrosstable)
png(file="boxplot2.png", width = 1600, height=1600,pointsize = 40)

myboxplots<-function(index) 
{
  boxplot(automobilenum[,index], main=names(automobilenum[index]))
  
}
par(mfrow=c(3,3),oma=c(0,0,2,0))
sapply(10:16,FUN=myboxplots)
title(main="Boxplots de toutes les variables",outer=T)
dev.off()

