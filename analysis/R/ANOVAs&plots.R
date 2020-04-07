library(ggplot2)
library(ez)
library(Hmisc)
library(reshape2)
library(psychReport)

#### clear environment
rm(list = ls())

#### load data
# on Inspiron 13
setwd("C:/Users/wuxiu/Documents/PhD@UBC/Lab/2ndYear/AnticipatoryPursuit/AnticipatoryPursuitMotionPerception/analysis/R")
source("pairwise.t.test.with.t.and.df.R")
plotFolder <- ("C:/Users/wuxiu/Documents/PhD@UBC/Lab/2ndYear/AnticipatoryPursuit/AnticipatoryPursuitMotionPerception/results/manuscript/figures/")
### modify these parameters to plot different conditions
dataFileName <- "PSE_exp1vs3.csv"
dataDFileName <- "PSEdiff_exp1vs3.csv"
pdfFileName <- "PSE_Exp1vs3.pdf"
pdfFileNameD <- "PSEdiff_Exp1vs3.pdf"
# for plotting
textSize <- 25
axisLineWidth <- 0.5
dotSize <- 3
subN <- 9 # for calculating standard errors

data <- read.csv(dataFileName)
dataD <- read.csv(dataDFileName)
# data <- data[data.exp==3]
# # exclude bad fitting...
# data <- subset(data[which(data$sub!=8),])

# PSE anova
sub <- data["sub"]
exp <- data["exp"]
prob <- data["prob"]
# timeBin <- data["timeBin"]
measure <- data["PSE"]
dataAnova <- data.frame(sub, prob, exp, measure)
dataAnova$prob <- as.factor(dataAnova$prob)
dataAnova$sub <- as.factor(dataAnova$sub)
dataAnova$exp <- as.factor(dataAnova$exp)
# dataAnova$timeBin <- as.factor(dataAnova$timeBin)
colnames(dataAnova)[4] <- "measure"
# dataAnova <- aggregate(perceptualErrorMean ~ sub * rotationSpeed * exp,
    # data = dataTemp, FUN = "mean")

anovaData <- ezANOVA(dataAnova, dv = .(measure), wid = .(sub),
    within = .(prob, exp), type = 3, return_aov = TRUE, detailed = TRUE)
# print(anovaData)
aovEffectSize(anovaData, 'pes')

p <- ggplot(dataAnova, aes(x = prob, y = measure, color = exp)) +
        stat_summary(aes(y = measure), fun.y = mean, geom = "point", shape = 95, size = 15) +
        stat_summary(fun.data = 'mean_sdl',
               fun.args = list(mult = 1.96/sqrt(subN)),
               geom = 'errorbar', width = .1) +
# geom = 'smooth', se = 'TRUE') +
        # stat_summary(aes(y = measure), fun.data = mean_se, geom = "errorbar", width = 0.1) +
        geom_point(aes(x = prob, y = measure), size = dotSize, shape = 1) +
        # geom_segment(aes_all(c('x', 'y', 'xend', 'yend')), data = data.frame(x = c(50, 40), xend = c(90, 40), y = c(-0.1, -0.1), yend = c(-0.1, 0.15)), size = axisLineWidth) +
        # scale_y_continuous(name = "Anticipatory pursuit velocity (deg/s)") + #, limits = c(-0.1, 0.55), expand = c(0, 0)) +
        scale_y_continuous(name = "PSE") + 
        scale_x_discrete(name = "Probability of rightward motion", breaks=c("50", "90")) +
        # scale_x_discrete(name = "Probability of rightward motion", breaks=c(50, 70, 90)) +
        # scale_colour_discrete(name = "After reversal\ndirection", labels = c("CCW", "CW")) +
        theme(axis.text=element_text(colour="black"),
                      axis.ticks=element_line(colour="black", size = axisLineWidth),
                      panel.grid.major = element_blank(),
                      panel.grid.minor = element_blank(),
                      panel.border = element_blank(),
                      panel.background = element_blank(),
                      text = element_text(size = textSize, colour = "black"),
                      legend.background = element_rect(fill="transparent"),
                      legend.key = element_rect(colour = "transparent", fill = "white"))
        # facet_wrap(~exp)
print(p)
ggsave(paste(plotFolder, pdfFileName, sep = ""))

## t-test of the difference
sub <- dataD["sub"]
exp <- dataD["exp"]
measure <- dataD["PSEdiff"]
dataDtemp <- data.frame(sub, exp, measure)
dataDtemp$sub <- as.factor(dataDtemp$sub)
dataDtemp$exp <- as.factor(dataDtemp$exp)
colnames(dataDtemp)[3] <- "measure"
# dataDttest <- aggregate(measure ~ exp, data = dataDtemp, FUN = "mean")

res <- pairwise.t.test.with.t.and.df(x = dataDtemp$measure, g = dataDtemp$exp, paired = TRUE, p.adj="none")
show(res) # [[3]] = p value table, un adjusted
res[[5]] # t-value
res[[6]] # dfs
res[[3]]
p.adjust(res[[3]], method = "bonferroni", n = 9) 

p <- ggplot(dataDtemp, aes(x = exp, y = measure)) +
        stat_summary(aes(y = measure), fun.y = mean, geom = "point", shape = 95, size = 15) +
        stat_summary(fun.data = 'mean_sdl',
               fun.args = list(mult = 1.96/sqrt(subN)),
               geom = 'errorbar', width = .1) +
        # stat_summary(aes(y = PSE), fun.data = mean_se, geom = "errorbar", width = 0.1) +
        geom_point(aes(x = exp, y = measure), size = dotSize, shape = 1) +
        # geom_segment(aes_all(c('x', 'y', 'xend', 'yend')), data = data.frame(x = c(50, 40), xend = c(90, 40), y = c(-0.1, -0.1), yend = c(-0.1, 0.15)), size = axisLineWidth) +
        scale_y_continuous(name = "PSE bias", limits = c(0, 0.15), expand = c(0, 0.01)) +
        scale_x_discrete(name = "Experiment", breaks=c("Exp1", "Exp3")) +
        # scale_x_discrete(name = "Probability of rightward motion", breaks=c(50, 70, 90)) +
        # scale_colour_discrete(name = "After reversal\ndirection", labels = c("CCW", "CW")) +
        theme(axis.text=element_text(colour="black"),
              axis.ticks=element_line(colour="black", size = axisLineWidth),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(),
              panel.border = element_blank(),
              panel.background = element_blank(),
              text = element_text(size = textSize, colour = "black"),
              legend.background = element_rect(fill="transparent"),
              legend.key = element_rect(colour = "transparent", fill = "white"))
        # facet_wrap(~prob)
print(p)
ggsave(paste(plotFolder, pdfFileNameD, sep = ""))