setwd("/home/alexis/Documents/stats/annee2/lm/projet/")
data<-read.csv("automobilecleanboxcox.csv")
str(data)
dim(data)
data<-data[,c(1, 6, 4, 11, 3, 12, 5)]
model<-lm(highwaylkm100~., data=data)
model$coefficients

set.seed(50)
new<-data.frame(0,0,0,0,0,0,0)
colnames(new)<-colnames(data)
for(i in 1:7){
  new[,i]<-rnorm(1, mean=mean(data[,i]), sd=sd(data[,i]))
}
new<-as.data.frame(new[,2:7])

intrvl<-predict(model, new, interval = "prediction")
intrvl
