% plot velocity traces, generate csv file for plotting in R
clear all; close all; clc

<<<<<<< HEAD
names = {'YZ'};
=======
names = {'tW'};
>>>>>>> parent of 02672d1... improve saccade...
sampleRate = 1000;
% for plotting
minVel = -10;%-1;
maxVel = 2;%12;
folder = pwd;

cd(folder)
% load('eyeDataAll.mat');
motionType{1} = load('eyeData_tW.mat'); % transparent motion
motionType{2} = load('eyeData_t2.mat'); % brownian motion
probCons = unique(motionType{1}.eyeTrialData.prob);
colorPlotting = [255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability

<<<<<<< HEAD
%% compare first and second half of the trials
% align fixation offset,
% separate perceptual and standard trials
for dirN = 1:size(dirCons, 2)
    for subN = 1:size(names, 2)
        cd(folder)
        load(['eyeData_' names{subN} '.mat']);
        probCons = unique(eyeTrialData.prob(eyeTrialData.errorStatus==0));
        %     maxFrames = max(eyeTrialData.frameLog.rdkOff(subN, :));
        frameLength(subN) = min(max(eyeTrialData.frameLog.rdkOff(subN, :)), (900+300+700)/1000*sampleRate);
        
        for probN = 1:size(probCons, 2)
            validI = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==1 & eyeTrialData.rdkDir(subN, :)==dirCons(dirN) & eyeTrialData.prob(subN, :)==probCons(probN));
            lengthF = round(length(validI)/2); % first half of the trials
            lengthL = length(validI)-lengthF; % last half of the trials
            frames{subN, probN}.firstStandard = NaN(lengthF, frameLength(subN)); % align the reversal; filled with NaN
            frames{subN, probN}.lastStandard = NaN(lengthL, frameLength(subN)); % align the reversal; filled with NaN
            % rows are trials, columns are frames
            
            % first half standard trials, fill in the velocity trace of each frame
            % use interpolate points for a better velocity trace
            for validTrialN = 1:lengthF
                endI = eyeTrialData.frameLog.rdkOff(subN, validI(validTrialN));
                if endI>frameLength(subN)
                    startI = endI-frameLength(subN)+1;
                    startIF = 1;
                else
                    startI = eyeTrialData.frameLog.fixationOn(subN, validI(validTrialN));
                    startIF = frameLength(subN)-endI+1;
                end
                frames{subN, probN}.firstStandard(validTrialN, startIF:end) = eyeTrialData.trial{subN, validI(validTrialN)}.DX_interpolSac(startI:endI);
            end
            
            % last half standard trials
            for validTrialN = 1:lengthL
                endI = eyeTrialData.frameLog.rdkOff(subN, validI(validTrialN+lengthF));
                if endI>frameLength(subN)
                    startI = endI-frameLength(subN)+1;
                    startIF = 1;
                else
                    startI = eyeTrialData.frameLog.fixationOn(subN, validI(validTrialN+lengthF));
                    startIF = frameLength(subN)-endI+1;
                end
                frames{subN, probN}.lastStandard(validTrialN, startIF:end) = eyeTrialData.trial{subN, validI(validTrialN+lengthF)}.DX_interpolSac(startI:endI);
            end
            
            % then perceptual trials
            validI = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.rdkDir(subN, :)==dirCons(dirN) & eyeTrialData.prob(subN, :)==probCons(probN));
            lengthF = round(length(validI)/2); % first half of the trials
            lengthL = length(validI)-lengthF; % last half of the trials
            frames{subN, probN}.firstPerceptual = NaN(lengthF, frameLength(subN)); % align the reversal; filled with NaN
            frames{subN, probN}.lastPerceptual = NaN(lengthL, frameLength(subN)); % align the reversal; filled with NaN
            % rows are trials, columns are frames
            
            % first half standard trials, fill in the velocity trace of each frame
            % use interpolate points for a better velocity trace
            for validTrialN = 1:lengthF
                endI = eyeTrialData.frameLog.rdkOff(subN, validI(validTrialN));
                if endI>frameLength(subN)
                    startI = endI-frameLength(subN)+1;
                    startIF = 1;
                else
                    startI = eyeTrialData.frameLog.fixationOn(subN, validI(validTrialN));
                    startIF = frameLength(subN)-endI+1;
                end
                frames{subN, probN}.firstPerceptual(validTrialN, startIF:end) = eyeTrialData.trial{subN, validI(validTrialN)}.DX_interpolSac(startI:endI);
            end
            
            % last half standard trials
            for validTrialN = 1:lengthL
                endI = eyeTrialData.frameLog.rdkOff(subN, validI(validTrialN+lengthF));
                if endI>frameLength(subN)
                    startI = endI-frameLength(subN)+1;
                    startIF = 1;
                else
                    startI = eyeTrialData.frameLog.fixationOn(subN, validI(validTrialN+lengthF));
                    startIF = frameLength(subN)-endI+1;
                end
                frames{subN, probN}.lastPerceptual(validTrialN, startIF:end) = eyeTrialData.trial{subN, validI(validTrialN+lengthF)}.DX_interpolSac(startI:endI);
            end
            
        end
    end
    maxFrameLength = max(frameLength);
    
    % for each probability, draw the mean velocity trace
=======
%% compare noise type and different probabilities
% align fixation offset, separate standard and perceptual trials
for motionN = 1:size(motionType, 2)
    %     maxFrames = max(eyeTrialData.frameLog.rdkOff(subN, :));
    frameLength(motionN) = min(max(motionType{motionN}.eyeTrialData.frameLog.rdkOff), (900+300+700)/1000*sampleRate);

>>>>>>> parent of 02672d1... improve saccade...
    for probN = 1:size(probCons, 2)
        % standard trials
        validI = find(motionType{motionN}.eyeTrialData.errorStatus~=1 & ...
            motionType{motionN}.eyeTrialData.trialType==1 & ...
            motionType{motionN}.eyeTrialData.rdkDir==-1 & ...
            motionType{motionN}.eyeTrialData.prob==probCons(probN));
        lengthT = length(validI); 
        frames{motionN, probN}.standard = NaN(lengthT, frameLength(motionN)); % align the reversal; filled with NaN
        % rows are trials, columns are frames
        
        % fill in the velocity trace of each frame
        % use interpolate points for a better velocity trace
        for validTrialN = 1:lengthT
            endI = motionType{motionN}.eyeTrialData.frameLog.rdkOff(1, validI(validTrialN));
            if endI>frameLength(motionN)
                startI = endI-frameLength(motionN)+1;
                startIF = 1;
            else
                startI = motionType{motionN}.eyeTrialData.frameLog.fixationOn(1, validI(validTrialN));
                startIF = frameLength(motionN)-endI+1;
            end
            frames{motionN, probN}.standard(validTrialN, startIF:end) = motionType{motionN}.eyeTrialData.trial{1, validI(validTrialN)}.DX_interpolSac(startI:endI);
        end
        
        % then perceptual trials
        validI = find(motionType{motionN}.eyeTrialData.errorStatus~=1 & ...
            motionType{motionN}.eyeTrialData.trialType==0 & ...
            motionType{motionN}.eyeTrialData.rdkDir==-1 & ...
            motionType{motionN}.eyeTrialData.prob==probCons(probN));
        lengthT = length(validI); 
        frames{motionN, probN}.perceptual = NaN(lengthT, frameLength(motionN)); % align the reversal; filled with NaN
        % rows are trials, columns are frames
        
        % fill in the velocity trace of each frame
        % use interpolate points for a better velocity trace
        for validTrialN = 1:lengthT
            endI = motionType{motionN}.eyeTrialData.frameLog.rdkOff(1, validI(validTrialN));
            if endI>frameLength(motionN)
                startI = endI-frameLength(motionN)+1;
                startIF = 1;
            else
                startI = motionType{motionN}.eyeTrialData.frameLog.fixationOn(1, validI(validTrialN));
                startIF = frameLength(motionN)-endI+1;
            end
            frames{motionN, probN}.perceptual(validTrialN, startIF:end) = motionType{motionN}.eyeTrialData.trial{1, validI(validTrialN)}.DX_interpolSac(startI:endI);
        end        
    end    
end
maxFrameLength = max(frameLength);

% for each probability, draw the mean velocity trace
for probN = 1:size(probCons, 2)
    meanVel{probN}.standard = NaN(size(motionType, 2), maxFrameLength);
    meanVel{probN}.perceptual = NaN(size(motionType, 2), maxFrameLength);
    stdVel{probN}.standard = NaN(size(motionType, 2), maxFrameLength);
    stdVel{probN}.perceptual = NaN(size(motionType, 2), maxFrameLength);
    
<<<<<<< HEAD
    figure % plot mean traces in all probabilities, just a rough check...
    subplot(2, 1, 1)
    for probN = 1:size(probCons, 2)
        plot(timePoints, velMean{probN}.firstStandard, '--', 'color', colorPlotting(probN, :))
        hold on
        p{probN} = plot(timePoints, velMean{probN}.lastStandard, '-', 'color', colorPlotting(probN, :));
=======
    for motionN = 1:size(motionType, 2)
        tempStartI = maxFrameLength-frameLength(motionN)+1;
        meanVel{probN}.standard(motionN, tempStartI:end) = nanmean(frames{motionN, probN}.standard);
        meanVel{probN}.perceptual(motionN, tempStartI:end) = nanmean(frames{motionN, probN}.perceptual);
        stdVel{probN}.standard(motionN, tempStartI:end) = nanstd(frames{motionN, probN}.standard);
        stdVel{probN}.perceptual(motionN, tempStartI:end) = nanstd(frames{motionN, probN}.perceptual);
>>>>>>> parent of 02672d1... improve saccade...
    end
    
<<<<<<< HEAD
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
=======
    % plotting parameters
    minFrameLength = min(frameLength);
    framePerSec = 1/sampleRate;
    timePoints = [(1:minFrameLength)-minFrameLength+0.7*sampleRate]*framePerSec*1000; % align at the rdk offset...
%     % rdk onset is 0
%     velMean{probN}.firstStandard = nanmean(meanVel{probN}.firstStandard(:, (maxFrameLength-minFrameLength+1):end), 1);
%     velMean{probN}.lastStandard = nanmean(meanVel{probN}.lastStandard(:, (maxFrameLength-minFrameLength+1):end), 1);
%     velMean{probN}.firstPerceptual = nanmean(meanVel{probN}.firstPerceptual(:, (maxFrameLength-minFrameLength+1):end), 1);
%     velMean{probN}.lastPerceptual = nanmean(meanVel{probN}.lastPerceptual(:, (maxFrameLength-minFrameLength+1):end), 1);
>>>>>>> parent of 02672d1... improve saccade...
end

figure % plot mean traces
subplot(2, 1, 1)
 for probN = 1:size(probCons, 2)
     plot(timePoints, meanVel{probN}.standard(1, :), '--', 'color', colorPlotting(probN, :))
     hold on
     plot(timePoints, meanVel{probN}.standard(2, :), '-', 'color', colorPlotting(probN, :))
 end
 line([-300 -300], [minVel maxVel],'Color','m','LineStyle','--')
 legend({'transparent-50', 'brownian-50', 'transparent-70', ...
     'brownian-70', 'transparent-90', 'brownian-90'}, 'Location', 'SouthWest')
 title('standard trials')
 xlabel('Time (ms)')
 ylabel('Horizontal velocity (deg/s)')
 ylim([minVel maxVel])
 
 subplot(2, 1, 2)
 for probN = 1:size(probCons, 2)
     plot(timePoints, meanVel{probN}.perceptual(1, :), '--', 'color', colorPlotting(probN, :))
     hold on
     plot(timePoints, meanVel{probN}.perceptual(2, :), '-', 'color', colorPlotting(probN, :))
 end
 line([-300 -300], [minVel maxVel],'Color','m','LineStyle','--')
%  legend([p{1}, p{2}, p{3}], {'50', '70', '90'}, 'Location', 'NorthWest')
 title('perceptual trials')
 xlabel('Time (ms)')
 ylabel('Horizontal velocity (deg/s)')
 ylim([minVel maxVel])
 saveas(gca, ['leftwardTrials_velocity_motionTypes.pdf'])

%% compare first and second half of the trials
% % align fixation offset,
% % separate perceptual and standard trials
% for subN = 1:size(names, 2)
%     %     maxFrames = max(eyeTrialData.frameLog.rdkOff(subN, :));
%     frameLength(subN) = min(max(eyeTrialData.frameLog.rdkOff(subN, :)), (900+300+700)/1000*sampleRate);
% 
%     for probN = 1:size(probCons, 2)
%         validI = find(eyeTrialData.errorStatus(subN, :)~=1 & eyeTrialData.trialType(subN, :)==1 & eyeTrialData.rdkDir(subN, :)==1 & eyeTrialData.prob(subN, :)==probCons(probN));
%         lengthF = round(length(validI)/2); % first half of the trials
%         lengthL = length(validI)-lengthF; % last half of the trials
%         frames{subN, probN}.firstStandard = NaN(lengthF, frameLength(subN)); % align the reversal; filled with NaN
%         frames{subN, probN}.lastStandard = NaN(lengthL, frameLength(subN)); % align the reversal; filled with NaN
%         % rows are trials, columns are frames
%         
%         % first half standard trials, fill in the velocity trace of each frame
%         % use interpolate points for a better velocity trace
%         for validTrialN = 1:lengthF
%             endI = eyeTrialData.frameLog.rdkOff(subN, validI(validTrialN));
%             if endI>frameLength(subN)
%                 startI = endI-frameLength(subN)+1;
%                 startIF = 1;
%             else
%                 startI = eyeTrialData.frameLog.fixationOn(subN, validI(validTrialN));
%                 startIF = frameLength(subN)-endI+1;
%             end
%             frames{subN, probN}.firstStandard(validTrialN, startIF:end) = eyeTrialData.trial{subN, validI(validTrialN)}.DX_interpolSac(startI:endI);
%         end
%         
%         % last half standard trials
%         for validTrialN = 1:lengthL
%             endI = eyeTrialData.frameLog.rdkOff(subN, validI(validTrialN+lengthF));
%             if endI>frameLength(subN)
%                 startI = endI-frameLength(subN)+1;
%                 startIF = 1;
%             else
%                 startI = eyeTrialData.frameLog.fixationOn(subN, validI(validTrialN+lengthF));
%                 startIF = frameLength(subN)-endI+1;
%             end
%             frames{subN, probN}.lastStandard(validTrialN, startIF:end) = eyeTrialData.trial{subN, validI(validTrialN+lengthF)}.DX_interpolSac(startI:endI);
%         end
%         
%         % then perceptual trials
%         validI = find(eyeTrialData.errorStatus(subN, :)~=1 & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.rdkDir(subN, :)==1 & eyeTrialData.prob(subN, :)==probCons(probN));
%         lengthF = round(length(validI)/2); % first half of the trials
%         lengthL = length(validI)-lengthF; % last half of the trials
%         frames{subN, probN}.firstPerceptual = NaN(lengthF, frameLength(subN)); % align the reversal; filled with NaN
%         frames{subN, probN}.lastPerceptual = NaN(lengthL, frameLength(subN)); % align the reversal; filled with NaN
%         % rows are trials, columns are frames
%         
%         % first half standard trials, fill in the velocity trace of each frame
%         % use interpolate points for a better velocity trace
%         for validTrialN = 1:lengthF
%             endI = eyeTrialData.frameLog.rdkOff(subN, validI(validTrialN));
%             if endI>frameLength(subN)
%                 startI = endI-frameLength(subN)+1;
%                 startIF = 1;
%             else
%                 startI = eyeTrialData.frameLog.fixationOn(subN, validI(validTrialN));
%                 startIF = frameLength(subN)-endI+1;
%             end
%             frames{subN, probN}.firstPerceptual(validTrialN, startIF:end) = eyeTrialData.trial{subN, validI(validTrialN)}.DX_interpolSac(startI:endI);
%         end
%         
%         % last half standard trials
%         for validTrialN = 1:lengthL
%             endI = eyeTrialData.frameLog.rdkOff(subN, validI(validTrialN+lengthF));
%             if endI>frameLength(subN)
%                 startI = endI-frameLength(subN)+1;
%                 startIF = 1;
%             else
%                 startI = eyeTrialData.frameLog.fixationOn(subN, validI(validTrialN+lengthF));
%                 startIF = frameLength(subN)-endI+1;
%             end
%             frames{subN, probN}.lastPerceptual(validTrialN, startIF:end) = eyeTrialData.trial{subN, validI(validTrialN+lengthF)}.DX_interpolSac(startI:endI);
%         end
%         
%     end
% end
% maxFrameLength = max(frameLength);
% 
% % for each probability, draw the mean velocity trace
% for probN = 1:size(probCons, 2)
%     meanVel{probN}.firstStandard = NaN(length(names), maxFrameLength);
%     meanVel{probN}.lastStandard = NaN(length(names), maxFrameLength);
%     meanVel{probN}.firstPerceptual = NaN(length(names), maxFrameLength);
%     meanVel{probN}.lastPerceptual = NaN(length(names), maxFrameLength);
%     stdVel{probN}.firstStandard = NaN(length(names), maxFrameLength);
%     stdVel{probN}.lastStandard = NaN(length(names), maxFrameLength);
%     stdVel{probN}.firstPerceptual = NaN(length(names), maxFrameLength);
%     stdVel{probN}.lastPerceptual = NaN(length(names), maxFrameLength);
%     
%     for subN = 1:size(names, 2)
%         tempStartI = maxFrameLength-frameLength(subN)+1;
%         meanVel{probN}.firstStandard(subN, tempStartI:end) = nanmean(frames{subN, probN}.firstStandard);
%         meanVel{probN}.lastStandard(subN, tempStartI:end) = nanmean(frames{subN, probN}.lastStandard);
%         meanVel{probN}.firstPerceptual(subN, tempStartI:end) = nanmean(frames{subN, probN}.firstPerceptual);
%         meanVel{probN}.lastPerceptual(subN, tempStartI:end) = nanmean(frames{subN, probN}.lastPerceptual);
%         stdVel{probN}.firstStandard(subN, tempStartI:end) = nanstd(frames{subN, probN}.firstStandard);
%         stdVel{probN}.lastStandard(subN, tempStartI:end) = nanstd(frames{subN, probN}.lastStandard);
%         stdVel{probN}.firstPerceptual(subN, tempStartI:end) = nanstd(frames{subN, probN}.firstPerceptual);
%         stdVel{probN}.lastPerceptual(subN, tempStartI:end) = nanstd(frames{subN, probN}.lastPerceptual);
%     end
%     
%     % plotting parameters
%     minFrameLength = min(frameLength);
%     framePerSec = 1/sampleRate;
%     timePoints = [(1:minFrameLength)-minFrameLength+0.7*sampleRate]*framePerSec*1000; % align at the rdk offset...
%     % rdk onset is 0
%     velMean{probN}.firstStandard = nanmean(meanVel{probN}.firstStandard(:, (maxFrameLength-minFrameLength+1):end), 1);
%     velMean{probN}.lastStandard = nanmean(meanVel{probN}.lastStandard(:, (maxFrameLength-minFrameLength+1):end), 1);
%     velMean{probN}.firstPerceptual = nanmean(meanVel{probN}.firstPerceptual(:, (maxFrameLength-minFrameLength+1):end), 1);
%     velMean{probN}.lastPerceptual = nanmean(meanVel{probN}.lastPerceptual(:, (maxFrameLength-minFrameLength+1):end), 1);
%     
% %     figure % plot individual mean traces
% %     for subN = 1:size(names, 2)
% %         plot(timePoints, meanVel{probN}.firstStandard(subN, (maxFrameLength-minFrameLength+1):end))
% %         hold on
% %     end
% %     title(['prob ', num2str(probCons(probN)), '%'])
% %     xlabel('Time (ms)')
% %     ylabel('Horizontal velocity (deg/s)')
% %     ylim([-2 12])
% 
% figure
%     plot(timePoints, velMean{probN}.firstStandard, 'k--')
%     hold on
%     plot(timePoints, velMean{probN}.lastStandard, 'k')
%     plot(timePoints, velMean{probN}.firstPerceptual, 'b--')
%     plot(timePoints, velMean{probN}.lastPerceptual, 'b')
%     legend({'first half standard', 'last half standard', 'first half perceptual', 'last half perceptual'}, 'Location', 'NorthWest')
%     line([-300 -300], [minVel maxVel],'Color','m','LineStyle','--')
%     title(['prob ', num2str(probCons(probN)), '%'])
%     xlabel('Time (ms)')
%     ylabel('Horizontal velocity (deg/s)')
%     ylim([minVel maxVel])
%     saveas(gca, ['velocityTracesProb', num2str(probCons(probN)), '_rightwardTrials_', names{subN}, '.pdf'])
% end
% 
% figure % plot mean traces in all probabilities, just a rough check...
% subplot(2, 1, 1)
%  for probN = 1:size(probCons, 2)
%      plot(timePoints, velMean{probN}.firstStandard, '--', 'color', colorPlotting(probN, :))
%      hold on
%      p{probN} = plot(timePoints, velMean{probN}.lastStandard, '-', 'color', colorPlotting(probN, :))
%  end
%  line([-300 -300], [minVel maxVel],'Color','m','LineStyle','--')
%  legend([p{1}, p{2}, p{3}], {'50', '70', '90'}, 'Location', 'NorthWest')
%  title('standard trials')
%  xlabel('Time (ms)')
%  ylabel('Horizontal velocity (deg/s)')
%  ylim([minVel maxVel])
%  
%  subplot(2, 1, 2)
%  for probN = 1:size(probCons, 2)
%      plot(timePoints, velMean{probN}.firstPerceptual, '--', 'color', colorPlotting(probN, :))
%      hold on
%      p{probN} = plot(timePoints, velMean{probN}.lastPerceptual, '-', 'color', colorPlotting(probN, :))
%  end
%  line([-300 -300], [minVel maxVel],'Color','m','LineStyle','--')
%  legend([p{1}, p{2}, p{3}], {'50', '70', '90'}, 'Location', 'NorthWest')
%  title('perceptual trials')
%  xlabel('Time (ms)')
%  ylabel('Horizontal velocity (deg/s)')
%  ylim([minVel maxVel])
%  saveas(gca, ['rightwardTrials_velocity_', names{subN}, '.pdf'])
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