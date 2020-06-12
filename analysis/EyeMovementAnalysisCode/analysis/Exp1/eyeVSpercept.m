initializeParas;

% different parameters to look at
checkParas = {'pursuit.APvelocityX' ...
    'pursuit.initialMeanVelocityX' 'pursuit.initialPeakVelocityX' 'pursuit.initialVelChangeX'...
    'pursuit.closedLoopMeanVelX' 'pursuit.gainX' ...
    'saccades.X.number' 'saccades.X.meanAmplitude' 'saccades.X.sumAmplitude'}; % field name in eyeTrialData
pdfNames = {'APvelX' ...
    'olpMeanVelX' 'olpPeakVelX' 'olpVelChangeX'...
    'clpMeanVelX' 'clpGainX' ...
    'sacNumX' 'sacMeanAmpX' 'sacSumAmpX'}; % name for saving the pdf
sacStart = 7; % from the n_th parameter is saccade

% some settings
individualPlots = 1;
averagedPlots = 1;
yLabels = {'AP horizontal velocity (deg/s)' ...
    'olp mean horizontal velocity (deg/s)' 'olp peak horizontal velocity (deg/s)' 'olp horizontal velocity change'...
    'clp mean horizontal velocity (deg/s)' 'clp gain (horizontal)' ...
    'saccade number (horizontal)' 'saccade mean amplitude (horizontal)' 'saccade sum amplitude (horizontal)'};

%% sort trials by perceptual responses, plot pursuit
for paraN = 1:1%size(checkParas, 2)
    for subN = 1:size(names, 2)
        probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
        if probSub(1)<50
            probNameI = 1;
        else
            probNameI = 2;
        end
        
        for probSubN = 1:size(probSub, 2)
            % low coherece trials perceived as moving to the right
            idxR = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & eyeTrialData.choice(subN, :)==1 & abs(eyeTrialData.coh(subN, :))<=0.05);
            % low coherece trials perceived as moving to the left
            idxL = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & eyeTrialData.choice(subN, :)==0 & abs(eyeTrialData.coh(subN, :))<=0.05);
            
            eval(['yValuesMean{paraN, subN}(probSubN, 1) = nanmean(eyeTrialData.' checkParas{paraN} '(subN, idxL));']); % choosing left
            eval(['yValuesStd{paraN, subN}(probSubN, 1) = nanstd(eyeTrialData.' checkParas{paraN} '(subN, idxL));']); % choosing left
            eval(['yValuesMean{paraN, subN}(probSubN, 2) = nanmean(eyeTrialData.' checkParas{paraN} '(subN, idxR));']); % choosing right
            eval(['yValuesStd{paraN, subN}(probSubN, 2) = nanstd(eyeTrialData.' checkParas{paraN} '(subN, idxR));']); % choosing right
        end
        %     individual plot
        if individualPlots==1
            if paraN<sacStart
                cd([pursuitFolder '\individuals'])
            else
                cd([saccadeFolder '\individuals'])
            end
            
            figure
            for probSubN = 1:size(probSub, 2)
                probN = find(probCons==probSub(probSubN));
                errorbar([-1 1], yValuesMean{paraN, subN}(probSubN, :), yValuesStd{paraN, subN}(probSubN, :), '--o', 'color', colorProb(probN, :))
                hold on
                %         xlim([0 1])
                %         ylim([-8 10])
            end
            legend(probNames{probNameI}, 'box', 'off')
            xlabel('Perceptual choice (-1=left, 1=right)')
            ylabel(yLabels{paraN})
            title([names{subN}, ', perceptual trials'])
            %     end
            saveas(gca, ['choice_' pdfNames{paraN} '_', names{subN}, '.pdf'])
        end
    end
end

%% grouped plots
for paraN = 1:1%size(checkParas, 2)
    for subN = 1:size(names, 2)
        probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
        if probSub(1)<50
            probNameI = 1;
        else
            probNameI = 2;
        end
        
        for probSubN = 1:size(probSub, 2)
            % low coherece trials perceived as moving to the right
            idxR = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & eyeTrialData.choice(subN, :)==1 & abs(eyeTrialData.coh(subN, :))<=0.05);
            % low coherece trials perceived as moving to the left
            idxL = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & eyeTrialData.choice(subN, :)==0 & abs(eyeTrialData.coh(subN, :))<=0.05);
            
            eval(['yValuesMean{paraN, subN}(probSubN, 1) = nanmean(eyeTrialData.' checkParas{paraN} '(subN, idxL));']); % choosing left
            eval(['yValuesStd{paraN, subN}(probSubN, 1) = nanstd(eyeTrialData.' checkParas{paraN} '(subN, idxL));']); % choosing left
            eval(['yValuesMean{paraN, subN}(probSubN, 2) = nanmean(eyeTrialData.' checkParas{paraN} '(subN, idxR));']); % choosing right
            eval(['yValuesStd{paraN, subN}(probSubN, 2) = nanstd(eyeTrialData.' checkParas{paraN} '(subN, idxR));']); % choosing right
        end
        %     individual plot
        if individualPlots==1
            if paraN<sacStart
                cd([pursuitFolder '\individuals'])
            else
                cd([saccadeFolder '\individuals'])
            end
            
            figure
            for probSubN = 1:size(probSub, 2)
                probN = find(probCons==probSub(probSubN));
                errorbar([-1 1], yValuesMean{paraN, subN}(probSubN, :), yValuesStd{paraN, subN}(probSubN, :), '--o', 'color', colorProb(probN, :))
                hold on
                %         xlim([0 1])
                %         ylim([-8 10])
            end
            legend(probNames{probNameI}, 'box', 'off')
            xlabel('Perceptual choice (-1=left, 1=right)')
            ylabel(yLabels{paraN})
            title([names{subN}, ', perceptual trials'])
            %     end
            saveas(gca, ['choice_' pdfNames{paraN} '_', names{subN}, '.pdf'])
        end
    end
end

%% trial correlation... doesn't make sense now
% for subN = 1:size(names, 2)
%     probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
%     if probSub(1)<50
%         probNameI = 1;
%     else
%         probNameI = 2;
%     end
%
%     for paraN = 1:sacStart-1%size(checkParas, 2) % automatically loop through the parameters
%         for probSubN = 1:size(probSub, 2)
%             idx = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0)
%             if individualPlot==1
%                 figure
%                 scatter(eyeTrialData.choice(subN, idx))
%                 title('perceptual trials')
%                 xlabel('perceived direction')
%                 ylabel(yLabels{paraN})
%                 %     ylim([-0.5 5])
%                 box off
% %                 saveas(gca, [pdfNames{paraN}, '_choiceVSeye_perceptualTrials.pdf'])
%             end
%         end
%     end
% end