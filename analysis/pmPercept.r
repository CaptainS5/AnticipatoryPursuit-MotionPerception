# install.packages("MPDiR")
# install.packages("dplyr")
# install.packages("quickpsy")
library(MPDiR)
library(dplyr)
library(quickpsy)
library(ggplot2)

#### clear environment
rm(list = ls())

#### load data
setwd("E:/XiuyunWu/AnticipatoryPursuit-MotionPerception/analysis")
dataP <- read.csv("pilot00.csv")
trialPerLevel <- 26

dataP <- dataP[which(dataP$trialType==0), ]
dataP[which(dataP$coh==0), ]$dir <- 1
dataP$resp <- dataP$resp-1 # 0-R, 1-L

# dataAgg <- aggregate(resp ~ sub * coh * dir * prob, data = dataP, FUN = function(x) c(countL = sum(x), totalN = length(x)))
dataAgg <- aggregate(resp ~ sub * coh * dir * prob, data = dataP, FUN = "sum")
do.call(data.frame, dataAgg)
# dataAgg$resp <- dataAgg$resp/trialPerLevel
dataAgg[which(dataAgg$dir==2), ]$coh <- dataAgg[which(dataAgg$dir==2), ]$coh*(-1)
show(dataAgg)

pdf("pilot00_pmPercept.pdf")
p <- ggplot(dataAgg, aes(x = coh, y = 1-resp/trialPerLevel)) +
        geom_point() +
        scale_y_continuous(name = "Probability of right") +
        scale_x_continuous(name = "Coherence (negative is left)", breaks=c(-0.15, -0.1, -0.05, 0, 0.05, 0.1, 0.15)) +
        facet_wrap(~prob)
print(p)
dev.off()
