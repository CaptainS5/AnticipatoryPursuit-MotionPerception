% fit oculometric curves of steady-state pursuit similar to psychometric curves 
initializeParas;
initializePSE;

% only uncomment the experiment you want to look at
% Exp1, 10 people, main experiment
expN = 1;
names = nameSets{1}; 
slidingWFolder = [slidingWFolder '\Exp1'];
eyeTrialData = expAll{1}.eyeTrialData;
RsaveFolder = [RFolder '\Exp1'];
probTotalN = 3;
colorProb = [8,48,107;66,146,198;198,219,239;66,146,198;8,48,107]/255; % all blue hues
probNames{1} = {'10', '30', '50'};
probNames{2} = {'50', '70', '90'};
probCons = [10 30 50 70 90];

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
        eyeTrialData.rdkDir(subN, :) = -eyeTrialData.rdkDir(subN, :);
        eyeTrialData.choice(subN, :) = 1-eyeTrialData.choice(subN, :); % flip left (0) and right (1)
        eyeTrialData.coh(subN, :) = -eyeTrialData.coh(subN, :);
        eyeTrialData.pursuit.APvelocityX(subN, :) = -eyeTrialData.pursuit.APvelocityX(subN, :);
        eyeTrialData.pursuit.APvelocityX_interpol(subN, :) = -eyeTrialData.pursuit.APvelocityX_interpol(subN, :);
    end
end

cohLevels = unique(eyeTrialData.coh(1, eyeTrialData.trialType(1, :)==0))';

%% do the fitting for each bin
for subN = 1:length(names)
    % find the idx of trials preceded by left/right choice
    leftChoiceTrialIdx = find(eyeTrialData.errorStatus(subN, 1:(end-1))==0 ...
        & eyeTrialData.prob(subN, 1:(end-1))==50 & eyeTrialData.choice(subN, 1:(end-1))==0);
    rightChoiceTrialIdx = find(eyeTrialData.errorStatus(subN, 1:(end-1))==0 ...
        & eyeTrialData.prob(subN, 1:(end-1))==50 & eyeTrialData.choice(subN, 1:(end-1))==1);
    
    tempI = find(eyeTrialData.trialType(subN, leftChoiceTrialIdx+1)==0 & eyeTrialData.errorStatus(subN, leftChoiceTrialIdx+1)==0 ...
        & eyeTrialData.prob(subN, leftChoiceTrialIdx+1)==50); 
    idxT{1} = leftChoiceTrialIdx(tempI)+1; % preceded by leftward trials
    tempI = find(eyeTrialData.trialType(subN, rightChoiceTrialIdx+1)==0 & eyeTrialData.errorStatus(subN, rightChoiceTrialIdx+1)==0 ...
        & eyeTrialData.prob(subN, rightChoiceTrialIdx+1)==50); 
    idxT{2} = rightChoiceTrialIdx(tempI)+1;% preceded by rightward trials
    
%     % calculate and draw individual psychometric curves
    figure
    hold on    
    for binN = 1:2
        % calculate the mean ASP
        dataASP{binN}(subN, 1) = nanmean(eyeTrialData.pursuit.APvelocityX(subN, idxT{binN}));
        
        % fit the psychometric curves for each bin
        data.cohFit = eyeTrialData.coh(subN, idxT{binN})';
        data.choice = eyeTrialData.choice(subN, idxT{binN})';
                
        % sort data to prepare for fitting--when there's no need to
        % calculate the weighted probabilities...
        data.cohIdx = zeros(size(data.cohFit));
        for cohN = 1:length(cohLevels)
            data.cohIdx(data.cohFit==cohLevels(cohN), 1) = cohN;
        end
        numRight{binN}(subN, :) = accumarray(data.cohIdx, data.choice, [], @sum); % choice 1=right, 0=left
        outOfNum{binN}(subN, :) = accumarray(data.cohIdx, data.choice, [], @numel); % total trial numbers
        
        %Perform fit
        [paramsValues{subN, binN} LL{subN, binN} exitflag{subN, binN}] = PAL_PFML_Fit(cohLevels, numRight{binN}(subN, :)', ...
            outOfNum{binN}(subN, :)', searchGrid, paramsFree, PF, 'lapseLimits',[0 0.1]);
        
        % plotting
        ProportionCorrectObserved=numRight{binN}(subN, :)./outOfNum{binN}(subN, :);
        StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
        ProportionCorrectModel = PF(paramsValues{subN, binN},StimLevelsFineGrain);
        if binN==1
            f{binN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-k', 'linewidth', 2);
            plot(cohLevels, ProportionCorrectObserved,'.k', 'markersize', 30);
        else
            f{binN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-b', 'linewidth', 2);
            plot(cohLevels, ProportionCorrectObserved,'.b', 'markersize', 30);
        end
        
        % saving parameters
        dataPercept.alpha{binN}(subN, 1) = paramsValues{subN, binN}(1); % threshold, or PSE
        dataPercept.beta{binN}(subN, 1) = paramsValues{subN, binN}(2); % slope
        dataPercept.gamma{binN}(subN, 1) = paramsValues{subN, binN}(3); % guess rate, or baseline
        dataPercept.lambda{binN}(subN, 1) = paramsValues{subN, binN}(4); % lapse rate
    end
    set(gca, 'fontsize', 16);
    set(gca, 'Xtick',cohLevels);
    axis([min(cohLevels) max(cohLevels) 0 1]);
    xlabel('Stimulus Intensity');
    ylabel('Proportion right');
    legend([f{:}], {'preceded by left', 'preceded by right'}, 'box', 'off', 'location', 'northwest')
%     
    cd(perceptFolder)
    saveas(gcf, ['pf_precededPerception_exp' num2str(expN) '_' names{subN} '.pdf'])
end
save(['dataPercept_precededPerception_exp' num2str(expN)], 'dataPercept');
save(['dataASP_precededPerception_exp' num2str(expN)], 'dataASP');

%% save csv for ANOVA
cd(RsaveFolder)
% perceptual data
data = table();
count = 1;
for subN = 1:length(names)
    for binN = 1:2
        data.sub(count, 1) = subN;
        data.prob(count, 1) = 50;
        data.precededPerception(count, 1) = binN-1; % 0=left, 1-right
        data.PSE(count, 1) = dataPercept.alpha{binN}(subN, 1);
        data.slope(count, 1) = dataPercept.beta{binN}(subN, 1);
        count = count+1;
    end
end
writetable(data, ['precededPerceptionPSE_exp' num2str(expN) '.csv'])

% asp data
data = table();
count = 1;
for subN = 1:length(names)
    for binN = 1:2
        data.sub(count, 1) = subN;
        data.prob(count, 1) = 50;
        data.precededPerception(count, 1) = binN-1; % 0=left, 1-right
        data.aspVelX(count, 1) = dataASP{binN}(subN, 1);
        count = count+1;
    end
end
writetable(data, ['precededPerceptionASP_exp' num2str(expN) '.csv'])