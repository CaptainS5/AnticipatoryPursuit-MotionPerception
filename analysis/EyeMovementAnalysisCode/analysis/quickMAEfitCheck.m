% to quickly check the MAE hypothesis
% separate trials into two bins: previous left standard or right standard
% if MAE plays a role, we may expect different psychometric functions
% of the two bins of trials
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

cohLevels = unique(eyeTrialData.coh(1, eyeTrialData.trialType(1, :)==0))';

%% do the fitting for each bin
cd(perceptFolder)
% initialize some parameters
for probNmerged = 1:3
    countL{probNmerged} = zeros(length(names), length(cohLevels));
    countR{probNmerged} = zeros(length(names), length(cohLevels));
    propR{probNmerged} = zeros(length(names), 2); % first column is left, second column is right
    idxL{probNmerged} = cell(length(names), length(cohLevels));
    idxR{probNmerged} = cell(length(names), length(cohLevels));
    idxMAE{probNmerged, 1} = cell(size(names));
    idxMAE{probNmerged, 2} = cell(size(names));
end

for subN = 1:length(names)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    dataPercept.probSub(subN, 1:length(probSub)) = probSub;
    
    for probSubN = 1:size(probSub, 2)
        if probSub(1)<50
            probNmerged = 4-probSubN;
        else
            probNmerged = probSubN;
        end
        
        idxP = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.errorStatus(subN, :)==0 ...
            & eyeTrialData.prob(subN, :)==probSub(probSubN)); % perceptual trials
        for tI = 1:length(idxP)
            if eyeTrialData.trialType(subN, idxP(tI)-1)==1 % preceded by standard trial
                cohI = find(cohLevels==eyeTrialData.coh(subN, idxP(tI)));
                if eyeTrialData.rdkDir(subN, idxP(tI)-1)==-1 % standard left trial
                    if isempty(idxL)
                        idxL{probNmerged}{subN, cohI} = idxP(tI);
                        idxMAE{probNmerged, 1}{subN} = idxP(tI);
                    else
                        idxL{probNmerged}{subN, cohI} = [idxL{probNmerged}{subN, cohI}; idxP(tI)];
                        idxMAE{probNmerged, 1}{subN} = [idxMAE{probNmerged, 1}{subN}; idxP(tI)];
                    end
                    countL{probNmerged}(subN, cohI) = countL{probNmerged}(subN, cohI) + 1;
                    if eyeTrialData.choice(subN, idxP(tI))==1
                        propR{probNmerged}(subN, 1) = propR{probNmerged}(subN, 1)+1;
                    end
                elseif eyeTrialData.rdkDir(subN, idxP(tI)-1)==1 % standard right trial
                    if isempty(idxR)
                        idxR{probNmerged}{subN, cohI} = idxP(tI);
                        idxMAE{probNmerged, 2}{subN} = idxP(tI);
                    else
                        idxR{probNmerged}{subN, cohI} = [idxR{probNmerged}{subN, cohI}; idxP(tI)];
                        idxMAE{probNmerged, 2}{subN} = [idxMAE{probNmerged, 2}{subN}; idxP(tI)];
                    end
                    countR{probNmerged}(subN, cohI) = countR{probNmerged}(subN, cohI) + 1;
                    if eyeTrialData.choice(subN, idxP(tI))==1
                        propR{probNmerged}(subN, 2) = propR{probNmerged}(subN, 2)+1;
                    end
                end
            end
        end
        countLMean(:, probNmerged) = nanmean(countL{probNmerged})';
        countRMean(:, probNmerged) = nanmean(countR{probNmerged})';
        countLSte(:, probNmerged) = nanstd(countL{probNmerged})'/sqrt(length(names));
        countRSte(:, probNmerged) = nanstd(countR{probNmerged})'/sqrt(length(names));
        propR{probNmerged}(:, 1) = propR{probNmerged}(:, 1)'/sum(countL{probNmerged}');
        propR{probNmerged}(:, 2) = propR{probNmerged}(:, 2)'/sum(countR{probNmerged}');
        
        propRmean(probNmerged, :) = nanmean(propR{probNmerged});
        propRste(probNmerged, :) = nanstd(propR{probNmerged})/sqrt(length(names));
    end
end
%% plot the trial proportion as a sanity check
% errorbar_groups(countLMean', countLSte',  ...
%     'bar_width',0.75,'errorbar_width',0.5, ...
%     'bar_names',{'-0.15' '-0.10' '-0.05' '0' '0.05' '0.10' '0.15'});
% legend({'50','70','90'}, 'location', 'best')
% title('preceded by standard left trials')
% ylabel('Count of trials');
% saveas(gcf, ['trialProportion_previousStandardL_all.pdf'])
%
% errorbar_groups(countRMean', countRSte',  ...
%     'bar_width',0.75,'errorbar_width',0.5, ...
%     'bar_names',{'-0.15' '-0.10' '-0.05' '0' '0.05' '0.10' '0.15'});
% legend({'50','70','90'}, 'location', 'best')
% title('preceded by standard right trials')
% xlabel('Coherence level')
% ylabel('Count of trials');
% saveas(gcf, ['trialProportion_previousStandardR_all.pdf'])

%% simply plot the difference of proportion of right trials
 errorbar_groups(propRmean', propRste',  ...
    'bar_width',0.75,'errorbar_width',0.5, ...
    'bar_names',{'50','70','90'});
legend({'preceded left' 'preceded right'}, 'location', 'best')
ylabel('Proportion of right');
saveas(gcf, ['proportionRight_MAE_all.pdf'])
    
%% fit the curve for the two bins
% for subN = 1:length(names)
%     probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
%     if probSub(1)<50
%         probNameI = 1;
%     else
%         probNameI = 2;
%     end
%     
%     figure
%     hold on
%     for probNmerged = 1:3
%         if probSub(1)<50
%             probSubN = 4-probNmerged;
%         else
%             probSubN = probNmerged;
%         end
%         
%         % fit the psychometric curves for each bin
%         for binN = 1:2
%             data.cohFit = eyeTrialData.coh(subN, idxMAE{probNmerged, binN}{subN})';
%             data.choice = eyeTrialData.choice(subN, idxMAE{probNmerged, binN}{subN})';
%             
%             probN = find(probCons==probSub(probSubN));
%             
%             % sort data to prepare for fitting--when there's no need to
%             % calculate the weighted probabilities...
%             cohLevels = unique(data.cohFit); % stimulus levels, negative is left
%             data.cohIdx = zeros(size(data.cohFit));
%             for cohN = 1:length(cohLevels)
%                 data.cohIdx(data.cohFit==cohLevels(cohN), 1) = cohN;
%             end
%             dataPercept.numRight{probNmerged, binN}{subN} = accumarray(data.cohIdx, data.choice, [], @sum); % choice 1=right, 0=left
%             dataPercept.outOfNum{probNmerged, binN}{subN} = accumarray(data.cohIdx, data.choice, [], @numel); % total trial numbers
%             dataPercept.cohLevels{probNmerged, binN}{subN} = cohLevels;
%             
%             %Perform fit
%             [paramsValues{probNmerged, binN}{subN} LL exitflag] = ...
%                 PAL_PFML_Fit(cohLevels,  dataPercept.numRight{probNmerged, binN}{subN}, ...
%                  dataPercept.outOfNum{probNmerged, binN}{subN}, searchGrid, paramsFree, PF);
%             
%             % plotting
%             ProportionCorrectObserved=dataPercept.numRight{probNmerged, binN}{subN}./dataPercept.outOfNum{probNmerged, binN}{subN};
%             StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
%             ProportionCorrectModel = PF(paramsValues{probNmerged, binN}{subN},StimLevelsFineGrain);
%             if binN==1
%                 plot(StimLevelsFineGrain, ProportionCorrectModel,'--','color', colorProb(probN, :), 'linewidth', 2);
%             else
%                 f{probSubN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', colorProb(probN, :), 'linewidth', 2);
%             end
%             plot(cohLevels, ProportionCorrectObserved,'.', 'color', colorProb(probN, :), 'markersize', 30);
%             
%             % saving parameters
%             dataPercept.alpha{binN}(subN, probNmerged) = paramsValues{probNmerged, binN}{subN}(1); % threshold, or PSE
%             dataPercept.beta{binN}(subN, probNmerged) = paramsValues{probNmerged, binN}{subN}(2); % slope
%             dataPercept.gamma{binN}(subN, probNmerged) = paramsValues{probNmerged, binN}{subN}(3); % guess rate, or baseline
%             dataPercept.lambda{binN}(subN, probNmerged) = paramsValues{probNmerged, binN}{subN}(4); % lapse rate
%         end
%         set(gca, 'fontsize',16);
%         set(gca, 'Xtick',cohLevels);
%         axis([min(cohLevels) max(cohLevels) 0 1]);
%         title(['left preceded (dashed) vs right preceded (solid) trials'])
%         xlabel('Stimulus Intensity');
%         ylabel('Proportion right');
%         legend([f{:}], probNames{probNameI}, 'box', 'off', 'location', 'northwest')
%         
%         cd(perceptFolder)
%         saveas(gcf, ['pf_MAE_', names{subN}, '.pdf'])
%     end
% end
% save('dataPercept_MAE', 'dataPercept');

%% plot bars of the difference between the two bins in each probability
% diffMean = mean(dataPercept.alpha{2}-dataPercept.alpha{1});
% diffSte = std(dataPercept.alpha{2}-dataPercept.alpha{1})/sqrt(length(names));
% % box plot
% figure
% boxplot(dataPercept.alpha{2}-dataPercept.alpha{1}, 'Labels', {'50','70','90'})
% xlabel('Probability of right');
% ylabel('Right preceded trials-left preceded trials PSE');
% cd(perceptFolder)
% saveas(gcf, ['PSE_MAE_box.pdf'])
% 
% % bar plot
% errorbar_groups(diffMean, diffSte,  ...
%     'bar_width',0.75,'errorbar_width',0.5, ...
%     'bar_names',{'50','70','90'})
% xlabel('Probability of right');
% ylabel('Right preceded trials-left preceded trials PSE');
% cd(perceptFolder)
% saveas(gcf, ['PSE_MAE_bar.pdf'])