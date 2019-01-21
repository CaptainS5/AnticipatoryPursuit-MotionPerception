% Xiuyun Wu, 01/14/2019
% getting the raw processed eye data... will be much more convenient for
% later analysis; from fixation onset to rdk offset

clear all; close all; clc
names = {'tW'};
cd ..
analysisPath = pwd;
dataPath = {'C:\Users\CaptainS5\Documents\PhD@UBC\Lab\2ndYear\AnticipatoryPursuit\AnticipatoryPursuitMotionPerception\data'};
trialPerCon = 26; % for each coherence level in each direction
% parameters
sampleRate = 1000;
screenSizeX = 39.7;
screenSizeY = 29.5;
screenResX = 1280;
screenResY = 1024;
distance = 57; % 55 for later experiments
% saccade algorithm threshold --> depends on your stimulus speed and
% expected saccade size
% note that this threshold is hard-coded! If you want to test different
% values this will not update while clicking through and you will have to
% declare the variable eagain in the command window
saccadeThreshold = 15;
microSaccadeThreshold = 5;

%% Perceptual trials

for subN = 1:length(names)
    currentSsubject = names{subN};
    cd(dataPath)
    cd(currentSsubject)
    currentSubjectPath = pwd;
    eyeFiles = dir('*.asc');
    load('parametersAll')
    load eventLog
    cd(analysisPath)
    errors = load(['Errorfiles\Sub_' currentSsubject '_errorFile.mat']);
    
    for currentTrial = 1:size(parameters, 1)
        eyeTrialData.sub(subN, currentTrial) = subN;
        eyeTrialData.trial(subN, currentTrial) = currentTrial;
        eyeTrialData.trialType(subN, currentTrial) = parameters.trialType(currentTrial, 1); % 0-perceptual trial, 1-standard trial
        eyeTrialData.prob(subN, currentTrial) = parameters.prob(currentTrial, 1); % n%
        eyeTrialData.rdkDir(subN, currentTrial) = parameters.rdkDir(currentTrial, 1); % -1=left, 1=right, 0=0 coherence, no direction
        eyeTrialData.coh(subN, currentTrial) = parameters.coh(currentTrial, 1)*parameters.rdkDir(currentTrial, 1); % negative-left, positive-right
        eyeTrialData.choice(subN, currentTrial) = parameters.choice(currentTrial, 1); % 0-left, 1-right 
        eyeTrialData.errorStatus(subN, currentTrial) = errors.errorStatus(currentTrial, 1);
        
        analyzeTrial;
        
        eyeTrialData.stim.onset(subN, currentTrial) = trial.stim_onset;
        eyeTrialData.stim.reversalOnset(subN, currentTrial) = trial.stim_reversalOnset;
        eyeTrialData.stim.reversalOffset(subN, currentTrial) = trial.stim_reversalOffset;
        eyeTrialData.stim.offset(subN, currentTrial) = trial.stim_offset;
        eyeTrialData.stim.beforeFrames(subN, currentTrial) = trial.stim_reversalOnset-trial.stim_onset; % for later alignment of velocity traces
        eyeTrialData.stim.afterFrames(subN, currentTrial) = trial.stim_offset-trial.stim_reversalOffset+1; % for later alignment of velocity traces
        eyeTrialData.frameLog.startFrame(subN, currentTrial) = trial.startFrame;
        eyeTrialData.frameLog.endFrame(subN, currentTrial) = trial.endFrame;
        eyeTrialData.frameLog.length(subN, currentTrial) = trial.length;
        eyeTrialData.frameLog.lostXframes{subN, currentTrial} = trial.lostXframes;
        eyeTrialData.frameLog.lostYframes{subN, currentTrial} = trial.lostYframes;
        eyeTrialData.frameLog.lostTframes{subN, currentTrial} = trial.lostTframes;
        eyeTrialData.frameLog.quickphaseFrames{subN, currentTrial} = trial.quickphaseFrames;
        eyeTrialData.saccades{subN, currentTrial} = trial.saccades;
        eyeTrialData.frames{subN, currentTrial} = trial.frames;
        
    end
end
cd([analysisPath '\analysis functions'])
save(['eyeDataAll.mat'], 'eyeTrialData');