% use eyeTrialData to do analysis, initialize parameters

clear all; close all; clc

nameSets{1} = {'XW0' 'p2' 'p4' 'p5' 'p6' 'p8' 'p9' 'p10' 'p14' '015'}; % experiment 1
% nameSets{2} = {'p3' 'p7' 'p12'};% 'p15'};
% nameSets{1} = {'tXW' 'tDC' 'p7' 'p3' 'p9' 'p8' 'p6' 'p4' 'p5'};
setN = 1; % choose which set to analyze
names = nameSets{setN};

sampleRate = 1000;

analysisFolder = pwd;
cd ..
cd ..
cd('pursuitPlots\Exp1')
pursuitFolder = pwd;
cd ..
cd ..
cd('saccadePlots\Exp1')
saccadeFolder = pwd;
cd ..
cd ..
cd('perceptPlots\Exp1')
perceptFolder = pwd;
cd ..
cd ..
cd('velocityTraces\Exp1')
velTraceFolder = pwd;
cd ..
cd ..
cd('correlationPlots\Exp1')
correlationFolder = pwd;
cd ..
cd ..
cd('mausAnalysis')
mausFolder = pwd;
cd ..
cd('slidingWindows\Exp1')
slidingWFolder = pwd;
cd(analysisFolder)
load(['eyeTrialData_all_set' num2str(setN) '_exp1.mat']);

% for Exp1
probCons = [10 30 50 70 90];
probNames{1} = {'10', '30', '50'};
probNames{2} = {'50', '70', '90'};

dirCons = [-1 1]; % -1=left, 1=right
dirNames = {'left' 'right'};

% for plotting
colorProb = [8,48,107;66,146,198;198,219,239;66,146,198;8,48,107]/255; % all blue hues
% colorProb = [232 113 240; 15 204 255; 255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability