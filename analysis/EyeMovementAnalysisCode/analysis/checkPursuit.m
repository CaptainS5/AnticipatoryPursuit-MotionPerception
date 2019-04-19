% use eyeDataAll to do more analysis with pursuit
% check pursuit properties based on trial condition/perceptual
% response; currently take the window of -50ms to 50ms around rdk onset
% for anticipatory pursuit

clear all; close all; clc

names = {'XW0' 'p2'};
sampleRate = 1000;
negativeWindow = -50;
positiveWindow = 50;

% for plotting
% minVel = [-6];
% maxVel = [12];
folder = pwd;
load(['eyeTrialDataLog_all.mat']);
% dirCons = [-1 1]; % -1=left, 1=right
% dirNames = {'left' 'right'};
colorProb = [255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability
% cd ..
%% first analyze AP for all trials
for subN = 1:size(names, 2)
    cd(folder)
    load(['eyeTrialData_' names{subN} '.mat']);
    cd ..
    
    eyeTrialData.pursuit.AP(subN, :) = NaN(1, size(eyeTrialDataLog.trialIdx(subN, :), 2));
    eyeTrialData.pursuit.initialMeanVelocity(subN, :) = NaN(1, size(eyeTrialDataLog.trialIdx(subN, :), 2));
    eyeTrialData.pursuit.closedLoopGain(subN, :) = NaN(1, size(eyeTrialDataLog.trialIdx(subN, :), 2));
    eyeTrialData.pursuit.closedLoopMeanVel(subN, :) = NaN(1, size(eyeTrialDataLog.trialIdx(subN, :), 2));
    for trialI = 1:size(eyeTrialDataLog.trialIdx(subN, :), 2)
        if eyeTrialDataLog.errorStatus(subN, trialI)==0
            startI = eyeTrialDataLog.frameLog.rdkOn(subN, trialI)+ms2frames(negativeWindow);
            endI = eyeTrialDataLog.frameLog.rdkOn(subN, trialI)+ms2frames(positiveWindow);
            eyeTrialData.pursuit.AP(subN, trialI) = nanmean(eyeTrialDataSub.trial{1, trialI}.DX_noSac(startI:endI));
            %             eyeTrialData.trial{subN, trialI}.pursuit = analyzePursuit(eyeTrialDataSub.trial{1, trialI}, eyeTrialDataSub.trial{1, trialI}.pursuit);
            eyeTrialData.pursuit.initialMeanVelocity(subN, trialI) = eyeTrialDataSub.trial{1, trialI}.pursuit.initialMeanVelocity;
            eyeTrialData.pursuit.closedLoopGain(subN, trialI) = eyeTrialDataSub.trial{1, trialI}.pursuit.gain;
            eyeTrialData.pursuit.closedLoopMeanVel(subN, trialI) = eyeTrialDataSub.trial{1, trialI}.pursuit.closedLoopMeanVel.X;
        end
    end
end
%% plotting
% cd('pursuitPlots')
%% box plots of pursuit
% compare different probabilities
% separate perceptual and standard trials
for subN = 1:size(names, 2)
    probCons = unique(eyeTrialDataLog.prob(subN, eyeTrialDataLog.errorStatus(subN, :)==0));
    
    apB{subN}.standard = NaN(500, size(probCons, 2));
    olpB{subN}.standard = NaN(500, size(probCons, 2));
    clpB{subN}.standard = NaN(500, size(probCons, 2));
    apB{subN}.perceptual = NaN(182, size(probCons, 2));
    olpB{subN}.perceptual = NaN(182, size(probCons, 2));
    clpB{subN}.perceptual = NaN(182, size(probCons, 2));
    perceptB{subN}.perceptual = NaN(182, size(probCons, 2));
    clpBL{subN}.standard = NaN(500, size(probCons, 2));
    clpBL{subN}.perceptual = NaN(182, size(probCons, 2));
    clpBR{subN}.standard = NaN(500, size(probCons, 2));
    clpBR{subN}.perceptual = NaN(182, size(probCons, 2));
    for probN = 1:size(probCons, 2)
        % standard trials
        validI = find(eyeTrialDataLog.errorStatus(subN, :)==0 & eyeTrialDataLog.trialType(subN, :)==1 & eyeTrialDataLog.prob(subN, :)==probCons(probN));
        apB{subN}.standard(1:length(validI), probN) = eyeTrialData.pursuit.AP(subN, validI);
        olpB{subN}.standard(1:length(validI), probN) = eyeTrialData.pursuit.initialMeanVelocity(subN, validI);
        clpB{subN}.standard(1:length(validI), probN) = eyeTrialData.pursuit.closedLoopGain(subN, validI);
        
        % then perceptual trials
        validI = find(eyeTrialDataLog.errorStatus(subN, :)==0 & eyeTrialDataLog.trialType(subN, :)==0 & eyeTrialDataLog.prob(subN, :)==probCons(probN));
        apB{subN}.perceptual(1:length(validI), probN) = eyeTrialData.pursuit.AP(subN, validI);
        olpB{subN}.perceptual(1:length(validI), probN) = eyeTrialData.pursuit.initialMeanVelocity(subN, validI);
        clpB{subN}.perceptual(1:length(validI), probN) = eyeTrialData.pursuit.closedLoopGain(subN, validI);
        perceptB{subN}.perceptual(1:length(validI), probN) = eyeTrialDataLog.choice(subN, validI);
        
        %%seperate left and rightward trials
        % standard trials
        validIL = find(eyeTrialDataLog.errorStatus(subN, :)==0 & eyeTrialDataLog.trialType(subN, :)==1 ...
            & eyeTrialDataLog.rdkDir(subN, :)==-1 & eyeTrialDataLog.prob(subN, :)==probCons(probN));
        clpBL{subN}.standard(1:length(validIL), probN) = eyeTrialData.pursuit.closedLoopGain(subN, validIL);
        validIR = find(eyeTrialDataLog.errorStatus(subN, :)==0 & eyeTrialDataLog.trialType(subN, :)==1 ...
            & eyeTrialDataLog.rdkDir(subN, :)==1 & eyeTrialDataLog.prob(subN, :)==probCons(probN));
        clpBR{subN}.standard(1:length(validIR), probN) = eyeTrialData.pursuit.closedLoopGain(subN, validIR);
        
        % then perceptual trials
        validIL = find(eyeTrialDataLog.errorStatus(subN, :)==0 & eyeTrialDataLog.trialType(subN, :)==0 ...
            & eyeTrialDataLog.rdkDir(subN, :)==-1 & eyeTrialDataLog.prob(subN, :)==probCons(probN));
        clpBL{subN}.perceptual(1:length(validIL), probN) = eyeTrialData.pursuit.closedLoopGain(subN, validIL);
        validIR = find(eyeTrialDataLog.errorStatus(subN, :)==0 & eyeTrialDataLog.trialType(subN, :)==0 ...
            & eyeTrialDataLog.rdkDir(subN, :)==1 & eyeTrialDataLog.prob(subN, :)==probCons(probN));
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

%%grouped bars of the mean of all participants
% sort data of different participants together
for probN = 1:size(probCons, 2)
    for subN = 1:size(names, 2)
        validI = find(eyeTrialDataLog.errorStatus(subN, :)==0 & eyeTrialDataLog.prob(subN, :)==probCons(probN));
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

%% building up of long-term effect? sliding window across trials
trialBin = 30; % window of trial numbers
% get sliding AP for each bock
for subN = 1:size(names, 2)
    probCons = unique(eyeTrialDataLog.prob(subN, :));
    slidingAP{subN} = NaN(size(probCons, 2), size(eyeTrialDataLog.prob, 2)/size(probCons, 2)-trialBin);
    slidingOLP{subN} = NaN(size(probCons, 2), size(eyeTrialDataLog.prob, 2)/size(probCons, 2)-trialBin);
    slidingCLP{subN} = NaN(size(probCons, 2), size(eyeTrialDataLog.prob, 2)/size(probCons, 2)-trialBin);
    slidingPercept{subN} = NaN(size(probCons, 2), size(eyeTrialDataLog.prob, 2)/size(probCons, 2)-trialBin);
    slidingCLPp{subN} = NaN(size(probCons, 2), size(eyeTrialDataLog.prob, 2)/size(probCons, 2)-trialBin);
    for probI = 1:size(probCons, 2)
        idxT = find(eyeTrialDataLog.prob(subN, :)==probCons(probI) & eyeTrialDataLog.errorStatus(subN, :)==0);
        for slideI = 1:length(idxT)-trialBin
            slidingAP{subN}(probI, slideI) = nanmean(eyeTrialData.pursuit.AP(subN, idxT(slideI:(slideI+trialBin-1))));
            slidingOLP{subN}(probI, slideI) = nanmean(eyeTrialData.pursuit.initialMeanVelocity(subN, idxT(slideI:(slideI+trialBin-1)))); % open loop pursuit
            slidingCLP{subN}(probI, slideI) = nanmean(eyeTrialData.pursuit.closedLoopGain(subN, idxT(slideI:(slideI+trialBin-1)))); % close loop pursuit gain
        end
        
        idxT = find(eyeTrialDataLog.prob(subN, :)==probCons(probI) & eyeTrialDataLog.errorStatus(subN, :)==0 ...
            & abs(eyeTrialDataLog.coh(subN, :))~=1);
        for slideI = 1:length(idxT)-trialBin+1
            slidingPercept{subN}(probI, slideI) = nanmean(eyeTrialDataLog.choice(subN, idxT(slideI:(slideI+trialBin-1))));
            slidingCLPp{subN}(probI, slideI) = nanmean(eyeTrialData.pursuit.closedLoopGain(subN, idxT(slideI:(slideI+trialBin-1)))); % close loop pursuit gain
        end
    end
%     % individual plot
    % AP
    figure
    for probI = 1:size(probCons, 2)
        plot(slidingAP{subN}(probI, :), 'color', colorProb(probI, :))
        hold on
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Trial number')
    ylabel('AP')
    title(names{subN})
    saveas(gca, ['slidingAP_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    
    % OLP
    figure
    for probI = 1:size(probCons, 2)
        plot(slidingOLP{subN}(probI, :), 'color', colorProb(probI, :))
        hold on
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Trial number')
    ylabel('Open-loop pursuit mean velocity')
    title(names{subN})
    saveas(gca, ['slidingOLPmeanV_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    %
    % CLP
    figure
    for probI = 1:size(probCons, 2)
        plot(slidingCLP{subN}(probI, :), 'color', colorProb(probI, :))
        hold on
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Trial number')
    ylabel('Closed-loop pursuit gain')
    title(names{subN})
    saveas(gca, ['slidingCLPgain_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    
    % CLP in perceptual trials
    figure
    for probI = 1:size(probCons, 2)
        plot(slidingCLPp{subN}(probI, :), 'color', colorProb(probI, :))
        hold on
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Trial number (only perceptual trials)')
    ylabel('Closed-loop pursuit gain')
    title(names{subN})
    saveas(gca, ['slidingCLPgain_perceptualTrials_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    
    % Perception
    figure
    for probI = 1:size(probCons, 2)
        plot(slidingPercept{subN}(probI, :), 'color', colorProb(probI, :))
        hold on
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Trial number')
    ylabel('Probability of perceiving right')
    title(names{subN})
    saveas(gca, ['slidingPercept_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
end

%% sort trials by preceeding probability of right, plot AP
trialBin = 5; % window of trial numbers; needs to be smaller than 50 for now
clear precedeProbPercept precedeProb perceptProbR clpProbR olpProbR apProbR xProb yAP yOLP yCLP xProbPercept yPercept
for subN = 1:size(names, 2)
    probCons = unique(eyeTrialDataLog.prob(subN, :));
    %     precedeProb{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
    %     apProbR{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
    %     olpProbR{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
    %     clpProbR{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
    for probI = 1:size(probCons, 2)
        % eye movements
        idxT = find(eyeTrialDataLog.prob(subN, :)==probCons(probI) & eyeTrialDataLog.errorStatus(subN, :)==0 ...
            & ~isnan(eyeTrialData.pursuit.AP(subN, :)) & ~isnan(eyeTrialData.pursuit.closedLoopMeanVel(subN, :)) & abs(eyeTrialDataLog.coh(subN, :))<1);
        % true preceding trials
        for slideI = 1:length(idxT)
            rightN = length(find(eyeTrialDataLog.rdkDir(subN, (idxT(slideI)-trialBin):(idxT(slideI)-1))==1)); % counting on perceptual choice, true preceding trials
            precedeProb{subN}(probI, slideI) = rightN/trialBin;
            apProbR{subN}(probI, slideI) = eyeTrialData.pursuit.AP(subN, idxT(slideI));
            olpProbR{subN}(probI, slideI) = eyeTrialData.pursuit.initialMeanVelocity(subN, idxT(slideI));
            clpProbR{subN}(probI, slideI) = eyeTrialData.pursuit.closedLoopGain(subN, idxT(slideI));
            perceptProbR{subN}(probI, slideI) = eyeTrialDataLog.choice(subN, idxT(slideI));
        end
        %     % preceding trials in the list
        %     for slideI = (trialBin+1):length(idxT)
        %         rightN = length(find(eyeTrialData.rdkDir(subN, idxT((slideI-trialBin):(slideI-1)))==1));
        %         precedeProb{subN}(probI, slideI-trialBin) = rightN/trialBin;
        %         apProbR{subN}(probI, slideI-trialBin) = eyeTrialData.pursuit.AP(subN, idxT(slideI));
        %         olpProbR{subN}(probI, slideI-trialBin) = eyeTrialData.pursuit.initialMeanVelocity(subN, idxT(slideI));
        %         clpProbR{subN}(probI, slideI-trialBin) = eyeTrialData.pursuit.closedLoopGain(subN, idxT(slideI));
        %         perceptProbR{subN}(probI, slideI-trialBin) = eyeTrialData.choice(subN, idxT(slideI));
        %     end
        [xProb{subN, probI} ia ic] = unique(precedeProb{subN}(probI, :));
        yAP{subN, probI} = accumarray(ic, apProbR{subN}(probI, :)', [], @mean); % mean AP of the corresponding probability
        yOLP{subN, probI} = accumarray(ic, olpProbR{subN}(probI, :)', [], @mean);
        yCLP{subN, probI} = accumarray(ic, clpProbR{subN}(probI, :)', [], @mean);
        yPercept{subN, probI} = accumarray(ic, perceptProbR{subN}(probI, :)', [], @mean); % mean AP of the corresponding probability
    end
    % individual plot
    % AP
    figure
    for probI = 1:size(probCons, 2)
        %         subplot(1, 3, probI)
        plot(xProb{subN, probI}, yAP{subN, probI}, 'color', colorProb(probI, :))
        hold on
        %         xlim([0 1])
        %         ylim([-8 10])
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Preceded probability of right')
    ylabel('AP')
    title([names{subN}])
    %     end
    saveas(gca, ['precedeProbRight_AP_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    %
    %     % OLP
    %     figure
    %     for probI = 1:size(probCons, 2)
    %         %         subplot(1, 3, probI)
    %         plot(xProb{subN, probI}, yOLP{subN, probI}, 'color', colorProb(probI, :))
    %         hold on
    %         %         xlim([0 1])
    %         %         ylim([-8 10])
    %     end
    %     legend({'50' '70' '90'}, 'box', 'off')
    %     xlabel('Preceded probability of right')
    %     ylabel('Open-loop pursuit mean velocity')
    %     title([names{subN}])
    %     %     end
    %     saveas(gca, ['precedeProbRight_OLPmeanV_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    
    % closed loop
    figure
    for probI = 1:size(probCons, 2)
        %         subplot(1, 3, probI)
        plot(xProb{subN, probI}, yCLP{subN, probI}, 'color', colorProb(probI, :))
        hold on
        %         xlim([0 1])
        %         ylim([-8 10])
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Preceded probability of right')
    ylabel('Closed-loop pursuit gain')
    title([names{subN}])
    %     end
    saveas(gca, ['precedeProbRight_CLPgain_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    
    % perception
    figure
    for probI = 1:size(probCons, 2)
        %         subplot(1, 3, probI)
        plot(xProb{subN, probI}, yPercept{subN, probI}, 'color', colorProb(probI, :))
        hold on
        %         xlim([0 1])
        %         ylim([-8 10])
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Preceded probability of right')
    ylabel('Probability of perceiving right')
    title([names{subN}])
    %     %     end
    saveas(gca, ['precedeProbRight_perception_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
end

%% sort trials by perceptual responses, plot pursuit
for subN = 1:size(names, 2)
    probCons = unique(eyeTrialDataLog.prob(subN, :));
    
    for probI = 1:size(probCons, 2)
        % low coherece trials perceived as moving to the right
        idxR = find(eyeTrialDataLog.prob(subN, :)==probCons(probI) & eyeTrialDataLog.errorStatus(subN, :)==0 ...
            & eyeTrialDataLog.choice(subN, :)==1 & abs(eyeTrialDataLog.coh(subN, :))<0.15);
        % low coherece trials perceived as moving to the left
        idxL = find(eyeTrialDataLog.prob(subN, :)==probCons(probI) & eyeTrialDataLog.errorStatus(subN, :)==0 ...
            & eyeTrialDataLog.choice(subN, :)==0 & abs(eyeTrialDataLog.coh(subN, :))<0.15);
        
        apChoice.mean{subN}(probI, 1) = nanmean(eyeTrialData.pursuit.AP(subN, idxL)); % choosing left
        apChoice.std{subN}(probI, 1) = nanstd(eyeTrialData.pursuit.AP(subN, idxL)); % choosing left
        apChoice.mean{subN}(probI, 2) = nanmean(eyeTrialData.pursuit.AP(subN, idxR)); % choosing right
        apChoice.std{subN}(probI, 2) = nanstd(eyeTrialData.pursuit.AP(subN, idxR)); % choosing right
        
        olpChoice.mean{subN}(probI, 1) = nanmean(eyeTrialData.pursuit.initialMeanVelocity(subN, idxL)); % choosing left
        olpChoice.std{subN}(probI, 1) = nanstd(eyeTrialData.pursuit.initialMeanVelocity(subN, idxL)); % choosing left
        olpChoice.mean{subN}(probI, 2) = nanmean(eyeTrialData.pursuit.initialMeanVelocity(subN, idxR)); % choosing right
        olpChoice.std{subN}(probI, 2) = nanstd(eyeTrialData.pursuit.initialMeanVelocity(subN, idxR)); % choosing right
        
        clpChoice.mean{subN}(probI, 1) = nanmean(eyeTrialData.pursuit.closedLoopMeanVel(subN, idxL)); % choosing left
        clpChoice.std{subN}(probI, 1) = nanstd(eyeTrialData.pursuit.closedLoopMeanVel(subN, idxL)); % choosing left
        clpChoice.mean{subN}(probI, 2) = nanmean(eyeTrialData.pursuit.closedLoopMeanVel(subN, idxR)); % choosing right
        clpChoice.std{subN}(probI, 2) = nanstd(eyeTrialData.pursuit.closedLoopMeanVel(subN, idxR)); % choosing right
        
    end
%     individual plot
    % AP
    figure
    for probI = 1:size(probCons, 2)
        %         subplot(1, 3, probI)
        errorbar([-1 1], apChoice.mean{subN}(probI, :), apChoice.std{subN}(probI, :), '--o', 'color', colorProb(probI, :))
        hold on
        %         xlim([0 1])
        %         ylim([-8 10])
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Perceptual choice (-1=left, 1=right)')
    ylabel('AP')
    title([names{subN}])
    %     end
    saveas(gca, ['choice_AP_', names{subN}, '.pdf'])
    
    %     % OLP
    %     figure
    %         for probI = 1:size(probCons, 2)
    %             %         subplot(1, 3, probI)
    %             errorbar([-1 1], olpChoice.mean{subN}(probI, :), olpChoice.std{subN}(probI, :), '--o', 'color', colorProb(probI, :))
    %             hold on
    %     %         xlim([0 1])
    %     %         ylim([-8 10])
    %         end
    %         legend({'50' '70' '90'}, 'box', 'off')
    %         xlabel('Perceptual choice (-1=left, 1=right)')
    %         ylabel('Open-loop mean velocity')
    %         title([names{subN}])
    %         %     end
    %         saveas(gca, ['choice_OLPmeanV_', names{subN}, '.pdf'])
    
    % closed-loop
    figure
    for probI = 1:size(probCons, 2)
        %         subplot(1, 3, probI)
        errorbar([-1 1], clpChoice.mean{subN}(probI, :), clpChoice.std{subN}(probI, :), '--o', 'color', colorProb(probI, :))
        hold on
        %         xlim([0 1])
        %         ylim([-8 10])
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Perceptual choice (-1=left, 1=right)')
    ylabel('Closed-loop mean velocity')
    title([names{subN}])
    %     end
    saveas(gca, ['choice_CLPmeanV_', names{subN}, '.pdf'])
end