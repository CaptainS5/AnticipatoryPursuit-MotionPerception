% to calculate and plot psychometric functions
% Xiuyun Wu, 04/28/2018
clear all; close all; clc

names = {'XW0' 'p2' 'p4' 'p5' 'p6' 'p8' 'p9' 'p10' 'p14' 'p15'};
averagedPlot = 0;
trialN = 26; % number of trials for each coherence level in each direction
% just flip the leftward probability participants? maybe later...
% colorPlotting = [217 217 217; 189 189 189; 150 150 150; 99 99 99; 37 37 37]/255;
probCons = [10; 30; 50; 70; 90];
probNames{1} = {'Prob 10%' 'Prob 30%' 'Prob 50%'};
probNames{2} = {'Prob 50%' 'Prob 70%' 'Prob 90%'};
colorPlotting = [232 113 240; 15 204 255; 255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability

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
for subN = 9:9%size(names, 2)
    load(['dataRaw_', names{subN}])
    data = dataRaw;
    data(data.coh==1, :) = [];
    data(data.choice==999, :) = []; % only for the initial pilot...
    
    data.cohFit = data.coh.*data.rdkDir; % left is negative
    %     data.cohIdx = zeros(size(data.cohFit));
    %     cohLevels = unique([data.prob, data.cohFit], 'rows');
    %     for ii = 1:length(cohLevels)
    %         data.cohIdx(all([data.prob, data.cohFit]==repmat(cohLevels(ii, :), size(data, 1), 1), 2)) = ii;
    %     end
    
    probSub = unique(data.prob);
    if probSub(1)<50
        probB = 1;
    else
        probB = 2;
    end
    dataPercept.probSub(subN, 1:length(probSub)) = probSub;
    
    figure
    hold on
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
        outOfNum{probN}(subN, :) = trialN*ones(size(cohLevels)); % total trial numbers
        
        %Perform fit
        [paramsValues{subN, probSubN} LL{subN, probSubN} exitflag{subN, probSubN}] = PAL_PFML_Fit(cohLevels, numRight{probN}(subN, :)', ...
            outOfNum{probN}(subN, :)', searchGrid, paramsFree, PF);
        
        % plotting
        ProportionCorrectObserved=numRight{probN}(subN, :)./outOfNum{probN}(subN, :);
        StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
        ProportionCorrectModel = PF(paramsValues{subN, probSubN},StimLevelsFineGrain);
        
        f{probSubN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', colorPlotting(probN, :), 'linewidth', 2);
        plot(cohLevels, ProportionCorrectObserved,'.', 'color', colorPlotting(probN, :), 'markersize', 30);
        
        % saving parameters
        if probSub(1)<50
            probNmerged = 4-probN;
            paramsValues{subN, probSubN}(1) = -paramsValues{subN, probSubN}(1); % also flip PSE
        else
            probNmerged = probN-2;
        end
        dataPercept.alpha(subN, probNmerged) = paramsValues{subN, probSubN}(1); % threshold, or PSE
        dataPercept.beta(subN, probNmerged) = paramsValues{subN, probSubN}(2); % slope
        dataPercept.gamma(subN, probNmerged) = paramsValues{subN, probSubN}(3); % guess rate, or baseline
        dataPercept.lambda(subN, probNmerged) = paramsValues{subN, probSubN}(4); % lapse rate
    end
    set(gca, 'fontsize',16);
    set(gca, 'Xtick',cohLevels);
    axis([min(cohLevels) max(cohLevels) 0 1]);
    xlabel('Stimulus Intensity');
    ylabel('Proportion right');
    legend([f{:}], probNames{probB}, 'box', 'off', 'location', 'northwest')
    
    saveas(gcf, ['pf_', names{subN}, '.pdf'])
end

%% draw averaged PSE plot
if averagedPlot==1
    % plot averaged pf
    figure
    hold on
    for probNmerged = 1:size(dataPercept.alpha, 2) % merged left&right probabilities
        % average PSE
        dataPercept.PSEmean(1, probNmerged) = mean(dataPercept.alpha(:, probNmerged));
        dataPercept.PSEste(1, probNmerged) = std(dataPercept.alpha(:, probNmerged))/sqrt(size(dataPercept.alpha, 1));
        
        % merge directions
        for subN = 1:size(dataPercept.alpha, 1)
            if dataPercept.probSub(subN, 1)<50
                tempNumRight(subN, :) = outOfNum{4-probNmerged}(subN, :)-numRight{4-probNmerged}(subN, :);
                tempNumRight(subN, :) = fliplr(tempNumRight(subN, :));
                tempOutOfNumber(subN, :) = outOfNum{4-probNmerged}(subN, :);
            else
                tempNumRight(subN, :) = numRight{probNmerged+2}(subN, :);
                tempOutOfNumber(subN, :) = outOfNum{probNmerged+2}(subN, :);
            end
        end
        numRightAll{probNmerged} = mean(tempNumRight);
        outOfNumAll{probNmerged} = mean(tempOutOfNumber);
        
        % fitting averaged psychometric function
        [paramsValuesAll{probNmerged} LLAll{probNmerged} exitflagAll{probNmerged}] = PAL_PFML_Fit(cohLevels, numRightAll{probNmerged}', ...
            outOfNumAll{probNmerged}', searchGrid, paramsFree, PF);
        dataPercept.alpha_all(probNmerged) = paramsValuesAll{probNmerged}(1);
        dataPercept.beta_all(probNmerged) = paramsValuesAll{probNmerged}(2);
        dataPercept.gamma_all(probNmerged) = paramsValuesAll{probNmerged}(3);
        dataPercept.lambda_all(probNmerged) = paramsValuesAll{probNmerged}(4);
        
        % plotting
        ProportionCorrectObserved=numRightAll{probNmerged}./outOfNumAll{probNmerged};
        StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
        ProportionCorrectModel = PF(paramsValuesAll{probNmerged},StimLevelsFineGrain);
        
        fAll{probNmerged} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', colorPlotting(probNmerged+2, :), 'linewidth', 2);
        plot(cohLevels, ProportionCorrectObserved,'.', 'color', colorPlotting(probNmerged+2, :), 'markersize', 30);
    end
    set(gca, 'fontsize',16);
    set(gca, 'Xtick',cohLevels);
    axis([min(cohLevels) max(cohLevels) 0 1]);
    xlabel('Stimulus Intensity');
    ylabel('Proportion right');
    legend([fAll{:}], probNames{2}, 'box', 'off', 'location', 'northwest')
    hold off
    saveas(gcf, ['pf_all.pdf'])
    
    % plot average PSE
    errorbar_groups(dataPercept.PSEmean, dataPercept.PSEste,  ...
        'bar_width',0.75,'errorbar_width',0.5, ...
        'bar_names',{'50','70','90'})
    xlabel('Probability of right');
    ylabel('PSE (right is positive)');
    saveas(gcf, ['PSE_all.pdf'])
    
    save('dataPercept_all', 'dataPercept');
end