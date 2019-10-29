% plot velocity traces, generate csv file for plotting in R
initializeParas;

% for plotting
yStandardRange = [-12 12];
yPerceptRange = [-7 7];

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
    load(['eyeTrialDataSub_' names{subN} '.mat']);
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

% calculate mean traces
for probNmerged = 1:2
    % first initialize; if a participant doesn't have the corresponding
    % prob condition, then the values remain NaN and will be ignored later
    meanVel{probNmerged}.leftStandard = NaN(length(names), maxFrameLength);
    meanVel{probNmerged}.rightStandard = NaN(length(names), maxFrameLength);
    meanVel{probNmerged}.leftPerceptual = NaN(length(names), maxFrameLength);
    meanVel{probNmerged}.rightPerceptual = NaN(length(names), maxFrameLength);
    meanVel{probNmerged}.vpLL = NaN(length(names), maxFrameLength);
    meanVel{probNmerged}.vpLR = NaN(length(names), maxFrameLength);
    meanVel{probNmerged}.vpRL = NaN(length(names), maxFrameLength);
    meanVel{probNmerged}.vpRR = NaN(length(names), maxFrameLength);
    meanVel{probNmerged}.zeroL = NaN(length(names), maxFrameLength);
    meanVel{probNmerged}.zeroR = NaN(length(names), maxFrameLength);
    meanVel{probNmerged}.ppL = NaN(length(names), maxFrameLength);
    meanVel{probNmerged}.ppR = NaN(length(names), maxFrameLength);
%     stdVel{probN}.leftStandard = NaN(length(names), maxFrameLength);
%     stdVel{probN}.rightStandard = NaN(length(names), maxFrameLength);
%     stdVel{probN}.leftPerceptual = NaN(length(names), maxFrameLength);
%     stdVel{probN}.rightPerceptual = NaN(length(names), maxFrameLength);
    for subN = 1:size(names, 2)
        probSub = unique(eyeTrialData.prob(subN, :));
        if probSub(1)<50
            probN = 3-probNmerged;
            probNameI = 1;
        else
            probN = probNmerged+1;
            probNameI = 2;
        end
        
        tempStartI = maxFrameLength-frameLength(subN)+1;
        leftSIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)<0 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==1);
        rightSIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)>0 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==1);
        leftPIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)<0 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0);
        rightPIdx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)>0 & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0);
        % trials separated by visual x perception
        vpLLidx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)<0 ...
            & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.choice(subN, :)==0);
        vpLRidx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)<0 ...
            & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.choice(subN, :)==1);
        vpRLidx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)>0 ...
            & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.choice(subN, :)==0);
        vpRRidx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)>0 ...
            & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.choice(subN, :)==1);  
        % zero coherence trials separated by perception
        zeroLidx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)==0 ...
            & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==0);  
        zeroRidx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.rdkDir(subN, :)==0 ...
            & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==1); 
        % perceptual trials separated by perception
        ppLidx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
            & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==0);  
        ppRidx = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
            & eyeTrialData.prob(subN, :)==probCons(probN) & eyeTrialData.choice(subN, :)==1); 
        
        % individual mean traces
        meanVel{probNmerged}.leftStandard(subN, tempStartI:end) = nanmean(frames{subN}(leftSIdx, :));
        meanVel{probNmerged}.rightStandard(subN, tempStartI:end) = nanmean(frames{subN}(rightSIdx, :));
        meanVel{probNmerged}.leftPerceptual(subN, tempStartI:end) = nanmean(frames{subN}(leftPIdx, :));
        meanVel{probNmerged}.rightPerceptual(subN, tempStartI:end) = nanmean(frames{subN}(rightPIdx, :));
        meanVel{probNmerged}.vpLL(subN, tempStartI:end) = nanmean(frames{subN}(vpLLidx, :));
        meanVel{probNmerged}.vpLR(subN, tempStartI:end) = nanmean(frames{subN}(vpLRidx, :));
        meanVel{probNmerged}.vpRL(subN, tempStartI:end) = nanmean(frames{subN}(vpRLidx, :));
        meanVel{probNmerged}.vpRR(subN, tempStartI:end) = nanmean(frames{subN}(vpRRidx, :));
        meanVel{probNmerged}.zeroL(subN, tempStartI:end) = nanmean(frames{subN}(zeroLidx, :));
        meanVel{probNmerged}.zeroR(subN, tempStartI:end) = nanmean(frames{subN}(zeroRidx, :));
        meanVel{probNmerged}.ppL(subN, tempStartI:end) = nanmean(frames{subN}(ppLidx, :));
        meanVel{probNmerged}.ppR(subN, tempStartI:end) = nanmean(frames{subN}(ppRidx, :));
        %             stdVel{probN}.firstStandard(subN, tempStartI:end) = nanstd(frames{subN, probN}.firstStandard);
        %             stdVel{probN}.lastStandard(subN, tempStartI:end) = nanstd(frames{subN, probN}.lastStandard);
        %             stdVel{probN}.firstPerceptual(subN, tempStartI:end) = nanstd(frames{subN, probN}.firstPerceptual);
        %             stdVel{probN}.lastPerceptual(subN, tempStartI:end) = nanstd(frames{subN, probN}.lastPerceptual);
    end
    
    % plotting parameters
    minFrameLength = min(frameLength);
    framePerSec = 1/sampleRate;
    timePoints = [(1:minFrameLength)-minFrameLength+0.7*sampleRate]*framePerSec*1000; % align at the rdk offset...
    % rdk onset is 0
    
    % collapsed all participants
    velMean{probNmerged}.leftStandard = nanmean(meanVel{probNmerged}.leftStandard(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probNmerged}.rightStandard = nanmean(meanVel{probNmerged}.rightStandard(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probNmerged}.leftPerceptual = nanmean(meanVel{probNmerged}.leftPerceptual(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probNmerged}.rightPerceptual = nanmean(meanVel{probNmerged}.rightPerceptual(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probNmerged}.vpLL = nanmean(meanVel{probNmerged}.vpLL(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probNmerged}.vpLR = nanmean(meanVel{probNmerged}.vpLR(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probNmerged}.vpRL = nanmean(meanVel{probNmerged}.vpRL(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probNmerged}.vpRR = nanmean(meanVel{probNmerged}.vpRR(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probNmerged}.zeroL = nanmean(meanVel{probNmerged}.zeroL(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probNmerged}.zeroR = nanmean(meanVel{probNmerged}.zeroR(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probNmerged}.ppL = nanmean(meanVel{probNmerged}.ppL(:, (maxFrameLength-minFrameLength+1):end), 1);
    velMean{probNmerged}.ppR = nanmean(meanVel{probNmerged}.ppR(:, (maxFrameLength-minFrameLength+1):end), 1);
end

%% Draw velocity trace plots
cd(velTraceFolder)
%% plot mean traces in all probabilities for each participant
for subN = 1:size(names, 2)
    probSub = unique(eyeTrialData.prob(subN, :));
    if probSub(1)<50
        probNameI = 1;
    else
        probNameI = 2;
    end
    
%     % just separate visual motion, and standard/perceptual trials
%     figure 
%     subplot(2, 1, 1)
%     for probSubN = 1:size(probSub, 2)
%         probN = find(probCons==probSub(probSubN));
%         if probSub(1)<50
%             probNmerged = 3-probN;
%         else
%             probNmerged = probN-1;
%         end
%         plot(timePoints, meanVel{probNmerged}.leftStandard(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorProb(probN, :)); %, 'LineWidth', 1)
%         hold on
%         p{probSubN} = plot(timePoints, meanVel{probNmerged}.rightStandard(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorProb(probN, :)); %, 'LineWidth', 1);
%     end
%     % line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
%     % line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
%     % line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
%     legend([p{1}, p{2}], probNames{probNameI}, 'Location', 'NorthWest')
%     title('standard trials')
%     xlabel('Time (ms)')
%     ylabel('Horizontal velocity (deg/s)')
%     xlim([-500 700])
%     ylim(yStandardRange)
%     box off
%     
%     subplot(2, 1, 2)
%     for probSubN = 1:size(probSub, 2)
%         probN = find(probCons==probSub(probSubN));
%         if probSub(1)<50
%             probNmerged = 3-probN;
%         else
%             probNmerged = probN-1;
%         end
%         plot(timePoints, meanVel{probNmerged}.leftPerceptual(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorProb(probN, :)); %, 'LineWidth', 1)
%         hold on
%         p{probSubN} = plot(timePoints, meanVel{probNmerged}.rightPerceptual(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorProb(probN, :)); %, 'LineWidth', 1);
%     end
%     % line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
%     % line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
%     % line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
%     legend([p{1}, p{2}], probNames{probNameI}, 'Location', 'NorthWest')
%     title('perceptual trials')
%     xlabel('Time (ms)')
%     ylabel('Horizontal velocity (deg/s)')
%     xlim([-500 700])
%     ylim(yPerceptRange)
%     box off
%     saveas(gca, ['velocityAllProbs_' names{subN} '.pdf'])
    
%     % perceptual trials, visual x perceived motion
%     figure 
%     subplot(2, 1, 1) % visual motion left
%     for probSubN = 1:size(probSub, 2)
%         probN = find(probCons==probSub(probSubN));
%         if probSub(1)<50
%             probNmerged = 4-probN;
%         else
%             probNmerged = probN-2;
%         end
%         plot(timePoints, meanVel{probNmerged}.vpLL(subN, (maxFrameLength-minFrameLength+1):end), '--', 'color', colorProb(probN, :)); %, 'LineWidth', 1)
%         hold on
%         p{probSubN} = plot(timePoints, meanVel{probNmerged}.vpLR(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorProb(probN, :)); %, 'LineWidth', 1);
%     end
%     % line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
%     % line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
%     % line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
%     legend([p{1}, p{2}, p{3}], probNames{probNameI}, 'Location', 'NorthWest')
%     title('perceptual trials, visual left, dashed perceived left')
%     xlabel('Time (ms)')
%     ylabel('Horizontal velocity (deg/s)')
%     xlim([-500 700])
%     ylim(yPerceptRange)
%     box off
%     
%     subplot(2, 1, 2)
%     for probSubN = 1:size(probSub, 2)
%         probN = find(probCons==probSub(probSubN));
%         if probSub(1)<50
%             probNmerged = 4-probN;
%         else
%             probNmerged = probN-2;
%         end
%         plot(timePoints, meanVel{probNmerged}.vpRL(subN, (maxFrameLength-minFrameLength+1):end), '--', 'color', colorProb(probN, :)); %, 'LineWidth', 1)
%         hold on
%         p{probSubN} = plot(timePoints, meanVel{probNmerged}.vpRR(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorProb(probN, :)); %, 'LineWidth', 1);
%     end
%     % line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
%     % line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
%     % line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
%     legend([p{1}, p{2}, p{3}], probNames{probNameI}, 'Location', 'NorthWest')
%     title('perceptual trials, visual right, dashed perceived left')
%     xlabel('Time (ms)')
%     ylabel('Horizontal velocity (deg/s)')
%     xlim([-500 700])
%     ylim(yPerceptRange)
%     box off
%     saveas(gca, ['velocity_vpMotion_AllProbs_' names{subN} '.pdf'])

% % 0 coherence trials
% figure
% for probSubN = 1:size(probSub, 2)
%     probN = find(probCons==probSub(probSubN));
%     if probSub(1)<50
%         probNmerged = 3-probN;
%     else
%         probNmerged = probN-1;
%     end
%     plot(timePoints, meanVel{probNmerged}.zeroL(subN, (maxFrameLength-minFrameLength+1):end), '--', 'color', colorProb(probN, :)); %, 'LineWidth', 1)
%     hold on
%     p{probSubN} = plot(timePoints, meanVel{probNmerged}.zeroR(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorProb(probN, :)); %, 'LineWidth', 1);
% end
% % line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
% % line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% % line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% legend([p{1}, p{2}], probNames{probNameI}, 'Location', 'NorthWest')
% title('0 coh trials')
% xlabel('Time (ms)')
% ylabel('Horizontal velocity (deg/s)')
% xlim([-500 700])
% %     ylim(yPerceptRange)
% box off
% saveas(gcf, ['velocity_zeroCoherence_AllProbs_' names{subN} '.pdf'])

% perceptual trials separated by perception
figure
for probSubN = 1:size(probSub, 2)
    probN = find(probCons==probSub(probSubN));
    if probSub(1)<50
        probNmerged = 3-probN;
    else
        probNmerged = probN-1;
    end
    plot(timePoints, meanVel{probNmerged}.ppL(subN, (maxFrameLength-minFrameLength+1):end), '--', 'color', colorProb(probN, :)); %, 'LineWidth', 1)
    hold on
    p{probSubN} = plot(timePoints, meanVel{probNmerged}.ppR(subN, (maxFrameLength-minFrameLength+1):end), 'color', colorProb(probN, :)); %, 'LineWidth', 1);
end
% line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
% line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
legend([p{1}, p{2}], probNames{probNameI}, 'Location', 'NorthWest')
title('Perceptual trials by perceived motion')
xlabel('Time (ms)')
ylabel('Horizontal velocity (deg/s)')
xlim([-500 700])
%     ylim(yPerceptRange)
box off
saveas(gcf, ['velocity_perceptualPerceived_AllProbs_' names{subN} '.pdf'])
end

%% plot mean traces of all participants in all probabilities 
% % just separate visual motion, and standard/perceptual trials
% figure 
% subplot(2, 1, 1)
% for probNmerged = 1:2
%     plot(timePoints, velMean{probNmerged}.leftStandard, 'color', colorProb(probNmerged+1, :)); %, 'LineWidth', 1)
%     hold on
%     p{probNmerged} = plot(timePoints, velMean{probNmerged}.rightStandard, 'color', colorProb(probNmerged+1, :)); %, 'LineWidth', 1);
% end
% % line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
% % line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% % line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% legend([p{1}, p{2}], {'50', '90'}, 'Location', 'NorthWest')
% title('standard trials')
% xlabel('Time (ms)')
% ylabel('Horizontal velocity (deg/s)')
% xlim([-500 700])
% ylim(yStandardRange)
% box off
% 
% subplot(2, 1, 2)
% for probNmerged = 1:2
%     plot(timePoints, velMean{probNmerged}.leftPerceptual, 'color', colorProb(probNmerged+1, :)); %, 'LineWidth', 1)
%     hold on
%     p{probNmerged} = plot(timePoints, velMean{probNmerged}.rightPerceptual, 'color', colorProb(probNmerged+1, :)); %, 'LineWidth', 1);
% end
% % line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
% % line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% % line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% legend([p{1}, p{2}], {'50', '90'}, 'Location', 'NorthWest')
% title('perceptual trials')
% xlabel('Time (ms)')
% ylabel('Horizontal velocity (deg/s)')
% xlim([-500 700])
% ylim(yPerceptRange)
% box off
% saveas(gca, ['velocityAllProbs_all_set' num2str(setN) '.pdf'])

% perceptual trials, visual x perceived motion
% figure 
% subplot(2, 1, 1)
% for probNmerged = 1:3
%     plot(timePoints, velMean{probNmerged}.vpLL, '--', 'color', colorProb(probNmerged+2, :)); %, 'LineWidth', 1)
%     hold on
%     p{probNmerged} = plot(timePoints, velMean{probNmerged}.vpLR, 'color', colorProb(probNmerged+2, :)); %, 'LineWidth', 1);
% end
% line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
% line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% legend([p{1}, p{2}, p{3}], {'50', '70', '90'}, 'Location', 'NorthWest')
% title('perceptual trials, visual left, dashed perceived left')
% xlabel('Time (ms)')
% ylabel('Horizontal velocity (deg/s)')
% xlim([-500 700])
% ylim([-4 4])
% box off
% 
% subplot(2, 1, 2)
% for probNmerged = 1:3
%     plot(timePoints, velMean{probNmerged}.vpRL, '--', 'color', colorProb(probNmerged+2, :)); %, 'LineWidth', 1)
%     hold on
%     p{probNmerged} = plot(timePoints, velMean{probNmerged}.vpRR, 'color', colorProb(probNmerged+2, :)); %, 'LineWidth', 1);
% end
% line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
% line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% legend([p{1}, p{2}, p{3}], {'50', '70', '90'}, 'Location', 'NorthWest')
% title('perceptual trials, visual right, dashed perceived left')
% xlabel('Time (ms)')
% ylabel('Horizontal velocity (deg/s)')
% xlim([-500 700])
% ylim([-4 4])
% box off
% saveas(gca, ['velocity_vpMotion_AllProbs_all_set' num2str(setN) '.pdf'])

% perceptual trials, different coherence levels
cohVelSub = cell(2, length(cohLevels));
% figure
for probNmerged = 1:2
    for subN = 1:length(names)
        probSub = unique(eyeTrialData.prob(subN, :));
        if probSub(1)<50
            probSubN = 3-probNmerged;
        else
            probSubN = probNmerged;
        end
        
        for cohI = 1:length(cohLevels)
            idxCoh = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.errorStatus(subN, :)==0 ...
            & eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.coh(subN, :)==cohLevels(cohI));
            cohVelSub{probNmerged, cohI}(subN, :) = nanmean(frames{subN}(idxCoh, :));
        end
    end
    
    for cohI = 1:length(cohLevels)
        cohVel{probNmerged}(cohI, :)=nanmean(cohVelSub{probNmerged, cohI});
    end
    
%     subplot(3, 1, probNmerged)
%     hold on
%     for cohI = 1:length(cohLevels)
%         plot(timePoints, cohVel{probNmerged}(cohI, (maxFrameLength-minFrameLength+1):end), '--', 'color', (cohI-1)/length(cohLevels)*ones(1, 3)); %, 'LineWidth', 1)
%     end
%     % line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
%     % line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
%     % line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
%     legend({'-0.15', '-0.1', '-0.05', '0', '0.05', '0.1', '0.15'}, 'Location', 'NorthWest')
%     title(['perceptual trials, ', num2str(probCons(probNmerged+2)), '% right'])
%     xlabel('Time (ms)')
%     ylabel('Horizontal velocity (deg/s)')
%     xlim([-500 700])
%     ylim([-2 5])
%     box off
end
% saveas(gcf, 'velTraceCohLevels_all.pdf')

% % zero coherence trials, perceived motion
% figure
% for probNmerged = 1:2
%     plot(timePoints, velMean{probNmerged}.zeroL, '--', 'color', colorProb(probNmerged+1, :)); %, 'LineWidth', 1)
%     hold on
%     p{probNmerged} = plot(timePoints, velMean{probNmerged}.zeroR, 'color', colorProb(probNmerged+1, :)); %, 'LineWidth', 1);
% end
% legend([p{1}, p{2}], {'50', '90'}, 'Location', 'NorthWest')
% title('0 coh trials')
% xlabel('Time (ms)')
% ylabel('Horizontal velocity (deg/s)')
% xlim([-500 700])
% ylim([-4 4])
% box off
% saveas(gcf, 'velTraceZeroCoh_all.pdf')

% perceptual trials, perceived motion
figure
for probNmerged = 1:2
    plot(timePoints, velMean{probNmerged}.ppL, '--', 'color', colorProb(probNmerged+1, :)); %, 'LineWidth', 1)
    hold on
    p{probNmerged} = plot(timePoints, velMean{probNmerged}.ppR, 'color', colorProb(probNmerged+1, :)); %, 'LineWidth', 1);
end
legend([p{1}, p{2}], {'50', '90'}, 'Location', 'NorthWest')
title('Perceptual trials by perceived motion')
xlabel('Time (ms)')
ylabel('Horizontal velocity (deg/s)')
xlim([-500 700])
ylim([-4 4])
box off
saveas(gcf, 'velTracePereptualPerceived_all.pdf')

%% generate csv files, each file for one probability condition
% each row is the mean velocity trace of one participant
% use the min frame length--the lengeth where all participants have
% valid data points
cd(analysisFolder)
cd ..
cd ..
cd('R')

% % perceptual trials by perceived motion
% for probNmerged = 1:2
%     velTAverageSub = [];
%     for binN = 1:2        
%         if binN==1
%             dataTemp = meanVel{probNmerged}.ppL(:, (maxFrameLength-minFrameLength+1):end);
%         else
%             dataTemp = meanVel{probNmerged}.ppR(:, (maxFrameLength-minFrameLength+1):end);
%         end
%         for subN = 1:size(names, 2)
%             velTAverageSub((binN-1)*length(names)+subN, :) = dataTemp(subN, :);
%         end
%     end
%     csvwrite(['velocityTracePerceptualPerceived_', num2str(probCons(probNmerged+1)), '.csv'], velTAverageSub)
% end

% % standard trials
% for probNmerged = 1:3
%     velTAverageSub = [];
%     for binN = 1:2        
%         if binN==1
%             dataTemp = meanVel{probNmerged}.leftStandard(:, (maxFrameLength-minFrameLength+1):end);
%         else
%             dataTemp = meanVel{probNmerged}.rightStandard(:, (maxFrameLength-minFrameLength+1):end);
%         end
%         for subN = 1:size(names, 2)
%             velTAverageSub((binN-1)*length(names)+subN, :) = dataTemp(subN, :);
%         end
%     end
%     csvwrite(['velocityTraceStandard_', num2str(probCons(probNmerged+2)), '.csv'], velTAverageSub)
% end
% 
% perceptual trials by visual motion
for probNmerged = 1:2
    velTAverageSub = [];
    for binN = 1:2        
        if binN==1
            dataTemp = meanVel{probNmerged}.leftPerceptual(:, (maxFrameLength-minFrameLength+1):end);
        else
            dataTemp = meanVel{probNmerged}.rightPerceptual(:, (maxFrameLength-minFrameLength+1):end);
        end
        for subN = 1:size(names, 2)
            velTAverageSub((binN-1)*length(names)+subN, :) = dataTemp(subN, :);
        end
    end
    csvwrite(['velocityTracePerceptual_', num2str(probCons(probNmerged+1)), '.csv'], velTAverageSub)
end
% 
% % perceptual visual left trials
% for probNmerged = 1:3
%     velTAverageSub = [];
%     for binN = 1:2        
%         if binN==1
%             dataTemp = meanVel{probNmerged}.vpLL(:, (maxFrameLength-minFrameLength+1):end);
%         else
%             dataTemp = meanVel{probNmerged}.vpLR(:, (maxFrameLength-minFrameLength+1):end);
%         end
%         for subN = 1:size(names, 2)
%             velTAverageSub((binN-1)*length(names)+subN, :) = dataTemp(subN, :);
%         end
%     end
%     csvwrite(['velocityTraceVPleft_', num2str(probCons(probNmerged+2)), '.csv'], velTAverageSub)
% end
% 
% % perceptual visual right trials
% for probNmerged = 1:3
%     velTAverageSub = [];
%     for binN = 1:2        
%         if binN==1
%             dataTemp = meanVel{probNmerged}.vpRL(:, (maxFrameLength-minFrameLength+1):end);
%         else
%             dataTemp = meanVel{probNmerged}.vpRR(:, (maxFrameLength-minFrameLength+1):end);
%         end
%         for subN = 1:size(names, 2)
%             velTAverageSub((binN-1)*length(names)+subN, :) = dataTemp(subN, :);
%         end
%     end
%     csvwrite(['velocityTraceVPright_', num2str(probCons(probNmerged+2)), '.csv'], velTAverageSub)
% end

% zero coherence trials
for probNmerged = 1:2
    velTAverageSub = [];
    for binN = 1:2        
        if binN==1
            dataTemp = meanVel{probNmerged}.zeroL(:, (maxFrameLength-minFrameLength+1):end);
        else
            dataTemp = meanVel{probNmerged}.zeroR(:, (maxFrameLength-minFrameLength+1):end);
        end
        for subN = 1:size(names, 2)
            velTAverageSub((binN-1)*length(names)+subN, :) = dataTemp(subN, :);
        end
    end
    csvwrite(['velocityTraceZeroCoh_', num2str(probCons(probNmerged+1)), '.csv'], velTAverageSub)
end