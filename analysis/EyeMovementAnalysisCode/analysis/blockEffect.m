initializeParas;

% different parameters to look at
checkParas = {'pursuit.APvelocityX' ...
    'pursuit.initialMeanVelocityX' 'pursuit.initialPeakVelocityX' 'pursuit.initialMeanAccelerationX' 'pursuit.initialVelChangeX'...
    'pursuit.gainX' 'pursuit.gainSacSumAmpX' 'pursuit.closedLoopMeanVelX' ...
    'saccades.X.number' 'saccades.X.meanAmplitude' 'saccades.X.sumAmplitude'}; % field name in eyeTrialData
pdfNames = {'APvelX' ...
    'olpMeanVelX' 'olpPeakVelX' 'olpMeanAcceleration' 'olpVelChangeX'...
    'clpGainX' 'clpGainSacSumAmpX' 'clpMeanVelX' ...
    'sacNumX' 'sacMeanAmpX' 'sacSumAmpX'}; % name for saving the pdf
sacStart = 9; % from the n_th parameter is saccade

% some settings
individualPlots = 1;
averagedPlots = 0;
scatterPlots = 0;
yLabels = {'AP horizontal velocity (deg/s)' ...
    'olp mean horizontal velocity (deg/s)' 'olp peak horizontal velocity (deg/s)' 'olp mean acceleration (deg/s2)' 'olp horizontal velocity change'...
    'clp gain (horizontal)' 'clp gain + sum sac amp/radius (horizontal)' 'clp mean horizontal velocity (deg/s)'...
    'saccade number (horizontal)' 'saccade mean amplitude (horizontal)' 'saccade sum amplitude (horizontal)'};
% for plotting, each parameter has a specific y value range
minY = [-3; ...
    -10; -15; ...
    0; ...
    0; 0; 0];
maxY = [3; ...
    10; 15; ...
    1.5; ...
    5; 2; 5];

%% box plots, compare different probabilities
% separate perceptual and standard trials
close all
for subN = 1:size(names, 2)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        probNameI = 1;
    else
        probNameI = 2;
    end
    
    for paraN = 5:5%:size(checkParas, 2) % automatically loop through the parameters... just too much of them
        yValues{paraN, subN}.standard = NaN(500, size(probSub, 2));
        yValues{paraN, subN}.perceptual = NaN(182, size(probSub, 2));
        yValuesL{paraN, subN}.standard = NaN(500, size(probSub, 2));
        yValuesL{paraN, subN}.perceptual = NaN(182, size(probSub, 2));
        yValuesR{paraN, subN}.standard = NaN(500, size(probSub, 2));
        yValuesR{paraN, subN}.perceptual = NaN(182, size(probSub, 2));
        
        for probSubN = 1:size(probSub, 2)
            % standard trials
            %             if ~strcmp(checkParas{paraN}, 'choice') % not including standard trials for perception
            validI = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            eval(['yValues{paraN, subN}.standard(1:length(validI), probSubN) = eyeTrialData.' checkParas{paraN} '(subN, validI);'])
            %             end
            % then perceptual trials
            validI = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            eval(['yValues{paraN, subN}.perceptual(1:length(validI), probSubN) = eyeTrialData.' checkParas{paraN} '(subN, validI);'])
            
            %%seperate left and rightward trials
            % standard trials
            %             if ~strcmp(checkParas{paraN}, 'choice') % not including standard trials for perception
            validIL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==1 ...
                & eyeTrialData.rdkDir(subN, :)==-1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            eval(['yValuesL{paraN, subN}.standard(1:length(validIL), probSubN) = eyeTrialData.' checkParas{paraN} '(subN, validIL);'])
            validIR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==1 ...
                & eyeTrialData.rdkDir(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            eval(['yValuesR{paraN, subN}.standard(1:length(validIR), probSubN) = eyeTrialData.' checkParas{paraN} '(subN, validIR);'])
            %             end
            % then perceptual trials
%             % sort by visual motion direction
%             validIL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
%                 & eyeTrialData.rdkDir(subN, :)==-1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
                        % sort by choice
                        validIL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                            & eyeTrialData.choice(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            eval(['yValuesL{paraN, subN}.perceptual(1:length(validIL), probSubN) = eyeTrialData.' checkParas{paraN} '(subN, validIL);'])
%             % sort by visual motion direction
%             validIR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
%                 & eyeTrialData.rdkDir(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            % sort by choice
            validIR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.choice(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            eval(['yValuesR{paraN, subN}.perceptual(1:length(validIR), probSubN) = eyeTrialData.' checkParas{paraN} '(subN, validIR);'])
        end
        
        if individualPlots==1
            if paraN<sacStart
                cd([pursuitFolder '\individuals'])
            else
                cd([saccadeFolder '\individuals'])
            end
            % individualplots
            % plot mean values of each participant
            if ~strcmp(checkParas{paraN}, 'choice') && ~strcmp(checkParas{paraN}, 'saccades.X.number') % do not plot boxplot of perception or saccade number... meaningless
                %                 % boxplots, left&right trials merged
                %                 figure
                %                 subplot(1, 2, 1)
                %                 hold on
                %                 boxplot(yValues{paraN, subN}.standard, 'Labels', probNames{probNameI})
                %                 title('standard trials')
                %                 ylabel(yLabels{paraN})
                %                 %             ylim([minY(paraN) maxY(paraN)])
                %                 box off
                %
                %                 subplot(1, 2, 2)
                %                 hold on
                %                 boxplot(yValues{paraN, subN}.perceptual, 'Labels', probNames{probNameI})
                %                 title('perceptual trials')
                %                 ylabel(yLabels{paraN})
                %                 %             ylim([minY(paraN) maxY(paraN)])
                %                 box off
                %
                %                 saveas(gca, [pdfNames{paraN}, '_boxplot_', names{subN}, '.pdf'])
                
                % barplots, left&right trials not merged
                %                 % standard trials
                %                 plotMean = [];
                %                 plotSte = [];
                %                 for probSubN = 1:size(probSub, 2)
                %                     plotMean(1, probSubN) = nanmean(yValuesL{paraN, subN}.standard(:, probSubN)); % left
                %                     plotMean(2, probSubN) = nanmean(yValuesR{paraN, subN}.standard(:, probSubN)); % right
                %                     plotSte(1, probSubN) = nanstd(yValuesL{paraN, subN}.standard(:, probSubN))/sqrt(size(names, 2)); % left
                %                     plotSte(2, probSubN) = nanstd(yValuesR{paraN, subN}.standard(:, probSubN))/sqrt(size(names, 2)); % right
                %                 end
                %                 errorbar_groups(plotMean, plotSte,  ...
                %                     'bar_width',0.75,'errorbar_width',0.5, ...
                %                     'bar_names',probNames{probNameI});
                %                 legend({'leftward trials' 'rightward trials'})
                %                 title('standard trials')
                %                 ylabel(yLabels{paraN})
                %                 %         ylim([0 1.3])
                %                 box off
                %                 saveas(gca, [pdfNames{paraN}, '_barplot_standardTrialsLR_' , names{subN}, '.pdf'])
                
                % left and right seperated, perceptual trials
                plotMean = [];
                plotSte = [];
                for probSubN = 1:size(probSub, 2)
                    plotMean(1, probSubN) = nanmean(yValuesL{paraN, subN}.perceptual(:, probSubN)); % left
                    plotMean(2, probSubN) = nanmean(yValuesR{paraN, subN}.perceptual(:, probSubN)); % right
                    plotSte(1, probSubN) = nanstd(yValuesL{paraN, subN}.perceptual(:, probSubN))/sqrt(size(names, 2)); % left
                    plotSte(2, probSubN) = nanstd(yValuesR{paraN, subN}.perceptual(:, probSubN))/sqrt(size(names, 2)); % right
                end
                errorbar_groups(plotMean, plotSte,  ...
                    'bar_width',0.75,'errorbar_width',0.5, ...
                    'bar_names',probNames{probNameI});
%                                 legend({'leftward trials' 'rightward trials'})
                legend({'perceived left trials' 'perceived right trials'})
                title('perceptual trials')
                ylabel(yLabels{paraN})
                %     ylim([-0.5 5])
                box off
%                 saveas(gca, [pdfNames{paraN}, '_barplot_perceptualTrialsLR_' , names{subN}, '.pdf'])
                saveas(gca, [pdfNames{paraN}, '_barplot_perceptualTrialsLR_sortByChoice_' , names{subN}, '.pdf'])
            end
        end
    end
end

%% grouped bars of the mean of all participants
% sort data of different participants together
for paraN = 5:5%size(checkParas, 2)
    subMeanS{paraN} = NaN(size(names, 2), 3); % standard trials
    subMeanSL{paraN} = NaN(size(names, 2), 3);
    subMeanSR{paraN} = NaN(size(names, 2), 3);
    subMeanP{paraN} = NaN(size(names, 2), 3); % perceptual trials
    subMeanPL{paraN} = NaN(size(names, 2), 3);
    subMeanPR{paraN} = NaN(size(names, 2), 3);
    
    for probN= 1:3 % here probN is merged, 50, 70, and 90
        for subN = 1:size(names, 2)
            
            probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
            if probSub(1)==10 % flip the left and right trials
                % also flip direction for AP (not absolute values)
                if strcmp(checkParas{paraN}, 'pursuit.APvelocityX')
                    subMeanS{paraN}(subN, probN) = nanmean(-yValues{paraN, subN}.standard(:, 4-probN));
                    subMeanP{paraN}(subN, probN) = nanmean(-yValues{paraN, subN}.perceptual(:, 4-probN));
                    
                    subMeanSL{paraN}(subN, probN) = nanmean(-yValuesR{paraN, subN}.standard(:, 4-probN));
                    subMeanPL{paraN}(subN, probN) = nanmean(-yValuesR{paraN, subN}.perceptual(:, 4-probN));
                    subMeanSR{paraN}(subN, probN) = nanmean(-yValuesL{paraN, subN}.standard(:, 4-probN));
                    subMeanPR{paraN}(subN, probN) = nanmean(-yValuesL{paraN, subN}.perceptual(:, 4-probN));
                else
                    subMeanS{paraN}(subN, probN) = nanmean(yValues{paraN, subN}.standard(:, 4-probN));
                    subMeanP{paraN}(subN, probN) = nanmean(yValues{paraN, subN}.perceptual(:, 4-probN));
                    
                    subMeanSL{paraN}(subN, probN) = nanmean(yValuesR{paraN, subN}.standard(:, 4-probN));
                    subMeanPL{paraN}(subN, probN) = nanmean(yValuesR{paraN, subN}.perceptual(:, 4-probN));
                    subMeanSR{paraN}(subN, probN) = nanmean(yValuesL{paraN, subN}.standard(:, 4-probN));
                    subMeanPR{paraN}(subN, probN) = nanmean(yValuesL{paraN, subN}.perceptual(:, 4-probN));
                end
            else
                subMeanS{paraN}(subN, probN) = nanmean(yValues{paraN, subN}.standard(:, probN));
                subMeanP{paraN}(subN, probN) = nanmean(yValues{paraN, subN}.perceptual(:, probN));
                
                subMeanSL{paraN}(subN, probN) = nanmean(yValuesL{paraN, subN}.standard(:, probN));
                subMeanPL{paraN}(subN, probN) = nanmean(yValuesL{paraN, subN}.perceptual(:, probN));
                subMeanSR{paraN}(subN, probN) = nanmean(yValuesR{paraN, subN}.standard(:, probN));
                subMeanPR{paraN}(subN, probN) = nanmean(yValuesR{paraN, subN}.perceptual(:, probN));
            end
            
        end
        % standard trials
        meanYs_all{paraN}(1, probN) = nanmean(subMeanS{paraN}(:, probN)); % all trials
        steYs_all{paraN}(1, probN) = nanstd(subMeanS{paraN}(:, probN))/sqrt(size(names, 2)); % all trials
        
        meanYs{paraN}(1, probN) = nanmean(subMeanSL{paraN}(:, probN)); % left trials
        meanYs{paraN}(2, probN) = nanmean(subMeanSR{paraN}(:, probN)); % right trials
        steYs{paraN}(1, probN) = nanstd(subMeanSL{paraN}(:, probN))/sqrt(size(names, 2)); % left trials
        steYs{paraN}(2, probN) = nanstd(subMeanSR{paraN}(:, probN))/sqrt(size(names, 2)); % right trials
        
        % perceptual trials
        meanYp_all{paraN}(1, probN) = nanmean(subMeanP{paraN}(:, probN)); % all trials
        steYp_all{paraN}(1, probN) = nanstd(subMeanP{paraN}(:, probN))/sqrt(size(names, 2)); % all trials
        
        meanYp{paraN}(1, probN) = nanmean(subMeanPL{paraN}(:, probN)); % left trials
        meanYp{paraN}(2, probN) = nanmean(subMeanPR{paraN}(:, probN)); % right trials
        steYp{paraN}(1, probN) = nanstd(subMeanPL{paraN}(:, probN))/sqrt(size(names, 2)); % left trials
        steYp{paraN}(2, probN) = nanstd(subMeanPR{paraN}(:, probN))/sqrt(size(names, 2)); % right trials
    end
    
    if averagedPlots==1
        if paraN<sacStart
            cd(pursuitFolder)
        else
            cd(saccadeFolder)
        end
        % plot
        %         errorbar_groups(meanYs_all{paraN},  steYs_all{paraN}, ...
        %             'bar_width',0.75,'errorbar_width',0.5, ...
        %             'bar_names',{'50','70','90'});
        %         title('standard trials')
        %         ylabel(yLabels{paraN})
        %         %     ylim([-0.5 5])
        %         box off
        %         saveas(gca, [pdfNames{paraN}, '_barplot_standardTrialsMerged.pdf'])
        
        errorbar_groups(meanYp_all{paraN},  steYp_all{paraN}, ...
            'bar_width',0.75,'errorbar_width',0.5, ...
            'bar_names',{'50','70','90'});
        title('perceptual trials')
        ylabel(yLabels{paraN})
        %     ylim([-0.5 5])
        box off
        saveas(gca, [pdfNames{paraN}, '_barplot_perceptualTrialsMerged.pdf'])
        
        %         % left and right seperated, standard trials
        %         errorbar_groups(meanYs{paraN}, steYs{paraN},  ...
        %             'bar_width',0.75,'errorbar_width',0.5, ...
        %             'bar_names',{'50','70','90'});
        %         legend({'leftward trials' 'rightward trials'})
        %         title('standard trials')
        %         ylabel(yLabels{paraN})
        %         %         ylim([0 1.3])
        %         box off
        %         saveas(gca, [pdfNames{paraN}, '_barplot_standardTrialsLR.pdf'])
        %
        % left and right seperated, perceptual trials
        errorbar_groups(meanYp{paraN}, steYp{paraN},  ...
            'bar_width',0.75,'errorbar_width',0.5, ...
            'bar_names',{'50','70','90'});
        %         legend({'leftward trials' 'rightward trials'})
        legend({'perceived left trials' 'perceived right trials'})
        title('perceptual trials')
        ylabel(yLabels{paraN})
        %     ylim([-0.5 5])
        box off
        saveas(gca, [pdfNames{paraN}, '_barplot_perceptualTrialsLR.pdf'])
%         saveas(gca, [pdfNames{paraN}, '_barplot_perceptualTrialsLR_sortByChoice.pdf'])
    end
    %     % probability not merged... not correct = =
    %     for probN= 1:size(probCons, 2)
    %         for subN = 1:size(names, 2)
    %             probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    %             probSubN = find(probSub==probCons(probN)); % find prob index within the participant
    %             if ~isempty(probSubN) % if this participant has the probability condition
    %                 subMeanS{paraN}(subN, probN) = nanmean(yValues{paraN, subN}.standard(:, probSubN));
    %                 subMeanP{paraN}(subN, probN) = nanmean(yValues{paraN, subN}.perceptual(:, probSubN));
    %
    %                 subMeanSL{paraN}(subN, probN) = nanmean(yValuesL{paraN, subN}.standard(:, probSubN));
    %                 subMeanPL{paraN}(subN, probN) = nanmean(yValuesL{paraN, subN}.perceptual(:, probSubN));
    %                 subMeanSR{paraN}(subN, probN) = nanmean(yValuesR{paraN, subN}.standard(:, probSubN));
    %                 subMeanPR{paraN}(subN, probN) = nanmean(yValuesR{paraN, subN}.perceptual(:, probSubN));
    %             end
    %
    %         end
    %         % standard trials
    %         meanYs_all{paraN}(1, probN) = nanmean(subMeanS{paraN}(:, probN)); % all trials
    %         steYs_all{paraN}(1, probN) = nanstd(subMeanS{paraN}(:, probN))/sqrt(size(names, 2)); % all trials
    %
    %         meanYs{paraN}(1, probN) = nanmean(subMeanSL{paraN}(:, probN)); % left trials
    %         meanYs{paraN}(2, probN) = nanmean(subMeanSR{paraN}(:, probN)); % right trials
    %         steYs{paraN}(1, probN) = nanstd(subMeanSL{paraN}(:, probN))/sqrt(size(names, 2)); % left trials
    %         steYs{paraN}(2, probN) = nanstd(subMeanSR{paraN}(:, probN))/sqrt(size(names, 2)); % right trials
    %
    %         % perceptual trials
    %         meanYp_all{paraN}(1, probN) = nanmean(subMeanP{paraN}(:, probN)); % all trials
    %         steYp_all{paraN}(1, probN) = nanstd(subMeanP{paraN}(:, probN))/sqrt(size(names, 2)); % all trials
    %
    %         meanYp{paraN}(1, probN) = nanmean(subMeanPL{paraN}(:, probN)); % left trials
    %         meanYp{paraN}(2, probN) = nanmean(subMeanPR{paraN}(:, probN)); % right trials
    %         steYp{paraN}(1, probN) = nanstd(subMeanPL{paraN}(:, probN))/sqrt(size(names, 2)); % left trials
    %         steYp{paraN}(2, probN) = nanstd(subMeanPR{paraN}(:, probN))/sqrt(size(names, 2)); % right trials
    %     end
    %
    %     % plot
    % %     if strcmp(checkParas{paraN}, 'pursuit.APvelocityX') % AP, left&right trials plot together
    %         errorbar_groups(meanYp_all{paraN},  steYp_all{paraN}, ...
    %             'bar_width',0.75,'errorbar_width',0.5, ...
    %             'bar_names',{'10' '30' '50','70','90'});
    %         title('all trials')
    %         ylabel(yLabels{paraN})
    %         %     ylim([-0.5 5])
    %         box off
    %         saveas(gca, [pdfNames{paraN}, '_barplot_allTrials.pdf'])
    % %     else
    %         % left and right seperated, standard trials
    %         errorbar_groups(meanYs{paraN}, steYs{paraN},  ...
    %             'bar_width',0.75,'errorbar_width',0.5, ...
    %             'bar_names',{'10' '30' '50','70','90'});
    %         legend({'leftward trials' 'rightward trials'})
    %         title('standard trials')
    %         ylabel(yLabels{paraN})
    %         %         ylim([0 1.3])
    %         box off
    %         saveas(gca, [pdfNames{paraN}, '_barplot_standardTrials.pdf'])
    %
    %         % left and right seperated, perceptual trials
    %         errorbar_groups(meanYp{paraN}, steYp{paraN},  ...
    %             'bar_width',0.75,'errorbar_width',0.5, ...
    %             'bar_names',{'10' '30' '50','70','90'});
    %         legend({'leftward trials' 'rightward trials'})
    %         title('perceptual trials')
    %         ylabel(yLabels{paraN})
    %         %     ylim([-0.5 5])
    %         box off
    %         saveas(gca, [pdfNames{paraN}, '_barplot_perceptualTrials.pdf'])
    % %     end
end

%% scatter plot of all participants in all probabilities
% each dot is one participant in one probability block
cd(analysisFolder)
cd ..
cd ..
cd('psychometricFunction')
load dataPercept_all
cd(analysisFolder)

for paraN = 1:1%sacStart-1%size(checkParas, 2)
    if scatterPlots==1
        if paraN<sacStart
            cd(pursuitFolder)
        else
            cd(saccadeFolder)
        end
        
        figure
        for subN = 1:size(names, 2)
            hold on
            scatter(dataPercept.alpha(subN, :), subMeanP{paraN}(subN, :))
        end
        %         for probNmerged = 1:3
        %             hold on
        %             scatter(dataPercept.alpha(:, probNmerged), subMeanP{paraN}(:, probNmerged), ...
        %                 'MarkerFaceColor', colorProb(probNmerged+2, :), 'MarkerEdgeColor', 'none')
        %         end
        %         legend({'50','70','90'})
        title('perceptual trials')
        xlabel('PSE')
        ylabel(yLabels{paraN})
        %     ylim([-0.5 5])
        box off
        %         saveas(gca, [pdfNames{paraN}, '_scatterplot_perceptualTrials.pdf'])
    end
end
