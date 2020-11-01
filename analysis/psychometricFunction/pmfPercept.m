% to calculate and plot psychometric functions
% Xiuyun Wu, 04/28/2018
clear all; close all; clc

perceptFolder = pwd;
cd ..
cd('EyeMovementAnalysisCode\analysis')
% only uncomment the experiment you want to look at
% Exp1, 10 people, main experiment
expN = 1;
names = {'XW0' 'p2' 'p4' 'p5' 'p6' 'p8' 'p9' 'p10' 'p14' '015'};
load(['eyeTrialData_all_exp1.mat'])
probTotalN = 3;
colorProb = [8,48,107;66,146,198;198,219,239;66,146,198;8,48,107]/255; % all blue hues
probNames{1} = {'10', '30', '50'};
probNames{2} = {'50', '70', '90'};
probCons = [10 30 50 70 90];

% % Exp2, 8 people, fixation control
% expN = 2;
% names = {'tFW' 'fh2' 'fh5' 'fh6' 'fh8' 'fh9' 'fht' 'p15'};
% load(['eyeTrialData_all_exp2.mat'])
% probTotalN = 2;
% probCons = [10 50 90];
% probNames{1} = {'10', '50'};
% probNames{2} = {'50', '90'};
% colorProb = [8,48,107;198,219,239;8,48,107]/255; % all blue hues

% % Exp3, 9 people, low-coh context trials
% expN = 3;
% names = {'tXW' 'tDC' 'p7' 'p3' 'p9' 'p8' 'p6' 'p4' 'p5'};
% load(['eyeTrialData_all_exp3.mat'])
% probTotalN = 2;
% probCons = [10 50 90];
% probNames{1} = {'10', '50'};
% probNames{2} = {'50', '90'};
% colorProb = [8,48,107;198,219,239;8,48,107]/255; % all blue hues

averagedPlot = 1;
% fitting settings
PF = @PAL_Logistic;  %Alternatives: PAL_Gumbel, PAL_Weibull,
%PAL_Quick, PAL_logQuick, PAL_Logistic
%PAL_CumulativeNormal, PAL_HyperbolicSecant

%Threshold, Slope, and lapse rate are free parameters, guess is fixed
paramsFree = [1 1 0 1];  %1: free parameter, 0: fixed parameter

%Parameter grid defining parameter space through which to perform a
%brute-force search for values to be used as initial guesses in iterative
%parameter search.
searchGrid.alpha = 0.01:.001:.11;
searchGrid.beta = logspace(0,3,101);
searchGrid.gamma = 0;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0:0.001:0.05;  %ditto

%% fitting data
dataPercept.probSub = NaN(size(names, 2), 3);
% try
%     cd ..
%     cd('EyeMovementAnalysisCode\analysis\')
%     load('eyeTrialData_all_exp2.mat')
%     loadRaw = 0;
%     cd(perceptFolder)
% catch
%     loadRaw = 1;
%     cd(perceptFolder)
%     cd('Exp2')
% end

for subN = 1:size(names, 2)
%     if loadRaw==1
%         load(['dataRaw_', names{subN}])
%         data = dataRaw;
%         data(data.coh==1, :) = [];
%         data(data.choice==999, :) = []; % only for the initial pilot...
%         data.cohFit = data.coh.*data.rdkDir; % left is negative
%     else
        data = table();
        idx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0);
        data.choice = eyeTrialData.choice(subN, idx)';
        data.cohFit = eyeTrialData.coh(subN, idx)';
        data.prob = eyeTrialData.prob(subN, idx)';
%     end
    
    probSub = unique(data.prob);
    if probSub(1)<50
        probB = 1;
        % to merge conditions, flip...
        data.choice = 1-data.choice;
        data.cohFit = -data.cohFit;
    else
        probB = 2;
    end
    dataPercept.probSub(subN, 1:length(probSub)) = probSub;
%     
%     figure
%     hold on
    %% fitting for each coherence level
    for probSubN = 1:length(probSub)
        probN = find(probCons==probSub(probSubN));
        % sort data
        dataT = data(data.prob==probSub(probSubN, :), :);
        cohLevels = unique(dataT.cohFit); % stimulus levels, negative is left
        dataT.cohIdx = zeros(size(dataT.cohFit));
        for ii = 1:length(cohLevels)
            dataT.cohIdx(dataT.cohFit==cohLevels(ii), 1) = ii;
        end
        numRight{probN}(subN, :) = accumarray(dataT.cohIdx, dataT.choice, [], @sum); % choice 1=right, 0=left
        outOfNum{probN}(subN, :) = accumarray(dataT.cohIdx, dataT.choice, [], @numel); % total trial numbers
        
        %Perform fit
        [paramsValues{subN, probSubN} LL{subN, probSubN} exitflag{subN, probSubN}] = PAL_PFML_Fit(cohLevels, numRight{probN}(subN, :)', ...
            outOfNum{probN}(subN, :)', searchGrid, paramsFree, PF, 'lapseLimits',[0 0.1]);
        
%         % plotting
%         ProportionCorrectObserved=numRight{probN}(subN, :)./outOfNum{probN}(subN, :);
%         StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
%         ProportionCorrectModel = PF(paramsValues{subN, probSubN},StimLevelsFineGrain);
%         
%         f{probSubN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', colorProb(probN, :), 'linewidth', 2);
%         plot(cohLevels, ProportionCorrectObserved,'.', 'color', colorProb(probN, :), 'markersize', 30);
        
        % saving parameters
        if probSub(1)<50
            probNmerged = probTotalN+1-probN;
%             paramsValues{subN, probSubN}(1) = -paramsValues{subN, probSubN}(1); % also flip PSE
        else
            probNmerged = probN-(probTotalN-1);
        end
        dataPercept.alpha(subN, probNmerged) = paramsValues{subN, probSubN}(1); % threshold, or PSE
        dataPercept.beta(subN, probNmerged) = paramsValues{subN, probSubN}(2); % slope
        dataPercept.gamma(subN, probNmerged) = paramsValues{subN, probSubN}(3); % guess rate, or baseline
        dataPercept.lambda(subN, probNmerged) = paramsValues{subN, probSubN}(4); % lapse rate
    end
%     set(gca, 'fontsize',16);
%     set(gca, 'Xtick',cohLevels);
%     axis([min(cohLevels) max(cohLevels) 0 1]);
%     xlabel('Stimulus Intensity');
%     ylabel('Proportion right');
%     legend([f{:}], probNames{probB}, 'box', 'off', 'location', 'northwest')
    
%     saveas(gcf, ['pf_', names{subN}, '.pdf'])
end

%% draw averaged PSE plot
if averagedPlot==1
    cd(perceptFolder)
    % plot averaged pf
%     figure
%     hold on
    for probNmerged = 1:size(dataPercept.alpha, 2) % merged left&right probabilities
        % average PSE
        dataPercept.PSEmean(1, probNmerged) = mean(dataPercept.alpha(:, probNmerged));
        dataPercept.PSEste(1, probNmerged) = std(dataPercept.alpha(:, probNmerged))/sqrt(size(dataPercept.alpha, 1));
        
        % average slope
        dataPercept.Bmean(1, probNmerged) = mean(dataPercept.beta(:, probNmerged));
        dataPercept.Bste(1, probNmerged) = std(dataPercept.beta(:, probNmerged))/sqrt(size(dataPercept.beta, 1));
        
        % merge directions
        for subN = 1:size(dataPercept.alpha, 1)
            if dataPercept.probSub(subN, 1)<50
                tempNumRight(subN, :) = outOfNum{probTotalN+1-probNmerged}(subN, :)-numRight{probTotalN+1-probNmerged}(subN, :);
                tempNumRight(subN, :) = fliplr(tempNumRight(subN, :));
                tempOutOfNumber(subN, :) = outOfNum{probTotalN+1-probNmerged}(subN, :);
            else
                tempNumRight(subN, :) = numRight{probNmerged+probTotalN-1}(subN, :);
                tempOutOfNumber(subN, :) = outOfNum{probNmerged+probTotalN-1}(subN, :);
            end
        end
        numRightAll{probNmerged} = mean(tempNumRight);
        outOfNumAll{probNmerged} = mean(tempOutOfNumber);
        
        % fitting averaged psychometric function
        [paramsValuesAll{probNmerged} LLAll{probNmerged} exitflagAll{probNmerged}] = PAL_PFML_Fit(cohLevels, numRightAll{probNmerged}', ...
            outOfNumAll{probNmerged}', searchGrid, paramsFree, PF, 'lapseLimits',[0 0.1]);
        dataPercept.alpha_all(probNmerged) = paramsValuesAll{probNmerged}(1);
        dataPercept.beta_all(probNmerged) = paramsValuesAll{probNmerged}(2);
        dataPercept.gamma_all(probNmerged) = paramsValuesAll{probNmerged}(3);
        dataPercept.lambda_all(probNmerged) = paramsValuesAll{probNmerged}(4);
        
%         % plotting
%         ProportionCorrectObserved=numRightAll{probNmerged}./outOfNumAll{probNmerged};
%         StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
%         ProportionCorrectModel = PF(paramsValuesAll{probNmerged},StimLevelsFineGrain);
%         
%         fAll{probNmerged} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', colorProb(probNmerged+1, :), 'linewidth', 2);
%         plot(cohLevels, ProportionCorrectObserved,'.', 'color', colorProb(probNmerged+1, :), 'markersize', 30);
    end
%     plot([dataPercept.PSEmean(1) dataPercept.PSEmean(1)], [0 1], '--')
%     plot([dataPercept.PSEmean(2) dataPercept.PSEmean(2)], [0 1], '--')
%     set(gca, 'fontsize',16);
%     set(gca, 'Xtick',cohLevels);
%     axis([min(cohLevels) max(cohLevels) 0 1]);
%     xlabel('Stimulus Intensity');
%     ylabel('Proportion right');
%     legend([fAll{:}], probNames{2}, 'box', 'off', 'location', 'northwest')
%     hold off
%     saveas(gcf, ['pf_all_exp2.pdf'])
    
%     % plot average PSE
%     errorbar_groups(dataPercept.PSEmean, dataPercept.PSEste,  ...
%         'bar_width',0.75,'errorbar_width',0.5, ...
%         'bar_names',{'50', '90'});
%     xlabel('Probability of right');
%     ylabel('PSE (right is positive)');
%     saveas(gcf, ['PSE_all.pdf'])
%     
    save(['dataPercept_all_exp' num2str(expN)], 'dataPercept');
%     
%     % plot average slope
%     errorbar_groups(dataPercept.Bmean, dataPercept.Bste,  ...
%         'bar_width',0.75,'errorbar_width',0.5, ...
%         'bar_names',{'50', '90'});
%     xlabel('Probability of right');
%     ylabel('Slope (beta)');
%     saveas(gcf, ['Slope_all.pdf'])    
end

%% save csv for ANOVA
% cd(perceptFolder)
% cd ..
% cd(['R\Exp' num2str(expN)])
% 
% data = table();
% count = 1;
% for subN = 1:length(names)
%     for probNmerged = 1:probTotalN
%         data.sub(count, 1) = subN;
%         data.prob(count, 1) = probCons(probNmerged+(probTotalN-1));
%         data.PSE(count, 1) = dataPercept.alpha(subN, probNmerged);
%         data.slope(count, 1) = dataPercept.beta(subN, probNmerged);
%         count = count+1;
%     end
% end
% writetable(data, ['dataPercept_Exp' num2str(expN) '.csv'])