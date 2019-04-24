% to calculate and plot psychometric functions
% Xiuyun Wu, 01/10/2018
clear all; close all; clc

names = {'XW0' 'p2' 'p4'};
trialN = 26; % number of trials for each coherence level in each direction
% just flip the leftward probability participants? maybe later...
% colorPlotting = [217 217 217; 189 189 189; 150 150 150; 99 99 99; 37 37 37]/255;
probCons = [10; 30; 50; 70; 90];
probNames{1} = {'Prob 10%' 'Prob 30%' 'Prob 50%'};
probNames{2} = {'Prob 50%' 'Prob 70%' 'Prob 90%'};
colorPlotting = [232 113 240; 15 204 255; 255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability

%% fitting data
for subN = 3:size(names, 2)
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
    
    probLevels = unique(data.prob);
    if probLevels(1)<50
        probB = 1;
    else
        probB = 2;
    end
    
    figure
    hold on    
    %% fitting for each coherence level
    for probN = 1:length(probLevels)
        probIdx = find(probCons==probLevels(probN));
        % sort data
        dataT = data(data.prob==probLevels(probN, :), :);
        cohLevels = unique(dataT.cohFit); % stimulus levels, negative is left
        dataT.cohIdx = zeros(size(dataT.cohFit));
        for ii = 1:length(cohLevels)
            dataT.cohIdx(dataT.cohFit==cohLevels(ii), 1) = ii;
        end
        numRight = accumarray(dataT.cohIdx, dataT.choice, [], @sum); % choice 1=right, 0=left
        outOfNum = trialN*ones(size(cohLevels)); % total trial numbers
        
        PF = @PAL_Logistic;  %Alternatives: PAL_Gumbel, PAL_Weibull,
        %PAL_Quick, PAL_logQuick, PAL_Logistic
        %PAL_CumulativeNormal, PAL_HyperbolicSecant
        
        %Threshold and Slope are free parameters, guess and lapse rate are fixed
        paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter
        
        %Parameter grid defining parameter space through which to perform a
        %brute-force search for values to be used as initial guesses in iterative
        %parameter search.
        searchGrid.alpha = 0.01:.001:.11;
        searchGrid.beta = logspace(0,3,101);
        searchGrid.gamma = 0;  %scalar here (since fixed) but may be vector
        searchGrid.lambda = 0.02;  %ditto
        
        %Perform fit
        [paramsValues{subN, probN} LL{subN, probN} exitflag{subN, probN}] = PAL_PFML_Fit(cohLevels, numRight, ...
            outOfNum, searchGrid, paramsFree, PF);
        
        % plotting
        ProportionCorrectObserved=numRight./outOfNum;
        StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
        ProportionCorrectModel = PF(paramsValues{subN, probN},StimLevelsFineGrain);
        
        f{probN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', colorPlotting(probIdx, :), 'linewidth', 2);
        plot(cohLevels, ProportionCorrectObserved,'.', 'color', colorPlotting(probIdx, :), 'markersize', 30);
    end
    set(gca, 'fontsize',16);
    set(gca, 'Xtick',cohLevels);
    axis([min(cohLevels) max(cohLevels) 0 1]);
    xlabel('Stimulus Intensity');
    ylabel('Proportion right');
    hold off
    legend([f{:}], probNames{probB}, 'box', 'off', 'location', 'northwest')
    
    saveas(gcf, ['pf_', names{subN}, '.pdf'])
end