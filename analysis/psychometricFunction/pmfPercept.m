% to calculate and plot psychometric functions
% Xiuyun Wu, 12/19/2018
clear all; close all; clc
load('dataRaw_tW')

%% Sorting data 
data = dataRaw;
data(data.coh==1, :) = [];
for subN = 1:size(names, 2)
data.cohFit = data.coh.*data.rdkDir; % left is negative
data.cohIdx = zeros(size(data.cohFit));

cohLevels = unique([data.sub, data.prob, data.cohFit]);
for ii = 1:length(cohLevels)
    data.cohIdx(data.cohFit==cohLevels(ii)) = ii;
end

% trialN = 26*ones(size(dataRaw, 1));

%% fitting
% use logistic model
PF = @PAL_Logistic;  %Alternatives: PAL_Gumbel, PAL_Weibull,
                     %PAL_Quick, PAL_logQuick,
                     %PAL_CumulativeNormal, PAL_HyperbolicSecant

%Threshold and Slope are free parameters, guess and lapse rate are fixed
paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter
 
%Parameter grid defining parameter space through which to perform a
%brute-force search for values to be used as initial guesses in iterative
%parameter search.
searchGrid.alpha = 0.01:.001:.11;
searchGrid.beta = logspace(0,3,101);
searchGrid.gamma = 0.5;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0.02;  %ditto

%Perform fit
[paramsValues LL exitflag] = PAL_PFML_Fit(dataRaw.coh,NumPos, ...
    OutOfNum,searchGrid,paramsFree,PF);
end