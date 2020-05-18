% bootstrapping for the psychometric curve fitting. use the sorted CSV file
% to keep the same with the ASP bootstrapping...
clear all; close all; clc

% load all CSVs...
samplingIdx = readmatrix('samplingIdx.csv');
aspSampleCons = readtable('aspBootstrapCons.csv'); % each row corresponds to the condition of one row in the value matrix
aspSampleValues = readmatrix('aspBootstrapValues.csv'); % each column is the mean asp of one simulation
dataAll = readtable('perceptualTrialsAllExps_AXP.csv');

% after fitting once
pseSampleValues = readmatrix('pseBootstrapValues.csv');
slopeSampleValues = readmatrix('slopeBootstrapValues.csv');

%% fitting psychometric curves
% % fitting settings
% PF = @PAL_Logistic;  %Alternatives: PAL_Gumbel, PAL_Weibull,
% %PAL_Quick, PAL_logQuick, PAL_Logistic
% %PAL_CumulativeNormal, PAL_HyperbolicSecant
% 
% %Threshold, Slope, and lapse rate are free parameters, guess is fixed
% paramsFree = [1 1 0 1];  %1: free parameter, 0: fixed parameter
% 
% %Parameter grid defining parameter space through which to perform a
% %brute-force search for values to be used as initial guesses in iterative
% %parameter search.
% searchGrid.alpha = -0.1:.01:.15;
% searchGrid.beta = 10:1:50;
% searchGrid.gamma = 0;  %scalar here (since fixed) but may be vector
% searchGrid.lambda = 0:0.01:0.05;  %ditto
% 
% pseSampleValues = NaN(size(aspSampleValues));
% slopeSampleValues = NaN(size(aspSampleValues));
% 
% % find the participants who did left conditions and need to be flipped
% 
% for conN = 1:size(aspSampleCons, 1)
%     idx = find(dataAll.exp==aspSampleCons.exp(conN, 1) & dataAll.sub==aspSampleCons.sub(conN, 1) & dataAll.prob==aspSampleCons.prob(conN, 1));
%     
%     t = cputime;
%     for sampleN = 1:size(samplingIdx, 1)
%         dataT = dataAll(samplingIdx(sampleN, idx), :);
%         cohLevels = unique(dataT.coh); % stimulus levels, negative is left
%         dataT.cohIdx = zeros(size(dataT.coh));
%         for ii = 1:length(cohLevels)
%             dataT.cohIdx(dataT.coh==cohLevels(ii), 1) = ii;
%         end
%         numRight{conN}(sampleN, :) = accumarray(dataT.cohIdx, dataT.choice, [], @sum); % choice 1=right, 0=left
%         outOfNum{conN}(sampleN, :) = accumarray(dataT.cohIdx, dataT.choice, [], @numel); % total trial numbers
%         
%         %Perform fit
%         [paramsValues{sampleN, conN} LL{sampleN, conN} exitflag{sampleN, conN}] = PAL_PFML_Fit(cohLevels, numRight{conN}(sampleN, :)', ...
%             outOfNum{conN}(sampleN, :)', searchGrid, paramsFree, PF);        
%         
%         pseSampleValues(conN, sampleN) = paramsValues{sampleN, conN}(1); % threshold, or PSE
%         slopeSampleValues(conN, sampleN) = paramsValues{sampleN, conN}(2); % slope
%         
%         display(['conN: ', num2str(conN)])
%         disp(['sampleN: ', num2str(sampleN)])
%         disp([num2str(cputime-t), ' s'])
%         save('perceptionBootstrapValues', 'pseSampleValues', 'slopeSampleValues')
%         t = cputime;
%     end
% end

%% stats for ASP, PSE, or slope
%     % flip the asp and pse values for left conditions
%     if aspSampleCons.flip==1
%         aspSampleValues(conN, :) = -aspSampleValues(conN, :);
%         pseSampleValues(conN, :) = -pseSampleValues(conN, :);
%     end