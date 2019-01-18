% Xiuyun Wu, 01/14/2019
% getting the raw processed eye data... will be much more convenient for
% later analysis; from fixation onset to rdk offset

clear all; close all; clc

global trial

names = {'tW'};
cd ..
analysisF = pwd;
dataFolder = {'C:\Users\CaptainS5\Documents\PhD@UBC\Lab\2ndYear\AnticipatoryPursuit\AnticipatoryPursuitMotionPerception\data'};
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
saccadeThreshold = 20;
microSaccadeThreshold = 5;

%% Perceptual trials
% count = 1;
for eye = 1:2
    eyeTrialData = [];
    for subN = 1:length(names)
        cd(analysisF)
        % Subject details
        subject = names{subN};
        trialN = 1; % label the trial number so it would be easier to correspond perceptual, left eye, and right eye data
        
        for blockN = 1:totalBlocks
            if eye==1
                errors = load(['Errorfiles\Exp' num2str(blockN) '_Subject' num2str(subN,'%.2i') '_Block' num2str(blockN,'%.2i') '_L_errorFile.mat']);
            else
                errors = load(['Errorfiles\Exp' num2str(blockN) '_Subject' num2str(subN,'%.2i') '_Block' num2str(blockN,'%.2i') '_R_errorFile.mat']);
            end
            % load response data for trial information
            dataFile = dir([dataFolder{:} '\' subject '\response' num2str(blockN) '_*.mat']);
            load([dataFolder{:} '\' subject '\' dataFile.name]) % resp is the response data for the current block
            
            for t = 1:size(resp, 1) % trial number
                eyeTrialData.sub(subN, trialN) = subN;
                eyeTrialData.trial(subN, trialN) = trialN;
                eyeTrialData.eye(subN, trialN) = eye;
                eyeTrialData.rotationSpeed(subN, trialN) = resp.rotationSpeed(t);
                eyeTrialData.afterReversalD(subN, trialN) = -resp.initialDirection(t); % 1=clockwise, -1=counterclockwise
                eyeTrialData.targetSide(subN, trialN) = resp.targetSide(t);
                eyeTrialData.errorStatus(subN, trialN) = errors.errorStatus(t);
                
                % read in data and socscalexy
                filename = ['session_' num2str(blockN,'%.2i') '_' eyeName{eye} '.dat'];
                data = readDataFile(filename, [dataFolder{:} '\' subject '\chronos']);
                data = socscalexy(data);
                [header, logData] = readLogFile(blockN, ['response' num2str(blockN,'%.2i') '_' subject] , [dataFolder{:} '\' subject]);
                sampleRate = 200;
                
                % setup trial
                trial = setupTrial(data, header, logData, t);
                
                find saccades;
                [saccades.X.onsets, saccades.X.offsets, saccades.X.isMax] = findSaccades(trial.stim_onset-40, min(trial.length, trial.stim_offset+40), trial.frames.DX_filt, trial.frames.DDX_filt, 20, 0);
                [saccades.Y.onsets, saccades.Y.offsets, saccades.Y.isMax] = findSaccades(trial.stim_onset-40, min(trial.length, trial.stim_offset+40), trial.frames.DY_filt, trial.frames.DDY_filt, 20, 0);
                [saccades.T.onsets, saccades.T.offsets, saccades.T.isMax] = findSaccades(trial.stim_onset-40, min(trial.length, trial.stim_offset+40), trial.frames.DT_filt, trial.frames.DDT_filt, torsionThreshold(subN), 0);
                
                % analyze saccades
                [trial] = analyzeSaccades(trial, saccades);
                clear saccades;
                
                % remove saccades
                trial = removeSaccades(trial);
                % end of setting up trial
                
                eyeTrialData.stim.onset(subN, trialN) = trial.stim_onset;
                eyeTrialData.stim.reversalOnset(subN, trialN) = trial.stim_reversalOnset;
                eyeTrialData.stim.reversalOffset(subN, trialN) = trial.stim_reversalOffset;
                eyeTrialData.stim.offset(subN, trialN) = trial.stim_offset;
                eyeTrialData.stim.beforeFrames(subN, trialN) = trial.stim_reversalOnset-trial.stim_onset; % for later alignment of velocity traces
                eyeTrialData.stim.afterFrames(subN, trialN) = trial.stim_offset-trial.stim_reversalOffset+1; % for later alignment of velocity traces
                eyeTrialData.frameLog.startFrame(subN, trialN) = trial.startFrame;
                eyeTrialData.frameLog.endFrame(subN, trialN) = trial.endFrame;
                eyeTrialData.frameLog.length(subN, trialN) = trial.length;
                eyeTrialData.frameLog.lostXframes{subN, trialN} = trial.lostXframes;
                eyeTrialData.frameLog.lostYframes{subN, trialN} = trial.lostYframes;
                eyeTrialData.frameLog.lostTframes{subN, trialN} = trial.lostTframes;
                eyeTrialData.frameLog.quickphaseFrames{subN, trialN} = trial.quickphaseFrames;
                eyeTrialData.saccades{subN, trialN} = trial.saccades;
                eyeTrialData.frames{subN, trialN} = trial.frames;
                
                trialN = trialN+1;
                %                 count = count+1;
            end
        end
    end
    cd([analysisF '\analysis functions'])
    save(['eyeDataAll_', eyeName{eye}, '.mat'], 'eyeTrialData');
end