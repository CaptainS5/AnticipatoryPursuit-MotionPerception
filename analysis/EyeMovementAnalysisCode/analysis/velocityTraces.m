% plot velocity traces, just have a glance of the mean traces
% generate csv file for further plotting in R
initializeParas;

% only uncomment the experiment you want to look at
% Exp1, 10 people, main experiment
expN = 1;
names = nameSets{1}; 
eyeTrialData = expAll{1}.eyeTrialData;
RsaveFolder = [RFolder '\Exp1'];
probTotalN = 3;
colorProb = [8,48,107;66,146,198;198,219,239;66,146,198;8,48,107]/255; % all blue hues
probNames{1} = {'10', '30', '50'};
probNames{2} = {'50', '70', '90'};
probCons = [10 30 50 70 90];

% % Exp2, 8 people, fixation control
% expN = 2;
% names = names2; 
% eyeTrialData = expAll{2}.eyeTrialData;
% RsaveFolder = [RFolder '\Exp2'];
% probTotalN = 2;

% % Exp3, 9 people, low-coh context trials
% expN = 3;
% names = nameSets{3}; 
% eyeTrialData = expAll{3}.eyeTrialData;
% RsaveFolder = [RFolder '\Exp3'];
% probTotalN = 2;

% choose the grouping you want to achieve
groupName = {'standardVisual', 'perceptualVisual', 'perceptualVisualLperceived', 'perceptualVisualRperceived', ...
    'zeroPerceived', 'perceptualPerceived', 'incongruent', 'congruent'};
% incongruent--perceived motion is not the same as visual motion, currently
% not including 0-coh trials
% congruent--perceived motion is the same as visual motion
% naming by trial type (could include grouping rules) + group based on which direction (visual or perceived)
groupN = [7;8]; % corresponds to the listed rules... can choose multiple, just list as a vector
% when choosing multiple groupN, will plot each group rule in one figure

% choose which plot to look at now
individualPlots = 0;
averagedPlots = 1;
textFontSize = 8;

% flip every direction... to collapse left and right probability blocks
for subN = 1:length(names)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        eyeTrialData.choice(subN, :) = 1-eyeTrialData.choice(subN, :); % flip left (0) and right (1)
        eyeTrialData.coh(subN, :) = -eyeTrialData.coh(subN, :);
        eyeTrialData.rdkDir(subN, :) = -eyeTrialData.rdkDir(subN, :);
    end
end

%% align rdk offset, frame data for all trials
for subN = 1:size(names, 2)
    cd(analysisFolder)
    load(['eyeTrialDataExp' num2str(expN) '_Sub_' names{subN} '.mat']);
    frameLength(subN) = min(max(eyeTrialData.frameLog.rdkOff(subN, :)), (900+300+700)/1000*sampleRate); % only plot until 600ms
    lengthT = size(eyeTrialDataSub.trial, 2);
    frames{subN} = NaN(lengthT, frameLength(subN));
    
    probSub = unique(eyeTrialData.prob(subN, :));
    if probSub(1)<50
        signFlip=-1; % flip velocity direction...
    else
        signFlip=1;
    end
    
    for trialN = 1:lengthT
        if eyeTrialData.errorStatus(subN, trialN)==0
            endI = eyeTrialData.frameLog.rdkOff(subN, trialN);
            if endI>frameLength(subN)
                startI = endI-frameLength(subN)+1;
                startIF = 1;
            else
                startI = eyeTrialData.frameLog.fixationOn(subN, trialN);
                startIF = frameLength(subN)-endI+1;
            end
            frames{subN}(trialN, startIF:end) = signFlip*eyeTrialDataSub.trial{1, trialN}.DX_interpolSac(startI:endI);
        end
    end
end
maxFrameLength = max(frameLength);

% plotting parameters
minFrameLength = min(frameLength);
framePerSec = 1/sampleRate;
timePoints = [(1:minFrameLength)-minFrameLength+0.7*sampleRate]*framePerSec*1000; % align at the rdk offset...
% rdk onset is 0

%% calculate mean traces
% for plotting each coh level separately...
absCohLevels = [0.05; 0.1; 0.15];
for cohN = 1:3 % this is to plot each coh level separately
    
    for ii = 1:length(groupN)
%         [indiMean{ii}, allMean{ii}, trialNumber{ii}] = getMeanTraces(eyeTrialData, frames, frameLength, names, probCons, probTotalN, groupN(ii));
        [indiMean{ii}, allMean{ii}, trialNumber{ii}] = getMeanTraces(eyeTrialData, frames, frameLength, names, probCons, probTotalN, groupN(ii), absCohLevels(cohN));
    end
    
    %% Draw velocity trace plots
    for ii = 1:length(groupN)
        % plot mean traces in all probabilities for each participant
        if individualPlots
            cd([velTraceFolder, '\Exp', num2str(expN)])
            switch groupN(ii)
                case 1
                    yRange = [-12 12]; % individual standard trials
                case 2
                    yRange = [-7 7]; % individual pereptual trials
                case 3
                    yRange = [-7 7];
                case 4
                    yRange = [-7 7];
                case 5
                    yRange = [-4 4];
                case 6
                    yRange = [-7 7];
                case 7
                    yRange = [-7 7];
                case 8
                    yRange = [-7 7];
            end
            
            for subN = 1:size(names, 2)
                probSub = unique(eyeTrialData.prob(subN, :));
                if probSub(1)<50
                    probNameI = 1;
                else
                    probNameI = 2;
                end
                
                figure
                for probSubN = 1:size(probSub, 2)
                    probN = find(probCons==probSub(probSubN));
                    if probSub(1)<50
                        probNmerged = probTotalN+1-probN;
                    else
                        probNmerged = probN-(probTotalN-1);
                    end
                    plot(timePoints, indiMean{ii}{probNmerged}.left(subN, (maxFrameLength-minFrameLength+1):end), '--', 'color', colorProb(probN, :)); %, 'LineWidth', 1)
                    text(timePoints(end), indiMean{ii}{probNmerged}.left(subN, end), num2str(trialNumber{ii}{probNmerged}.left(subN, 1)), 'color', colorProb(probN, :), 'FontSize',textFontSize)
                    hold on
                    p{probSubN} = plot(timePoints, indiMean{ii}{probNmerged}.right(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorProb(probN, :)); %, 'LineWidth', 1);
                    text(timePoints(end), indiMean{ii}{probNmerged}.right(subN, end), num2str(trialNumber{ii}{probNmerged}.right(subN, 1)), 'color', colorProb(probN, :), 'FontSize',textFontSize)
                end
                line([-300 -300], [min(yRange) max(yRange)],'Color','k','LineStyle','--')
                line([-50 -50], [min(yRange) max(yRange)],'Color','r','LineStyle','--')
                line([50 50], [min(yRange) max(yRange)],'Color','r','LineStyle','--')
                legend([p{:}], probNames{probNameI}, 'Location', 'NorthWest')
                title(groupName{groupN(ii)})
                xlabel('Time (ms)')
                ylabel('Horizontal eye velocity (deg/s)')
                xlim([-500 700])
                ylim(yRange)
                box off
                saveas(gcf, ['velTrace_' groupName{groupN(ii)} '_AllProbs_Exp' num2str(expN) '_' names{subN} '.pdf'])
            end
        end
        
        % plot mean traces of all participants in all probabilities
        if averagedPlots
            cd(velTraceFolder)
            switch groupN(ii)
                case 1
                    yRange = [-10 10]; % average standard trials
                case 2
                    yRange = [-4 4]; % average pereptual trials
                case 3
                    yRange = [-4 4];
                case 4
                    yRange = [-4 4];
                case 5
                    yRange = [-4 4];
                case 6
                    yRange = [-4 4];
                case 7
                    yRange = [-4 4];
                case 8
                    yRange = [-4 4];
            end
            
            figure
            for probNmerged = 1:probTotalN
                plot(timePoints, allMean{ii}{probNmerged}.left, '--', 'color', colorProb(probNmerged+probTotalN-1, :)); %, 'LineWidth', 1)
                hold on
                p{probNmerged} = plot(timePoints, allMean{ii}{probNmerged}.right, 'color', colorProb(probNmerged+probTotalN-1, :)); %, 'LineWidth', 1);
            end
            line([-300 -300], [min(yRange) max(yRange)],'Color','k','LineStyle','--')
            line([-50 -50], [min(yRange) max(yRange)],'Color','r','LineStyle','--')
            line([50 50], [min(yRange) max(yRange)],'Color','r','LineStyle','--')
            legend([p{:}], probNames{2}, 'Location', 'NorthWest')
            title(['coh ', num2str(absCohLevels(cohN)), ',', groupName{groupN(ii)}])
            xlabel('Time (ms)')
            ylabel('Horizontal eye velocity (deg/s)')
            xlim([-500 700])
            ylim(yRange)
            box off
            saveas(gcf, ['velTrace_coh' num2str(absCohLevels(cohN)) '_' groupName{groupN(ii)} '_all_exp' num2str(expN) '.pdf'])
        end
    end
end

%% generate csv files, each file for one probability condition
% % each row is the mean velocity trace of one participant
% % use the min frame length--the lengeth where all participants have
% % valid data points
% % cd(RsaveFolder)
% % averaged traces
% for ii = 1:length(groupN)
%     for probNmerged = 1:probTotalN
%         velTAverageSub = [];
%         for binN = 1:2
%             if binN==1
%                 dataTemp = indiMean{ii}{probNmerged}.left(:, (maxFrameLength-minFrameLength+1):end);
%             else
%                 dataTemp = indiMean{ii}{probNmerged}.right(:, (maxFrameLength-minFrameLength+1):end);
%             end
%             for subN = 1:size(names, 2)
%                 velTAverageSub((binN-1)*length(names)+subN, :) = dataTemp(subN, :);
%             end
%         end
%         csvwrite(['velocityTrace_' groupName{groupN(ii)} '_exp' num2str(expN) '_prob' num2str(probCons(probNmerged+probTotalN-1)), '.csv'], velTAverageSub)
%     end
% end

%%
function [indiMean, allMean, trialNumber] = getMeanTraces(eyeTrialData, frames, frameLength, names, probCons, probTotalN, groupN, coh)
% calculate mean traces
% indiMean: each row is one participant
% allMean: averaged across participants
% trialNumber: corresponds to indiMean, the trial number for each element

maxFrameLength = max(frameLength);
minFrameLength = min(frameLength);
for probNmerged = 1:probTotalN
    % first initialize; if a participant doesn't have the corresponding
    % prob condition, then the values remain NaN and will be ignored later
    indiMean{probNmerged}.left = NaN(length(names), maxFrameLength);
    indiMean{probNmerged}.right = NaN(length(names), maxFrameLength);
    
    for subN = 1:size(names, 2)
        probSub = unique(eyeTrialData.prob(subN, :));
        if probSub(1)<50
            probN = probTotalN+1-probNmerged;
            probNameI = 1;
        else
            probN = probNmerged+probTotalN-1;
            probNameI = 2;
        end
        
        tempStartI = maxFrameLength-frameLength(subN)+1;
        switch groupN
            case 1 % standard trials by visual motion
                leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)<0 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==1);
                rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)>0 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==1);
            case 2 % perceptual trials by visual motion
                leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)<0 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0);
                rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)>0 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0);
            case 3 % perceptual trials with left visual motion, by perceived motion
                leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)<0 ...
                    & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.choice(subN, :)==0);
                rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)<0 ...
                    & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.choice(subN, :)==1);
            case 4 % perceptual trials with right visual motion, by perceived motion
                leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)>0 ...
                    & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.choice(subN, :)==0);
                rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)>0 ...
                    & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.choice(subN, :)==1);
            case 5 % zero coherence trials, by perceived motion
                leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)==0 ...
                    & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==0);
                rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)==0 ...
                    & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==1);
            case 6 % perceptual trials, by perceived motion
                leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                    & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==0);
                rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                    & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==1);
            case 7 % perceptual trials misperceived, not including 0 coh, by perceived motion
                leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                    & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==0 & eyeTrialData.rdkDir(subN, :)>0 & abs(eyeTrialData.coh(subN, :))==coh);
                rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                    & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==1  & eyeTrialData.rdkDir(subN, :)<0  & abs(eyeTrialData.coh(subN, :))==coh);
            case 8 % perceptual trials correctly perceived
                leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                    & eyeTrialData.rdkDir(subN, :)<0 & eyeTrialData.choice(subN, :)==0 & eyeTrialData.prob(subN, :)==probCons(probN) & abs(eyeTrialData.coh(subN, :))==coh);
                rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                    & eyeTrialData.rdkDir(subN, :)>0 & eyeTrialData.choice(subN, :)==1 & eyeTrialData.prob(subN, :)==probCons(probN) & abs(eyeTrialData.coh(subN, :))==coh);
        end
        
        % individual mean traces
        indiMean{probNmerged}.left(subN, tempStartI:end) = nanmean(frames{subN}(leftIdx, :), 1);
        indiMean{probNmerged}.right(subN, tempStartI:end) = nanmean(frames{subN}(rightIdx, :), 1);
        
        trialNumber{probNmerged}.left(subN, 1) = length(leftIdx);
        trialNumber{probNmerged}.right(subN, 1) = length(rightIdx);
    end
    
    % collapsed all participants
    allMean{probNmerged}.left = nanmean(indiMean{probNmerged}.left(:, (maxFrameLength-minFrameLength+1):end), 1);
    allMean{probNmerged}.right = nanmean(indiMean{probNmerged}.right(:, (maxFrameLength-minFrameLength+1):end), 1);
end

end