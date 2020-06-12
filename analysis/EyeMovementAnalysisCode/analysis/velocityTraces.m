% plot velocity traces, just have a glance of the mean traces
% generate csv file for further plotting in R
initializeParas;

% only uncomment the experiment you want to look at
% % Exp1, 10 people, main experiment
% expN = 1;
% names = nameSets{1}; 
% slidingWFolder = [slidingWFolder '\Exp1'];
% eyeTrialData = expAll{1}.eyeTrialData;
% RsaveFolder = [RFolder '\Exp1'];
% probTotalN = 3;
% colorProb = [8,48,107;66,146,198;198,219,239;66,146,198;8,48,107]/255; % all blue hues
% probNames{1} = {'10', '30', '50'};
% probNames{2} = {'50', '70', '90'};
% probCons = [10 30 50 70 90];

% % Exp2, 8 people, fixation control
% expN = 2;
% names = names2; 
% slidingWFolder = [slidingWFolder '\Exp2'];
% eyeTrialData = expAll{2}.eyeTrialData;
% RsaveFolder = [RFolder '\Exp2'];
% probTotalN = 2;

% Exp3, 9 people, low-coh context trials
expN = 3;
names = nameSets{3}; 
slidingWFolder = [slidingWFolder '\Exp3'];
eyeTrialData = expAll{3}.eyeTrialData;
RsaveFolder = [RFolder '\Exp3'];
probTotalN = 2;

% choose the grouping you want to achieve
groupName = {'standardVisual', 'perceptualVisual', 'perceptualVisualLpercepved', 'perceptualVisualRperceived', 'zeroPerceived', 'perceptualPerceived', 'wrongPerceptualPerceived'};
% naming by trial type (could include grouping rules) + group based on which direction (visual or perceived)
groupN = 7; % corresponds to the listed rules... can choose multiple, just list as a vector
% when choosing multiple groupN, will plot each group rule in one figure

% choose which plot to look at now
individualPlots = 1;
averagedPlots = 1;

% for plotting, choose one and set as 'yRange'
% yRange = [-12 12]; % individual standard trials
% yRange = [-7 7]; % individual pereptual trials
yRange = [-4 4]; % averaged perceptual trials

% flip every direction... to collapse left and right probability blocks
for subN = 1:length(names)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        eyeTrialData.choice(subN, :) = 1-eyeTrialData.choice(subN, :); % flip left (0) and right (1)
        eyeTrialData.coh(subN, :) = -eyeTrialData.coh(subN, :);
        eyeTrialData.rdkDir(subN, :) = -eyeTrialData.rdkDir(subN, :);
    end
end
cohLevels = unique(eyeTrialData.coh(1, eyeTrialData.trialType(1, :)==0))';

%% align rdk offset, frame data for all trials
for subN = 1:size(names, 2)
    cd(analysisFolder)
    load(['eyeTrialDataSubExp' num2str(expN) '_' names{subN} '.mat']);
    frameLength(subN) = min(max(eyeTrialData.frameLog.rdkOff(subN, :)), (900+300+700)/1000*sampleRate);
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
for ii = 1:length(groupN)
    [indiMean{ii}, allMean{ii}] = getMeanTraces(eyeTrialData, frames, frameLength, names, probCons, probTotalN, groupN(ii));
end

%% Draw velocity trace plots
cd(velTraceFolder)
for ii = 1:length(groupN)
    % plot mean traces in all probabilities for each participant
    if individualPlots
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
                hold on
                p{probSubN} = plot(timePoints, indiMean{ii}{probNmerged}.right(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorProb(probN, :)); %, 'LineWidth', 1);
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
        figure
        for probNmerged = 1:probTotalN
            plot(timePoints, allMean{ii}{probNmerged}.left, '--', 'color', colorProb(probNmerged+probTotalN-1, :)); %, 'LineWidth', 1)
            hold on
            p{probNmerged} = plot(timePoints, allMean{ii}{probNmerged}.right, 'color', colorProb(probNmerged+probTotalN-1, :)); %, 'LineWidth', 1);
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
        saveas(gcf, ['velTrace_' groupName{groupN(ii)} '_all_exp' num2str(expN) '.pdf'])
    end
    
end

%% generate csv files, each file for one probability condition
% each row is the mean velocity trace of one participant
% use the min frame length--the lengeth where all participants have
% valid data points
cd(RsaveFolder)
for ii = 1:length(groupN)
    for probNmerged = 1:probTotalN
        velTAverageSub = [];
        for binN = 1:2
            if binN==1
                dataTemp = indiMean{ii}{probNmerged}.left(:, (maxFrameLength-minFrameLength+1):end);
            else
                dataTemp = indiMean{ii}{probNmerged}.right(:, (maxFrameLength-minFrameLength+1):end);
            end
            for subN = 1:size(names, 2)
                velTAverageSub((binN-1)*length(names)+subN, :) = dataTemp(subN, :);
            end
        end
        csvwrite(['velocityTrace_' groupName{groupN(ii)} '_exp' num2str(expN) '_prob' num2str(probCons(probNmerged+probTotalN-1)), '.csv'], velTAverageSub)
    end
end

%%
function [indiMean, allMean] = getMeanTraces(eyeTrialData, frames, frameLength, names, probCons, probTotalN, groupN)
% calculate mean traces
% indiMean: each row is one participant
% allMean: averaged across participants

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
            case 7 % perceptual trials misperceived, include 0 coh, by perceived motion
                leftIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                    & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==0 & eyeTrialData.rdkDir(subN, :)>=0);
                rightIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                    & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==1  & eyeTrialData.rdkDir(subN, :)<=0);
        end
        
        % individual mean traces
        indiMean{probNmerged}.left(subN, tempStartI:end) = nanmean(frames{subN}(leftIdx, :));
        indiMean{probNmerged}.right(subN, tempStartI:end) = nanmean(frames{subN}(rightIdx, :));
    end
    
    % collapsed all participants
    allMean{probNmerged}.left = nanmean(indiMean{probNmerged}.left(:, (maxFrameLength-minFrameLength+1):end), 1);
    allMean{probNmerged}.right = nanmean(indiMean{probNmerged}.right(:, (maxFrameLength-minFrameLength+1):end), 1);
end

end