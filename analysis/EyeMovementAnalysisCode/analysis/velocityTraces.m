% plot velocity traces, generate csv file for plotting in R
clear all; close all; clc

names = {'XW0' 'p2'};
sampleRate = 1000;
% for plotting
minVel = [-12 -1];
maxVel = [5 12];
load(['eyeTrialDataLog_all.mat']);
% cd ..
folder = pwd;
probCons = [10 30 50 70 90];
dirCons = [-1 1]; % -1=left, 1=right
dirNames = {'left' 'right'};
colorPlotting = [255 0 0; 0 0 255; 255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability

%% align fixation offset, frame data for all trials
for subN = 1:size(names, 2)
    cd(folder)
    load(['eyeTrialData_' names{subN} '.mat']);
    frameLength(subN) = min(max(eyeTrialDataLog.frameLog.rdkOff(subN, :)), (900+300+700)/1000*sampleRate);
    lengthT = size(eyeTrialDataSub.trial, 2);
    frames{subN} = NaN(lengthT, frameLength(subN));
    
    for trialN = 1:lengthT        
        endI = eyeTrialDataLog.frameLog.rdkOff(subN, trialN);
        if endI>frameLength(subN)
            startI = endI-frameLength(subN)+1;
            startIF = 1;
        else
            startI = eyeTrialDataLog.frameLog.fixationOn(subN, trialN);
            startIF = frameLength(subN)-endI+1;
        end
        frames{subN}(trialN, startIF:end) = eyeTrialDataSub.trial{1, trialN}.DX_interpolSac(startI:endI);
    end
end
maxFrameLength = max(frameLength);

%% Draw velocity trace plots
cd ..
cd('velocityTraces')

% for each probability, draw the mean velocity trace
for probN = 3:size(probCons, 2)
    meanVel{probN}.leftStandard = NaN(length(names), maxFrameLength);
    meanVel{probN}.rightStandard = NaN(length(names), maxFrameLength);
    meanVel{probN}.leftPerceptual = NaN(length(names), maxFrameLength);
    meanVel{probN}.rightPerceptual = NaN(length(names), maxFrameLength);
%     stdVel{probN}.leftStandard = NaN(length(names), maxFrameLength);
%     stdVel{probN}.rightStandard = NaN(length(names), maxFrameLength);
%     stdVel{probN}.leftPerceptual = NaN(length(names), maxFrameLength);
%     stdVel{probN}.rightPerceptual = NaN(length(names), maxFrameLength);
    
    for subN = 1:size(names, 2)
        if find(eyeTrialDataLog.prob(subN, :)==probCons(probN))
            tempStartI = maxFrameLength-frameLength(subN)+1;
            leftSIdx = find(eyeTrialDataLog.rdkDir(subN, :)<0 & eyeTrialDataLog.prob(subN, :)==probCons(probN) & abs(eyeTrialDataLog.coh(subN, :))==1);
            rightSIdx = find(eyeTrialDataLog.rdkDir(subN, :)>0 & eyeTrialDataLog.prob(subN, :)==probCons(probN) & abs(eyeTrialDataLog.coh(subN, :))==1);
            leftPIdx = find(eyeTrialDataLog.rdkDir(subN, :)<0 & eyeTrialDataLog.prob(subN, :)==probCons(probN) & abs(eyeTrialDataLog.coh(subN, :))<1);
            rightPIdx = find(eyeTrialDataLog.rdkDir(subN, :)>0 & eyeTrialDataLog.prob(subN, :)==probCons(probN) & abs(eyeTrialDataLog.coh(subN, :))<1);
            
            meanVel{probN}.leftStandard(subN, tempStartI:end) = nanmean(frames{subN}(leftSIdx, :));
            meanVel{probN}.rightStandard(subN, tempStartI:end) = nanmean(frames{subN}(rightSIdx, :));
            meanVel{probN}.leftPerceptual(subN, tempStartI:end) = nanmean(frames{subN}(leftPIdx, :));
            meanVel{probN}.rightPerceptual(subN, tempStartI:end) = nanmean(frames{subN}(rightPIdx, :));
%             stdVel{probN}.firstStandard(subN, tempStartI:end) = nanstd(frames{subN, probN}.firstStandard);
%             stdVel{probN}.lastStandard(subN, tempStartI:end) = nanstd(frames{subN, probN}.lastStandard);
%             stdVel{probN}.firstPerceptual(subN, tempStartI:end) = nanstd(frames{subN, probN}.firstPerceptual);
%             stdVel{probN}.lastPerceptual(subN, tempStartI:end) = nanstd(frames{subN, probN}.lastPerceptual);
        end
    end
    
    % plotting parameters
    minFrameLength = min(frameLength);
    framePerSec = 1/sampleRate;
    timePoints = [(1:minFrameLength)-minFrameLength+0.7*sampleRate]*framePerSec*1000; % align at the rdk offset...
    % rdk onset is 0
    velMean{probN}.leftStandard = nanmean(meanVel{probN}.leftStandard(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probN}.rightStandard = nanmean(meanVel{probN}.rightStandard(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probN}.leftPerceptual = nanmean(meanVel{probN}.leftPerceptual(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probN}.rightPerceptual = nanmean(meanVel{probN}.rightPerceptual(:, (maxFrameLength-minFrameLength+1):end), 1);
        
%     for subN = 1:size(names, 2)
%         figure % plot individual mean traces
%         p1 = plot(timePoints, meanVel{probN}.leftStandard(subN, (maxFrameLength-minFrameLength+1):end), 'k');
%         hold on
%         plot(timePoints, meanVel{probN}.rightStandard(subN, (maxFrameLength-minFrameLength+1):end), 'k');
%         p2 = plot(timePoints, meanVel{probN}.leftPerceptual(subN, (maxFrameLength-minFrameLength+1):end), 'b');
%         plot(timePoints, meanVel{probN}.rightPerceptual(subN, (maxFrameLength-minFrameLength+1):end), 'b');
%         legend([p1, p2], {'standard', 'perceptual'}, 'Location', 'NorthWest')
%         title(['prob ', num2str(probCons(probN)), '%'])
%         xlim([-500 700])
%         xlabel('Time (ms)')
%         ylabel('Horizontal velocity (deg/s)')
%         %     ylim([-2 12])
%         saveas(gca, ['velocityTracesProb', num2str(probCons(probN)), '_', names{subN}, '.pdf'])
%     end
%     
%     figure % mean of participants
%     p1 = plot(timePoints, velMean{probN}.leftStandard, 'k', 'LineWidth', 1.5);
%     hold on
%     plot(timePoints, velMean{probN}.rightStandard, 'k', 'LineWidth', 1.5)
%     p2 = plot(timePoints, velMean{probN}.leftPerceptual, 'b', 'LineWidth', 1.5);
%     plot(timePoints, velMean{probN}.rightPerceptual, 'b', 'LineWidth', 1.5)
%     legend([p1, p2], {'standard', 'perceptual'}, 'Location', 'NorthWest')
% %     line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
% %     line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% %     line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
%     title(['prob ', num2str(probCons(probN)), '%'])
%     xlim([-500 700])
%     xlabel('Time (ms)')
%     ylabel('Horizontal velocity (deg/s)')
% %     ylim([-12 12])
%     box off
%     saveas(gca, ['velocityTracesProb', num2str(probCons(probN)), '_all.pdf'])
end

% plot mean traces in all probabilities for all participants
for subN = 1:size(names, 2)
    figure 
    subplot(2, 1, 1)
    for probN = 3:size(probCons, 2)
        plot(timePoints, meanVel{probN}.leftStandard(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorPlotting(probN, :)); %, 'LineWidth', 1)
        hold on
        p{probN} = plot(timePoints, meanVel{probN}.rightStandard(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorPlotting(probN, :)); %, 'LineWidth', 1);
    end
    % line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
    % line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
    % line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
    legend([p{3}, p{4}, p{5}], {'50', '70', '90'}, 'Location', 'NorthWest')
    title('standard trials')
    xlabel('Time (ms)')
    ylabel('Horizontal velocity (deg/s)')
    xlim([-500 700])
%     ylim([-12 12])
    box off
    
    subplot(2, 1, 2)
    for probN = 3:size(probCons, 2)
        plot(timePoints, meanVel{probN}.leftPerceptual(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorPlotting(probN, :)); %, 'LineWidth', 1)
        hold on
        p{probN} = plot(timePoints, meanVel{probN}.rightPerceptual(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorPlotting(probN, :)); %, 'LineWidth', 1);
    end
    % line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
    % line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
    % line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
    legend([p{3}, p{4}, p{5}], {'50', '70', '90'}, 'Location', 'NorthWest')
    title('perceptual trials')
    xlabel('Time (ms)')
    ylabel('Horizontal velocity (deg/s)')
    xlim([-500 700])
%     ylim([-4 5])
    box off
    saveas(gca, ['velocityAllProbs_' names{subN} '.pdf'])
end

figure % plot mean traces in all probabilities for all participants
subplot(2, 1, 1)
for probN = 3:size(probCons, 2)
    plot(timePoints, velMean{probN}.leftStandard, 'color', colorPlotting(probN, :)); %, 'LineWidth', 1)
    hold on
    p{probN} = plot(timePoints, velMean{probN}.rightStandard, 'color', colorPlotting(probN, :)); %, 'LineWidth', 1);
end
% line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
% line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
legend([p{3}, p{4}, p{5}], {'50', '70', '90'}, 'Location', 'NorthWest')
title('standard trials')
xlabel('Time (ms)')
ylabel('Horizontal velocity (deg/s)')
xlim([-500 700])
ylim([-12 12])
box off

subplot(2, 1, 2)
for probN = 3:size(probCons, 2)
    plot(timePoints, velMean{probN}.leftPerceptual, 'color', colorPlotting(probN, :)); %, 'LineWidth', 1)
    hold on
    p{probN} = plot(timePoints, velMean{probN}.rightPerceptual, 'color', colorPlotting(probN, :)); %, 'LineWidth', 1);
end
% line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
% line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
legend([p{3}, p{4}, p{5}], {'50', '70', '90'}, 'Location', 'NorthWest')
title('perceptual trials')
xlabel('Time (ms)')
ylabel('Horizontal velocity (deg/s)')
xlim([-500 700])
ylim([-4 5])
box off
saveas(gca, ['velocityAllProbs_all.pdf'])
%%

% % generate csv files, each file for one probability condition
% % each row is the mean velocity trace of one participant
% % use the min frame length--the lengeth where all participants have
% % valid data points
% for speedI = 1:size(conditions, 2)
%     idxN = [];
%     % find the min frame length in each condition
%     for subN = 1:size(names, 2)
%         tempI = find(~isnan(velTAverage{speedI}(subN, :)));
%         idxN(subN) = tempI(1);
%     end
%     startIdx(speedI) = max(idxN);
% end
%
% startI = max(startIdx);
% velTAverageSub = [];
% cd('C:\Users\CaptainS5\Documents\PhD@UBC\Lab\1st year\TorsionPerception\analysis')
% for speedI = 1:size(conditions, 2)
%     for subN = 1:size(names, 2)
%         velTAverageSub(subN, :) = velTAverage{speedI}(subN, startI:end);
%     end
%     csvwrite(['velocityTraceExp2_bothEye_', num2str(conditions(speedI)), '.csv'], velTAverageSub)
% end