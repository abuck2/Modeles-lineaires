setwd("/home/axel/Documents/Modèles_linéaires/")
automobile<-read.csv("automobileclean.csv")

library(xtable)
library(pastecs)
library(doBy)
library(ggplot2)
library(het.test)
automobilenum <- automobile[,c("wheelbase","length","width","height","curbweight","enginesize","bore","stroke",
                               "compressionratio","horsepower","peakrpm","highwaylkm100")]
statdescauto<-t(stat.desc(automobilenum,T,T))
statdescauto<- statdescauto[,c("mean","std.dev","median","min","max")]
xtable(statdescauto)
autocrosstable<-xtabs(~aspiration+fueltype, data=automobile)
xtable(autocrosstable)
bymeanauto<-summaryBy(highwaylkm100 ~ fueltype + aspiration, data=automobile)
xtable(bymeanauto)

ggplot(bymeanauto, aes(x=fueltype, y=highwaylkm100.mean, colour=aspiration,group=aspiration)) + geom_line() + geom_point() + ggtitle("Consommation de carburant en fonction du carburant et du type d'aspiration")+
  theme(legend.justification=c(1,0),legend.position=c(1,0)) 
savePlot("meanauto.png")
png(file="boxplot2.png", width = 1600, height=1600,pointsize = 40)
myboxplots<-function(index) 
{
  boxplot(automobilenum[,index], main=names(automobilenum[index]))
  
}
par(mfrow=c(3,3),oma=c(0,0,2,0))
sapply(10:16,FUN=myboxplots)
title(main="Boxplots de toutes les variables",outer=T)
dev.off()


