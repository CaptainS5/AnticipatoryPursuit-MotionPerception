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

dirCons = [-1 1]; % -1=left, 1=right
dirNames = {'left' 'right'};
colorPlotting = [255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability

%% align fixation offset, frame data for all trials
for subN = 1:size(names, 2)
    cd(folder)
    load(['eyeTrialData_' names{subN} '.mat']);
    frameLength(subN) = min(max(eyeTrialDataLog.frameLog.rdkOff(subN, :)), (900+300+700)/1000*sampleRate);
    lengthT = size(eyeTrialData.trial, 2);
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
        frames{subN}(trialN, startIF:end) = eyeTrialData.trial{1, trialN}.DX_interpolSac(startI:endI);
    end
end
maxFrameLength = max(frameLength);

%% Draw velocity trace plots
cd ..
cd('velocityTraces')

% for each probability, draw the mean velocity trace
for probN = 1:size(probCons, 2)
    meanVel{probN}.leftStandard = NaN(length(names), maxFrameLength);
    meanVel{probN}.rightStandard = NaN(length(names), maxFrameLength);
    meanVel{probN}.leftPerceptual = NaN(length(names), maxFrameLength);
    meanVel{probN}.rightPerceptual = NaN(length(names), maxFrameLength);
    stdVel{probN}.leftStandard = NaN(length(names), maxFrameLength);
    stdVel{probN}.rightStandard = NaN(length(names), maxFrameLength);
    stdVel{probN}.leftPerceptual = NaN(length(names), maxFrameLength);
    stdVel{probN}.rightPerceptual = NaN(length(names), maxFrameLength);
    
    for subN = 1:size(names, 2)
        tempStartI = maxFrameLength-frameLength(subN)+1;
        meanVel{probN}.firstStandard(subN, tempStartI:end) = nanmean(frames{subN, probN}.firstStandard);
        meanVel{probN}.lastStandard(subN, tempStartI:end) = nanmean(frames{subN, probN}.lastStandard);
        meanVel{probN}.firstPerceptual(subN, tempStartI:end) = nanmean(frames{subN, probN}.firstPerceptual);
        meanVel{probN}.lastPerceptual(subN, tempStartI:end) = nanmean(frames{subN, probN}.lastPerceptual);
        stdVel{probN}.firstStandard(subN, tempStartI:end) = nanstd(frames{subN, probN}.firstStandard);
        stdVel{probN}.lastStandard(subN, tempStartI:end) = nanstd(frames{subN, probN}.lastStandard);
        stdVel{probN}.firstPerceptual(subN, tempStartI:end) = nanstd(frames{subN, probN}.firstPerceptual);
        stdVel{probN}.lastPerceptual(subN, tempStartI:end) = nanstd(frames{subN, probN}.lastPerceptual);
    end
    
    % plotting parameters
    minFrameLength = min(frameLength);
    framePerSec = 1/sampleRate;
    timePoints = [(1:minFrameLength)-minFrameLength+0.7*sampleRate]*framePerSec*1000; % align at the rdk offset...
    % rdk onset is 0
    velMean{probN}.firstStandard = nanmean(meanVel{probN}.firstStandard(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probN}.lastStandard = nanmean(meanVel{probN}.lastStandard(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probN}.firstPerceptual = nanmean(meanVel{probN}.firstPerceptual(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probN}.lastPerceptual = nanmean(meanVel{probN}.lastPerceptual(:, (maxFrameLength-minFrameLength+1):end), 1);
    
    %     figure % plot individual mean traces
    %     for subN = 1:size(names, 2)
    %         plot(timePoints, meanVel{probN}.firstStandard(subN, (maxFrameLength-minFrameLength+1):end))
    %         hold on
    %     end
    %     title(['prob ', num2str(probCons(probN)), '%'])
    %     xlabel('Time (ms)')
    %     ylabel('Horizontal velocity (deg/s)')
    %     ylim([-2 12])
    
    figure
    plot(timePoints, velMean{probN}.firstStandard, 'k--')
    hold on
    plot(timePoints, velMean{probN}.lastStandard, 'k')
    plot(timePoints, velMean{probN}.firstPerceptual, 'b--')
    plot(timePoints, velMean{probN}.lastPerceptual, 'b')
    legend({'first half standard', 'last half standard', 'first half perceptual', 'last half perceptual'}, 'Location', 'NorthWest')
    line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
    line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
    line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
    title(['prob ', num2str(probCons(probN)), '%'])
    xlabel('Time (ms)')
    ylabel('Horizontal velocity (deg/s)')
    ylim([minVel(dirN) maxVel(dirN)])
    box off
    saveas(gca, ['velocityTracesProb', num2str(probCons(probN)), '_', dirNames{dirN}, 'Trials_', names{subN}, '.pdf'])
end

figure % plot mean traces in all probabilities, just a rough check...
subplot(2, 1, 1)
for probN = 1:size(probCons, 2)
    plot(timePoints, velMean{probN}.firstStandard, '--', 'color', colorPlotting(probN, :))
    hold on
    p{probN} = plot(timePoints, velMean{probN}.lastStandard, '-', 'color', colorPlotting(probN, :));
end
line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
legend([p{1}, p{2}, p{3}], {'50', '70', '90'}, 'Location', 'NorthWest')
title('standard trials')
xlabel('Time (ms)')
ylabel('Horizontal velocity (deg/s)')
xlim([-1000 700])
ylim([minVel(dirN) maxVel(dirN)])
box off

subplot(2, 1, 2)
for probN = 1:size(probCons, 2)
    plot(timePoints, velMean{probN}.firstPerceptual, '--', 'color', colorPlotting(probN, :))
    hold on
    p{probN} = plot(timePoints, velMean{probN}.lastPerceptual, '-', 'color', colorPlotting(probN, :));
end
line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
legend([p{1}, p{2}, p{3}], {'50', '70', '90'}, 'Location', 'NorthWest')
title('perceptual trials')
xlabel('Time (ms)')
ylabel('Horizontal velocity (deg/s)')
xlim([-1000 700])
ylim([minVel(dirN) maxVel(dirN)])
box off
saveas(gca, [dirNames{dirN}, 'Trials_velocity_', names{subN}, '.pdf'])
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