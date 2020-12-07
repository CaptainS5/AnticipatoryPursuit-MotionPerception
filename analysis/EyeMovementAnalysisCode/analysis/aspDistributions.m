% to examine the distribution of asp 
initializeParas;
yRange = [0 0.4];
xRange = [-3 5];

% % Exp1, 10 people, main experiment
% expN = 1;
% names = nameSets{1};
% eyeTrialData = expAll{1}.eyeTrialData;
% RsaveFolder = [RFolder '\Exp1'];
% pursuitFolder = [pursuitFolder, '\Exp1'];
% probTotalN = 3;
% colorProb = [8,48,107;66,146,198;198,219,239;66,146,198;8,48,107]/255; % all blue hues
% probNames{1} = {'50', '30', '10'};
% probNames{2} = {'50', '70', '90'};
% probCons = [10 30 50 70 90];

% Exp2, 8 people, fixation control
expN = 2;
names = names2;
eyeTrialData = expAll{2}.eyeTrialData;
RsaveFolder = [RFolder '\Exp2'];
probNames{1} = {'50', '10'};
probTotalN = 2;

% % Exp3, 9 people, low-coh context trials
% expN = 3;
% names = nameSets{3};
% eyeTrialData = expAll{3}.eyeTrialData;
% RsaveFolder = [RFolder '\Exp3'];
% probNames{1} = {'50', '10'};
% probTotalN = 2;

%% first plot the distribution of asp in each block for each participant
for subN = 5:5%size(names, 2)    
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        probNameI = 1;
        probSub = fliplr(probSub); % make it in the order of 50, 30, 10
        eyeTrialData.pursuit.APvelocityX(subN, :) = -eyeTrialData.pursuit.APvelocityX(subN, :); % flip the anticipatory pursuit direction
    else
        probNameI = 2;
    end
    
    figure
    hold on
    for probSubN = 1:length(probSub)
        idxP = find(eyeTrialData.trialType(subN, :)==0 ...
            & eyeTrialData.errorStatus(subN, :)==0 ...
            & eyeTrialData.prob(subN, :)==probSub(probSubN)); % perceptual trials
        % sort the asp values
        trialIdx{subN, probSubN} = idxP;
        aspAll{subN, probSubN} = eyeTrialData.pursuit.APvelocityX(subN, idxP);
        
        % plot the distributions
        p{subN, probSubN} = histogram(aspAll{subN, probSubN}, 'Normalization', 'probability', 'DisplayStyle', 'stairs', 'EdgeColor', colorProb(probSubN, :), 'lineWidth', 2);
        line([nanmean(aspAll{subN, probSubN}) nanmean(aspAll{subN, probSubN})], yRange, 'linestyle', '--', 'color', colorProb(probSubN, :), 'lineWidth', 2)
        %                 end
    end
    title(['exp', num2str(expN)])
    xlabel('Anticipatory pursuit velocity (°/s)')
    xlim(xRange)
    ylim(yRange)
    legend([p{subN, :}], probNames{probNameI})
    saveas(gcf, [pursuitFolder, '\aspDistribution_exp_', num2str(expN), '_', names{subN}, '.pdf'])
end