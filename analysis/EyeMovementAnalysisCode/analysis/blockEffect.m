% generate csv files for values in different probability conditions
% could then plot&analyze in R
% can also check with quick matlab plots

initializeParas;
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

% different parameters to look at
checkParas = {'pursuit.APvelocityX' 'pursuit.APvelocityX_interpol' ...
    'pursuit.initialMeanVelocityX' 'pursuit.initialPeakVelocityX' 'pursuit.initialMeanAccelerationX' 'pursuit.initialVelChangeX'...
    'pursuit.gainX' 'pursuit.gainX_interpol' 'pursuit.closedLoopMeanVelX' 'pursuit.closedLoopMeanVelX'...
    'saccades.X.number' 'saccades.X.meanAmplitude' 'saccades.X.sumAmplitude'}; % field name in eyeTrialData
pdfNames = {'APvelX' 'APvelXInterpolated'...
    'olpMeanVelX' 'olpPeakVelX' 'olpMeanAcceleration' 'olpVelChangeX'...
    'clpGainX' 'clpGainXInterpolated' 'clpMeanVelX' 'clpAbsMeanVelX'...
    'sacNumX' 'sacMeanAmpX' 'sacSumAmpX'}; % name for saving the pdf
sacStart = 11; % from the n_th parameter is saccade
paraStart = 9;
paraEnd = 9; % which parameters to plot

% choose the grouping you want to achieve
groupName = {'standardMerged', 'standardVisual', 'perceptualMerged', 'perceptualVisual', 'perceptualPerceived', ...
    'perceptualVisualLperceived', 'perceptualVisualRperceived', 'wrongPerceptualPerceived', 'correctPerceptualPerceived', ...
    'perceptualConsistency'};
% naming by trial type (could include grouping rules) + group based on which direction (visual or perceived)
groupN = [10]; % corresponds to the listed rules... can choose multiple, just list as a vector
% when choosing multiple groupN, will do one by one

% some other settings
individualPlots = 1;
averagedPlots = 1;
scatterPlots = 0;
yLabels = {'AP horizontal velocity (deg/s)' 'AP interpolated horizontal velocity (deg/s)'...
    'olp mean horizontal velocity (deg/s)' 'olp peak horizontal velocity (deg/s)' 'olp mean acceleration (deg/s2)' 'olp horizontal velocity change'...
    'clp gain (horizontal)' 'clp interpolated gain (horizontal)' 'clp mean horizontal velocity (deg/s)' 'clp mean abs horizontal velocity (deg/s)'...
    'saccade number (horizontal)' 'saccade mean amplitude (horizontal)' 'saccade sum amplitude (horizontal)'};
% % for plotting, each parameter has a specific y value range--didn't
% update...
% minY = [-3; ...
%     -10; -15; ...
%     0; ...
%     0; 0; 0];
% maxY = [3; ...
%     10; 15; ...
%     1.5; ...
%     5; 2; 5];

% flip conditions and directions... to collapse between directions
for subN = 1:length(names)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        eyeTrialData.choice(subN, :) = 1-eyeTrialData.choice(subN, :); % flip left (0) and right (1)
        eyeTrialData.coh(subN, :) = -eyeTrialData.coh(subN, :);
        eyeTrialData.rdkDir(subN, :) = -eyeTrialData.rdkDir(subN, :);

        eyeTrialData.pursuit.APvelocityX(subN, :) = -eyeTrialData.pursuit.APvelocityX(subN, :);
        eyeTrialData.pursuit.APvelocityX_interpol(subN, :) = -eyeTrialData.pursuit.APvelocityX_interpol(subN, :);
        eyeTrialData.pursuit.initialVelChangeX(subN, :) = -eyeTrialData.pursuit.initialVelChangeX(subN, :);
        eyeTrialData.pursuit.initialMeanVelocityX(subN, :) = -eyeTrialData.pursuit.initialMeanVelocityX(subN, :);
        eyeTrialData.pursuit.closedLoopMeanVelX(subN, :) = -eyeTrialData.pursuit.closedLoopMeanVelX(subN, :);
    end
end

%% box plots, compare different probabilities
% separate perceptual and standard trials
close all
for subN = 1:size(names, 2)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        probName = probNames{1};
    else
        probName = probNames{2};
    end
    
    for paraN = paraStart:paraEnd%:size(checkParas, 2) % automatically loop through the parameters... just too much of them
        for ii = 1:length(groupN)
            [yValues{paraN, ii}{subN} trialSubN{paraN, ii}{subN}] = getMeanValues(eyeTrialData, checkParas, paraN, groupN(ii), probSub, subN);
        end
        
        if individualPlots==1
            if paraN<sacStart
                cd([pursuitFolder '\individuals'])
            else
                cd([saccadeFolder '\individuals'])
            end
            % individualplots
            % plot mean values of each participant, box/barplots (modify within the function plotIndividual)
            for ii = length(groupN)
                plotIndividual(yValues{paraN, ii}{subN}, yLabels, checkParas, paraN, groupName, groupN(ii), probSub, subN, pdfNames, names, probName);
            end
            
%             % barplot of difference
%             if ~isempty(find(groupN==6)) && ~isempty(find(groupN==7))
%                 
%                 plotMean = [];
%                 plotSte = [];
%                 for probSubN = 1:size(probSub, 2)
%                     plotMean(1, probSubN) = nanmean(yValues{6, ii}{subN}.left(:, probSubN)-yValues{6, ii}{subN}.right(:, probSubN)); % left
%                     plotMean(2, probSubN) = nanmean(yValues{7, ii}{subN}.right(:, probSubN)-yValues{7, ii}{subN}.left(:, probSubN)); % right
%                     plotSte(1, probSubN) = nanstd(yValues{6, ii}{subN}.left(:, probSubN)-yValues{6, ii}{subN}.right(:, probSubN))/sqrt(size(names, 2)); % left
%                     plotSte(2, probSubN) = nanstd(yValues{7, ii}{subN}.right(:, probSubN)-yValues{7, ii}{subN}.left(:, probSubN))/sqrt(size(names, 2)); % right
%                 end
%                 errorbar_groups(plotMean, plotSte,  ...
%                     'bar_width',0.75,'errorbar_width',0.5, ...
%                     'bar_names',probNames{probNameI});
%                 legend({'visual left trials' 'visual right trials'}, 'Location', 'best')
%                 title('difference between perceived direction trials (same as visual motion-opposite)')
%                 ylabel(yLabels{paraN})
%                 %     ylim([-0.5 5])
%                 box off
%                 saveas(gca, [pdfNames{paraN}, '_diffBarplot_vpMotion_' , names{subN}, '.pdf'])
%             end
%             close all
        end
    end
end

%% grouped bars of the mean of all participants
% sort data of different participants together
for paraN = paraStart:paraEnd%size(checkParas, 2)
    for ii = 1:length(groupN)
        [subMean{paraN, ii} meanYall{paraN, ii} steYall{paraN, ii} trialAllN{paraN, ii}]= getGroupAverage(eyeTrialData, yValues{paraN, ii}, trialSubN{paraN, ii}, checkParas, paraN, groupN(ii), probTotalN, size(names, 2));
        
        if groupN(ii)==3 || groupN(ii)==1
            % generate csv file for R, group by trials merged
            cd(RsaveFolder)
            data = table();
            count = 1;
            for subN = 1:length(names)
                for probN = 1:probTotalN % probN is merged already
                    data.sub(count, 1) = subN;
                    data.prob(count, 1) = probCons(probN+probTotalN-1);
                    data.measure(count, 1) = subMean{paraN, ii}(subN, probN);
                    count = count+1;
                end
            end
            writetable(data, ['data' pdfNames{paraN} '_exp' num2str(expN) '.csv'])
        else
            % generate csv file for R, group by trials not merged
            cd(RsaveFolder)
            data = table();
            count = 1;
            for subN = 1:length(names)
                for probN = 1:probTotalN % probN is merged already
                    for dirN = 1:2
                        if dirN==1
                            dir = -1;
                        else
                            dir=1;
                        end
                        data.sub(count, 1) = subN;
                        data.prob(count, 1) = probCons(probN+probTotalN-1);
                        if groupN==10
                            data.consistency(count, 1) = dir;
                        else
                            data.dir(count, 1) = dir;
                        end
                        data.measure(count, 1) = subMean{paraN, ii}{dirN}(subN, probN);
                        data.trialNumber(count, 1) = trialAllN{paraN, ii}{dirN}(subN, probN);
                        count = count+1;
                    end
                end
            end
            writetable(data, ['data' pdfNames{paraN} '_' groupName{groupN(ii)} '_exp' num2str(expN) '.csv'])
        end
    end
    
%     % difference... not updated
%     if ~isempty(find(groupN==6)) && ~isempty(find(groupN==7))
%         meanVPDiff{paraN}(1, probN) = nanmean(subMeanLL{paraN}(:, probN)-subMeanLR{paraN}(:, probN)); % left trials
%         meanVPDiff{paraN}(2, probN) = nanmean(subMeanRR{paraN}(:, probN)-subMeanRL{paraN}(:, probN)); % right trials
%         steVPDiff{paraN}(1, probN) = nanstd(subMeanLL{paraN}(:, probN)-subMeanLR{paraN}(:, probN))/sqrt(size(names, 2)); % left trials
%         steVPDiff{paraN}(2, probN) = nanstd(subMeanRR{paraN}(:, probN)-subMeanRL{paraN}(:, probN))/sqrt(size(names, 2)); % right trials
%     end
    
    if averagedPlots==1 %% below not updated
        if paraN<sacStart
            cd(pursuitFolder)
        else
            cd(saccadeFolder)
        end
        
        for ii = length(groupN)
            plotAll(meanYall{paraN, ii}, steYall{paraN, ii}, yLabels, paraN, groupName, groupN(ii), pdfNames, probNames{2}, expN);
        end
%         close all
    end
end

%% scatter plot of all participants in all probabilities, not updated
% % each dot is one participant in one probability block
% cd(analysisFolder)
% cd ..
% cd ..
% cd('psychometricFunction')
% load dataPercept_all_exp2
% cd(analysisFolder)
%
% for paraN = paraStart:paraEnd%sacStart-1%size(checkParas, 2)
%     if scatterPlots==1
%         %         if paraN<sacStart
%         %             cd(pursuitFolder)
%         %         else
%         %             cd(saccadeFolder)
%         %         end
%         cd(correlationFolder)
%
%         figure
%         for subN = 1:size(names, 2)
%             hold on
%             scatter(dataPercept.alpha(subN, :), subMeanP{paraN}(subN, :))
%         end
%         %         for probNmerged = 1:3
%         %             hold on
%         %             scatter(dataPercept.alpha(:, probNmerged), subMeanP{paraN}(:, probNmerged), ...
%         %                 'MarkerFaceColor', colorProb(probNmerged+2, :), 'MarkerEdgeColor', 'none')
%         %         end
%         %         legend({'50','70','90'})
%         title('perceptual trials')
%         xlabel('PSE')
%         ylabel(yLabels{paraN})
%         %     ylim([-0.5 5])
%         box off
%         saveas(gca, [pdfNames{paraN}, '_scatterplot_perceptualTrials.pdf'])
%     end
% end

function [yValues, trialSubN] = getMeanValues(eyeTrialData, checkParas, paraN, groupN, probSub, subN)
% initialize
if groupN==1
    yValues = NaN(500, size(probSub, 2));
elseif groupN==2
    yValues.left = NaN(500, size(probSub, 2));
    yValues.right = NaN(500, size(probSub, 2));
elseif groupN==3
    yValues = NaN(182, size(probSub, 2));
else
    yValues.left = NaN(182, size(probSub, 2));
    yValues.right = NaN(182, size(probSub, 2));
end

for probSubN = 1:size(probSub, 2)
    switch groupN
        case 1
            validI = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
        case 2
            validIL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==1 ...
                & eyeTrialData.rdkDir(subN, :)==-1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            validIR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==1 ...
                & eyeTrialData.rdkDir(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
        case 3
            validI = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probSubN));
        case 4
            validIL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)==-1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            validIR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
        case 5
            validIL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.choice(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            validIR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.choice(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
        case 6
            validIL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)==-1 & eyeTrialData.choice(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            validIR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)==-1 & eyeTrialData.choice(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
        case 7
            validIL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)==1 & eyeTrialData.choice(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            validIR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)==1 & eyeTrialData.choice(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
        case 8
            validIL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)>=0 & eyeTrialData.choice(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            validIR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)<=0 & eyeTrialData.choice(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
        case 9
            validIL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)<0 & eyeTrialData.choice(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            validIR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)>0 & eyeTrialData.choice(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
        case 10
            % visual left, perceived left
            validILL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)<0 & eyeTrialData.choice(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            % visual right, perceived right
            validIRR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)>0 & eyeTrialData.choice(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            % visual left, perceived right
            validILR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)<0 & eyeTrialData.choice(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            % visual right, perceived left
            validIRL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)>0 & eyeTrialData.choice(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probSubN));
    end
    
    if groupN==10 % flip all visual left trials
        eval(['yValues.right(1:length(validILL), probSubN) = -eyeTrialData.' checkParas{paraN} '(subN, validILL);']) % consistent
        eval(['yValues.right((length(validILL)+1):(length(validILL)+length(validIRR)), probSubN) = eyeTrialData.' checkParas{paraN} '(subN, validIRR);']) % consistent
        eval(['yValues.left(1:length(validILR), probSubN) = -eyeTrialData.' checkParas{paraN} '(subN, validILR);']) % inconsistent
        eval(['yValues.left((length(validILR)+1):(length(validILR)+length(validIRL)), probSubN) = eyeTrialData.' checkParas{paraN} '(subN, validIRL);']) % inconsistent
        trialSubN.right(1, probSubN) = length(validILL)+length(validIRR);
        trialSubN.left(1, probSubN) = length(validILR)+length(validIRL);
    else
        if paraN==10 % needs to calculate absolute value
            if groupN==1 || groupN==3
                eval(['yValues(1:length(validI), probSubN) = abs(eyeTrialData.' checkParas{paraN} '(subN, validI));'])
            else
                eval(['yValues.left(1:length(validIL), probSubN) = abs(eyeTrialData.' checkParas{paraN} '(subN, validIL));'])
                eval(['yValues.right(1:length(validIR), probSubN) = abs(eyeTrialData.' checkParas{paraN} '(subN, validIR));'])
            end
        else
            if groupN==1 || groupN==3
                eval(['yValues(1:length(validI), probSubN) = eyeTrialData.' checkParas{paraN} '(subN, validI);'])
            else
                eval(['yValues.left(1:length(validIL), probSubN) = eyeTrialData.' checkParas{paraN} '(subN, validIL);'])
                eval(['yValues.right(1:length(validIR), probSubN) = eyeTrialData.' checkParas{paraN} '(subN, validIR);'])
            end
        end
        if groupN==1 || groupN==3
            trialSubN(1, probSubN) = length(validI);
        else
            trialSubN.left(1, probSubN) = length(validIL);
            trialSubN.right(1, probSubN) = length(validIR);
        end
    end
end
end

function plotIndividual(yValues, yLabels, checkParas, paraN, groupName, groupN, probSub, subN, pdfNames, names, probName)
% boxplots
if ~strcmp(checkParas{paraN}, 'choice') && ~strcmp(checkParas{paraN}, 'saccades.X.number')
    % do not plot boxplot of perception or saccade number... meaningless
    figure
    if groupN==1 || groupN==3 %left&right trials merged
        boxplot(yValues, 'Labels', probName)
        title([groupName{groupN}])
        ylabel(yLabels{paraN})
    else % left and right separated
        subplot(1, 2, 1)
        hold on
        boxplot(yValues.left, 'Labels', probName)
        title([groupName{groupN}, ', left'])
        ylabel(yLabels{paraN})
        box off
        
        subplot(1, 2, 2)
        hold on
        boxplot(yValues.right, 'Labels', probName)
        title([groupName{groupN}, ', right'])
        ylabel(yLabels{paraN})
        box off
    end
    saveas(gca, [pdfNames{paraN}, '_boxplot_', names{subN}, '.pdf'])
end

% barplots
plotMean = [];
plotSte = [];
for probSubN = 1:size(probSub, 2)
    if groupN==1 || groupN==3 %left&right trials merged
        plotMean(1, probSubN) = nanmean(yValues(:, probSubN)); % left
        plotSte(1, probSubN) = nanstd(yValues(:, probSubN))/sqrt(size(names, 2)); % left
    else
        plotMean(1, probSubN) = nanmean(yValues.left(:, probSubN)); % left
        plotMean(2, probSubN) = nanmean(yValues.right(:, probSubN)); % right
        plotSte(1, probSubN) = nanstd(yValues.left(:, probSubN))/sqrt(size(names, 2)); % left
        plotSte(2, probSubN) = nanstd(yValues.right(:, probSubN))/sqrt(size(names, 2)); % right
    end
end
errorbar_groups(plotMean, plotSte,  ...
    'bar_width',0.75,'errorbar_width',0.5, ...
    'bar_names',probName);
if groupN<5
    legend({'leftward trials' 'rightward trials'})
elseif groupN<10
    legend({'trials perceiving left' 'trials perceiving right'})
else
    legend({'consistent trials' 'inconsistent trials'})
end
title(groupName{groupN})
ylabel(yLabels{paraN})
%         ylim([0 1.3])
box off
saveas(gca, [pdfNames{paraN}, '_barplot_' groupName{groupN} '_' , names{subN}, '.pdf'])
end

function [subMean, meanY, steY, trialAllN] = getGroupAverage(eyeTrialData, yValues, trialSubN, checkParas, paraN, groupN, probTotalN, subTotalN)
% initialize
if groupN==1 || groupN==3
    subMean = NaN(subTotalN, probTotalN);
else
    subMean{1} = NaN(subTotalN, probTotalN); % left trials
    subMean{2} = NaN(subTotalN, probTotalN); % right trials
end

for probN= 1:probTotalN % here probN is merged, 50 and 90
    for subN = 1:subTotalN
        probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
        if probSub(1)==10 % flip the left and right trials
            if groupN==1 || groupN==3
                subMean(subN, probN) = nanmean(yValues{subN}(:, probTotalN+1-probN));
                trialAllN(subN, probN) = trialSubN{subN}(1, probTotalN+1-probN);
            else
                subMean{1}(subN, probN) = nanmean(yValues{subN}.left(:, probTotalN+1-probN));
                subMean{2}(subN, probN) = nanmean(yValues{subN}.right(:, probTotalN+1-probN));
                trialAllN{1}(subN, probN) = trialSubN{subN}.left(1, probTotalN+1-probN);
                trialAllN{2}(subN, probN) = trialSubN{subN}.right(1, probTotalN+1-probN);
            end
        else
            if groupN==1 || groupN==3
                subMean(subN, probN) = nanmean(yValues{subN}(:, probN));
                trialAllN(subN, probN) = trialSubN{subN}(1, probN);
            else
                subMean{1}(subN, probN) = nanmean(yValues{subN}.left(:, probN));
                subMean{2}(subN, probN) = nanmean(yValues{subN}.right(:, probN));
                trialAllN{1}(subN, probN) = trialSubN{subN}.left(1, probN);
                trialAllN{2}(subN, probN) = trialSubN{subN}.right(1, probN);
            end
        end
    end
    
    if groupN==1 || groupN==3
        meanY(1, probN) = nanmean(subMean(:, probN)); % all trials
        steY(1, probN) = nanstd(subMean(:, probN))/sqrt(subTotalN);
    else
        meanY(1, probN) = nanmean(subMean{1}(:, probN)); % left trials
        steY(1, probN) = nanstd(subMean{1}(:, probN))/sqrt(subTotalN);
        
        meanY(2, probN) = nanmean(subMean{2}(:, probN)); % right trials
        steY(2, probN) = nanstd(subMean{2}(:, probN))/sqrt(subTotalN);
    end
end
end

function plotAll(meanYall, steYall, yLabels, paraN, groupName, groupN, pdfNames, probName, expN)
if groupN==1 || groupN==3 %left&right trials merged
    errorbar_groups(meanYall,  steYall, ...
        'bar_width',0.75,'errorbar_width',0.5, ...
        'bar_names',probName);
    title([groupName{groupN}])
    ylabel(yLabels{paraN})
    box off
else % left and right separated
    errorbar_groups(meanYall, steYall,  ...
        'bar_width',0.75,'errorbar_width',0.5, ...
        'bar_names',probName);
    if groupN<10
        legend({'leftward trials' 'rightward trials'})
    else
        legend({'consistent trials' 'inconsistent trials'})
    end
    title([groupName{groupN}])
    ylabel(yLabels{paraN})
    box off
end
saveas(gca, [pdfNames{paraN}, '_barplot_', groupName{groupN}, '_all_exp', num2str(expN), '.pdf'])
end