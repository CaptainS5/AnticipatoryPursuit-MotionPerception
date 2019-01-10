% to calculate and plot psychometric functions
% Xiuyun Wu, 12/19/2018
clear all; close all; clc

names = {'tW'};
trialN = 13; % number of trials for each coherence level in each direction

%% fitting data
for subN = 1:size(names, 2)
    load(['dataRaw_', names{subN}])
    data = dataRaw;
    data(data.coh==1, :) = [];
    
    data.cohFit = data.coh.*data.rdkDir; % left is negative
%     data.cohIdx = zeros(size(data.cohFit));    
%     cohLevels = unique([data.prob, data.cohFit], 'rows');
%     for ii = 1:length(cohLevels)
%         data.cohIdx(all([data.prob, data.cohFit]==repmat(cohLevels(ii, :), size(data, 1), 1), 2)) = ii;
%     end    
    
    probLevels = unique(data.prob);    
    %% fitting for each coherence level
    for probN = 1:length(probLevels)
        % sort data
        dataT = data(data.prob==probLevels(probN));
        cohLevels = unique(dataT.coh); % stimulus levels, negative is left
        
        outOfNum = trialN*ones(size(cohLevels)); % total trial numbers
        
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
        [paramsValues LL exitflag] = PAL_PFML_Fit(cohLevels, numRight, ...
            outOfNum, searchGrid,paramsFree,PF);
    end
end