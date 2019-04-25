% Xiuyun Wu, 01/14/2019
% getting the raw processed eye data... will be much more convenient for
% later analysis; from fixation onset to rdk offset
% run this after getting the errorfiles

clear all; close all; clc
names = {'XW0' 'p2' 'p4'};
cd ..
analysisPath = pwd;
dataPath = 'C:\Users\vision\Documents\Xiuyun\AnticipatoryPursuit-MotionPerception\data'; % saccade pc
% dataPath =
% 'C:\Users\CaptainS5\Documents\PhD@UBC\Lab\2ndYear\AnticipatoryPursuit\AnticipatoryPursuitMotionPerception\data'; % dell laptop
% dataPath = 'E:\XiuyunWu\AnticipatoryPursuit-MotionPerception\data'; % ASUS laptop
trialPerCon = 26; % for each coherence level in each direction
% parameters
sampleRate = 1000;
screenSizeX = 39.7;
screenSizeY = 29.5;
screenResX = 1600;
screenResY = 1200;
distance = 55; % 57.29 for tW
% saccade algorithm threshold --> depends on your stimulus speed and
% expected saccade size
% note that this threshold is hard-coded! If you want to test different
% values this will not update while clicking through and you will have to
% declare the variable eagain in the command window
saccadeThreshold = 15;
microSaccadeThreshold = 5;

%% Perceptual trials

for subN = 1:length(names)
    currentSubject = names{subN};
    cd(dataPath)
    cd(currentSubject)
    currentSubjectPath = pwd;
    eyeFiles = dir('*.asc');
    load('parametersAll')
    load eventLog
    cd(analysisPath)
    errors = load(['Errorfiles\Sub_' currentSubject '_errorFile.mat']);
    clear eyeTrialData
    
    for currentTrial = 1:size(parameters, 1)
%         if currentTrial>1364
%             screenResX = 2000;
%             screenResY = 1500;
%         end
        eyeTrialData.sub(subN, currentTrial) = subN;
        eyeTrialData.trialIdx(subN, currentTrial) = currentTrial;
        eyeTrialData.trialType(subN, currentTrial) = parameters.trialType(currentTrial, 1); % 0-perceptual trial, 1-standard trial
        eyeTrialData.prob(subN, currentTrial) = parameters.prob(currentTrial, 1); % n%
        eyeTrialData.rdkDir(subN, currentTrial) = parameters.rdkDir(currentTrial, 1); % -1=left, 1=right, 0=0 coherence, no direction
        eyeTrialData.coh(subN, currentTrial) = parameters.coh(currentTrial, 1)*parameters.rdkDir(currentTrial, 1); % negative-left, positive-right
        eyeTrialData.choice(subN, currentTrial) = parameters.choice(currentTrial, 1); % 0-left, 1-right
        eyeTrialData.errorStatus(subN, currentTrial) = errors.errorStatus(currentTrial, 1);
        if errors.errorStatus(currentTrial, 1)~=-1
            analyzeTrial;
            
            eyeTrialData.frameLog.fixationOn(subN, currentTrial) = trial.log.trialStart;
            eyeTrialData.frameLog.fixationOff(subN, currentTrial) = trial.log.fixationOff;
            eyeTrialData.frameLog.rdkOn(subN, currentTrial) = trial.log.targetOnset;
            eyeTrialData.frameLog.rdkOff(subN, currentTrial) = trial.log.trialEnd;
            
            eyeTrialData.pursuit.APvelocityX(subN, currentTrial) = trial.pursuit.APvelocityX;
            eyeTrialData.pursuit.onset(subN, currentTrial) = trial.pursuit.onset; % visually driven pursuit onset
            eyeTrialData.pursuit.onsetSteadyState(subN, currentTrial) = trial.pursuit.onsetSteadyState;
            eyeTrialData.pursuit.onsetTrue(subN, currentTrial) = trial.pursuit.onsetTrue; % original onset, could be earlier than visual stimulus onset
            eyeTrialData.pursuit.openLoopStartFrame(subN, currentTrial) = trial.pursuit.openLoopStartFrame;
            eyeTrialData.pursuit.openLoopEndFrame(subN, currentTrial) = trial.pursuit.openLoopEndFrame;
            eyeTrialData.pursuit.initialMeanVelocityX(subN, currentTrial) = trial.pursuit.initialMeanVelocityX;
            eyeTrialData.pursuit.initialPeakVelocityX(subN, currentTrial) = trial.pursuit.initialPeakVelocityX;
            eyeTrialData.pursuit.initialMeanAccelerationX(subN, currentTrial) = trial.pursuit.MeanAccelerationX;
            eyeTrialData.pursuit.initialPeakAccelerationX(subN, currentTrial) = trial.pursuit.PeakAccelerationX;
            eyeTrialData.pursuit.closedLoopMeanVelX(subN, currentTrial) = trial.pursuit.closedLoopMeanVelX;
            eyeTrialData.pursuit.gainX(subN, currentTrial) = trial.pursuit.gainX;
             
            eyeTrialData.saccades.X.number(subN, currentTrial) = trial.saccades.X.;
            eyeTrialData.saccades.X.meanAmplitude(subN, currentTrial) = trial.saccades.X.;
            eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = trial.saccades.X.;
            eyeTrialData.saccades.X.meanDuration(subN, currentTrial) = trial.saccades.X.;
            eyeTrialData.saccades.X.sumAmplitude(subN, currentTrial) = trial.saccades.X.sacSum;
            eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = trial.saccades.X.;
            eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = trial.saccades.X.;
            eyeTrialData.saccades.X.onsets_pursuit{subN, currentTrial} = trial.saccades.X.;
            eyeTrialData.saccades.X.offsets_pursuit{subN, currentTrial} = trial.saccades.X.;
            
            eyeTrialDataSub.trial{1, currentTrial}.eyeX_filt = trial.eyeX_filt; % for velocity traces
            eyeTrialDataSub.trial{1, currentTrial}.eyeY_filt = trial.eyeY_filt; 
            eyeTrialDataSub.trial{1, currentTrial}.eyeDX_filt = trial.eyeDX_filt; 
            eyeTrialDataSub.trial{1, currentTrial}.eyeDY_filt = trial.eyeDY_filt; 
            eyeTrialDataSub.trial{1, currentTrial}.X_noSac = trial.X_noSac; 
            eyeTrialDataSub.trial{1, currentTrial}.Y_noSac = trial.Y_noSac; 
            eyeTrialDataSub.trial{1, currentTrial}.DX_noSac = trial.DX_noSac; 
            eyeTrialDataSub.trial{1, currentTrial}.DY_noSac = trial.DY_noSac; 
            eyeTrialDataSub.trial{1, currentTrial}.X_interpolSac = trial.X_interpolSac; 
            eyeTrialDataSub.trial{1, currentTrial}.Y_interpolSac = trial.Y_interpolSac; 
            eyeTrialDataSub.trial{1, currentTrial}.DX_interpolSac = trial.DX_interpolSac; 
            eyeTrialDataSub.trial{1, currentTrial}.DY_interpolSac = trial.DY_interpolSac; 
        else
            eyeTrialData.frameLog.fixationOn(subN, currentTrial) = NaN;
            eyeTrialData.frameLog.fixationOff(subN, currentTrial) = NaN;
            eyeTrialData.frameLog.rdkOn(subN, currentTrial) = NaN;
            eyeTrialData.frameLog.rdkOff(subN, currentTrial) = NaN;
            
            eyeTrialDataSub.trial{1, currentTrial} = NaN; % for velocity traces
        end
    end
    cd([analysisPath '\analysis'])    
    save(['eyeTrialData_' names{subN} '.mat'], 'eyeTrialDataSub');
end
save(['eyeTrialData_all.mat'], 'eyeTrialData');