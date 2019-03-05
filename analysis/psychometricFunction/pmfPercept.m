% to calculate and plot psychometric functions
% Xiuyun Wu, 01/10/2018
clear all; close all; clc

<<<<<<< HEAD
names = {'YZ'};
=======
names = {'t2'};
>>>>>>> parent of 02672d1... improve saccade...
trialN = 26; % number of trials for each coherence level in each direction
colorPlotting = [255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability

%% fitting data
for subN = 1:size(names, 2)
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
    
    figure
    hold on
    
    %% fitting for each coherence level
    for probN = 1:length(probLevels)
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
        
        f{probN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', colorPlotting(probN, :), 'linewidth', 2);
        plot(cohLevels, ProportionCorrectObserved,'.', 'color', colorPlotting(probN, :), 'markersize', 30);
    end
    set(gca, 'fontsize',16);
    set(gca, 'Xtick',cohLevels);
    axis([min(cohLevels) max(cohLevels) 0 1]);
    xlabel('Stimulus Intensity');
    ylabel('Proportion right');
    hold off
    legend([f{:}], {'Prob 50%' 'Prob 70%' 'Prob 90%'}, 'box', 'off', 'location', 'northwest')
    
    saveas(gcf, ['pf_', names{subN}, '.pdf'])
end