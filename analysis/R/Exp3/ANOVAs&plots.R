library(ggplot2)
library(ez)
library(Hmisc)

#### clear environment
rm(list = ls())

#### load data
# on Inspiron 13
setwd("C:/Users/wuxiu/Documents/PhD@UBC/Lab/2ndYear/AnticipatoryPursuit/AnticipatoryPursuitMotionPerception/analysis/R")
source("pairwise.t.test.with.t.and.df.R")
plotFolder <- ("C:/Users/wuxiu/Documents/PhD@UBC/Lab/Comprehensive exam/figures/")
### modify these parameters to plot different conditions
dataFileName <- "aspGainCompare.csv"
# pdfFileName <- "aspGainExp2.pdf"
# for plotting
textSize <- 25
axisLineWidth <- 0.5
dotSize <- 3
subN <- 9 # for calculating standard errors

# source("pairwise.t.test.with.t.and.df.R")
data <- read.csv(dataFileName)

# # exclude bad fitting...
# data <- subset(data[which(data$sub!=8),])

# # PSE anova
# sub <- data["sub"]
# prob <- data["prob"]
# # timeBin <- data["timeBin"]
# measure <- data["aspGain"]
# dataAnova <- data.frame(sub, prob, measure)
# dataAnova$prob <- as.factor(dataAnova$prob)
# dataAnova$sub <- as.factor(dataAnova$sub)
# # dataAnova$timeBin <- as.factor(dataAnova$timeBin)
# colnames(dataAnova)[3] <- "PSE"
# # dataAnova <- aggregate(perceptualErrorMean ~ sub * rotationSpeed * exp,
#     # data = dataTemp, FUN = "mean")

# # anovaData <- ezANOVA(dataAnova, dv = .(PSE), wid = .(sub),
# #     within = .(prob), type = 3)
# # print(anovaData)

# p <- ggplot(dataAnova, aes(x = prob, y = PSE)) +
#         stat_summary(aes(y = PSE), fun.y = mean, geom = "point", shape = 95, size = 15) +
#         stat_summary(fun.data = 'mean_sdl',
#                fun.args = list(mult = 1.96/sqrt(subN)),
#                geom = 'errorbar', width = .1) +
# # geom = 'smooth', se = 'TRUE') +
#         # stat_summary(aes(y = PSE), fun.data = mean_se, geom = "errorbar", width = 0.1) +
#         geom_point(aes(x = prob, y = PSE), size = dotSize, shape = 1) +
#         # geom_segment(aes_all(c('x', 'y', 'xend', 'yend')), data = data.frame(x = c(50, 40), xend = c(90, 40), y = c(-0.1, -0.1), yend = c(-0.1, 0.15)), size = axisLineWidth) +
#         scale_y_continuous(name = "Anticipatory pursuit gain", limits = c(-0.1, 0.55), expand = c(0, 0)) +
#         scale_x_discrete(name = "Probability of rightward motion", breaks=c("50", "70", "90")) +
#         # scale_x_discrete(name = "Probability of rightward motion", breaks=c(50, 70, 90)) +
#         # scale_colour_discrete(name = "After reversal\ndirection", labels = c("CCW", "CW")) +
#         theme(axis.text=element_text(colour="black"),
#               axis.ticks=element_line(colour="black", size = axisLineWidth),
#               panel.grid.major = element_blank(),
#               panel.grid.minor = element_blank(),
#               panel.border = element_blank(),
#               panel.background = element_blank(),
#               text = element_text(size = textSize, colour = "black"),
#               legend.background = element_rect(fill="transparent"),
#               legend.key = element_rect(colour = "transparent", fill = "white"))
#         # facet_wrap(~prob)
# print(p)
# ggsave(paste(plotFolder, pdfFileName, sep = ""))

## comparison between experiments 
# ASP gain bias
sub <- data["sub"]
exp <- data["exp"]
aspGainDiff <- data["aspGainDiff"]
dataAnova <- data.frame(sub, exp, aspGainDiff)
dataAnova$exp <- as.factor(dataAnova$exp)
dataAnova$sub <- as.factor(dataAnova$sub)

anovaData <- ezANOVA(dataAnova, dv = .(aspGainDiff), wid = .(sub),
    within = .(exp), type = 3)
print(anovaData)

# p <- ggplot(data, aes(x = exp, y = aspGainDiff)) +
#         stat_summary(aes(y = aspGainDiff), fun.y = mean, geom = "point", shape = 95, size = 15) +
#         stat_summary(fun.data = 'mean_sdl',
#                fun.args = list(mult = 1.96/sqrt(subN)),
#                geom = 'errorbar', width = .1) +
#         # stat_summary(aes(y = PSE), fun.data = mean_se, geom = "errorbar", width = 0.1) +
#         geom_point(aes(x = exp, y = aspGainDiff), size = dotSize, shape = 1) +
#         # geom_segment(aes_all(c('x', 'y', 'xend', 'yend')), data = data.frame(x = c(50, 40), xend = c(90, 40), y = c(-0.1, -0.1), yend = c(-0.1, 0.15)), size = axisLineWidth) +
#         scale_y_continuous(name = "ASP gain bias", limits = c(0, 0.3), expand = c(0, 0.05)) +
#         scale_x_discrete(name = "Experiment", breaks=c("Exp1", "Exp2")) +
#         # scale_x_discrete(name = "Probability of rightward motion", breaks=c(50, 70, 90)) +
#         # scale_colour_discrete(name = "After reversal\ndirection", labels = c("CCW", "CW")) +
#         theme(axis.text=element_text(colour="black"),
#               axis.ticks=element_line(colour="black", size = axisLineWidth),
#               panel.grid.major = element_blank(),
#               panel.grid.minor = element_blank(),
#               panel.border = element_blank(),
#               panel.background = element_blank(),
#               text = element_text(size = textSize, colour = "black"),
#               legend.background = element_rect(fill="transparent"),
#               legend.key = element_rect(colour = "transparent", fill = "white"))
#         # facet_wrap(~prob)
# print(p)
# ggsave(paste(plotFolder, pdfFileName, sep = ""))

# # PSE bias
# sub <- data["sub"]
# exp <- data["exp"]
# PSEbias <- data["PSEbias"]
# dataAnova <- data.frame(sub, exp, PSEbias)
# dataAnova$exp <- as.factor(dataAnova$exp)
# dataAnova$sub <- as.factor(dataAnova$sub)

# anovaData <- ezANOVA(dataAnova, dv = .(PSEbias), wid = .(sub),
#     within = .(exp), type = 3)
# print(anovaData)

# p <- ggplot(data, aes(x = exp, y = PSEbias)) +
#         stat_summary(aes(y = PSEbias), fun.y = mean, geom = "point", shape = 95, size = 15) +
#         stat_summary(fun.data = 'mean_sdl',
#                fun.args = list(mult = 1.96/sqrt(subN)),
#                geom = 'errorbar', width = .1) +
#         # stat_summary(aes(y = PSE), fun.data = mean_se, geom = "errorbar", width = 0.1) +
#         geom_point(aes(x = exp, y = PSEbias), size = dotSize, shape = 1) +
#         # geom_segment(aes_all(c('x', 'y', 'xend', 'yend')), data = data.frame(x = c(50, 40), xend = c(90, 40), y = c(-0.1, -0.1), yend = c(-0.1, 0.15)), size = axisLineWidth) +
#         scale_y_continuous(name = "PSE bias", limits = c(0, 0.15), expand = c(0, 0.01)) +
#         scale_x_discrete(name = "Experiment", breaks=c("Exp1", "Exp2")) +
#         # scale_x_discrete(name = "Probability of rightward motion", breaks=c(50, 70, 90)) +
#         # scale_colour_discrete(name = "After reversal\ndirection", labels = c("CCW", "CW")) +
#         theme(axis.text=element_text(colour="black"),
#               axis.ticks=element_line(colour="black", size = axisLineWidth),
#               panel.grid.major = element_blank(),
#               panel.grid.minor = element_blank(),
#               panel.border = element_blank(),
#               panel.background = element_blank(),
#               text = element_text(size = textSize, colour = "black"),
#               legend.background = element_rect(fill="transparent"),
#               legend.key = element_rect(colour = "transparent", fill = "white"))
#         # facet_wrap(~prob)
# print(p)
# ggsave(paste(plotFolder, pdfFileName, sep = ""))