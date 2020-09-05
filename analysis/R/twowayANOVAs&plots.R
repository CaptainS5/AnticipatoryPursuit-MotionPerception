library(ggplot2)
library(ez)
library(Hmisc)
library(reshape2)
library(psychReport)
library(lsr)
library(bayestestR)
library(BayesFactor)

#### clear environment
rm(list = ls())

#### load data
# on Inspiron 13
setwd("C:/Users/wuxiu/Documents/PhD@UBC/Lab/2ndYear/AnticipatoryPursuit/AnticipatoryPursuitMotionPerception/analysis/R")
source("pairwise.t.test.with.t.and.df.R")
plotFolder <- ("C:/Users/wuxiu/Documents/PhD@UBC/Lab/2ndYear/AnticipatoryPursuit/AnticipatoryPursuitMotionPerception/results/manuscript/figures/rawPlots/")
### modify these parameters to plot different conditions
# dataFileName <- "timeBinPSE_exp1.csv"
dataFileName <- "clpGain_exp1vs3.csv"
# pdfFileName <- "timeBinPSE_exp1.pdf"
pdfInteractionFileName <- "clpGain_exp1vs3_interaction.pdf"
# pdfFileNameD <- "slopeDiff_exp1vs3.pdf"
# for plotting
textSize <- 25
axisLineWidth <- 0.5
dotSize <- 3
# slope
ylimLow <- 10
ylimHigh <- 50
# PSE
ylimLow <- -0.15
ylimHigh <- 0.15
# ASP
ylimLow <- -1
ylimHigh <- 5
# # ASP gain
# ylimLow <- -0.1
# ylimHigh <- 0.4
# clp gain in context trials
ylimLow <- 0
ylimHigh <- 1

data <- read.csv(dataFileName)
subs <- unique(data$sub)
subN <- length(subs)
# dataD <- read.csv(dataDFileName)
# data <- data[data.exp==3]
# # exclude bad fitting...
# data <- subset(data[which(data$sub!=8),])

## compare two experiments
# PSE anova
sub <- data["sub"]
exp <- data["exp"]
# timeBin <- data["timeBin"]
prob <- data["prob"]
measure <- data["measure"]
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

# # compute Bayes Factor inclusion...
# bf <- anovaBF(measure ~ prob + timeBin + prob*timeBin + sub, data = dataAnova, 
#              whichRandom="sub")
# bayesfactor_inclusion(bf, match_models = TRUE)

# p <- ggplot(dataAnova, aes(x = prob, y = measure, color = exp)) +
#         stat_summary(aes(y = measure), fun.y = mean, geom = "point", shape = 95, size = 15) +
#         stat_summary(fun.data = 'mean_sdl',
#                fun.args = list(mult = 1.96/sqrt(subN)),
#                geom = 'errorbar', width = .1) +
# # geom = 'smooth', se = 'TRUE') +
#         # stat_summary(aes(y = measure), fun.data = mean_se, geom = "errorbar", width = 0.1) +
#         geom_point(aes(x = prob, y = measure), size = dotSize, shape = 1) +
#         # geom_segment(aes_all(c('x', 'y', 'xend', 'yend')), data = data.frame(x = c(50, 40), xend = c(90, 40), y = c(-0.1, -0.1), yend = c(-0.1, 0.15)), size = axisLineWidth) +
#         scale_y_continuous(name = "Anticipatory pursuit velocity (°/s)") + #, limits = c(-0.1, 0.55), expand = c(0, 0)) +
#         # scale_y_continuous(name = "PSE") + 
#         scale_x_discrete(name = "Probability of rightward motion", breaks=c("50", "90")) +
#         # scale_x_discrete(name = "Probability of rightward motion", breaks=c(50, 70, 90)) +
#         # scale_colour_discrete(name = "After reversal\ndirection", labels = c("CCW", "CW")) +
#         theme(axis.text=element_text(colour="black"),
#                       axis.ticks=element_line(colour="black", size = axisLineWidth),
#                       panel.grid.major = element_blank(),
#                       panel.grid.minor = element_blank(),
#                       panel.border = element_blank(),
#                       panel.background = element_blank(),
#                       text = element_text(size = textSize, colour = "black"),
#                       legend.background = element_rect(fill="transparent"),
#                       legend.key = element_rect(colour = "transparent", fill = "white"))
#         # facet_wrap(~exp)
# print(p)
# ggsave(paste(plotFolder, pdfFileName, sep = ""))

# ## t-test of the simple main effect of probability in the control experiment
# dataD <- dataAnova[dataAnova$exp==3,]
# # show(dataD)
# res <- pairwise.t.test.with.t.and.df(x = dataD$measure, g = dataD$prob, paired = TRUE, p.adj="none")
# show(res) # [[3]] = p value table, un adjusted
# res[[5]] # t-value
# res[[6]] # dfs
# res[[3]]
# p.adjust(res[[3]], method = "bonferroni", n = 4) 
# cohensd <- cohensD(subset(dataD, prob==50)$measure, subset(dataD, prob==90)$measure, method = 'paired')
# show(cohensd)

## interaction plot
dataPlot <- data.frame(sub, prob, exp, measure)
colnames(dataPlot)[4] <- "measure"
dataPlot$sub <- as.factor(dataPlot$sub)
# dataPlot$prob <- as.factor(dataPlot$prob)
# is.numeric(dataPlot$timeBin)
dataPlot$exp <- as.factor(dataPlot$exp)
# dataPlot <- aggregate(measure ~ exp+prob, data = dataPlot, FUN = "mean")
# show(dataPlot)

# # for time bin plots
# p <- ggplot(dataPlot, aes(x = timeBin, y = measure, color = prob)) +
#         stat_summary(fun.y = mean, geom = "point", shape = 95, size = 17.5) +
#         stat_summary(fun.y = mean, geom = "line", width = 1) +
#         stat_summary(fun.data = 'mean_sdl', fun.args = list(mult = 1.96/sqrt(subN)), geom = 'errorbar', width = 1.5, size = 1) +
#         scale_x_continuous(name = "time bin of trials", breaks=c(1, 2), limits = c(0.5, 2.5), expand = c(0, 0)) +
p <- ggplot(dataPlot, aes(x = prob, y = measure, color = exp)) +
        stat_summary(fun.y = mean, geom = "point", shape = 95, size = 17.5) +
        stat_summary(fun.y = mean, geom = "line", width = 1) +
        stat_summary(fun.data = 'mean_sdl', fun.args = list(mult = 1.96/sqrt(subN)), geom = 'errorbar', width = 1.5, size = 1) +
        stat_summary(aes(y = measure), fun.data = mean_se, geom = "errorbar", width = 0.1) +
        # geom_point(aes(x = prob, y = measure), size = dotSize, shape = 1) +
        geom_segment(aes_all(c('x', 'y', 'xend', 'yend')), data = data.frame(x = c(50, 45), y = c(ylimLow, ylimLow), xend = c(90, 45), yend = c(ylimLow, ylimHigh)), size = axisLineWidth, inherit.aes = FALSE) +
        # scale_y_continuous(name = "Anticipatory pursuit velocity (°/s)", breaks = seq(ylimLow, ylimHigh, 1), expand = c(0, 0)) +
        scale_y_continuous(name = "Steady-state pursuit gain", breaks = seq(ylimLow, ylimHigh, 1), expand = c(0, 0)) +
        # scale_y_continuous(name = "Anticipatory pursuit velocity gain", breaks = seq(ylimLow, ylimHigh, 0.1), expand = c(0, 0)) +
        coord_cartesian(ylim=c(ylimLow, ylimHigh)) +
        # scale_y_continuous(name = "PSE", limits = c(ylimLow, ylimHigh), breaks = c(ylimLow, 0, ylimHigh), expand = c(0, 0)) + 
        scale_x_continuous(name = "Probability of rightward motion", breaks=c(50, 90), limits = c(45, 95), expand = c(0, 0)) +
        # scale_x_discrete(name = "Probability of rightward motion", breaks=c("50", "90")) +
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
ggsave(paste(plotFolder, pdfInteractionFileName, sep = ""))

# ## t-test of the difference
# sub <- dataD["sub"]
# exp <- dataD["exp"]
# measure <- dataD["slopeDiff"]
# dataDtemp <- data.frame(sub, exp, measure)
# dataDtemp$sub <- as.factor(dataDtemp$sub)
# dataDtemp$exp <- as.factor(dataDtemp$exp)
# colnames(dataDtemp)[3] <- "measure"
# # dataDttest <- aggregate(measure ~ exp, data = dataDtemp, FUN = "mean")

# # res <- pairwise.t.test.with.t.and.df(x = dataDtemp$measure, g = dataDtemp$exp, paired = TRUE, p.adj="none")
# # show(res) # [[3]] = p value table, un adjusted
# # res[[5]] # t-value
# # res[[6]] # dfs
# # res[[3]]
# # p.adjust(res[[3]], method = "bonferroni", n = 3) 

# # # bias in PSE
# # ylimLow <- -0.05
# # ylimHigh <- 0.2
# # # bias in ASP
# # ylimLow <- 0
# # ylimHigh <- 3
# # bias in slope
# ylimLow <- -40
# ylimHigh <- 30

# p <- ggplot(dataDtemp, aes(x = exp, y = measure)) +
#         stat_summary(aes(y = measure), fun.y = mean, geom = "point", shape = 95, size = 15) +
#         stat_summary(fun.data = 'mean_sdl',
#                fun.args = list(mult = 1.96/sqrt(subN)),
#                geom = 'linerange', size = 1) +
#         geom_line(aes(x = exp, y = measure, group = sub), size = 0.5, linetype = "dashed") +
#         geom_point(aes(x = exp, y = measure), size = dotSize, shape = 1) +
#         geom_segment(aes_all(c('x', 'y', 'xend', 'yend')), data = data.frame(x = c(0), y = c(ylimLow), xend = c(0), yend = c(ylimHigh)), size = axisLineWidth) +
#         # scale_y_continuous(name = "Bias of PSE") + #, limits = c(0, 0.15), expand = c(0, 0.01)) +
#         scale_y_continuous(name = "Bias of slope") + #, limits = c(0, 0.15), expand = c(0, 0.01)) +
#         # scale_y_continuous(name = "Bias of anticipatory pursuit velocity(deg/s)") + #, limits = c(0, 0.15), expand = c(0, 0.01)) +
#         scale_x_discrete(name = "Experiment", limits = c("1", "3"), labels = c("1" = "Exp1", "3" = "Exp3")) +
#         # scale_x_discrete(name = "Experiment", limits = c("1", "2"), labels = c("1" = "Exp1", "2" = "Exp2")) +
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
# ggsave(paste(plotFolder, pdfFileNameD, sep = ""))