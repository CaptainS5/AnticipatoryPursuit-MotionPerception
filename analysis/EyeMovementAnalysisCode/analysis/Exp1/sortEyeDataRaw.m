% Xiuyun Wu, 04/28/2019
% getting the raw processed eye data... will be much more convenient for
% later analysis; from fixation onset to rdk offset
% run this after getting the errorfiles

clear all; close all; clc
% Exp1
nameSets{1} = {'XW0' 'p2' 'p4' 'p5' 'p6' 'p8' 'p9' 'p10' 'p14' '015'};
% nameSets{2} = {'p3' 'p7' 'p12'};% 'p15'};
% Exp2
% nameSets{1} = {'tXW' 'tDC' 'p7' 'p3' 'p9' 'p8' 'p6' 'p4' 'p5'}; % in the same order as Exp1
% this will save you huge trouble...
% Exp3
% nameSets{1} = {'tFW' 'fh2' 'p15' 'fh6' 'fht' 'fh8'};
subStartI = [1];
cd ..
cd ..
analysisPath = pwd;
% dataPath = 'C:\Users\vision\Documents\Xiuyun\AnticipatoryPursuit-MotionPerception\data'; % saccade pc
dataPath = 'C:\Users\wuxiu\Documents\PhD@UBC\Lab\2ndYear\AnticipatoryPursuit\AnticipatoryPursuitMotionPerception\data\Exp1'; % dell laptop
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
saccadeThreshold = 5;
microSaccadeThreshold = 5;

%% All trials
for setN = 1:length(subStartI)
    if subStartI(setN)>1 % load eyeTrialDataAll
        cd([analysisPath '\analysis\Exp1'])
        load(['eyeTrialData_all_set' num2str(setN) '.mat'])
    else
        clear eyeTrialData
    end
    names = nameSets{setN};
    
    for subN = subStartI(setN):length(names)
        currentSubject = names{subN};
        cd(dataPath)
        cd(currentSubject)
        currentSubjectPath = pwd;
        eyeFiles = dir('*.asc');
        load('parametersAll')
        load eventLog
        cd(analysisPath)
        errors = load(['Errorfiles\Exp1\Sub_' currentSubject '_errorFile.mat']);
        clear eyeTrialDataSub
        
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
            if errors.errorStatus(currentTrial, 1)==0
                analyzeTrial;
                
                eyeTrialData.frameLog.fixationOn(subN, currentTrial) = trial.log.trialStart;
                eyeTrialData.frameLog.fixationOff(subN, currentTrial) = trial.log.fixationOff;
                eyeTrialData.frameLog.rdkOn(subN, currentTrial) = trial.log.targetOnset;
                eyeTrialData.frameLog.rdkOff(subN, currentTrial) = trial.log.trialEnd;
                
                eyeTrialData.pursuit.APvelocityX(subN, currentTrial) = trial.pursuit.APvelocityX;
                eyeTrialData.pursuit.APvelocityX_interpol(subN, currentTrial) = trial.pursuit.APvelocityX_interpol;
                eyeTrialData.pursuit.onset(subN, currentTrial) = trial.pursuit.onset; % visually driven pursuit onset
                eyeTrialData.pursuit.onsetSteadyState(subN, currentTrial) = trial.pursuit.onsetSteadyState;
                eyeTrialData.pursuit.onsetTrue(subN, currentTrial) = trial.pursuit.onsetTrue; % original onset, could be earlier than visual stimulus onset
                eyeTrialData.pursuit.openLoopStartFrame(subN, currentTrial) = trial.pursuit.openLoopStartFrame;
                eyeTrialData.pursuit.openLoopEndFrame(subN, currentTrial) = trial.pursuit.openLoopEndFrame;
                eyeTrialData.pursuit.initialMeanVelocityX(subN, currentTrial) = trial.pursuit.initialMeanVelocityX;
                eyeTrialData.pursuit.initialPeakVelocityX(subN, currentTrial) = trial.pursuit.initialPeakVelocityX;
                eyeTrialData.pursuit.initialMeanAccelerationX(subN, currentTrial) = trial.pursuit.initialMeanAccelerationX;
                eyeTrialData.pursuit.initialPeakAccelerationX(subN, currentTrial) = trial.pursuit.initialPeakAccelerationX;
                eyeTrialData.pursuit.closedLoopMeanVelX(subN, currentTrial) = trial.pursuit.closedLoopMeanVelX;
                eyeTrialData.pursuit.gainX(subN, currentTrial) = trial.pursuit.gainX;
                eyeTrialData.pursuit.gainX_interpol(subN, currentTrial) = trial.pursuit.gainX_interpol;
                eyeTrialData.pursuit.initialVelChangeX(subN, currentTrial) = -nanmean(trial.DX_noSac( (trial.pursuit.openLoopStartFrame-ms2frames(5)) : (trial.pursuit.openLoopStartFrame+ms2frames(5)) )) ...
                    +nanmean(trial.DX_noSac( (trial.pursuit.openLoopEndFrame-ms2frames(5)) : (trial.pursuit.openLoopEndFrame+ms2frames(5)) ));
                
                %             eyeTrialData.saccades.X.number(subN, currentTrial) = trial.saccades.X_right.number;
                %             eyeTrialData.saccades.X.meanAmplitude(subN, currentTrial) = trial.saccades.X.meanAmplitude;
                %             eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = trial.saccades.X.maxAmplitude;
                %             eyeTrialData.saccades.X.meanDuration(subN, currentTrial) = trial.saccades.X.meanDuration;
                %             eyeTrialData.saccades.X.sumAmplitude(subN, currentTrial) = trial.saccades.X.sacSum;
                %             eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = trial.saccades.X.peakVelocity;
                %             eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = trial.saccades.X.meanVelocity;
                %             eyeTrialData.saccades.X.onsets_pursuit{subN, currentTrial} = trial.saccades.X.onsets_pursuit;
                %             eyeTrialData.saccades.X.offsets_pursuit{subN, currentTrial} = trial.saccades.X.offsets_pursuit;
                %
                % record saccades in both directions...
%                 if trial. log.rdkDir>0 || (trial.log.rdkDir==0 && trial.pursuit.closedLoopMeanVelX>=0)% first use rdk dir to judge, then see pursuit; trial.pursuit.closedLoopMeanVelX>=0 % right ward pursuit
                    eyeTrialData.saccades.X_right.number(subN, currentTrial) = trial.saccades.X_right.number;
                    eyeTrialData.saccades.X_right.meanAmplitude(subN, currentTrial) = trial.saccades.X_right.meanAmplitude;
                    %                 eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = trial.saccades.X_right.maxAmplitude;
                    eyeTrialData.saccades.X_right.meanDuration(subN, currentTrial) = trial.saccades.X_right.meanDuration;
                    eyeTrialData.saccades.X_right.sumAmplitude(subN, currentTrial) = trial.saccades.X_right.sumAmplitude;
                    %                 eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = trial.saccades.X_right.peakVelocity;
                    %                 eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = trial.saccades.X_right.meanVelocity;
                    eyeTrialData.saccades.X_right.onsets_pursuit{subN, currentTrial} = trial.saccades.X_right.onsets_pursuit;
                    eyeTrialData.saccades.X_right.offsets_pursuit{subN, currentTrial} = trial.saccades.X_right.offsets_pursuit;
%                 elseif trial. log.rdkDir<0 || (trial.log.rdkDir==0 && trial.pursuit.closedLoopMeanVelX<0)
                    eyeTrialData.saccades.X_left.number(subN, currentTrial) = trial.saccades.X_left.number;
                    eyeTrialData.saccades.X_left.meanAmplitude(subN, currentTrial) = trial.saccades.X_left.meanAmplitude;
                    %                 eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = trial.saccades.X_left.maxAmplitude;
                    eyeTrialData.saccades.X_left.meanDuration(subN, currentTrial) = trial.saccades.X_left.meanDuration;
                    eyeTrialData.saccades.X_left.sumAmplitude(subN, currentTrial) = trial.saccades.X_left.sumAmplitude;
                    %                 eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = trial.saccades.X_left.peakVelocity;
                    %                 eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = trial.saccades.X_left.meanVelocity;
                    eyeTrialData.saccades.X_left.onsets_pursuit{subN, currentTrial} = trial.saccades.X_left.onsets_pursuit;
                    eyeTrialData.saccades.X_left.offsets_pursuit{subN, currentTrial} = trial.saccades.X_left.offsets_pursuit;
%                 end
%                 if ~isnan(eyeTrialData.saccades.X.sumAmplitude(subN, currentTrial))
%                     eyeTrialData.pursuit.gainSacSumAmpX(subN, currentTrial) = eyeTrialData.pursuit.gainX(subN, currentTrial)+eyeTrialData.saccades.X.sumAmplitude(subN, currentTrial)/10;
%                 else
%                     eyeTrialData.pursuit.gainSacSumAmpX(subN, currentTrial) = eyeTrialData.pursuit.gainX(subN, currentTrial);
%                 end
                
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
                
                eyeTrialData.pursuit.APvelocityX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.APvelocityX_interpol(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.onset(subN, currentTrial) = NaN; % visually driven pursuit onset
                eyeTrialData.pursuit.onsetSteadyState(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.onsetTrue(subN, currentTrial) = NaN; % original onset, could be earlier than visual stimulus onset
                eyeTrialData.pursuit.openLoopStartFrame(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.openLoopEndFrame(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.initialMeanVelocityX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.initialPeakVelocityX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.initialMeanAccelerationX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.initialPeakAccelerationX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.closedLoopMeanVelX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.gainX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.gainX_interpol(subN, currentTrial) = NaN;
%                 eyeTrialData.pursuit.gainSacSumAmpX(subN, currentTrial) = NaN;
                eyeTrialData.pursuit.initialVelChangeX(subN, currentTrial) = NaN;
                
                eyeTrialData.saccades.X_right.number(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_right.meanAmplitude(subN, currentTrial) = NaN;
                %             eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_right.meanDuration(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_right.sumAmplitude(subN, currentTrial) = NaN;
                %             eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = NaN;
                %             eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_right.onsets_pursuit{subN, currentTrial} = NaN;
                eyeTrialData.saccades.X_right.offsets_pursuit{subN, currentTrial} = NaN;
                
                eyeTrialData.saccades.X_left.number(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_left.meanAmplitude(subN, currentTrial) = NaN;
                %             eyeTrialData.saccades.X.maxAmplitude(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_left.meanDuration(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_left.sumAmplitude(subN, currentTrial) = NaN;
                %             eyeTrialData.saccades.X.peakVelocity(subN, currentTrial) = NaN;
                %             eyeTrialData.saccades.X.meanVelocity(subN, currentTrial) = NaN;
                eyeTrialData.saccades.X_left.onsets_pursuit{subN, currentTrial} = NaN;
                eyeTrialData.saccades.X_left.offsets_pursuit{subN, currentTrial} = NaN;
                
                eyeTrialDataSub.trial{1, currentTrial} = NaN; % for velocity traces
            end
        end
        cd([analysisPath '\analysis\Exp1'])
        save(['eyeTrialDataSub_' names{subN} '.mat'], 'eyeTrialDataSub');
    end
    save(['eyeTrialData_all_set' num2str(setN) 'exp1.mat'], 'eyeTrialData');
end