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
load(['eyeData_all.mat']);
% dirCons = [-1 1]; % -1=left, 1=right
% dirNames = {'left' 'right'};
colorProb = [255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability
% cd ..
%% first analyze AP for all trials
for subN = 1:size(names, 2)
    cd(folder)
%     load(['eyeData_' names{subN} '.mat']);
    
    for trialI = 1:size(eyeTrialData.trialIdx, 2)
        if eyeTrialData.errorStatus(subN, trialI)==0
            startI = eyeTrialData.frameLog.rdkOn(subN, trialI)+ms2frames(negativeWindow);
            endI = eyeTrialData.frameLog.rdkOn(subN, trialI)+ms2frames(positiveWindow);
            eyeTrialData.pursuit.AP(subN, trialI) = nanmean(eyeTrialData.trial{subN, trialI}.DX_noSac(startI:endI));
%             eyeTrialData.trial{subN, trialI}.pursuit = analyzePursuit(eyeTrialData.trial{subN, trialI}, eyeTrialData.trial{subN, trialI}.pursuit);
            eyeTrialData.pursuit.initialMeanVelocity(subN, trialI) = eyeTrialData.trial{subN, trialI}.pursuit.initialMeanVelocity;
            eyeTrialData.pursuit.closedLoopGain(subN, trialI) = eyeTrialData.trial{subN, trialI}.pursuit.gain;
            eyeTrialData.pursuit.closedLoopMeanVel(subN, trialI) = eyeTrialData.trial{subN, trialI}.pursuit.closedLoopMeanVel.X;
        end
    end
end
cd ..
%% plotting
% build up of AP? sliding window across trials, 20 trials bins
% cd('pursuitPlots')
trialBin = 30; % window of trial numbers
% get sliding AP for each bock
for subN = 1:size(names, 2)
    probCons = unique(eyeTrialData.prob(subN, :));
    slidingAP{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
    slidingOLP{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
    slidingCLP{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
    slidingPercept{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
    for probI = 1:size(probCons, 2)
        idxT = find(eyeTrialData.prob(subN, :)==probCons(probI) & eyeTrialData.errorStatus(subN, :)==0);
        for slideI = 1:length(idxT)-trialBin
            slidingAP{subN}(probI, slideI) = nanmean(eyeTrialData.pursuit.AP(subN, idxT(slideI:(slideI+trialBin-1))));
            slidingOLP{subN}(probI, slideI) = nanmean(eyeTrialData.pursuit.initialMeanVelocity(subN, idxT(slideI:(slideI+trialBin-1)))); % open loop pursuit
            slidingCLP{subN}(probI, slideI) = nanmean(eyeTrialData.pursuit.closedLoopGain(subN, idxT(slideI:(slideI+trialBin-1)))); % close loop pursuit gain
        end
        
        idxT = find(eyeTrialData.prob(subN, :)==probCons(probI) & eyeTrialData.errorStatus(subN, :)==0 ...
            & abs(eyeTrialData.coh(subN, :))~=1);
        for slideI = 1:length(idxT)-trialBin
            slidingPercept{subN}(probI, slideI) = nanmean(eyeTrialData.choice(subN, idxT(slideI:(slideI+trialBin-1))));
        end
    end
    % individual plot
%         % AP
%         figure
%         for probI = 1:size(probCons, 2)
%             plot(slidingAP{subN}(probI, :))
%             hold on
%         end
%         legend({'50' '70' '90'}, 'box', 'off')
%         xlabel('Trial number')
%         ylabel('AP')
%         title(names{subN})
%         saveas(gca, ['slidingAP_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
%     
%         % OLP
%         figure
%         for probI = 1:size(probCons, 2)
%             plot(slidingOLP{subN}(probI, :))
%             hold on
%         end
%         legend({'50' '70' '90'}, 'box', 'off')
%         xlabel('Trial number')
%         ylabel('Open-loop pursuit mean velocity')
%         title(names{subN})
%         saveas(gca, ['slidingOLPmeanV_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
%     
    % CLP
    figure
    for probI = 1:size(probCons, 2)
        plot(slidingCLP{subN}(probI, :))
        hold on
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Trial number')
    ylabel('Closed-loop pursuit gain')
    title(names{subN})
    saveas(gca, ['slidingCLPgain_', names{subN}, '_bin', num2str(trialBin), '.pdf'])

% % Perception
%     figure
%     for probI = 1:size(probCons, 2)
%         plot(slidingPercept{subN}(probI, :))
%         hold on
%     end
%     legend({'50' '70' '90'}, 'box', 'off')
%     xlabel('Trial number')
%     ylabel('Probability of perceiving right')
%     title(names{subN})
%     saveas(gca, ['slidingPercept_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
end

%% sort trials by preceeding probability of right, plot AP
trialBin = 5; % window of trial numbers; needs to be smaller than 50 for now
clear precedeProbPercept precedeProb perceptProbR clpProbR olpProbR apProbR xProb yAP yOLP yCLP xProbPercept yPercept
for subN = 1:size(names, 2)
    probCons = unique(eyeTrialData.prob(subN, :));
%     precedeProb{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
%     apProbR{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
%     olpProbR{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
%     clpProbR{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
for probI = 1:size(probCons, 2)
    % eye movements
    idxT = find(eyeTrialData.prob(subN, :)==probCons(probI) & eyeTrialData.errorStatus(subN, :)==0 ...
        & ~isnan(eyeTrialData.pursuit.AP(subN, :)) & ~isnan(eyeTrialData.pursuit.closedLoopMeanVel(subN, :)) & abs(eyeTrialData.coh(subN, :))<1);
    % true preceding trials
    for slideI = 1:length(idxT)
        rightN = length(find(eyeTrialData.rdkDir(subN, (idxT(slideI)-trialBin):(idxT(slideI)-1))==1)); % counting on perceptual choice, true preceding trials
        precedeProb{subN}(probI, slideI) = rightN/trialBin;
        apProbR{subN}(probI, slideI) = eyeTrialData.pursuit.AP(subN, idxT(slideI));
        olpProbR{subN}(probI, slideI) = eyeTrialData.pursuit.initialMeanVelocity(subN, idxT(slideI));
        clpProbR{subN}(probI, slideI) = eyeTrialData.pursuit.closedLoopGain(subN, idxT(slideI));
        perceptProbR{subN}(probI, slideI) = eyeTrialData.choice(subN, idxT(slideI));
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
        plot(xProb{subN, probI}, yAP{subN, probI})
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
% %     % OLP
% %     figure
% %     for probI = 1:size(probCons, 2)
% %         %         subplot(1, 3, probI)
% %         plot(xProb{subN, probI}, yOLP{subN, probI})
% %         hold on
% %         %         xlim([0 1])
% %         %         ylim([-8 10])
% %     end
% %     legend({'50' '70' '90'}, 'box', 'off')
% %     xlabel('Preceded probability of right')
% %     ylabel('Open-loop pursuit mean velocity')
% %     title([names{subN}])
% %     %     end
% %     saveas(gca, ['precedeProbRight_OLPmeanV_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    
    % closed loop
    figure
    for probI = 1:size(probCons, 2)
        %         subplot(1, 3, probI)
        plot(xProb{subN, probI}, yCLP{subN, probI})
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
        plot(xProb{subN, probI}, yPercept{subN, probI})
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

%% sort trials by perceptual responses, plot AP and steady-state
% pursuit
for subN = 1:size(names, 2)
    probCons = unique(eyeTrialData.prob(subN, :));
    
    for probI = 1:size(probCons, 2)
        % low coherece trials perceived as moving to the right
        idxR = find(eyeTrialData.prob(subN, :)==probCons(probI) & eyeTrialData.errorStatus(subN, :)==0 ...
            & eyeTrialData.choice(subN, :)==1 & abs(eyeTrialData.coh(subN, :))<0.15);
        % low coherece trials perceived as moving to the left
        idxL = find(eyeTrialData.prob(subN, :)==probCons(probI) & eyeTrialData.errorStatus(subN, :)==0 ...
            & eyeTrialData.choice(subN, :)==0 & abs(eyeTrialData.coh(subN, :))<0.15);
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
    % individual plot
        % AP
        figure
        for probI = 1:size(probCons, 2)
            %         subplot(1, 3, probI)
            errorbar([-1 1], apChoice.mean{subN}(probI, :), apChoice.std{subN}(probI, :), '--o')
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
%             errorbar([-1 1], olpChoice.mean{subN}(probI, :), olpChoice.std{subN}(probI, :), '--o')
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
        errorbar([-1 1], clpChoice.mean{subN}(probI, :), clpChoice.std{subN}(probI, :), '--o')
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
