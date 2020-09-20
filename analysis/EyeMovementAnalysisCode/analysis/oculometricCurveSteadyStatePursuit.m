% fit oculometric curves of steady-state pursuit similar to psychometric curves 
initializeParas;
initializePSE;

% only uncomment the experiment you want to look at
% Exp1, 10 people, main experiment
expN = 1;
names = nameSets{1}; 
pursuitFolder = [pursuitFolder '\Exp1'];
eyeTrialData = expAll{1}.eyeTrialData;
RsaveFolder = [RFolder '\Exp1'];
probTotalN = 3;
colorProb = [198,219,239;66,146,198;8,48,107]/255; % all blue hues
% probNames{1} = {'10', '30', '50'};
probNames = {'50', '70', '90'};
probCons = [50 70 90];

% % Exp2, 8 people, fixation control
% expN = 2;
% names = names2; 
% slidingWFolder = [slidingWFolder '\Exp2'];
% eyeTrialData = expAll{2}.eyeTrialData;
% RsaveFolder = [RFolder '\Exp2'];
% probTotalN = 2;

% % Exp3, 9 people, low-coh context trials
% expN = 3;
% names = nameSets{3}; 
% slidingWFolder = [slidingWFolder '\Exp3'];
% eyeTrialData = expAll{3}.eyeTrialData;
% RsaveFolder = [RFolder '\Exp3'];
% probTotalN = 2;

% flip every direction... to collapse left and right probability
% blocks
for subN = 1:length(names)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        eyeTrialData.prob(subN, :) = 100-eyeTrialData.prob(subN, :);
        eyeTrialData.rdkDir(subN, :) = -eyeTrialData.rdkDir(subN, :);
        eyeTrialData.choice(subN, :) = 1-eyeTrialData.choice(subN, :); % flip left (0) and right (1)
        eyeTrialData.coh(subN, :) = -eyeTrialData.coh(subN, :);
        eyeTrialData.pursuit.closedLoopMeanVelX(subN, :) = -eyeTrialData.pursuit.closedLoopMeanVelX(subN, :);
    end
    
    % binarize steady-state pursuit velocity
    eyeTrialData.pursuit.closedLoopDir(subN, eyeTrialData.pursuit.closedLoopMeanVelX(subN, :)>0) = 1; % right
    eyeTrialData.pursuit.closedLoopDir(subN, eyeTrialData.pursuit.closedLoopMeanVelX(subN, :)<0) = 0; % left
end

cohLevels = unique(eyeTrialData.coh(1, eyeTrialData.trialType(1, :)==0))';

%% do the fitting for each bin
for subN = 1:length(names)
    figure
    hold on
    %% fitting for each coherence level
    for probN = 1:probTotalN
        dataT = table();
        idx = find(eyeTrialData.errorStatus(subN, :)==0 ...
        & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0);
        % sort data
        dataT.cohFit = eyeTrialData.coh(subN, idx)';
        dataT.eyeChoice = eyeTrialData.pursuit.closedLoopDir(subN, idx)';
        dataT.cohIdx = zeros(size(dataT.cohFit));
        for ii = 1:length(cohLevels)
            dataT.cohIdx(dataT.cohFit==cohLevels(ii), 1) = ii;
        end
        numRight{probN}(subN, :) = accumarray(dataT.cohIdx, dataT.eyeChoice, [], @sum); % choice 1=right, 0=left
        outOfNum{probN}(subN, :) = accumarray(dataT.cohIdx, dataT.eyeChoice, [], @numel); % total trial numbers
        
        %Perform fit
        [paramsValues{subN, probN} LL{subN, probN} exitflag{subN, probN}] = PAL_PFML_Fit(cohLevels, numRight{probN}(subN, :)', ...
            outOfNum{probN}(subN, :)', searchGrid, paramsFree, PF, 'lapseLimits',[0 0.1]);
        
        % plotting
        ProportionCorrectObserved=numRight{probN}(subN, :)./outOfNum{probN}(subN, :);
        StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
        ProportionCorrectModel = PF(paramsValues{subN, probN},StimLevelsFineGrain);
        
        f{probN} = plot(StimLevelsFineGrain, ProportionCorrectModel, '-', 'color', colorProb(probN, :), 'linewidth', 2);
        plot(cohLevels, ProportionCorrectObserved,'.', 'color', colorProb(probN, :), 'markersize', 30);
        
        % saving parameters
        dataFit.alpha(subN, probN) = paramsValues{subN, probN}(1); % threshold, or PSE
        dataFit.beta(subN, probN) = paramsValues{subN, probN}(2); % slope
        dataFit.gamma(subN, probN) = paramsValues{subN, probN}(3); % guess rate, or baseline
        dataFit.lambda(subN, probN) = paramsValues{subN, probN}(4); % lapse rate
    end
    set(gca, 'fontsize',16);
    set(gca, 'Xtick',cohLevels);
    axis([min(cohLevels) max(cohLevels) 0 1]);
    xlabel('Stimulus Intensity');
    ylabel('Proportion right (eye)');
    legend([f{:}], probNames, 'box', 'off', 'location', 'northwest')
    
    cd(pursuitFolder)
%     saveas(gcf, ['oculometricFunction_exp', num2str(expN), '_', names{subN}, '.pdf'])
end
cd(analysisFolder)
save(['oculometricFunction_exp' num2str(expN)], 'dataFit');

%% save csv for ANOVA
cd(RsaveFolder)
% perceptual data
data = table();
count = 1;
for subN = 1:length(names)
    for probN = 1:probTotalN
        data.sub(count, 1) = subN;
        data.prob(count, 1) = probCons(probN);
        data.OSE(count, 1) = dataFit.alpha(subN, probN);
        data.slope(count, 1) = dataFit.beta(subN, probN);
        count = count+1;
    end
end
writetable(data, ['OSE_exp' num2str(expN) '.csv'])