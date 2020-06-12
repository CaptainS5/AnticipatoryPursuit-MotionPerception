% do sliding correlations to see the effect of trial history length
% Pearson correlation for AP and logistic correlation for perception

initializeParas;
wMax = 50; % largest window size, how many trials before
% pdfNames = {'visualMotionCor' 'visualMotionWeightedCor' 'perceivedMotionCor'};
% pdfNames = {'visualMotionCor_AP' 'perceivedMotionCor_AP'};
pdfNames = {'visualMotionCor_APinterpol' 'perceivedMotionCor_APinterpol'};

% recode the direction and perceptual choices
idxT = find(eyeTrialData.rdkDir==0); % 0 coherence coded as 0.5
eyeTrialData.rdkDir(idxT) = 0.5;
idxT = find(eyeTrialData.rdkDir==-1); % left coded as 0
eyeTrialData.rdkDir(idxT) = 0;

% correct for mistakenly pressing the wrong key in standard trials
idxT = find(eyeTrialData.trialType==1); % standard trials, same perceptual choice as visual
eyeTrialData.choice(idxT) = eyeTrialData.rdkDir(idxT);

% also flip every direction... to collapse left and right probability
% blocks
for subN = 1:length(names)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        eyeTrialData.rdkDir(subN, :) = 1-eyeTrialData.rdkDir(subN, :);
        eyeTrialData.choice(subN, :) = 1-eyeTrialData.choice(subN, :); % flip left (0) and right (1)
        eyeTrialData.coh(subN, :) = -eyeTrialData.coh(subN, :);
        eyeTrialData.pursuit.APvelocityX(subN, :) = -eyeTrialData.pursuit.APvelocityX(subN, :);
        eyeTrialData.pursuit.APvelocityX_interpol(subN, :) = -eyeTrialData.pursuit.APvelocityX_interpol(subN, :);
    end
end

%% loop through different windows, how many trials before the current trial
for windowSize = 1:wMax
    if windowSize==1
        % initialize correlation value matrices; 3 types of previous motion...
        % see below
        for ii = 1:2
%             rPercept{ii} = nan(length(names), wMax);
%             pPercept{ii} =nan(length(names), wMax);
            rAP{ii} = nan(length(names), wMax);
            pAP{ii} = nan(length(names), wMax);
        end
    end
    
    % loop through participants
    for subN = 1:length(names)
        % initialize parameters
        clear motionDvisual motionDvisualWeighted motionDperceived perception ap
        % get the idx of perceptual trials
        idxP = find(eyeTrialData.trialType(subN, :)==0);
        
        % then loop through perceptual trials
        for pI = 1:length(idxP)
            % get the average value of the previous trials
            % always right=1, left=0
            motionDvisual(pI, 1) = sum(eyeTrialData.rdkDir(subN, idxP(pI)-windowSize:idxP(pI)-1))/windowSize; % not weighted
            % this is incorrect weighting... need to be modified
%             motionDvisualWeighted(pI, 1) = sum(eyeTrialData.rdkDir(subN, idxP(pI)-windowSize:idxP(pI)-1).*abs(eyeTrialData.coh(subN, idxP(pI)-windowSize:idxP(pI)-1)))/windowSize; % perceptual trials weight by cohenrence
            motionDperceived(pI, 1) = sum(eyeTrialData.choice(subN, idxP(pI)-windowSize:idxP(pI)-1))/windowSize; % based on participant's choice
            % get the value of the current trial
%             perception(pI, 1) = eyeTrialData.choice(subN, idxP(pI));
            ap(pI, 1) = eyeTrialData.pursuit.APvelocityX_interpol(subN, idxP(pI));
        end
        
        % get the correlation
%         % perception
%         [rPercept{1}(subN, windowSize) pPercept{1}(subN, windowSize)] = corr(motionDvisual, perception, 'type', 'Pearson');
%         [rPercept{2}(subN, windowSize) pPercept{2}(subN, windowSize)] = corr(motionDvisualWeighted, perception, 'type', 'Pearson');
%         [rPercept{3}(subN, windowSize) pPercept{3}(subN, windowSize)] = corr(motionDperceived, perception, 'type', 'Pearson');
        % ap
        [rAP{1}(subN, windowSize) pAP{1}(subN, windowSize)] = corr(motionDvisual, ap, 'rows', 'complete', 'type', 'Pearson');
%         [rAP{2}(subN, windowSize) pAP{2}(subN, windowSize)] = corr(motionDvisualWeighted, ap, 'rows', 'complete', 'type', 'Pearson');
        [rAP{2}(subN, windowSize) pAP{2}(subN, windowSize)] = corr(motionDperceived, ap, 'rows', 'complete', 'type', 'Pearson');
%     figure
%     scatter(motionDvisual, ap)
%     xlabel('Previous visual motion')
%     ylabel('AP horizontal velocity interpolated')
%     saveas(gcf,[pdfNames{1}, '_', names{subN}, '.pdf'])    
%     
%     figure
%     scatter(motionDperceived, ap)
%     xlabel('Previous perceived motion')
%     ylabel('AP horizontal velocity interpolated')
%     saveas(gcf,[pdfNames{2}, '_', names{subN}, '.pdf'])    
    end
end

%% plot correlation vs. windowSize
for ii = 1:2 % 3 types of previous motion calculation
    figure
%     p{1} = plot(1:wMax, mean(rPercept{ii}), 'b');
    hold on
    plot(1:wMax, nanmean(rAP{ii}), 'r');
    
%     errorbar(1:wMax, mean(rPercept{ii}), std(rPercept{ii})/sqrt(length(names)))
    errorbar(1:wMax, mean(rAP{ii}), std(rAP{ii})/sqrt(length(names)))
    
%     legend([p{1} p{2}], {'perception' 'anticipatory pursuit'}, 'box', 'off', 'location', 'best')
    
    ylim([0 0.45])
    xlabel('Number of previous trials')
    ylabel('Correlation of AP velocity interpolated')
    title(pdfNames{ii})
    box off

    cd(correlationFolder)
    saveas(gcf, [pdfNames{ii}, '.pdf'])
end