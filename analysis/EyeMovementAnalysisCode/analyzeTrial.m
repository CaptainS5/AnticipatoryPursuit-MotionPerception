%% THIS m-file is the magic script that analyzes all your eye data
% this script requries several functions:
% readEyeData.m, processEyeData.m, readoutTrial.m, findSaccades.m, 
% analyzeSaccades.m
% optional: findPursuit.m, analyzePursuit.m, removeSaccades.m,
% findMicroSaccades.m
% optional: we also have scripts to read and analyze target and finger data
% for the EyeCatch/EyeStrike paradigm that can be added here --> ask if you
% need more info

% history
% 07-2012       JE created analyzeTrial.m
% 2012-2018     JF added stuff to and edited analyzeTrial.m
% 13-07-2018    JF commented to make the script more accecable for future 
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de

%% Eye Data
%  eye data need to have been converted using convert_edf2asc.m
global trial
% if currentTrial<=682
%     ascFile = eyeFiles(1,1).name;
% elseif currentTrial<=1364
%     ascFile = eyeFiles(2,1).name;
% else
%     ascFile = eyeFiles(3,1).name;
% end
ascFile = [currentSubject 't' num2str(currentTrial, '%04d') '.mat']; % mat file, one file for each trial
trialStartIdx = eventLog.fixationOn(currentTrial, 1); % different trial start can be specified using e.g. parameters
trialEndIdx = eventLog.rdkOff(currentTrial, 1)+ms2frames(600);
eyeData = readEyeData(ascFile, dataPath, currentSubject, analysisPath, trialStartIdx, trialEndIdx);
eyeData = processEyeData(eyeData); 

%% extract all relevant experimental data and store it in trial variable
trial = readoutTrial(eyeData, currentSubject, analysisPath, parameters, currentTrial, eventLog); 
trial.stim_onset = trial.log.targetOnset;
trial.stim_offset = trial.log.trialEnd;
trial.length = trial.stim_offset;

%% find saccades
threshold = evalin('base', 'saccadeThreshold');
onset = 1;
offset = min(trial.stim_offset+ms2frames(300), size(trial.eyeDX_filt, 1)); % to be able to detect saccades at the end of display
if trial.log.coh==0
    stimulusVelocityX = 0;
else
    stimulusVelocityX = 10*trial.log.coh; % deg/s, became slower with low coherence
end
stimulusVelocityY = 0;
[saccades.X.onsets, saccades.X.offsets] = findSaccades(onset, offset, trial.eyeDX_filt, trial.eyeDDX_filt, threshold, stimulusVelocityX);
[saccades.Y.onsets, saccades.Y.offsets] = findSaccades(onset, offset, trial.eyeDY_filt, trial.eyeDDY_filt, threshold, stimulusVelocityY);

%% analyze saccades
[trial] = analyzeSaccades(trial, saccades);
clear saccades;
% remove saccades
trial = removeSaccades(trial);

 %% OPTIONAL: find and analyze pursuit
pursuit = findPursuit(trial); 
trial.pursuit = pursuit;
% % analyze pursuit
% pursuit = analyzePursuit(trial, pursuit);

%% OPTIONAL: find micro saccades
% % remove saccades
% trial = removeSaccades(trial);
% m_threshold = evalin('base', 'microSaccadeThreshold');
% [saccades.X.onsets, saccades.X.offsets] = findSaccades(onset, offset, trial.DX_noSac, trial.DDX_noSac, m_threshold, 0);
% [saccades.Y.onsets, saccades.Y.offsets] = findSaccades(onset, offset, trial.DY_noSac, trial.DDY_noSac, m_threshold, 0);
% % analyze micro-saccades
% [trial] = analyzeMicroSaccades(trial, saccades);


