% analysis of anticipatory pursuit
% currently take the window of -50ms to 50ms around rdk onset

clear all; close all; clc

names = {'YZ'};
sampleRate = 1000;
% for plotting
minVel = [-6];
maxVel = [12];
folder = pwd;

% dirCons = [-1 1]; % -1=left, 1=right
% dirNames = {'left' 'right'};
colorPlotting = [255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability

%% compare different probabilities
% separate perceptual and standard trials
for subN = 1:size(names, 2)
    cd(folder)
    load(['eyeData_' names{subN} '.mat']);
    probCons = unique(eyeTrialData.prob(eyeTrialData.errorStatus==0));
    cd ..
    
    anticipatoryP{subN}.standard = NaN(500, size(probCons, 2));
    anticipatoryP{subN}.perceptual = NaN(182, size(probCons, 2));
    for probN = 1:size(probCons, 2)
        % standard trials
        validI = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==1 & eyeTrialData.prob(subN, :)==probCons(probN));
        lengthI = length(validI);
        
        for validTrialN = 1:lengthI
            startI = eyeTrialData.frameLog.rdkOn(subN, validI(validTrialN))-ms2frames(50);
            endI = eyeTrialData.frameLog.rdkOn(subN, validI(validTrialN))+ms2frames(50);
            anticipatoryP{subN}.standard(validTrialN, probN) = nanmean(eyeTrialData.trial{subN, validI(validTrialN)}.DX_noSac(startI:endI));
        end
        
        % then perceptual trials
        validI = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.prob(subN, :)==probCons(probN));
        lengthI = length(validI); 
        
        % last half standard trials
        for validTrialN = 1:lengthI
            startI = eyeTrialData.frameLog.rdkOn(subN, validI(validTrialN))-ms2frames(50);
            endI = eyeTrialData.frameLog.rdkOn(subN, validI(validTrialN))+ms2frames(50);
            anticipatoryP{subN}.perceptual(validTrialN, probN) = nanmean(eyeTrialData.trial{subN, validI(validTrialN)}.DX_noSac(startI:endI));
        end
    end
    
    cd(folder)
    % boxplots
    figure % plot mean anticipatory pursuit in all probabilities, just a rough check...
    subplot(1, 2, 1)
    hold on
    boxplot(anticipatoryP{subN}.standard)
    legend({'50' '70' '90'}, 'box', 'off')
    title('standard trials')
    ylabel('Horizontal eye velocity (deg/s)')
%     ylim([minVel maxVel])
    box off
    
    subplot(1, 2, 2)
    hold on
    boxplot(anticipatoryP{subN}.perceptual)
    legend({'50' '70' '90'}, 'box', 'off')
    title('perceptual trials')
    ylabel('Horizontal eye velocity (deg/s)')
%     ylim([minVel maxVel])
    box off
    saveas(gca, ['anticipatoryP_boxplot_', names{subN}, '.pdf'])
    
    % grouped bars
    for probN = 1:size(probCons, 2)
        meanAP(1, probN) = nanmean(anticipatoryP{subN}.standard(:, probN));
        stdAP(1, probN) = nanstd(anticipatoryP{subN}.standard(:, probN));
    end
    errorbar_groups(meanAP,zeros(size(stdAP)), stdAP, ...
        'bar_width',0.75,'errorbar_width',0.5, ...
        'bar_names',{'50','70','90'});
    title('standard trials')
    ylabel('Horizontal eye velocity (deg/s)')
%     ylim([-0.5 5])
    box off
    saveas(gca, ['anticipatoryP_standard_', names{subN}, '.pdf'])
    
    %     subplot(1, 2, 2)
    for probN = 1:size(probCons, 2)
        meanAP(1, probN) = nanmean(anticipatoryP{subN}.perceptual(:, probN));
        stdAP(1, probN) = nanstd(anticipatoryP{subN}.perceptual(:, probN));
    end
    errorbar_groups(meanAP,zeros(size(stdAP)),stdAP,  ...
        'bar_width',0.75,'errorbar_width',0.5, ...
        'bar_names',{'50','70','90'});
    title('perceptual trials')
    ylabel('Horizontal eye velocity (deg/s)')
%     ylim([-0.5 5])
    box off
    saveas(gca, ['anticipatoryP_perceptual_', names{subN}, '.pdf'])
end

%% compare first and second half of the trials
% % separate perceptual and standard trials
% for subN = 1:size(names, 2)
%     cd(folder)
%     load(['eyeData_' names{subN} '.mat']);
%     probCons = unique(eyeTrialData.prob);
%     cd ..
% 
%     for probN = 1:size(probCons, 2)
%         % standard trials
%         validI = find(eyeTrialData.errorStatus(subN, :)~=1 & eyeTrialData.trialType(subN, :)==1 & eyeTrialData.prob(subN, :)==probCons(probN));
%         lengthF = round(length(validI)/2); % first half of the trials
%         lengthL = length(validI)-lengthF; % last half of the trials
%         anticipatoryP{subN, probN}.firstStandard = NaN(lengthF, 1); % align the reversal; filled with NaN
%         anticipatoryP{subN, probN}.lastStandard = NaN(lengthL, 1); % align the reversal; filled with NaN
%         % rows are trials, columns are frames
% 
%         % first half standard trials, fill in the velocity trace of each frame
%         % use interpolate points for a better velocity trace
%         for validTrialN = 1:lengthF
%             startI = eyeTrialData.frameLog.rdkOn(subN, validI(validTrialN))-ms2frames(50);
%             endI = eyeTrialData.frameLog.rdkOn(subN, validI(validTrialN))+ms2frames(50);
%             anticipatoryP{subN, probN}.firstStandard(validTrialN, 1) = nanmean(eyeTrialData.trial{subN, validI(validTrialN)}.DX_noSac(startI:endI));
%         end
% 
%         % last half standard trials
%         for validTrialN = 1:lengthL
%             startI = eyeTrialData.frameLog.rdkOn(subN, validI(validTrialN+lengthF))-ms2frames(50);
%             endI = eyeTrialData.frameLog.rdkOn(subN, validI(validTrialN+lengthF))+ms2frames(50);
%             anticipatoryP{subN, probN}.lastStandard(validTrialN, 1) = nanmean(eyeTrialData.trial{subN, validI(validTrialN+lengthF)}.DX_noSac(startI:endI));
%         end
% 
%         % then perceptual trials
%         validI = find(eyeTrialData.errorStatus(subN, :)~=1 & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.prob(subN, :)==probCons(probN));
%         lengthF = round(length(validI)/2); % first half of the trials
%         lengthL = length(validI)-lengthF; % last half of the trials
%         anticipatoryP{subN, probN}.firstPerceptual = NaN(lengthF, 1); % align the reversal; filled with NaN
%         anticipatoryP{subN, probN}.lastPerceptual = NaN(lengthL, 1); % align the reversal; filled with NaN
%         % rows are trials, columns are frames
% 
%         % first half standard trials, fill in the velocity trace of each frame
%         % use interpolate points for a better velocity trace
%         for validTrialN = 1:lengthF
%             startI = eyeTrialData.frameLog.rdkOn(subN, validI(validTrialN))-ms2frames(50);
%             endI = eyeTrialData.frameLog.rdkOn(subN, validI(validTrialN))+ms2frames(50);
%             anticipatoryP{subN, probN}.firstPerceptual(validTrialN, 1) = nanmean(eyeTrialData.trial{subN, validI(validTrialN)}.DX_noSac(startI:endI));
%         end
% 
%         % last half standard trials
%         for validTrialN = 1:lengthL
%             startI = eyeTrialData.frameLog.rdkOn(subN, validI(validTrialN+lengthF))-ms2frames(50);
%             endI = eyeTrialData.frameLog.rdkOn(subN, validI(validTrialN+lengthF))+ms2frames(50);
%             anticipatoryP{subN, probN}.lastPerceptual(validTrialN, 1) = nanmean(eyeTrialData.trial{subN, validI(validTrialN+lengthF)}.DX_noSac(startI:endI));
%         end
%     end
% 
% %     figure % plot mean anticipatory pursuit in all probabilities, just a rough check...
% %     subplot(1, 2, 1)
%     for probN = 1:size(probCons, 2)
%         meanAP(1, probN) = nanmean(anticipatoryP{subN, probN}.firstStandard);
%         stdAP(1, probN) = nanstd(anticipatoryP{subN, probN}.firstStandard);
%         meanAP(2, probN) = nanmean(anticipatoryP{subN, probN}.lastStandard);
%         stdAP(2, probN) = nanstd(anticipatoryP{subN, probN}.lastStandard);
%     end
%     errorbar_groups(meanAP,stdAP, ...
%       'bar_width',0.75,'errorbar_width',0.5, ...
%       'bar_names',{'50','70','90'});
%     legend({'first', 'last'}, 'Location', 'NorthWest', 'box', 'off')
%     title('standard trials')
%     ylabel('Horizontal eye velocity (deg/s)')
%     ylim([-0.5 4])
%     box off
%     saveas(gca, ['anticipatoryP_standard_', names{subN}, '.pdf'])
% 
% %     subplot(1, 2, 2)
%     for probN = 1:size(probCons, 2)
%         meanAP(1, probN) = nanmean(anticipatoryP{subN, probN}.firstPerceptual);
%         stdAP(1, probN) = nanstd(anticipatoryP{subN, probN}.firstPerceptual);
%         meanAP(2, probN) = nanmean(anticipatoryP{subN, probN}.lastPerceptual);
%         stdAP(2, probN) = nanstd(anticipatoryP{subN, probN}.lastPerceptual);
%     end
%     errorbar_groups(meanAP,stdAP, ...
%       'bar_width',0.75,'errorbar_width',0.5, ...
%       'bar_names',{'50','70','90'});
%     legend({'first', 'last'}, 'Location', 'NorthWest', 'box', 'off')
%     title('perceptual trials')
%     ylabel('Horizontal eye velocity (deg/s)')
%     ylim([-0.5 4])
%     box off
%     saveas(gca, ['anticipatoryP_perceptual_', names{subN}, '.pdf'])
% end