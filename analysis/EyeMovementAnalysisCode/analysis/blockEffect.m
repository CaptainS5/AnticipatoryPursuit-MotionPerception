initializeParas;

% different parameters to look at
checkParas = {'pursuit.APvelocityX' ...
    'pursuit.initialMeanVelocityX' 'pursuit.initialPeakVelocityX' 'pursuit.initialMeanAccelerationX' ...
    'pursuit.gainX' ...
    'saccades.X.number' 'saccades.X.meanAmplitude' 'saccades.X.sumAmplitude'}; % field name in eyeTrialData
pdfNames = {'APvelX' ...
    'olpMeanVelX' 'olpPeakVelX' ...
    'clpGainX' ...
    'sacNumX' 'sacMeanAmpX' 'sacSumAmpX'}; % name for saving the pdf
sacStart = 5; % from the n_th parameter is saccade

% some settings
individualPlots = 1;
averagedPlots = 1;
yLabels = {'AP horizontal velocity (deg/s)' ...
    'olp mean horizontal velocity (deg/s)' 'olp peak horizontal velocity (deg/s)' 'olp mean acceleration (deg/s2)'...
    'clp gain (horizontal)' ...
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
    
    for paraN = 4:4%size(checkParas, 2) % automatically loop through the parameters... just too much of them
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
            validIL = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)==-1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            eval(['yValuesL{paraN, subN}.perceptual(1:length(validIL), probSubN) = eyeTrialData.' checkParas{paraN} '(subN, validIL);'])
            validIR = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0 ...
                & eyeTrialData.rdkDir(subN, :)==1 & eyeTrialData.prob(subN, :)==probSub(probSubN));
            eval(['yValuesR{paraN, subN}.perceptual(1:length(validIR), probSubN) = eyeTrialData.' checkParas{paraN} '(subN, validIR);'])
        end
        
        if individualPlots==1
            if paraN<sacStart
                cd(pursuitFolder)
            else
                cd(saccadeFolder)
            end
            % individual plots
            % plot mean values of each participant
            if ~strcmp(checkParas{paraN}, 'choice') && ~strcmp(checkParas{paraN}, 'saccades.X.number') % do not plot boxplot of perception or saccade number... meaningless
                figure
                subplot(1, 2, 1)
                hold on
                boxplot(yValues{paraN, subN}.standard, 'Labels', probNames{probNameI})
                title('standard trials')
                ylabel(yLabels{paraN})
                %             ylim([minY(paraN) maxY(paraN)])
                box off
                
                subplot(1, 2, 2)
                hold on
                boxplot(yValues{paraN, subN}.perceptual, 'Labels', probNames{probNameI})
                title('perceptual trials')
                ylabel(yLabels{paraN})
                %             ylim([minY(paraN) maxY(paraN)])
                box off
                
                saveas(gca, [pdfNames{paraN}, '_boxplot_', names{subN}, '.pdf'])
            end
        end
    end
end

%% grouped bars of the mean of all participants
% sort data of different participants together
for paraN = 4:4%size(checkParas, 2)
    tempMeanS{paraN} = NaN(size(names, 2), size(probCons, 2)); % standard trials
    tempMeanSL{paraN} = NaN(size(names, 2), size(probCons, 2));
    tempMeanSR{paraN} = NaN(size(names, 2), size(probCons, 2));
    tempMeanP{paraN} = NaN(size(names, 2), size(probCons, 2)); % perceptual trials
    tempMeanPL{paraN} = NaN(size(names, 2), size(probCons, 2));
    tempMeanPR{paraN} = NaN(size(names, 2), size(probCons, 2));
    
    for probN= 1:3 % here probN is merged, 50, 70, and 90
        for subN = 1:size(names, 2)
            if strcmp(checkParas{paraN}, 'pursuit.initialMeanVelocityX') % flip direction to merge the left and right trials
                yValues{paraN, subN}.standard = abs(yValues{paraN, subN}.standard);
                yValues{paraN, subN}.perceptual = abs(yValues{paraN, subN}.perceptual);
                yValuesL{paraN, subN}.standard = abs(yValuesL{paraN, subN}.standard);
                yValuesL{paraN, subN}.perceptual = abs(yValuesL{paraN, subN}.perceptual);
                yValuesR{paraN, subN}.standard = abs(yValuesR{paraN, subN}.standard);
                yValuesR{paraN, subN}.perceptual = abs(yValuesR{paraN, subN}.perceptual);
            end
            
            probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
            if probSub(1)==10 % flip the left and right trials
                % also flip direction for AP (these are not absolute values)
                if strcmp(checkParas{paraN}, 'pursuit.APvelocityX')
                    tempMeanS{paraN}(subN, probN) = nanmean(-yValues{paraN, subN}.standard(:, 4-probN));
                    tempMeanP{paraN}(subN, probN) = nanmean(-yValues{paraN, subN}.perceptual(:, 4-probN));
                    
                    tempMeanSL{paraN}(subN, probN) = nanmean(-yValuesR{paraN, subN}.standard(:, 4-probN));
                    tempMeanPL{paraN}(subN, probN) = nanmean(-yValuesR{paraN, subN}.perceptual(:, 4-probN));
                    tempMeanSR{paraN}(subN, probN) = nanmean(-yValuesL{paraN, subN}.standard(:, 4-probN));
                    tempMeanPR{paraN}(subN, probN) = nanmean(-yValuesL{paraN, subN}.perceptual(:, 4-probN));
                else
                    tempMeanS{paraN}(subN, probN) = nanmean(yValues{paraN, subN}.standard(:, 4-probN));
                    tempMeanP{paraN}(subN, probN) = nanmean(yValues{paraN, subN}.perceptual(:, 4-probN));
                    
                    tempMeanSL{paraN}(subN, probN) = nanmean(yValuesR{paraN, subN}.standard(:, 4-probN));
                    tempMeanPL{paraN}(subN, probN) = nanmean(yValuesR{paraN, subN}.perceptual(:, 4-probN));
                    tempMeanSR{paraN}(subN, probN) = nanmean(yValuesL{paraN, subN}.standard(:, 4-probN));
                    tempMeanPR{paraN}(subN, probN) = nanmean(yValuesL{paraN, subN}.perceptual(:, 4-probN));
                end
            else
                tempMeanS{paraN}(subN, probN) = nanmean(yValues{paraN, subN}.standard(:, probN));
                tempMeanP{paraN}(subN, probN) = nanmean(yValues{paraN, subN}.perceptual(:, probN));
                
                tempMeanSL{paraN}(subN, probN) = nanmean(yValuesL{paraN, subN}.standard(:, probN));
                tempMeanPL{paraN}(subN, probN) = nanmean(yValuesL{paraN, subN}.perceptual(:, probN));
                tempMeanSR{paraN}(subN, probN) = nanmean(yValuesR{paraN, subN}.standard(:, probN));
                tempMeanPR{paraN}(subN, probN) = nanmean(yValuesR{paraN, subN}.perceptual(:, probN));
            end
            
        end
        % standard trials
        meanYs_all{paraN}(1, probN) = nanmean(tempMeanS{paraN}(:, probN)); % all trials
        steYs_all{paraN}(1, probN) = nanstd(tempMeanS{paraN}(:, probN))/sqrt(size(names, 2)); % all trials
        
        meanYs{paraN}(1, probN) = nanmean(tempMeanSL{paraN}(:, probN)); % left trials
        meanYs{paraN}(2, probN) = nanmean(tempMeanSR{paraN}(:, probN)); % right trials
        steYs{paraN}(1, probN) = nanstd(tempMeanSL{paraN}(:, probN))/sqrt(size(names, 2)); % left trials
        steYs{paraN}(2, probN) = nanstd(tempMeanSR{paraN}(:, probN))/sqrt(size(names, 2)); % right trials
        
        % perceptual trials
        meanYp_all{paraN}(1, probN) = nanmean(tempMeanP{paraN}(:, probN)); % all trials
        steYp_all{paraN}(1, probN) = nanstd(tempMeanP{paraN}(:, probN))/sqrt(size(names, 2)); % all trials
        
        meanYp{paraN}(1, probN) = nanmean(tempMeanPL{paraN}(:, probN)); % left trials
        meanYp{paraN}(2, probN) = nanmean(tempMeanPR{paraN}(:, probN)); % right trials
        steYp{paraN}(1, probN) = nanstd(tempMeanPL{paraN}(:, probN))/sqrt(size(names, 2)); % left trials
        steYp{paraN}(2, probN) = nanstd(tempMeanPR{paraN}(:, probN))/sqrt(size(names, 2)); % right trials
    end
    
    if averagedPlots==1
        if paraN<sacStart
            cd(pursuitFolder)
        else
            cd(saccadeFolder)
        end
        % plot
        %     if strcmp(checkParas{paraN}, 'pursuit.APvelocityX') % AP, left&right trials plot together
        errorbar_groups(meanYp_all{paraN},  steYp_all{paraN}, ...
            'bar_width',0.75,'errorbar_width',0.5, ...
            'bar_names',{'50','70','90'});
        title('all trials')
        ylabel(yLabels{paraN})
        %     ylim([-0.5 5])
        box off
        saveas(gca, [pdfNames{paraN}, '_barplot_allTrialsMerged.pdf'])
        %     else
        % left and right seperated, standard trials
        errorbar_groups(meanYs{paraN}, steYs{paraN},  ...
            'bar_width',0.75,'errorbar_width',0.5, ...
            'bar_names',{'50','70','90'});
        legend({'leftward trials' 'rightward trials'})
        title('standard trials')
        ylabel(yLabels{paraN})
        %         ylim([0 1.3])
        box off
        saveas(gca, [pdfNames{paraN}, '_barplot_standardTrialsMerged.pdf'])
        
        % left and right seperated, perceptual trials
        errorbar_groups(meanYp{paraN}, steYp{paraN},  ...
            'bar_width',0.75,'errorbar_width',0.5, ...
            'bar_names',{'50','70','90'});
        legend({'leftward trials' 'rightward trials'})
        title('perceptual trials')
        ylabel(yLabels{paraN})
        %     ylim([-0.5 5])
        box off
        saveas(gca, [pdfNames{paraN}, '_barplot_perceptualTrialsMerged.pdf'])
    end
    %     % probability not merged... not correct = =
    %     for probN= 1:size(probCons, 2)
    %         for subN = 1:size(names, 2)
    %             probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    %             probSubN = find(probSub==probCons(probN)); % find prob index within the participant
    %             if ~isempty(probSubN) % if this participant has the probability condition
    %                 tempMeanS{paraN}(subN, probN) = nanmean(yValues{paraN, subN}.standard(:, probSubN));
    %                 tempMeanP{paraN}(subN, probN) = nanmean(yValues{paraN, subN}.perceptual(:, probSubN));
    %
    %                 tempMeanSL{paraN}(subN, probN) = nanmean(yValuesL{paraN, subN}.standard(:, probSubN));
    %                 tempMeanPL{paraN}(subN, probN) = nanmean(yValuesL{paraN, subN}.perceptual(:, probSubN));
    %                 tempMeanSR{paraN}(subN, probN) = nanmean(yValuesR{paraN, subN}.standard(:, probSubN));
    %                 tempMeanPR{paraN}(subN, probN) = nanmean(yValuesR{paraN, subN}.perceptual(:, probSubN));
    %             end
    %
    %         end
    %         % standard trials
    %         meanYs_all{paraN}(1, probN) = nanmean(tempMeanS{paraN}(:, probN)); % all trials
    %         steYs_all{paraN}(1, probN) = nanstd(tempMeanS{paraN}(:, probN))/sqrt(size(names, 2)); % all trials
    %
    %         meanYs{paraN}(1, probN) = nanmean(tempMeanSL{paraN}(:, probN)); % left trials
    %         meanYs{paraN}(2, probN) = nanmean(tempMeanSR{paraN}(:, probN)); % right trials
    %         steYs{paraN}(1, probN) = nanstd(tempMeanSL{paraN}(:, probN))/sqrt(size(names, 2)); % left trials
    %         steYs{paraN}(2, probN) = nanstd(tempMeanSR{paraN}(:, probN))/sqrt(size(names, 2)); % right trials
    %
    %         % perceptual trials
    %         meanYp_all{paraN}(1, probN) = nanmean(tempMeanP{paraN}(:, probN)); % all trials
    %         steYp_all{paraN}(1, probN) = nanstd(tempMeanP{paraN}(:, probN))/sqrt(size(names, 2)); % all trials
    %
    %         meanYp{paraN}(1, probN) = nanmean(tempMeanPL{paraN}(:, probN)); % left trials
    %         meanYp{paraN}(2, probN) = nanmean(tempMeanPR{paraN}(:, probN)); % right trials
    %         steYp{paraN}(1, probN) = nanstd(tempMeanPL{paraN}(:, probN))/sqrt(size(names, 2)); % left trials
    %         steYp{paraN}(2, probN) = nanstd(tempMeanPR{paraN}(:, probN))/sqrt(size(names, 2)); % right trials
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