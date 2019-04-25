% FUNCTION to analyze open and closed loop pursuit when viewing moving
% stimuli; requires ms2frames.m
% history
% 07-2012       JE created analyzePursuit.m
% 2012-2018     JF added stuff to and edited analyzePursuit.m
% 14-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
%
% input: trial --> structure containing relevant current trial information
%        pursuit --> structure containing pursuit onset
% output: pursuit --> structure containing relevant all open and closed
%                     loop pursuit measures

function [pursuit] = analyzePursuit(trial, pursuit)
% define the window of anticipatory pursuit
negativeAPwindow = ms2frames(-50);
positiveAPwindow = ms2frames(50);
% calculate AP...
pursuit.APvelocity.X = nanmean(trial.DX_noSac((trial.stim_onset+negativeAPwindow):(trial.stim_onset+positiveAPwindow)));

% define the window you want to analyze open-loop pursuit in
openLoopLength = 140;
pursuitOff = trial.stim_offset-ms2frames(150); % may want to adjust if target has already disappeard 

%%calculated open-loop duration
if pursuit.onset && pursuit.onsetSteadyState
    openLoopDuration = pursuit.onsetSteadyState - pursuit.onset;
else
    openLoopDuration = ms2frames(openLoopLength);
end
%%end of calculated open-loop duration
% or use the following:
%%fixed open-loop duration
openLoopDuration = ms2frames(openLoopLength);
%%end of fixed open-loop duration

% analyze open-loop phase first
startFrame = nanmax([trial.stim_onset+positiveAPwindow pursuit.onset]); % if there is no pursuit onset we still want to analyze eye movement quaility
endFrame = startFrame+openLoopDuration; %nanmin([(pursuit.onset+openLoopDuration) trial.saccades.firstSaccadeOnset (trial.stim_onset+positiveAPwindow+openLoopDuration)]);
% if startFrame<trial.stim_onset+positiveAPwindow % if onset is
% earlier that AP window, set it to AP window--already restrict this
% in findPursuit.m
%     startFrame = trial.stim_onset+positiveAPwindow;
%     endFrame = trial.stim_onset+openLoopDuration;
% end

pursuit.openLoopStartFrame = startFrame;
pursuit.openLoopEndFrame = endFrame;
% If subjects were fixating in the beginning (saccadeType = 2) or if purusit onset
% was inside a saccade (saccadeType = -2) there is no open loop values
if pursuit.saccadeType == 2 || pursuit.saccadeType == -2
    pursuit.initialMeanVelocity = NaN;
    pursuit.initialPeakVelocity = NaN;
    pursuit.initialMeanAcceleration = NaN;
    pursuit.initialPeakAcceleration = NaN;   
else
    % first analyze initial pursuit in X
    meanVelocityX = trial.DX_noSac(startFrame:endFrame);
    remove = isnan(meanVelocityX);
    meanVelocityX(remove) = [];
    pursuit.initialMeanVelocity.X = mean(abs(meanVelocityX));
    if length(meanVelocityX) < ms2frames(40) % if open loop pursuit is less than 40 ms before catch up saccde pursuit was not truely initiated
        pursuit.initialMeanVelocity.X = NaN;
    end    
    peakVelocityX = trial.DX_noSac(startFrame:endFrame);
    remove = isnan(peakVelocityX);
    peakVelocityX(remove) = [];
    pursuit.initialPeakVelocity.X = max(abs(peakVelocityX));
    if length(peakVelocityX) < ms2frames(40)
        pursuit.initialPeakVelocity.X = NaN;
    end    
    meanAccelerationX = trial.eyeDDX_filt(startFrame:endFrame);
    remove = isnan(meanAccelerationX);
    meanAccelerationX(remove) = [];
    pursuit.initialMeanAcceleration.X = mean(abs(meanAccelerationX));
    if length(meanAccelerationX) < ms2frames(40)
        pursuit.initialMeanAcceleration.X = NaN;
    end
    
    peakAccelerationX = trial.eyeDDX_filt(startFrame:endFrame);
    remove = isnan(peakAccelerationX);
    peakAccelerationX(remove) = [];
    pursuit.initialPeakAcceleration.X = max(abs(peakAccelerationX));
    if length(peakAccelerationX) < ms2frames(40)
        pursuit.initialPeakAcceleration.X = NaN;
    end
    % next analyze initial pursuit in y 
    meanVelocityY = trial.DY_noSac(startFrame:endFrame);
    remove = isnan(meanVelocityY);
    meanVelocityY(remove) = [];
    pursuit.initialMeanVelocity.Y = mean(abs(meanVelocityY));
    if length(meanVelocityY) < 40
        pursuit.initialMeanAcceleration.Y = NaN;
    end
    peakVelocityY = trial.DY_noSac(startFrame:endFrame);
    remove = isnan(peakVelocityY);
    peakVelocityY(remove) = [];
    pursuit.initialPeakVelocity.Y = max(abs(peakVelocityY));
    if length(peakVelocityY) < 40
        pursuit.initialPeakVelocity.Y = NaN;
    end  
    meanAccelerationY = trial.eyeDDY_filt(startFrame:endFrame);
    remove = isnan(meanAccelerationY);
    meanAccelerationY(remove) = [];
    pursuit.initialMeanAcceleration.Y = mean(abs(meanAccelerationY));
    if length(meanAccelerationY) < 40
        pursuit.initialMeanAcceleration.Y = NaN;
    end    
    peakAccelerationY = trial.eyeDDY_filt(startFrame:endFrame);
    remove = isnan(peakAccelerationY);
    peakAccelerationY(remove) = [];
    pursuit.initialPeakAcceleration.Y = max(abs(peakAccelerationY));
    if length(peakAccelerationY) < 40
        pursuit.initialPeakAcceleration.Y = NaN;
    end
    % combine x and y
    if isempty(pursuit.initialMeanVelocity.X) || isempty(pursuit.initialMeanVelocity.Y)
        pursuit.initialMeanVelocity = NaN;
    else
        pursuit.initialMeanVelocity = nanmean(sqrt(pursuit.initialMeanVelocity.X.^2 + pursuit.initialMeanVelocity.Y.^2));
    end    
    if isempty(pursuit.initialPeakVelocity.X) || isempty(pursuit.initialPeakVelocity.Y)
        pursuit.initialPeakVelocity = NaN;
    else
        pursuit.initialPeakVelocity = nanmean(sqrt(pursuit.initialPeakVelocity.X.^2 + pursuit.initialPeakVelocity.Y.^2));
    end
    if isempty(pursuit.initialMeanAcceleration.X) || isempty(pursuit.initialMeanAcceleration.Y)
        pursuit.initialMeanAcceleration = NaN;
    else
        pursuit.initialMeanAcceleration = nanmean(sqrt(pursuit.initialMeanAcceleration.X.^2 + pursuit.initialMeanAcceleration.Y.^2));
    end   
    if isempty(pursuit.initialPeakAcceleration.X) || isempty(pursuit.initialPeakAcceleration.Y)
        pursuit.initialPeakAcceleration = NaN;
    else
        pursuit.initialPeakAcceleration = nanmean(sqrt(pursuit.initialPeakAcceleration.X.^2 + pursuit.initialPeakAcceleration.Y.^2));
    end
end
% now analyze closed loop
% if there is no pursuit onset, use stimulus onset as onset 
% if isnan(pursuit.onset)
%     startFrame = trial.stim_onset + positiveAPwindow + openLoopDuration;
% else
%     startFrame = pursuit.onset + openLoopDuration;
% end
startFrame = pursuit.openLoopEndFrame+1;
endFrame = pursuitOff;
closedLoop = startFrame:endFrame;
pursuit.closedLoopMeanVel.X = nanmean(trial.DX_noSac(startFrame:endFrame));
% calculate gain first
speedXY_noSac = sqrt((trial.DX_noSac).^2 + (trial.DY_noSac).^2);
speedX_noSac = sqrt((trial.DX_noSac).^2);
absoluteVel = repmat(abs(trial.stimulus.absoluteVelocity), size(speedXY_noSac));
idx = absoluteVel < 0.05;
absoluteVel(idx) = NaN;
pursuitGainX = (speedX_noSac(closedLoop))./absoluteVel(closedLoop);
pursuit.gain.X= nanmean(pursuitGainX);
if length(pursuitGainX) < ms2frames(40)
    pursuit.gain.X = NaN;
end
% % calculate position error
% horizontalError = trial.X_noSac(startFrame:endFrame)-trial.stimulus.XposGenerated(startFrame:endFrame);
% verticalError = trial.stimulus.YposGenerated(startFrame:endFrame)-trial.Y_noSac(startFrame:endFrame);
% pursuit.positionError = nanmean(sqrt(horizontalError.^2+ verticalError.^2));
% % calculate velocity error
% pursuit.velocityError = nanmean(sqrt((trial.stimulus.XvelGenerated(startFrame:endFrame) - trial.DX_noSac(startFrame:endFrame)).^2 + ...
%     (trial.stimulus.YvelGenerated(startFrame:endFrame) - trial.DY_noSac(startFrame:endFrame)).^2)); %auch 2D
% determine the latency, i.e. when did the eye move with respect to 
% target movement
if pursuit.onset == trial.stim_onset
    pursuit.latency = NaN;
else
    pursuit.latency = pursuit.onset - trial.stim_onset;
end

end