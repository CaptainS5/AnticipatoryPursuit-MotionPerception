# install.packages("MPDiR")
# remove.packages('Rcpp')
# install.packages("dplyr")
# install.packages("quickpsy")
library(MPDiR)
library(dplyr)
library(quickpsy)
library(ggplot2)

#### clear environment
rm(list = ls())

#### load data
# ASUS
# setwd("E:/XiuyunWu/AnticipatoryPursuitMotionPerception/analysis/psychometricFunction")
# XPS13
setwd("C:/Users/CaptainS5/Documents/PhD@UBC/Lab/2nd year/Anticipatory pursuit & ambiguous motion/AnticipatoryPursuitMotionPerception/analysis/psychometricFunction")
dataP <- read.csv("psychometricFunctionData.csv")
# rdkDir: -1 = left, 1 = right
# choice: 0 = left, 1 = right
# trialType: 1 = standard trial, 0 = test trial
# fixationDuration: the determined duration
# fixationDurationTrue: the actual display duration
trialPerLevel <- 26

dataP <- dataP[which(dataP$trialType==0), ]
# assign coh 0 rdk to have the direction right--for plotting...
dataP[which(dataP$coh==0), ]$rdkDir <- 1

# dataAgg <- aggregate(choice ~ sub * coh * rdkDir * prob, data = dataP, FUN = function(x) c(countL = sum(x), totalN = length(x)))
# since right=1 and left=0, sum is the number of choosing right
dataAgg <- aggregate(choice ~ sub * coh * rdkDir * prob, data = dataP, FUN = "sum")
do.call(data.frame, dataAgg)
# change the left direction coh levels to negative, for plotting...
dataAgg[which(dataAgg$rdkDir==-1), ]$coh <- dataAgg[which(dataAgg$rdkDir==-1), ]$coh*(-1)
dataAgg$prob <- factor(dataAgg$prob)
show(dataAgg)

pdf("tW_pmPercept.pdf")
p <- ggplot(dataAgg, aes(x = coh, y = choice/trialPerLevel, colour = prob)) +
        geom_line() +
        scale_y_continuous(name = "Probability of right") +
        scale_x_continuous(name = "Coherence (negative is left)", breaks=c(-0.15, -0.1, -0.05, 0, 0.05, 0.1, 0.15))
        # facet_wrap(~prob)
print(p)
dev.off()
