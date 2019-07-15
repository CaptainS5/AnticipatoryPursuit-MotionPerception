% to quickly check the evolution of perception
% separate perceptual trials into two bins: early trials, and later trials
% then fit the psychometric functions of the two bins of trials
initializeParas;
initializePSE;

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

%% do the fitting for each bin
for subN = 1:length(names)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        probNameI = 1;
    else
        probNameI = 2;
    end
    dataPercept.probSub(subN, 1:length(probSub)) = probSub;
    
%     figure
%     hold on
    for probSubN = 1:size(probSub, 2)
        idxP = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.errorStatus(subN, :)==0 ...
            & eyeTrialData.prob(subN, :)==probSub(probSubN)); % perceptual trials
        halfN = round(length(idxP)/2);
        idxT{1} = idxP(1:halfN); % the first half
        idxT{2} = idxP(halfN+1:end); % the second half
        
        % then fit the psychometric curves for each bin
        for binN = 1:2
            data.cohFit = eyeTrialData.coh(subN, idxT{binN})';
            data.choice = eyeTrialData.choice(subN, idxT{binN})';
            
            probN = find(probCons==probSub(probSubN));
            
            % sort data to prepare for fitting--when there's no need to
            % calculate the weighted probabilities...
            cohLevels = unique(data.cohFit); % stimulus levels, negative is left
            data.cohIdx = zeros(size(data.cohFit));
            for cohN = 1:length(cohLevels)
                data.cohIdx(data.cohFit==cohLevels(cohN), 1) = cohN;
            end
            numRight{probN, binN}(subN, :) = accumarray(data.cohIdx, data.choice, [], @sum); % choice 1=right, 0=left
            outOfNum{probN, binN}(subN, :) = accumarray(data.cohIdx, data.choice, [], @numel); % total trial numbers
            
            %Perform fit
            [paramsValues{subN, probSubN}{binN} LL{subN, probSubN}{binN} exitflag{subN, probSubN}{binN}] = PAL_PFML_Fit(cohLevels, numRight{probN, binN}(subN, :)', ...
                outOfNum{probN, binN}(subN, :)', searchGrid, paramsFree, PF);
            
            % plotting
            ProportionCorrectObserved=numRight{probN, binN}(subN, :)./outOfNum{probN, binN}(subN, :);
            StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
            ProportionCorrectModel = PF(paramsValues{subN, probSubN}{binN},StimLevelsFineGrain);
%             if binN==1
%                 plot(StimLevelsFineGrain, ProportionCorrectModel,'--','color', colorProb(probN, :), 'linewidth', 2);
%             else
%                 f{probSubN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', colorProb(probN, :), 'linewidth', 2);
%             end
%             plot(cohLevels, ProportionCorrectObserved,'.', 'color', colorProb(probN, :), 'markersize', 30);
            
            % saving parameters
            if probSub(1)<50
                probNmerged = 4-probN;
            else
                probNmerged = probN-2;
            end
            dataPercept.alpha{binN}(subN, probNmerged) = paramsValues{subN, probSubN}{binN}(1); % threshold, or PSE
            dataPercept.beta{binN}(subN, probNmerged) = paramsValues{subN, probSubN}{binN}(2); % slope
            dataPercept.gamma{binN}(subN, probNmerged) = paramsValues{subN, probSubN}{binN}(3); % guess rate, or baseline
            dataPercept.lambda{binN}(subN, probNmerged) = paramsValues{subN, probSubN}{binN}(4); % lapse rate
        end
%         set(gca, 'fontsize',16);
%         set(gca, 'Xtick',cohLevels);
%         axis([min(cohLevels) max(cohLevels) 0 1]);
%         title(['First half (dashed) vs second half (solid) perceptual trials'])
%         xlabel('Stimulus Intensity');
%         ylabel('Proportion right');
%         legend([f{:}], probNames{probNameI}, 'box', 'off', 'location', 'northwest')
%         
%         cd(perceptFolder)
%         saveas(gcf, ['pf_timeBins_', names{subN}, '.pdf'])
    end
end
save('dataPercept_timeBins', 'dataPercept');

%% plot bars of the difference between the two bins in each probability
% diffMean = mean(dataPercept.alpha{2}-dataPercept.alpha{1});
% diffSte = std(dataPercept.alpha{2}-dataPercept.alpha{1})/sqrt(length(names));
% % box plot
% figure
% boxplot(dataPercept.alpha{2}-dataPercept.alpha{1}, 'Labels', {'50','70','90'})
% xlabel('Probability of right');
% ylabel('Second half trials-first half trials PSE (right is positive)');
% cd(perceptFolder)
% saveas(gcf, ['PSE_timeBins_box.pdf'])
% 
% % bar plot
% errorbar_groups(diffMean, diffSte,  ...
%     'bar_width',0.75,'errorbar_width',0.5, ...
%     'bar_names',{'50','70','90'})
% xlabel('Probability of right');
% ylabel('Second half trials-first half trials PSE (right is positive)');
% cd(perceptFolder)
% saveas(gcf, ['PSE_timeBins_bar.pdf'])

%% save csv for ANOVA
cd(analysisFolder)
cd ..
cd ..
cd('R')

data = table();
count = 1;
for subN = 1:length(names)
    for probNmerged = 1:3
        for binN = 1:2
            data.sub(count, 1) = subN;
            data.prob(count, 1) = probCons(probNmerged+2);
            data.timeBin(count, 1) = binN;
            data.PSE(count, 1) = dataPercept.alpha{binN}(subN, probNmerged);
            data.slope(count, 1) = dataPercept.beta{binN}(subN, probNmerged);
            count = count+1;
        end
    end
end
writetable(data, 'earlyLatePSE.csv')

data = table();
count = 1;
for subN = 1:length(names)
    for probNmerged = 1:3
        for binN = 1:2
            data.sub(count, 1) = subN;
            data.prob(count, 1) = probCons(probNmerged+2);
            data.PSEDiff(count, 1) = dataPercept.alpha{2}(subN, probNmerged)-dataPercept.alpha{1}(subN, probNmerged);
            count = count+1;
        end
    end
end
writetable(data, 'earlyLatePSEDiff.csv')