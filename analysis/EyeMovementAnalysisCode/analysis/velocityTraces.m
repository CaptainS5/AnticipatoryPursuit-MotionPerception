% plot velocity traces, generate csv file for plotting in R, Exp2
clear all; close all; clc

names = {'tW'};
sampleRate = 1000;
folder = pwd;

cd(folder)
load('eyeDataAll.mat');
probCons = unique(eyeTrialData.prob);

% align fixation offset, 
% separate perceptual and standard trials
for subN = 1:size(names, 2)
%     maxFrames = max(eyeTrialData.frameLog.rdkOff(subN, :));
    frameLength(subN) = max(eyeTrialData.frameLog.rdkOff(subN, :));
    for probI = 1:size(probCons, 2)
        % first standard trials
        validI = find(eyeTrialData.errorStatus(subN, :)~=1 & eyeTrialData.trialType(subN, :)==1);
        lengthF = round(length(validI)/2); % total number of trials
        lengthL = length(validI)-lengthF;
        frames{subN, probI}.firstStandard = NaN(lengthF, frameLength(subN)); % align the reversal; filled with NaN
        frames{subN, probI}.lastStandard = NaN(lengthL, frameLength(subN)); % align the reversal; filled with NaN
        % rows are trials, columns are frames
        
        % fill in the velocity trace of each frame
        % use interpolate points for a better velocity trace
        for validTrialN = 1:lengthF
            startI = eyeTrialData.frameLog.fixationOn(subN, validI(validTrialN));
            endI = eyeTrialData.frameLog.rdkOff(subN, validI(validTrialN));
            startIF = frameLength-eyeTrialData.frameLog.rdkOff(subN, validI(validTrialN))+1;
            frames{subN, probI}.firstStandard(validTrialN, startIF:end) = eyeTrialData.trial{subN, validI(validTrialN)}.DX_noSac(startI:endI); 
        end
        
        % then perceptual trials
        
    end
end
maxFrameLength = max(frameLength);

% % for each probability, draw the mean filtered and unfiltered
% % velocity trace
% for probI = 1:size(conditions, 2)
%     velTAverage{probI} = NaN(length(names), maxFrameLength);
%     velTStd{probI} = NaN(length(names), maxFrameLength);
%     %         velTUnfiltAverage{speedI} = NaN(length(names), maxFrameLength);
%     %         velTUnfiltStd{speedI} = NaN(length(names), maxFrameLength);
%     
%     for subN = 1:size(names, 2)
%         tempStartI = maxFrameLength-frameLength(subN)+1;
%         velTAverage{probI}(subN, tempStartI:end) = nanmean(frames{subN, probI});
%         velTStd{probI}(subN, tempStartI:end) = nanstd(frames{subN, probI});
%         %             velTUnfiltAverage{speedI}(subN, tempStartI:end) = nanmean(framesUnfilt{subN, speedI});
%         %             velTUnfiltStd{speedI}(subN, tempStartI:end) = nanstd(framesUnfilt{subN, speedI});
%     end
%     
%     % plotting parameters
%     minFrameLength = min(frameLength);
%     beforeFrames = minFrameLength-reversalFrames-afterFrames;
%     framePerSec = 1/sampleRate;
%     timePReversal = [0:(reversalFrames-1)]*framePerSec*1000;
%     timePBeforeReversal = timePReversal(1)-(beforeFrames+1-[1:beforeFrames])*framePerSec*1000;
%     timePAfterReversal = timePReversal(end)+[1:afterFrames]*framePerSec*1000;
%     timePoints = [timePBeforeReversal timePReversal timePAfterReversal]; % align at the reversal and after...
%     % reversal onset is 0
%     velTmean{probI} = nanmean(velTAverage{probI}(:, (maxFrameLength-minFrameLength+1):end));
%     % need to plot ste? confidence interval...?
%     
%     %         figure
%     %         % filtered mean velocity trace
%     %         plot(timePoints, velTmean{speedI})
%     %         % hold on
%     %         % patch(timePoints, )
%     %         title([eyeName{eye}, ' rotational speed ', num2str(conditions(speedI))])
%     %         xlabel('Time (ms)')
%     %         ylabel('Torsional velocity (deg/s)')
%     %         % ylim([-0.5 0.5])
%     %
%     %         % saveas(gca, ['velocityTraces_', num2str(conditions(speedI)), '.pdf'])
%     
%     figure % plot individual traces
%     for subN = 1:size(names, 2)
%         % filtered mean velocity trace
%         plot(timePoints, velTAverage{probI}(subN, (maxFrameLength-minFrameLength+1):end))
%         hold on
%         % patch(timePoints, )
%     end
%     title([eyeName{eye}, ' rotational speed ', num2str(conditions(probI))])
%     xlabel('Time (ms)')
%     ylabel('Torsional velocity (deg/s)')
%     % ylim([-0.5 0.5])
%     
%     % saveas(gca, ['velocityTracesSub_', num2str(conditions(speedI)), '.pdf'])
% end

% % generate csv files, each file for one speed condition
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