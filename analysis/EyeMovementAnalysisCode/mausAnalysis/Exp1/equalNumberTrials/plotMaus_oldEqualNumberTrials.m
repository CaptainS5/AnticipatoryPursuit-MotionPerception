% plotting using the analyzed data from analysisMaus.m
initializeParas;
initializePSE;

wMax = 50; % largest window size, how many trials before
binMax = 3; % number of bins
% binLegend = {'perceived leftmost' 'medium' 'perceived rightmost'};
% binLegend = {'perceived leftmost' 'less lefter' 'medium' 'less righter' 'perceived rightmost'};
binLegend = {'visual leftmost' 'medium' 'visual rightmost'};
% binLegend = {'visual leftmost' 'less lefter' 'medium' 'less righter' 'visual rightmost'};
aveWinP = zeros(wMax, 1); % whether to plot the average perceptual psychometric function plot of this window size
aveWinP(15) = 1;
% aveWinP(40) = 1;% change the ones you want to plot to 1
aveWinAP = zeros(wMax, 1); % whether to plot the average AP psychometric function plot of this window size
aveWinAP(2) = 1; % change the ones you want to plot to 1
% aveWinAP(15) = 1; % change the ones you want to plot to 1
perceptPlots = 1;
APplots = 1;

cohLevels = unique(eyeTrialData.coh(1, eyeTrialData.trialType(1, :)==0))';

load(['percept_AP_binMax', num2str(binMax)])

%% Perceptual plots
cd(mausFolder)
if perceptPlots==1
    for windowSize = 1:wMax
        if aveWinP(windowSize)==1
            if windowSize<binMax-1
                binMaxTemp = windowSize;
            else
                binMaxTemp = binMax;
            end
            
            % plot individual psychometric functions
            for subN = 1:length(names)
                for probNmerged = 1:3
                    clear f
                    figure
                    hold on
                    for binN = 1:binMaxTemp
                        % this is when all coh levels have data, which may not
                        % be true if we have many bins
                        %                     numRight = mean(dataM.percept.numRight{windowSize, probNmerged}{binN})'; % choice 1=right, 0=left
                        %                     outOfNum = mean(dataM.percept.outOfNum{windowSize, probNmerged}{binN})'; % total trial numbers
                        
                        % get the mean proportion right for each coherence
                        % level...
                        cohLevels = dataM.percept.cohLevels{windowSize, probNmerged}{binN, subN};
                        numRight = dataM.percept.numRight{windowSize, probNmerged}{binN, subN};
                        outOfNum = dataM.percept.outOfNum{windowSize, probNmerged}{binN, subN};                        
                        
                        %Perform fit
                        [paramsValues LL exitflag] ...
                            = PAL_PFML_Fit(cohLevels, numRight, ...
                            outOfNum, searchGrid, paramsFree, PF);
                        
                        % plotting
                        StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
                        ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
                        f{binN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', (binN-1)/binMaxTemp*ones(1, 3), 'linewidth', 2);
                        plot(cohLevels, numRight./outOfNum,'.', 'color', (binN-1)/binMaxTemp*ones(1, 3), 'markersize', 30);
                    end
                    set(gca, 'fontsize',16);
                    set(gca, 'Xtick',cohLevels);
                    axis([min(cohLevels) max(cohLevels) 0 1]);
                    title([probNames{2}{probNmerged} ', ' num2str(windowSize) ' trials'])
                    xlabel('Stimulus Intensity');
                    ylabel('Proportion right (perception)');
                    legend([f{:}], binLegend, ...
                        'box', 'off', 'location', 'northwest')
                    saveas(gcf, ['pf_merged' probNames{2}{probNmerged} '_binMax' num2str(binMax) '_average' num2str(windowSize) 'trials_' names{subN} '.pdf'])
                end
            end
            
            %% plot the average psychometric functions in each bin
            for probNmerged = 1:3
                clear f
                figure
                hold on
                for binN = 1:binMaxTemp
                    % this is when all coh levels have data, which may not
                    % be true if we have many bins
                    %                     numRight = mean(dataM.percept.numRight{windowSize, probNmerged}{binN})'; % choice 1=right, 0=left
                    %                     outOfNum = mean(dataM.percept.outOfNum{windowSize, probNmerged}{binN})'; % total trial numbers
                    
                    % get the mean proportion right for each coherence
                    % level...
                    probTemp = NaN(size(names, 2), length(cohLevels));
                    for subN = 1:size(names, 2)
                        for cohSub = 1:length(dataM.percept.cohLevels{windowSize, probNmerged}{binN, subN})
                            cohI = find(cohLevels==dataM.percept.cohLevels{windowSize, probNmerged}{binN, subN}(cohSub));
                            if ~isempty(cohI)
                                probTemp(subN, cohI) = dataM.percept.ProportionCorrectObserved{windowSize, probNmerged}{binN, subN}(cohSub);
                            end
                        end
                    end
                    outOfNum = 100*ones(size(cohLevels));
                    numRight = nanmean(probTemp)'.*outOfNum;
                    
                    %Perform fit
                    [paramsValuesAll LL exitflag] ...
                        = PAL_PFML_Fit(cohLevels, numRight, ...
                        outOfNum, searchGrid, paramsFree, PF);
                    
                    % plotting
                    ProportionCorrectObserved{probNmerged, binN} = numRight./outOfNum;
                    StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
                    ProportionCorrectModel = PF(paramsValuesAll,StimLevelsFineGrain);
                    f{binN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', (binN-1)/binMaxTemp*ones(1, 3), 'linewidth', 2);
                    plot(cohLevels, ProportionCorrectObserved{probNmerged, binN},'.', 'color', (binN-1)/binMaxTemp*ones(1, 3), 'markersize', 30);
                end
                set(gca, 'fontsize',16);
                set(gca, 'Xtick',cohLevels);
                axis([min(cohLevels) max(cohLevels) 0 1]);
                title([probNames{2}{probNmerged} ', ' num2str(windowSize) ' trials'])
                xlabel('Stimulus Intensity');
                ylabel('Proportion right (perception)');
                legend([f{:}], binLegend, ...
                    'box', 'off', 'location', 'northwest')
                saveas(gcf, ['pf_merged' probNames{2}{probNmerged} '_binMax' num2str(binMax) '_average' num2str(windowSize) 'trials.pdf'])
            end
            
            %% plot PSE vs previous directions
            clear s
            for probNmerged = 1:3
                figure
                scatter(previousDbins{windowSize, probNmerged}(:), dataM.percept.alpha{windowSize, probNmerged}(:), 'MarkerEdgeColor', [1 1 1]);
                lsline
                for subN = 1:length(names)
                    hold on
                    s{subN} = scatter(previousDbins{windowSize, probNmerged}(subN, :), dataM.percept.alpha{windowSize, probNmerged}(subN, :));
                end
                axis square
                legend([s{:}], names, 'box', 'off', 'location', 'northeastoutside')
                title([probNames{2}(probNmerged)])
                xlabel('Previous perceived direction')
                ylabel('PSE')
                saveas(gcf, ['PSEvsPreviousD_merged' probNames{2}{probNmerged} '_binMax' num2str(binMax) '_' num2str(windowSize) 'trials.pdf'])
            end
            
            %% plot the fit to all data with data points of each bin...
            for probNmerged=1:3
                figure
                hold on
                % fit to all data
                StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
                ProportionCorrectModel = PF(dataM.percept.paramsValuesAll{probNmerged},StimLevelsFineGrain);
                plot(StimLevelsFineGrain, ProportionCorrectModel, '-b', 'linewidth', 2);
                
                % data points of each bin
                for binN = 1:binMaxTemp
                    f{binN} = plot(cohLevels, ProportionCorrectObserved{probNmerged, binN},'.', 'color', (binN-1)/binMaxTemp*ones(1, 3), 'markersize', 30);
                end
                set(gca, 'fontsize',16);
                set(gca, 'Xtick',cohLevels);
                axis([min(cohLevels) max(cohLevels) 0 1]);
                title([probNames{2}{probNmerged} ', ' num2str(windowSize) ' trials'])
                xlabel('Stimulus Intensity');
                ylabel('Proportion right (perception)');
                legend([f{:}], binLegend, ...
                    'box', 'off', 'location', 'northwest')
                saveas(gcf, ['pfFitAll_merged' probNames{2}{probNmerged} '_binMax' num2str(binMax) '_average' num2str(windowSize) 'trials.pdf'])
            end
        
            %% plot residuals vs previous directions
            clear s
            for probNmerged = 1:3
                figure
                scatter(previousDbins{windowSize, probNmerged}(:), dataM.percept.residuals{windowSize, probNmerged}(:), 'MarkerEdgeColor', [1 1 1]);
                lsline
                for subN = 1:length(names)
                    hold on
                    s{subN} = scatter(previousDbins{windowSize, probNmerged}(subN, :), dataM.percept.residuals{windowSize, probNmerged}(subN, :));
                end
                legend([s{:}], names, 'box', 'off', 'location', 'northeastoutside')
                axis square
                if corrM.percept.pValue(windowSize, probNmerged)<0.05
                    title([probNames{2}{probNmerged} ', r*=' num2str(corrM.percept.rho(windowSize, probNmerged))])
                else
                    title([probNames{2}{probNmerged} ', r=' num2str(corrM.percept.rho(windowSize, probNmerged))])
                end
                xlabel('Previous perceived direction')
                ylabel('Perceptual residuals')
                saveas(gcf, ['PerceptResidualsVSpreviousD_merged' probNames{2}{probNmerged} '_binMax' num2str(binMax) '_' num2str(windowSize) 'trials.pdf'])
            end
        end
    end
    %% plot correlation vs window size
    figure
    hold on
    for probNmerged = 1:3
        plot(1:wMax, corrM.percept.rho(:, probNmerged), 'Color', colorProb(probNmerged+2, :))
    end
    legend(probNames{2}, 'box', 'off', 'location', 'best')
    xlabel('Trial history length')
    ylabel('Correlation (perception residuals)')
    saveas(gcf, ['correlationVStrialHistoryLength_perception_binMax' num2str(binMax) '.pdf'])
end
close all

%% AP plots
if APplots==1
    cd(mausFolder)
    % for plotting velocity traces
    yPerceptRange = [-6 6];
    
    for windowSize = 1:wMax
        if aveWinAP(windowSize)==1
            if windowSize<binMax-1
                binMaxTemp = windowSize;
            else
                binMaxTemp = binMax;
            end
            
            %% average velocity traces
            % align fixation offset, frame data for all trials
            for subN = 1:size(names, 2)
                cd(analysisFolder)
                load(['eyeTrialDataSub_' names{subN} '.mat']);
                frameLength(subN) = min(max(eyeTrialData.frameLog.rdkOff(subN, :)), (900+300+700)/1000*sampleRate);
                lengthT = size(eyeTrialDataSub.trial, 2);
                frames{subN} = NaN(lengthT, frameLength(subN));
            
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
                        frames{subN}(trialN, startIF:end) = eyeTrialDataSub.trial{1, trialN}.DX_interpolSac(startI:endI);
                    end
                end
            end
            maxFrameLength = max(frameLength);
            % plotting parameters
            minFrameLength = min(frameLength);
            framePerSec = 1/sampleRate;
            timePoints = [(1:minFrameLength)-minFrameLength+0.7*sampleRate]*framePerSec*1000; % align at the rdk offset...
            % rdk onset is 0

            % for each probability, get the mean velocity trace
            for probN = 1:size(probCons, 2)
                for binN = 1:binMaxTemp
                    % first initialize; if a participant doesn't have the corresponding
                    % prob condition, then the values remain NaN and will be ignored later
                    meanVel{probN}{binN} = NaN(length(names), maxFrameLength);
                    
                    for subN = 1:size(names, 2)
                        probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
                        if probSub(1)<50
                            probNmerged = 4-probN;
                        else
                            probNmerged = probN-2;
                        end
                        if ~isempty(find(eyeTrialData.prob(subN, :)==probCons(probN)))
                            meanVelMerged{probNmerged}{binN} = NaN(length(names), maxFrameLength);
                            tempStartI = maxFrameLength-frameLength(subN)+1;
                            idxTemp = idxBins{windowSize, probNmerged}{subN, binN};
                            meanVel{probN}{binN}(subN, tempStartI:end) = nanmean(frames{subN}(idxTemp, :));
                            meanVelMerged{probNmerged}{binN}(subN, tempStartI:end) = meanVel{probN}{binN}(subN, tempStartI:end);
                        end
                    end
                end
            end
            
            % Draw velocity trace plots
            cd(mausFolder)
%             % plot mean traces in all probabilities for each participant
%             for subN = 1:size(names, 2)
%                 probSub = unique(eyeTrialData.prob(subN, :));
%                 if probSub(1)<50
%                     probNameI = 1;
%                 else
%                     probNameI = 2;
%                 end
%             
%                 figure
%                 for probSubN = 1:size(probSub, 2)
%                     subplot(3, 1, probSubN) 
%                     hold on
%                     probN = find(probCons==probSub(probSubN));
%                     for binN = 1:binMaxTemp
%                         p{binN} = plot(timePoints, meanVel{probN}{binN}(subN, (maxFrameLength-minFrameLength+1):end), 'color', (binN-1)/binMax*ones(1, 3)); %, 'LineWidth', 1);
%                     end
%                     % line([-300 -300], [minVel(dirN) maxVel(dirN)],'Color','m','LineStyle','--')
% %                     line([-50 -50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
% %                     line([50 50], [minVel(dirN) maxVel(dirN)],'Color','k','LineStyle','--')
%                     legend([p{:}], binLegend, ...
%                         'Location', 'NorthWest')
%                     title([probNames{probNameI}{probSubN} ', ' num2str(windowSize) ' trials'])
%                     xlabel('Time (ms)')
%                     ylabel('Horizontal velocity (deg/s)')
%                     xlim([-500 700])
%                     ylim(yPerceptRange)
%                     box off
%                 end
%                 
%                 saveas(gca, ['velocityAllProbs_' num2str(windowSize) 'trials_' names{subN} '.pdf'])
%             end
            
            % plot mean traces of all participants in all probabilities
            figure
            for probNmerged = 1:3
                subplot(3, 1, probNmerged)
                hold on
                for binN = 1:binMaxTemp
                    velMean{probNmerged}{binN} = nanmean(meanVelMerged{probNmerged}{binN}(:, (maxFrameLength-minFrameLength+1):end), 1);
                    p{binN} = plot(timePoints, velMean{probNmerged}{binN}, 'color', (binN-1)/binMaxTemp*ones(1, 3)); %, 'LineWidth', 1);
                end
                if probNmerged==1
                    legend([p{:}], binLegend, 'Location', 'NorthWest')
                end
                title([probNames{2}{probNmerged} ', ' num2str(windowSize) ' trials'])
                xlim([-200 200])
                xlabel('Time (ms)')
                ylabel('Horizontal velocity (deg/s)')
%                 xlim([-500 700])
                ylim([-4 4])
                box off
            end
            
            saveas(gca, ['velocityAllProbs_allSet' num2str(setN) '_binMax' num2str(binMax) '_' num2str(windowSize) 'trials.pdf'])
            
            % plot proportion right vs previous directions
            clear s
            for probNmerged = 1:3
                figure
                scatter(previousDbins{windowSize, probNmerged}(:), ...
                    dataM.AP.proportionRight{windowSize, probNmerged}(:));
                lsline
                for subN = 1:length(names)
                    hold on
                    s{subN} = scatter(previousDbins{windowSize, probNmerged}(subN, :), ...
                        dataM.AP.proportionRight{windowSize, probNmerged}(subN, :));
                end
                legend([s{:}], names, 'box', 'off', 'location', 'northeastoutside')
                axis square
                if corrM.AP.pValue(windowSize, probNmerged)<0.05
                    title([probNames{2}{probNmerged} ', r*=' num2str(corrM.AP.rho(windowSize, probNmerged))])
                else
                    title([probNames{2}{probNmerged} ', r=' num2str(corrM.AP.rho(windowSize, probNmerged))])
                end
                xlabel('Previous perceived direction')
                ylabel('AP velocity proportion of right trials')
                saveas(gcf, ['APbinaryVSpreviousD_merged' probNames{2}{probNmerged} '_binMax' num2str(binMax) '_' num2str(windowSize) 'trials.pdf'])
            end
        end
    end
    % plot correlation vs window size
    figure
    hold on
    for probNmerged = 1:3
        plot(1:wMax, corrM.AP.rho(:, probNmerged), 'Color', colorProb(probNmerged+2, :))
    end
    legend(probNames{2}, 'box', 'off', 'location', 'best')
    xlabel('Trial history length')
    ylabel('Correlation (AP binary)')
    saveas(gcf, ['correlationVStrialHistoryLength_AP_binMax' num2str(binMax) '.pdf'])
end