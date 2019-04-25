% FUNCTION to analyze saccade parameters

% history
% 07-2012       JE created analyzeSaccades.m
% 2012-2018     JF added stuff to and edited analyzeSaccades.m
% 13-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
%
% input: trial --> structure containing relevant current trial information
%        saccades --> output from findSaccades.m; contains on- & offsets
% output: trial --> structure containing relevant current trial information
%                   with saccades added
%         saccades --> edited saccade structure

function [trial, saccades] = analyzeSaccades(trial)
% define the window you want to analyze saccades in
startFrame = nanmax(trial.stim_onset+ms2frames(50), trial.pursuit.onset);
endFrame = trial.stim_offset-ms2frames(150);
% then find the proper onsets and offsets
xIdx = find(trial.saccades.X.onsets>=startFrame & trial.saccades.X.onsets<=endFrame);
yIdx = find(trial.saccades.Y.onsets>=startFrame & trial.saccades.Y.onsets<=endFrame);
trial.saccades.X.onsets = trial.saccades.X.onsets(xIdx);
trial.saccades.X.offsets = trial.saccades.X.offsets(xIdx);
trial.saccades.Y.onsets = trial.saccades.Y.onsets(yIdx);
trial.saccades.Y.offsets = trial.saccades.Y.offsets(yIdx);
trial.saccades.onsets = [trial.saccades.X.onsets; trial.saccades.Y.onsets];
trial.saccades.offsets = [trial.saccades.X.offsets; trial.saccades.Y.offsets];

xIdxL = find(trial.saccades.X_left.onsets>=startFrame & trial.saccades.X_left.onsets<=endFrame);
xIdxR = find(trial.saccades.X_right.onsets>=startFrame & trial.saccades.X_right.onsets<=endFrame);
trial.saccades.X_left.onsets = trial.saccades.X_left.onsets(xIdxL);
trial.saccades.X_left.offsets = trial.saccades.X_left.offsets(xIdxL);
trial.saccades.X_right.onsets = trial.saccades.X_right.onsets(xIdxR);
trial.saccades.X_right.offsets = trial.saccades.X_right.offsets(xIdxR);

% calculate saccade amplitudes
% if there are no y-saccades, use x and y position of x saccades and vice
% versa; otherwise use the earlier onset and later offset; basically we
% assume that the eye is making a saccade and x- and y-position should be
% affected equally
xSac = length(trial.saccades.X.onsets);
ySac = length(trial.saccades.Y.onsets);
if numel(trial.saccades.onsets) == 0
    trial.saccades.amplitudes = NaN;
elseif isempty(ySac)
    trial.saccades.amplitudes = sqrt((trial.eyeX_filt(trial.saccades.X.offsets) - trial.eyeX_filt(trial.saccades.X.onsets)).^2 ...
        + (trial.eyeY_filt(trial.saccades.X.offsets) - trial.eyeY_filt(trial.saccades.X.onsets)).^2);
elseif isempty(xSac)
    trial.saccades.amplitudes = sqrt((trial.eyeX_filt(trial.saccades.Y.offsets) - trial.eyeX_filt(trial.saccades.Y.onsets)).^2 ...
        + (trial.eyeY_filt(trial.saccades.Y.offsets) - trial.eyeY_filt(trial.saccades.Y.onsets)).^2);
else
    if length(trial.saccades.onsets) ~= length(trial.saccades.offsets)
        trial.saccades.amplitudes = sqrt((trial.eyeX_filt(trial.saccades.X.offsets) - trial.eyeX_filt(trial.saccades.X.onsets)).^2 ...
        + (trial.eyeY_filt(trial.saccades.X.offsets) - trial.eyeY_filt(trial.saccades.X.onsets)).^2);
    else
        trial.saccades.amplitudes = sqrt((trial.eyeX_filt(trial.saccades.offsets) - trial.eyeX_filt(trial.saccades.onsets)).^2 ...
            + (trial.eyeY_filt(trial.saccades.offsets) - trial.eyeY_filt(trial.saccades.onsets)).^2);
    end
end
if ~isempty(xSac)
    trial.saccades.X.amplitudes = sqrt((trial.eyeX_filt(trial.saccades.X.offsets) - trial.eyeX_filt(trial.saccades.X.onsets)).^2 ...
        + (trial.eyeY_filt(trial.saccades.X.offsets) - trial.eyeY_filt(trial.saccades.X.onsets)).^2);
end

xSacL = length(trial.saccades.X_left.onsets);
xSacR = length(trial.saccades.X_right.onsets);
if ~isempty(xSacL)
    trial.saccades.X_left.amplitudes = abs(trial.eyeX_filt(trial.saccades.X_left.offsets) - trial.eyeX_filt(trial.saccades.X_left.onsets));
    % trial.saccades.X_left.amplitudes = sqrt((trial.eyeX_filt(trial.saccades.X_left.offsets) - trial.eyeX_filt(trial.saccades.X_left.onsets)).^2 ...
    %         + (trial.eyeY_filt(trial.saccades.X_left.offsets) - trial.eyeY_filt(trial.saccades.X_left.onsets)).^2);
else
    trial.saccades.X_left.amplitudes = NaN;
end
if ~isempty(xSacR)
    trial.saccades.X_right.amplitudes = abs(trial.eyeX_filt(trial.saccades.X_right.offsets) - trial.eyeX_filt(trial.saccades.X_right.onsets));
else
    trial.saccades.X_right.amplitudes = NaN;
end

% caluclate mean and max amplitude, mean duration, total number, &
% cumulative saccade amplitude (saccadic sum)
if isempty(trial.saccades.onsets)
    trial.saccades.meanAmplitude = [];
    trial.saccades.maxAmplitude = [];   
    trial.saccades.X.meanDuration = [];
    trial.saccades.Y.meanDuration = [];
    trial.saccades.meanDuration = [];
    trial.saccades.number = [];
    trial.saccades.sacSum = [];
    trial.saccades.X_left.number = [];
    trial.saccades.X_left.meanAmplitude = [];
    trial.saccades.X_left.meanDuration = [];
    trial.saccades.X_left.sumAmplitude = [];
    trial.saccades.X_right.number = [];
    trial.saccades.X_right.meanAmplitude = [];
    trial.saccades.X_right.meanDuration = [];
    trial.saccades.X_right.sumAmplitude = [];
else
    trial.saccades.meanAmplitude = nanmean(trial.saccades.amplitudes);
    trial.saccades.maxAmplitude = max(trial.saccades.amplitudes);
    trial.saccades.X.meanAmplitude = nanmean(trial.saccades.X.amplitudes);
    trial.saccades.X.maxAmplitude = max(trial.saccades.X.amplitudes);
    trial.saccades.X.meanDuration = mean(trial.saccades.X.offsets - trial.saccades.X.onsets);
    trial.saccades.Y.meanDuration = mean(trial.saccades.Y.offsets - trial.saccades.Y.onsets);
    trial.saccades.meanDuration = nanmean(sqrt(trial.saccades.X.meanDuration.^2 + ...
                                               trial.saccades.Y.meanDuration.^2));
    trial.saccades.number = length(trial.saccades.onsets);
    trial.saccades.X.number = length(trial.saccades.X.onsets);
    trial.saccades.sacSum = sum(trial.saccades.amplitudes);
    trial.saccades.X.sacSum = sum(trial.saccades.X.amplitudes);
    trial.saccades.X_left.number = length(trial.saccades.X_left.onsets);
    trial.saccades.X_left.meanAmplitude = nanmean(trial.saccades.X_left.amplitudes);
    trial.saccades.X_left.meanDuration = mean(trial.saccades.X_left.offsets - trial.saccades.X_left.onsets);
    trial.saccades.X_left.sumAmplitude = sum(trial.saccades.X_left.amplitudes);
    trial.saccades.X_right.number = length(trial.saccades.X_right.onsets);
    trial.saccades.X_right.meanAmplitude = nanmean(trial.saccades.X_right.amplitudes);
    trial.saccades.X_right.meanDuration = mean(trial.saccades.X_right.offsets - trial.saccades.X_right.onsets);
    trial.saccades.X_right.sumAmplitude = sum(trial.saccades.X_right.amplitudes);
end

% calculate mean and peak velocity for each saccade; then find average
trial.saccades.X.peakVelocity = [];
trial.saccades.Y.peakVelocity = [];
trial.saccades.X.meanVelocity = [];
trial.saccades.Y.meanVelocity = [];
saccadesXXpeakVelocity = NaN(length(trial.saccades.X.onsets),1);
saccadesXYpeakVelocity = NaN(length(trial.saccades.X.onsets),1);
saccadesXXmeanVelocity = NaN(length(trial.saccades.X.onsets),1);
saccadesXYmeanVelocity = NaN(length(trial.saccades.X.onsets),1);
for i = 1:length(trial.saccades.X.onsets)
    saccadesXXpeakVelocity(i) = max(abs(trial.eyeDX_filt(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i))));
    saccadesXYpeakVelocity(i) = max(abs(trial.eyeDY_filt(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i))));
    saccadesXXmeanVelocity(i) = nanmean(abs(trial.eyeDX_filt(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i))));
    saccadesXYmeanVelocity(i) = nanmean(abs(trial.eyeDY_filt(trial.saccades.X.onsets(i):trial.saccades.X.offsets(i))));
end
saccadesYYpeakVelocity = NaN(length(trial.saccades.Y.onsets),1);
saccadesYXpeakVelocity = NaN(length(trial.saccades.Y.onsets),1);
saccadesYYmeanVelocity = NaN(length(trial.saccades.Y.onsets),1);
saccadesYXmeanVelocity = NaN(length(trial.saccades.Y.onsets),1);
for i = 1:length(trial.saccades.Y.onsets)
    saccadesYYpeakVelocity(i) = max(abs(trial.eyeDY_filt(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i))));
    saccadesYXpeakVelocity(i) = max(abs(trial.eyeDX_filt(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i))));
    saccadesYYmeanVelocity(i) = nanmean(abs(trial.eyeDY_filt(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i))));
    saccadesYXmeanVelocity(i) = nanmean(abs(trial.eyeDX_filt(trial.saccades.Y.onsets(i):trial.saccades.Y.offsets(i))));
end
trial.saccades.X.peakVelocity = max([saccadesXXpeakVelocity; saccadesYXpeakVelocity]);
trial.saccades.Y.peakVelocity = max([saccadesXYpeakVelocity; saccadesYYpeakVelocity]);
trial.saccades.X.meanVelocity = nanmean([saccadesXXmeanVelocity; saccadesYXmeanVelocity]);
trial.saccades.Y.meanVelocity = nanmean([saccadesXYmeanVelocity; saccadesYYmeanVelocity]);

trial.saccades.peakVelocity = nanmean(sqrt(trial.saccades.X.peakVelocity.^2 + trial.saccades.Y.peakVelocity.^2));
trial.saccades.meanVelocity = nanmean(sqrt(trial.saccades.X.meanVelocity.^2 + trial.saccades.Y.meanVelocity.^2));

end
