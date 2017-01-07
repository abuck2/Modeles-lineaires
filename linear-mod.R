##Setup
setwd("/home/alexis/Documents/stats/annee2/lm/projet/")
data<-read.csv("automobilecleanboxcox.csv")

## selection des variables
str(data)
dim(data)
mean(data$highwaylkm100)
data<-data[,c(1, 6, 4, 11, 3, 12, 5)]
model<-lm(highwaylkm100~., data=data)
model$coefficients

## Création d'une nouvelle variable
set.seed(50)
new<-data.frame(0,0,0,0,0,0,0)
colnames(new)<-colnames(data)
for(i in 1:7){
  new[,i]<-rnorm(1, mean=mean(data[,i]), sd=sd(data[,i]))
}
new<-as.data.frame(new[,2:7])

## Intervalle de prédiction
intrvl<-predict(model, new, interval = "prediction")
intrvl

#IC
intrvl<-predict(model, new, interval = "confidence")
intrvl


## Non transformée
data<-read.csv("automobileclean.csv")
data<-data[,c(4,5,12,15,16,17,3)]
model<-lm(highwaylkm100~., data=data)

## Création d'une nouvelle variable
set.seed(50)
new<-data.frame(0,0,0,0,0,0,0)
colnames(new)<-colnames(data)
for(i in 1:7){
  new[,i]<-rnorm(1, mean=mean(data[,i]), sd=sd(data[,i]))
}
new<-as.data.frame(new[,2:7])

## Intervalle de prédiction
intrvl<-predict(model, new, interval = "prediction")
intrvl
