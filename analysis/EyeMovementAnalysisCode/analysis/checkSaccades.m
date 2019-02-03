% use eyeDataAll to do more analysis with saccades
% how many saccades are in the gap duration/anticipatory pursuit window?
% what are the directions of these saccades?
clear all; close all; clc

names = {'tW'};
sampleRate = 1000;
% for plotting
folder = pwd;

dirCons = [-1 1]; % -1=left, 1=right
dirNames = {'left' 'right'};
colorPlotting = [255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability

%% compare different probabilities
% separate perceptual and standard trials
for subN = 1:size(names, 2)
    cd(folder)
    load(['eyeData_' names{subN} '.mat']);
    probCons = unique(eyeTrialData.prob);
    cd ..
    
    saccadesNum{subN}.left = zeros(682, size(probCons, 2));
    saccadesNum{subN}.right = zeros(682, size(probCons, 2)); % number of saccades during the anticipatory window
    for probN = 1:size(probCons, 2)
        validI = find(eyeTrialData.errorStatus(subN, :)~=1 & eyeTrialData.trialType(subN, :)==1 & eyeTrialData.prob(subN, :)==probCons(probN));
        lengthI = length(validI);
        
        for validTrialN = 1:lengthI
            trialI = mod(validI(validTrialN), 682); % index of the trial in that probability block
            if trialI==0
                trialI = 682;
            end
            startI = eyeTrialData.frameLog.fixationOff(subN, validI(validTrialN));
            endI = eyeTrialData.frameLog.rdkOn(subN, validI(validTrialN))+ms2frames(50); % the window to check whether there is any horizontal saccades
            if ~isempty(eyeTrialData.trial{subN, validI(validTrialN)}.saccades.X.onsets) % if there are any horizontal saccades
                for ii = 1:length(eyeTrialData.trial{subN, validI(validTrialN)}.saccades.X.onsets)
                    if eyeTrialData.trial{subN, validI(validTrialN)}.saccades.X.onsets(ii)>=startI && ...
                            eyeTrialData.trial{subN, validI(validTrialN)}.saccades.X.onsets(ii)<endI % if saccade is during the window
                        onset = eyeTrialData.trial{subN, validI(validTrialN)}.saccades.X.onsets(ii);
                        offset = eyeTrialData.trial{subN, validI(validTrialN)}.saccades.X.offsets(ii);
                        if eyeTrialData.trial{subN, validI(validTrialN)}.eyeDX_filt(round((onset+offset)/2), 1)<0 % leftward saccades, negative velocity
                            saccadesNum{subN}.left(trialI, probN) = saccadesNum{subN}.left(trialI, probN)-1;
                        elseif eyeTrialData.trial{subN, validI(validTrialN)}.eyeDX_filt(round((onset+offset)/2), 1)>0
                            saccadesNum{subN}.right(trialI, probN) = saccadesNum{subN}.right(trialI, probN)+1;
                        end
                    end
                end
            end
        end
    end
    saccadesNum{subN}.left(saccadesNum{subN}.left==0) = NaN;
    saccadesNum{subN}.right(saccadesNum{subN}.right==0) = NaN;
    
    cd(folder)
    figure
    subplot(3, 1, 1)
    plot(1:682, saccadesNum{subN}.left(:, 1), '+', 'MarkerSize', 5)
    hold on
    plot(1:682, saccadesNum{subN}.right(:, 1), '+', 'MarkerSize', 5)
    title(['prob 50, left=', num2str(abs(nansum(saccadesNum{subN}.left(:, 1)))), ', right=', num2str(nansum(saccadesNum{subN}.right(:, 1)))])
    xlabel('Trial')
    ylabel('Sac Num')
    ylim([-2 2])
    box off
    
    subplot(3, 1, 2)
    plot(1:682, saccadesNum{subN}.left(:, 2), '+', 'MarkerSize', 5)
    hold on
    plot(1:682, saccadesNum{subN}.right(:, 2), '+', 'MarkerSize', 5)
    title(['prob 70, left=', num2str(abs(nansum(saccadesNum{subN}.left(:, 2)))), ', right=', num2str(nansum(saccadesNum{subN}.right(:, 2)))])
    xlabel('Trial')
    ylabel('Sac Num')
    ylim([-2 2])
    box off
    
    subplot(3, 1, 3)
    plot(1:682, saccadesNum{subN}.left(:, 3), '+', 'MarkerSize', 5)
    hold on
    plot(1:682, saccadesNum{subN}.right(:, 3), '+', 'MarkerSize', 5)
    title(['prob 90, left=', num2str(abs(nansum(saccadesNum{subN}.left(:, 3)))), ', right=', num2str(nansum(saccadesNum{subN}.right(:, 3)))])
    xlabel('Trial')
    ylabel('Sac Num')
    ylim([-2 2])
    box off
        
    saveas(gca, ['saccadeDuringAP_', names{subN}, '.pdf'])
end
