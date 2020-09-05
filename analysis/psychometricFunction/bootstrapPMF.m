% bootstrapping for the psychometric curve fitting. use the sorted CSV file
% to keep the same with the ASP bootstrapping...
% set a criterion for "valid" sampling
clear all; close all; clc

% % old procedure, generating samples in Python, then load all CSVs...
samplingIdx = readmatrix('samplingIdx.csv');

aspSampleValues = readmatrix('aspBootstrapValues.csv'); % each column is the mean asp of one simulation
% load('aspBootstrapValuesNew.mat');
dataAll = readtable('perceptualTrialsAllExps_AXP.csv');
% aspSampleCons = readtable('aspBootstrapCons.csv'); % each row corresponds to the condition of one row in the value matrix
% % first, figure out which conditions need to be flipped...
% flipConsIdx = find(aspSampleCons.prob==10);
% flipCons = aspSampleCons(flipConsIdx, 1:2);
% aspSampleCons.flip(:, 1) = 1;
% for ii = 1:size(flipCons, 1)
%     tempI = find(aspSampleCons.sub==flipCons.sub(ii, 1) & aspSampleCons.exp==flipCons.exp(ii, 1));
%     aspSampleCons.flip(tempI, 1) = -1;
% end
% save('aspSampleCons.mat', 'aspSampleCons')
load('aspSampleCons.mat') % need to multiply flip (1: not to be flipped, -1: flip)

% after fitting once
load('perceptionBootstrapValuesLapseLimited.mat')

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
% figure
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
%             outOfNum{conN}(sampleN, :)', searchGrid, paramsFree, PF, 'lapseLimits',[0 0.1]);    
% 
% % plotting
%         ProportionCorrectObserved=numRight{conN}(sampleN, :)./outOfNum{conN}(sampleN, :);
%         StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
%         ProportionCorrectModel = PF(paramsValues{sampleN, conN},StimLevelsFineGrain);
%         hold on
%         plot(StimLevelsFineGrain, ProportionCorrectModel,'-', 'linewidth', 2);
%         plot(cohLevels, ProportionCorrectObserved,'.', 'markersize', 30);
%         hold off
%         
%         pseSampleValues(conN, sampleN) = paramsValues{sampleN, conN}(1); % threshold, or PSE
%         slopeSampleValues(conN, sampleN) = paramsValues{sampleN, conN}(2); % slope
%         
%         display(['conN: ', num2str(conN)])
%         disp(['sampleN: ', num2str(sampleN)])
%         disp([num2str(cputime-t), ' s'])
%         save('perceptionBootstrapValuesLapseLimited', 'pseSampleValues', 'slopeSampleValues')
%         t = cputime;
%     end
% end

%% redo asp sampling...
% for conN = 1:size(aspSampleCons, 1)
%     idx = find(dataAll.exp==aspSampleCons.exp(conN, 1) & dataAll.sub==aspSampleCons.sub(conN, 1) & dataAll.prob==aspSampleCons.prob(conN, 1));
%     
%     for sampleN = 1:size(samplingIdx, 1)
%         dataT = dataAll(samplingIdx(sampleN, idx), :); 
%         aspSampleValues(conN, sampleN) = nanmean(dataT.aspVelX); 
%     end
% end
% save('aspBootstrapValuesNew', 'aspSampleValues')

%% stats for ASP, PSE, or slope
% flip first
tempI = find(aspSampleCons.flip==-1);

sampleCons = aspSampleCons;
sampleCons.prob(tempI, 1) = 100-sampleCons.prob(tempI, 1);
aspValues = aspSampleValues;
aspValues(tempI, :) = -aspValues(tempI, :);
pseValues = pseSampleValues;
pseValues(tempI, :) = -pseValues(tempI, :);
slopeValues = slopeSampleValues;

%% 
for expN = 1:3
    expIdx = find(sampleCons.exp==expN);
    subN = length(unique(sampleCons.sub(expIdx, :)));
    probCons = unique(sampleCons.prob(expIdx, :));
    for probN = 1:length(probCons)
        dataIdx = find(sampleCons.exp==expN & sampleCons.prob==probCons(probN));
        
        aspT = nanmean(aspValues(dataIdx, :));
        pseT = nanmean(pseValues(dataIdx, :));
        slopeT = nanmean(slopeValues(dataIdx, :));
        
        aspMean = mean(aspT);
        pseMean = mean(pseT);
        slopeMean = mean(slopeT);
        
        aspCI = 1.96/sqrt(subN)*std(aspT);
        pseCI = 1.96/sqrt(subN)*std(pseT);
        slopeCI = 1.96/sqrt(subN)*std(slopeT);
        
%         figure
%         histogram(aspT)
%         figure
%         histogram(pseT)
%         figure
%         histogram(slopeT)
%         pause
%         close all
        
        disp(['exp', num2str(expN), ', prob', num2str(probCons(probN)), ', asp mean=', num2str(aspMean)])
        disp(['exp', num2str(expN), ', prob', num2str(probCons(probN)), ', asp 95%CI=', num2str(aspCI)])
        disp(['exp', num2str(expN), ', prob', num2str(probCons(probN)), ', pse mean=', num2str(pseMean)])
        disp(['exp', num2str(expN), ', prob', num2str(probCons(probN)), ', pse 95CI=', num2str(pseCI)])
%         disp(['exp', num2str(expN), ', prob', num2str(probCons(probN)), ', slope mean=', num2str(slopeMean)])
%         disp(['exp', num2str(expN), ', prob', num2str(probCons(probN)), ', slope 95CI=', num2str(slopeCI)])
    end
end