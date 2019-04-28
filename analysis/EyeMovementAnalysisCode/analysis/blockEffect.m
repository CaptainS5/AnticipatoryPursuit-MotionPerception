initializeParas;

% different parameters to look at
checkParas = {'choice' 'pursuit.APvelocityX' ...
    'pursuit.initialMeanVelocityX' 'pursuit.initialPeakVelocityX' ...
    'pursuit.closedLoopGainX' ...
    'saccades.X.number' 'saccades.X.meanAmplitude' 'saccades.X.sumAmplitude'}; % field name in eyeTrialData
fileNames = {'perception' 'APvelX' ...
    'olpMeanVelX' 'olpPeakVelX' ...
    'pursuit.closedLoopGainX' ...
    'saccades.X.number' 'saccades.X.meanAmplitude' 'saccades.X.sumAmplitude'}; % name for saving the pdf

%% box plots, compare different probabilities
% separate perceptual and standard trials
for subN = 1:size(names, 2)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    
    apB{subN}.standard = NaN(500, size(probSub, 2));
    olpB{subN}.standard = NaN(500, size(probSub, 2));
    clpB{subN}.standard = NaN(500, size(probSub, 2));
    apB{subN}.perceptual = NaN(182, size(probSub, 2));
    olpB{subN}.perceptual = NaN(182, size(probSub, 2));
    clpB{subN}.perceptual = NaN(182, size(probSub, 2));
    perceptB{subN}.perceptual = NaN(182, size(probSub, 2));
    clpBL{subN}.standard = NaN(500, size(probSub, 2));
    clpBL{subN}.perceptual = NaN(182, size(probSub, 2));
    clpBR{subN}.standard = NaN(500, size(probSub, 2));
    clpBR{subN}.perceptual = NaN(182, size(probSub, 2));
    for probN = 1:size(probSub, 2)
        % standard trials
        validI = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probN));
        apB{subN}.standard(1:length(validI), probN) = eyeTrialData.pursuit.AP(subN, validI);
        olpB{subN}.standard(1:length(validI), probN) = eyeTrialData.pursuit.initialMeanVelocity(subN, validI);
        clpB{subN}.standard(1:length(validI), probN) = eyeTrialData.pursuit.closedLoopGain(subN, validI);
        
        % then perceptual trials
        validI = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probN));
        apB{subN}.perceptual(1:length(validI), probN) = eyeTrialData.pursuit.AP(subN, validI);
        olpB{subN}.perceptual(1:length(validI), probN) = eyeTrialData.pursuit.initialMeanVelocity(subN, validI);
        clpB{subN}.perceptual(1:length(validI), probN) = eyeTrialData.pursuit.closedLoopGain(subN, validI);
        perceptB{subN}.perceptual(1:length(validI), probN) = eyeTrialData.choice(subN, validI);
        
        %%seperate left and rightward trials
        % standard trials
        validIL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==1 ...
            & eyeTrialData.rdkDir(subN, :)==-1 & eyeTrialData.prob(subN, :)==probSub(probN));
        clpBL{subN}.standard(1:length(validIL), probN) = eyeTrialData.pursuit.closedLoopGain(subN, validIL);
        validIR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==1 ...
            & eyeTrialData.rdkDir(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probN));
        clpBR{subN}.standard(1:length(validIR), probN) = eyeTrialData.pursuit.closedLoopGain(subN, validIR);
        
        % then perceptual trials
        validIL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
            & eyeTrialData.rdkDir(subN, :)==-1 & eyeTrialData.prob(subN, :)==probSub(probN));
        clpBL{subN}.perceptual(1:length(validIL), probN) = eyeTrialData.pursuit.closedLoopGain(subN, validIL);
        validIR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
            & eyeTrialData.rdkDir(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probN));
        clpBR{subN}.perceptual(1:length(validIR), probN) = eyeTrialData.pursuit.closedLoopGain(subN, validIR);
    end
    
    % boxplots
    %     % plot mean anticipatory pursuit mean velocity
    %     figure
    %     subplot(1, 2, 1)
    %     hold on
    %     boxplot(apB{subN}.standard, 'Labels', {'50' '70' '90'})
    %     title('standard trials')
    %     ylabel('AP (deg/s)')
    %     %     ylim([minVel maxVel])
    %     box off
    %     subplot(1, 2, 2)
    %     hold on
    %     boxplot(apB{subN}.perceptual, 'Labels', {'50' '70' '90'})
    %     title('perceptual trials')
    %     ylabel('AP (deg/s)')
    %     %     ylim([minVel maxVel])
    %     box off
    %     saveas(gca, ['anticipatoryP_boxplot_', names{subN}, '.pdf'])
    %
    %         % open-loop velocity
    %         figure
    %         subplot(1, 2, 1)
    %         hold on
    %         boxplot(olpB{subN}.standard, 'Labels', {'50' '70' '90'})
    %         title('standard trials')
    %         ylabel('Open-loop mean velocity (deg/s)')
    %         %     ylim([minVel maxVel])
    %         box off
    %         subplot(1, 2, 2)
    %         hold on
    %         boxplot(olpB{subN}.perceptual, 'Labels', {'50' '70' '90'})
    %         title('perceptual trials')
    %         ylabel('Open-loop mean velocity (deg/s)')
    %         %     ylim([minVel maxVel])
    %         box off
    %         saveas(gca, ['OLP_boxplot_', names{subN}, '.pdf'])
    
    %         % closed-loop gain, boxplot
    %         figure
    %         subplot(1, 2, 1)
    %         hold on
    %         boxplot(clpB{subN}.standard, 'Labels', {'50' '70' '90'})
    %         title('standard trials')
    %         ylabel('Closed-loop gain')
    %         %     ylim([minVel maxVel])
    %         box off
    %         subplot(1, 2, 2)
    %         hold on
    %         boxplot(clpB{subN}.perceptual, 'Labels', {'50' '70' '90'})
    %         title('perceptual trials')
    %         ylabel('Closed-loop gain')
    %         %     ylim([minVel maxVel])
    %         box off
    %         saveas(gca, ['CLPgain_boxplot_', names{subN}, '.pdf'])
    
    %         % closed-loop gain, boxplot, leftward and rightward trials seperated
    %         figure
    %         subplot(2, 2, 1)
    %         hold on
    %         boxplot(clpBL{subN}.standard, 'Labels', {'50' '70' '90'})
    %         title('standard trials, leftward')
    %         ylabel('Closed-loop gain')
    %         ylim([0 1.2])
    %         box off
    %         subplot(2, 2, 2)
    %         hold on
    %         boxplot(clpBR{subN}.standard, 'Labels', {'50' '70' '90'})
    %         title('standard trials, rightward')
    %         ylabel('Closed-loop gain')
    %         ylim([0 1.2])
    %         box off
    %
    %         subplot(2, 2, 3)
    %         hold on
    %         boxplot(clpBL{subN}.perceptual, 'Labels', {'50' '70' '90'})
    %         title('perceptual trials, leftward')
    %         ylabel('Closed-loop gain')
    %         ylim([0 1])
    %         box off
    %         saveas(gca, ['CLPleft&right_boxplot_', names{subN}, '.pdf'])
    %         subplot(2, 2, 4)
    %         hold on
    %         boxplot(clpBR{subN}.perceptual, 'Labels', {'50' '70' '90'})
    %         title('perceptual trials, rightward')
    %         ylabel('Closed-loop gain')
    %         ylim([0 1])
    %         box off
    %         saveas(gca, ['CLPgainleft&right_boxplot_', names{subN}, '.pdf'])
    %
    %     % perception in perceptual trials
    %     figure
    %     plot([50 70 90], nanmean(perceptB{subN}.perceptual),'--');
    % %     set(gca, 'XTick', 'XTickLabels', {'50' '70' '90'})
    %     title('perceptual trials')
    %     ylabel('Probability of perceiving right (0-left, 1-right)')
    %     %     ylim([minVel maxVel])
    %     box off
    %     saveas(gca, ['perception_diffProbs_', names{subN}, '.pdf'])
end

%% grouped bars of the mean of all participants
% sort data of different participants together
for probN = 1:size(probSub, 2)
    for subN = 1:size(names, 2)
        validI = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probN));
        apTemp = eyeTrialData.pursuit.AP(subN, validI);
        meanAP(subN, probN) = nanmean(apTemp);
        %         stdAP(subN, probN) = nanstd(apTemp);
        
        % standard trials
        meanCLPsL(subN, probN) = nanmean(clpBL{subN}.standard(:, probN));
        %         stdCLPsL(subN, probN) = nanstd(clpBL{subN}.standard(:, probN));
        meanCLPsR(subN, probN) = nanmean(clpBR{subN}.standard(:, probN));
        %         stdCLPsR(subN, probN) = nanstd(clpBR{subN}.standard(:, probN));
        
        % perceptual trials
        meanCLPpL(subN, probN) = nanmean(clpBL{subN}.perceptual(:, probN));
        %         stdCLPpL(subN, probN) = nanstd(clpBL{subN}.perceptual(:, probN));
        meanCLPpR(subN, probN) = nanmean(clpBR{subN}.perceptual(:, probN));
        %         stdCLPpR(subN, probN) = nanstd(clpBR{subN}.perceptual(:, probN));
    end
    meanCLPs(1, probN) = mean(meanCLPsL(:, probN)); % left trials
    meanCLPs(2, probN) = mean(meanCLPsR(:, probN)); % right trials
    steCLPs(1, probN) = std(meanCLPsL(:, probN))/sqrt(size(names, 2)); % left trials
    steCLPs(2, probN) = std(meanCLPsR(:, probN))/sqrt(size(names, 2)); % right trials
    
    meanCLPp(1, probN) = mean(meanCLPpL(:, probN)); % left trials
    meanCLPp(2, probN) = mean(meanCLPpR(:, probN)); % right trials
    steCLPp(1, probN) = std(meanCLPpL(:, probN))/sqrt(size(names, 2)); % left trials
    steCLPp(2, probN) = std(meanCLPpR(:, probN))/sqrt(size(names, 2)); % right trials
end

% % AP, all trials together
% errorbar_groups(mean(meanAP), zeros(size(mean(meanAP))), std(meanAP)/sqrt(size(meanAP, 1)), ...
%     'bar_width',0.75,'errorbar_width',0.5, ...
%     'bar_names',{'50','70','90'});
% title('all trials')
% ylabel('AP (deg/s)')
% %     ylim([-0.5 5])
% box off
% saveas(gca, ['AP_barplot_allTrials.pdf'])
% 
% % CLP gain, left and right seperated, standard trials
% errorbar_groups(meanCLPs, zeros(size(steCLPs)), steCLPs,  ...
%     'bar_width',0.75,'errorbar_width',0.5, ...
%     'bar_names',{'50','70','90'});
% legend({'leftward trials' 'rightward trials'})
% title('standard trials')
% ylabel('Closed-loop gain')
% ylim([0 1.3])
% box off
% saveas(gca, ['CLPgain_barplot_standardTrials.pdf'])
% 
% % CLP gain, left and right seperated, perceptual trials
% errorbar_groups(meanCLPp, zeros(size(steCLPp)), steCLPp,  ...
%     'bar_width',0.75,'errorbar_width',0.5, ...
%     'bar_names',{'50','70','90'});
% legend({'leftward trials' 'rightward trials'})
% title('perceptual trials')
% ylabel('Closed-loop gain')
% %     ylim([-0.5 5])
% box off
% saveas(gca, ['CLPgain_barplot_perceptualTrials.pdf'])