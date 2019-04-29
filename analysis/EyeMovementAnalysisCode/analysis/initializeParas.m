% use eyeTrialData to do analysis, initialize parameters

clear all; close all; clc

names = {'XW0' 'p2' 'p4' 'p5'};
sampleRate = 1000;

analysisFolder = pwd;
cd ..
cd('pursuitPlots')
pursuitFolder = pwd;
cd ..
cd('saccadePlots')
saccadeFolder = pwd;
cd ..
cd('perceptPlots')
perceptFolder = pwd;
cd ..
cd('velocityTraces')
velTraceFolder = pwd;
cd(analysisFolder)
load(['eyeTrialData_all.mat']);

probCons = [10 30 50 70 90];
probNames{1} = {'10', '30', '50'};
probNames{2} = {'50', '70', '90'};

dirCons = [-1 1]; % -1=left, 1=right
dirNames = {'left' 'right'};

% for plotting
colorProb = [232 113 240; 15 204 255; 255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability