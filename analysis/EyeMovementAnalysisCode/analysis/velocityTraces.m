% plot velocity traces, generate csv file for plotting in R
initializeParas;

% for plotting
yStandardRange = [-12 12];
yPerceptRange = [-7 7];

%% align fixation offset, frame data for all trials
for subN = 1:size(names, 2)
    cd(analysisFolder)
    load(['eyeTrialDataSub_' names{subN} '.mat']);
    frameLength(subN) = min(max(eyeTrialData.frameLog.rdkOff(subN, :)), (900+300+700)/1000*sampleRate);
    lengthT = size(eyeTrialDataSub.trial, 2);
    frames{subN} = NaN(lengthT, frameLength(subN));
    
    for trialN = 1:lengthT        
        endI = eyeTrialData.frameLog.rdkOff(subN, trialN);
        if endI>frameLength(subN)
            startI = endI-frameLength(subN)+1;
            startIF = 1;
        else
            startI = eyeTrialData.frameLog.fixationOn(subN, trialN);
            startIF = frameLength(subN)-endI+1;
        end
        frames{subN}(trialN, startIF:end) = eyeTrialDataSub.trial{1, trialN}.DX_interpolSac(startI:endI);
    end
end
maxFrameLength = max(frameLength);

%% Draw velocity trace plots
cd(velTraceFolder)
% for each probability, draw the mean velocity trace
for probN = 1:size(probCons, 2)
    % first initialize; if a participant doesn't have the corresponding
    % prob condition, then the values remain NaN and will be ignored later
    meanVel{probN}.leftStandard = NaN(length(names), maxFrameLength);
    meanVel{probN}.rightStandard = NaN(length(names), maxFrameLength);
    meanVel{probN}.leftPerceptual = NaN(length(names), maxFrameLength);
    meanVel{probN}.rightPerceptual = NaN(length(names), maxFrameLength);
%     stdVel{probN}.leftStandard = NaN(length(names), maxFrameLength);
%     stdVel{probN}.rightStandard = NaN(length(names), maxFrameLength);
%     stdVel{probN}.leftPerceptual = NaN(length(names), maxFrameLength);
%     stdVel{probN}.rightPerceptual = NaN(length(names), maxFrameLength);
    for subN = 1:size(names, 2)
        if ~isempty(find(eyeTrialData.prob(subN, :)==probCons(probN)))
            tempStartI = maxFrameLength-frameLength(subN)+1;
            leftSIdx = find(eyeTrialData.rdkDir(subN, :)<0 & eyeTrialData.prob(subN, :)==probCons(probN) & abs(eyeTrialData.coh(subN, :))==1);
            rightSIdx = find(eyeTrialData.rdkDir(subN, :)>0 & eyeTrialData.prob(subN, :)==probCons(probN) & abs(eyeTrialData.coh(subN, :))==1);
            leftPIdx = find(eyeTrialData.rdkDir(subN, :)<0 & eyeTrialData.prob(subN, :)==probCons(probN) & abs(eyeTrialData.coh(subN, :))<1);
            rightPIdx = find(eyeTrialData.rdkDir(subN, :)>0 & eyeTrialData.prob(subN, :)==probCons(probN) & abs(eyeTrialData.coh(subN, :))<1);
            
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
end

% plot mean traces in all probabilities for each participant
for subN = 1:size(names, 2)
    probSub = unique(eyeTrialData.prob(subN, :));
    if probSub(1)<50
        probNameI = 1;
    else
        probNameI = 2;
    end
    
    figure 
    subplot(2, 1, 1)
    for probSubN = 1:size(probSub, 2)
        probN = find(probCons==probSub(probSubN));
        plot(timePoints, meanVel{probN}.leftStandard(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorPlotting(probN, :)); %, 'LineWidth', 1)
        hold on
        p{probSubN} = plot(timePoints, meanVel{probN}.rightStandard(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorPlotting(probN, :)); %, 'LineWidth', 1);
    end
    % line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
    % line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
    % line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
    legend([p{1}, p{2}, p{3}], probNames{probNameI}, 'Location', 'NorthWest')
    title('standard trials')
    xlabel('Time (ms)')
    ylabel('Horizontal velocity (deg/s)')
    xlim([-500 700])
    ylim(yStandardRange)
    box off
    
    subplot(2, 1, 2)
    for probSubN = 1:size(probSub, 2)
        probN = find(probCons==probSub(probSubN));
        plot(timePoints, meanVel{probN}.leftPerceptual(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorPlotting(probN, :)); %, 'LineWidth', 1)
        hold on
        p{probSubN} = plot(timePoints, meanVel{probN}.rightPerceptual(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorPlotting(probN, :)); %, 'LineWidth', 1);
    end
    % line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
    % line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
    % line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
    legend([p{1}, p{2}, p{3}], probNames{probNameI}, 'Location', 'NorthWest')
    title('perceptual trials')
    xlabel('Time (ms)')
    ylabel('Horizontal velocity (deg/s)')
    xlim([-500 700])
    ylim(yPerceptRange)
    box off
    saveas(gca, ['velocityAllProbs_' names{subN} '.pdf'])
end

figure % plot mean traces of all participants in all probabilities 
subplot(2, 1, 1)
for probN = 1:size(probCons, 2)
    plot(timePoints, velMean{probN}.leftStandard, 'color', colorPlotting(probN, :)); %, 'LineWidth', 1)
    hold on
    p{probN} = plot(timePoints, velMean{probN}.rightStandard, 'color', colorPlotting(probN, :)); %, 'LineWidth', 1);
end
% line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
% line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
legend([p{1}, p{2}, p{3}, p{4}, p{5}], {'10', '30', '50', '70', '90'}, 'Location', 'NorthWest')
title('standard trials')
xlabel('Time (ms)')
ylabel('Horizontal velocity (deg/s)')
xlim([-500 700])
ylim(yStandardRange)
box off

subplot(2, 1, 2)
for probN = 1:size(probCons, 2)
    plot(timePoints, velMean{probN}.leftPerceptual, 'color', colorPlotting(probN, :)); %, 'LineWidth', 1)
    hold on
    p{probN} = plot(timePoints, velMean{probN}.rightPerceptual, 'color', colorPlotting(probN, :)); %, 'LineWidth', 1);
end
% line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
% line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
legend([p{1}, p{2}, p{3}, p{4}, p{5}], {'10', '30', '50', '70', '90'}, 'Location', 'NorthWest')
title('perceptual trials')
xlabel('Time (ms)')
ylabel('Horizontal velocity (deg/s)')
xlim([-500 700])
ylim(yPerceptRange)
box off
saveas(gca, ['velocityAllProbs_all.pdf'])

%% generate csv files, each file for one probability condition
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