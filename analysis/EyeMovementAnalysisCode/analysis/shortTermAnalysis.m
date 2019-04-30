initializeParas;

% different parameters to look at
checkParas = {'choice' 'pursuit.APvelocityX' ...
    'pursuit.initialMeanVelocityX' 'pursuit.initialPeakVelocityX' ...
    'pursuit.gainX' ...
    'saccades.X.number' 'saccades.X.meanAmplitude' 'saccades.X.sumAmplitude'}; % field name in eyeTrialData
pdfNames = {'perception' 'APvelX' ...
    'olpMeanVelX' 'olpPeakVelX' ...
    'clpGainX' ...
    'sacNumX' 'sacMeanAmpX' 'sacSumAmpX'}; % name for saving the pdf
sacStart = 6; % from the n_th parameter is saccade

allLength = 682; % length of all trials in one block
sLength = 500; % length of standard trials in one block
pLength = 182; % length of perceptual trials in one block
trialBin = 2; % window of trial numbers

% some settings
individualPlots = 0;
averagedPlots = 1;
yLabels = {'Probability of perceiving right-probability of right' 'AP horizontal velocity (deg/s)' ...
    'olp mean horizontal velocity (deg/s)' 'olp peak horizontal velocity (deg/s)' ...
    'clp gain (horizontal)' ...
    'saccade number (horizontal)' 'saccade mean amplitude (horizontal)' 'saccade sum amplitude (horizontal)'};
% for plotting, each parameter has a specific y value range
minY = [0; -3; ...
    -10; -15; ...
    0; ...
    0; 0; 0];
maxY = [1; 3; ...
    10; 15; ...
    1.5; ...
    5; 2; 5];

%% sort trials by preceeding probability of right--true preceeding trials, not trials in the sorted list
% be careful not to include the current trial...
for subN = 1:size(names, 2)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        probNameI = 1;
    else
        probNameI = 2;
    end
    
    for paraN = 1:sacStart-1%size(checkParas, 2) % automatically loop through the parameters
        for probSubN = 1:size(probSub, 2)
            yValuesAll{paraN, subN}{probSubN} = NaN(1, allLength-trialBin+1);
            yValuesS{paraN, subN}{probSubN} = NaN(1, sLength-trialBin+1);
            yValuesP{paraN, subN}{probSubN} = NaN(1, pLength-trialBin+1);
            precedeProbAll{paraN, subN}{probSubN} = NaN(1, allLength-trialBin+1);
            precedeProbS{paraN, subN}{probSubN} = NaN(1, sLength-trialBin+1);
            precedeProbP{paraN, subN}{probSubN} = NaN(1, pLength-trialBin+1);
            yValuesSortedAll{paraN, subN}{probSubN} = NaN(1, allLength-trialBin+1);
            yValuesSortedS{paraN, subN}{probSubN} = NaN(1, sLength-trialBin+1);
            yValuesSortedP{paraN, subN}{probSubN} = NaN(1, pLength-trialBin+1);
            
            % all trials
            idxT = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0);
            for slideI = (trialBin+1):length(idxT)
                rightN = length(find(eyeTrialData.rdkDir(subN, (idxT(slideI)-trialBin):(idxT(slideI)-1))>0));
                precedeProbAll{paraN, subN}{probSubN}(slideI-trialBin) = rightN/trialBin;
                eval(['yValuesAll{paraN, subN}{probSubN}(slideI-trialBin) = eyeTrialData.' checkParas{paraN} '(subN, idxT(slideI));']);
            end
            nanI = find(isnan(yValuesAll{paraN, subN}{probSubN}));
            yValuesAll{paraN, subN}{probSubN}(nanI) = [];
            precedeProbAll{paraN, subN}{probSubN}(nanI) = [];
            [xProbAll{paraN, subN}{probSubN} ia ic] = unique(precedeProbAll{paraN, subN}{probSubN});
            yValuesSortedAll{paraN, subN}{probSubN} = accumarray(ic, yValuesAll{paraN, subN}{probSubN}', [], @mean); % mean AP of the corresponding probability
            
            % standard trials
            idxT = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & abs(eyeTrialData.coh(subN, :))==1);
            for slideI = (trialBin+1):length(idxT)
                rightN = length(find(eyeTrialData.rdkDir(subN, (idxT(slideI)-trialBin):(idxT(slideI)-1))>0));
                precedeProbS{paraN, subN}{probSubN}(slideI-trialBin) = rightN/trialBin;
                eval(['yValuesS{paraN, subN}{probSubN}(slideI-trialBin) = eyeTrialData.' checkParas{paraN} '(subN, idxT(slideI));']);
            end
            nanI = find(isnan(yValuesS{paraN, subN}{probSubN}));
            precedeProbS{paraN, subN}{probSubN}(nanI) = [];
            yValuesS{paraN, subN}{probSubN}(nanI) = [];
            [xProbS{paraN, subN}{probSubN} ia ic] = unique(precedeProbS{paraN, subN}{probSubN});
            yValuesSortedS{paraN, subN}{probSubN} = accumarray(ic, yValuesS{paraN, subN}{probSubN}', [], @mean); % mean AP of the corresponding probability
            
            % perceptual trials
            idxT = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & abs(eyeTrialData.coh(subN, :))~=1);
            for slideI = (trialBin+1):length(idxT)
                rightN = length(find(eyeTrialData.rdkDir(subN, (idxT(slideI)-trialBin):(idxT(slideI)-1))>0));
                precedeProbP{paraN, subN}{probSubN}(slideI-trialBin) = rightN/trialBin;
                eval(['yValuesP{paraN, subN}{probSubN}(slideI-trialBin) = eyeTrialData.' checkParas{paraN} '(subN, idxT(slideI));']);
            end
            nanI = find(isnan(yValuesP{paraN, subN}{probSubN}));
            precedeProbP{paraN, subN}{probSubN}(nanI) = [];
            yValuesP{paraN, subN}{probSubN}(nanI) = [];
            [xProbP{paraN, subN}{probSubN} ia ic] = unique(precedeProbP{paraN, subN}{probSubN});
            yValuesSortedP{paraN, subN}{probSubN} = accumarray(ic, yValuesP{paraN, subN}{probSubN}', [], @mean); % mean AP of the corresponding probability
            % left trials
            idxTL = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & abs(eyeTrialData.coh(subN, :))~=1 & eyeTrialData.rdkDir(subN, :)<0);
            for slideI = (trialBin+1):length(idxTL)
                rightN = length(find(eyeTrialData.rdkDir(subN, (idxTL(slideI)-trialBin):(idxTL(slideI)-1))>0));
                precedeProbPL{paraN, subN}{probSubN}(slideI-trialBin) = rightN/trialBin;
                eval(['yValuesPL{paraN, subN}{probSubN}(slideI-trialBin) = eyeTrialData.' checkParas{paraN} '(subN, idxTL(slideI));']);
            end
            nanI = find(isnan(yValuesPL{paraN, subN}{probSubN}));
            precedeProbPL{paraN, subN}{probSubN}(nanI) = [];
            yValuesPL{paraN, subN}{probSubN}(nanI) = [];
            [xProbPL{paraN, subN}{probSubN} ia ic] = unique(precedeProbPL{paraN, subN}{probSubN});
            yValuesSortedPL{paraN, subN}{probSubN} = accumarray(ic, yValuesPL{paraN, subN}{probSubN}', [], @mean); % mean AP of the corresponding probability
            % right trials
            idxTR = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & abs(eyeTrialData.coh(subN, :))~=1  & eyeTrialData.rdkDir(subN, :)>0);
            for slideI = (trialBin+1):length(idxTR)
                rightN = length(find(eyeTrialData.rdkDir(subN, (idxTR(slideI)-trialBin):(idxTR(slideI)-1))>0));
                precedeProbPR{paraN, subN}{probSubN}(slideI-trialBin) = rightN/trialBin;
                eval(['yValuesPR{paraN, subN}{probSubN}(slideI-trialBin) = eyeTrialData.' checkParas{paraN} '(subN, idxTR(slideI));']);
            end
            nanI = find(isnan(yValuesPR{paraN, subN}{probSubN}));
            precedeProbPR{paraN, subN}{probSubN}(nanI) = [];
            yValuesPR{paraN, subN}{probSubN}(nanI) = [];
            [xProbPR{paraN, subN}{probSubN} ia ic] = unique(precedeProbPR{paraN, subN}{probSubN});
            yValuesSortedPR{paraN, subN}{probSubN} = accumarray(ic, yValuesPR{paraN, subN}{probSubN}', [], @mean); % mean AP of the corresponding probability
            
        end
        
        if individualPlots==1
            if paraN==1
                cd([perceptFolder '\individuals'])
            elseif paraN<sacStart
                cd([pursuitFolder '\individuals'])
            else
                cd([saccadeFolder '\individuals'])
            end
            
            % individual plot
            % perceptual trials, all trials merged
            figure
            for probSubN = 1:size(probSub, 2)
                probN = find(probCons==probSub(probSubN));
                plot(xProbP{paraN, subN}{probSubN}, yValuesSortedP{paraN, subN}{probSubN}, 'color', colorProb(probN, :))
                hold on
                %         xlim([0 1])
                %         ylim([-8 10])
            end
            legend(probNames{probNameI}, 'box', 'off')
            xlabel('Preceded probability of right')
            ylabel(yLabels{paraN})
            title([names{subN}, ' perceptual'])
            saveas(gca, ['precedeProbRight_perceptualTrials_' pdfNames{paraN},  '_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
            % left & right trials separated
            figure
            for probSubN = 1:size(probSub, 2)
                probN = find(probCons==probSub(probSubN));
                plot(xProbPL{paraN, subN}{probSubN}, yValuesSortedPL{paraN, subN}{probSubN}, '--', 'color', colorProb(probN, :))
                hold on
                plot(xProbPR{paraN, subN}{probSubN}, yValuesSortedPR{paraN, subN}{probSubN}, '-', 'color', colorProb(probN, :))
                %         xlim([0 1])
                %         ylim([-8 10])
            end
            if probSub(1)==50
                legend({'50-left' '50-right' '70-left' '70-right' '90-left' '90-right'}, 'box', 'off')
            else
                legend({'10-left' '10-right' '30-left' '30-right' '50-left' '50-right'}, 'box', 'off')
            end
            xlabel('Preceded probability of right')
            ylabel(yLabels{paraN})
            title([names{subN}, ' perceptual'])
            saveas(gca, ['precedeProbRight_perceptualTrialsLR_' pdfNames{paraN},  '_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
            
%             if ~strcmp(checkParas{paraN}, 'choice')
%                 % standard trials
%                 figure
%                 for probSubN = 1:size(probSub, 2)
%                     probN = find(probCons==probSub(probSubN));
%                     plot(xProbS{paraN, subN}{probSubN}, yValuesSortedS{paraN, subN}{probSubN}, 'color', colorProb(probN, :))
%                     hold on
%                     %         xlim([0 1])
%                     %         ylim([-8 10])
%                 end
%                 legend(probNames{probNameI}, 'box', 'off')
%                 xlabel('Preceded probability of right')
%                 ylabel(yLabels{paraN})
%                 title([names{subN}, ' standard'])
%                 saveas(gca, ['precedeProbRight_standardTrials_' pdfNames{paraN},  '_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
%                 
%                 % all trials
%                 figure
%                 for probSubN = 1:size(probSub, 2)
%                     probN = find(probCons==probSub(probSubN));
%                     plot(xProbAll{paraN, subN}{probSubN}, yValuesSortedAll{paraN, subN}{probSubN}, 'color', colorProb(probN, :))
%                     hold on
%                     %         xlim([0 1])
%                     %         ylim([-8 10])
%                 end
%                 legend(probNames{probNameI}, 'box', 'off')
%                 xlabel('Preceded probability of right')
%                 ylabel(yLabels{paraN})
%                 title([names{subN}, ' all'])
%                 saveas(gca, ['precedeProbRight_allTrials_' pdfNames{paraN},  '_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
%                 
%             end
        end
    end
end

%% grouped values
if averagedPlots==1
    for paraN = 1:sacStart-1%size(checkParas, 2)
        for probNmerged= 1:3 % here probN is merged, 50, 70, and 90
            tempProbAll{paraN, probNmerged} = [];
            tempYall{paraN, probNmerged} = [];
            tempProbS{paraN, probNmerged} = [];
            tempYs{paraN, probNmerged} = [];
            tempProbP{paraN, probNmerged} = [];
            tempYp{paraN, probNmerged} = [];
            tempProbPL{paraN, probNmerged} = [];
            tempYpL{paraN, probNmerged} = [];
            tempProbPR{paraN, probNmerged} = [];
            tempYpR{paraN, probNmerged} = [];
            
            for subN = 1:size(names, 2)
                probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
                if probSub(1)==10
                    tempProbAll{paraN, probNmerged} = [tempProbAll{paraN, probNmerged}; 1-precedeProbAll{paraN, subN}{4-probNmerged}'];
                    tempProbS{paraN, probNmerged} = [tempProbS{paraN, probNmerged}; 1-precedeProbS{paraN, subN}{4-probNmerged}'];
                    tempProbP{paraN, probNmerged} = [tempProbP{paraN, probNmerged}; 1-precedeProbP{paraN, subN}{4-probNmerged}'];
                    tempProbPL{paraN, probNmerged} = [tempProbPL{paraN, probNmerged}; 1-precedeProbPR{paraN, subN}{4-probNmerged}'];
                    tempProbPR{paraN, probNmerged} = [tempProbPR{paraN, probNmerged}; 1-precedeProbPL{paraN, subN}{4-probNmerged}'];
                    if strcmp(checkParas{paraN}, 'pursuit.APvelocityX')
                        % flip direction for AP (these are not absolute values) and perceptual choices
                        tempYall{paraN, probNmerged} = [tempYall{paraN, probNmerged}; -yValuesAll{paraN, subN}{4-probNmerged}'];
                        tempYs{paraN, probNmerged} = [tempYs{paraN, probNmerged}; -yValuesS{paraN, subN}{4-probNmerged}'];
                        tempYp{paraN, probNmerged} = [tempYp{paraN, probNmerged}; -yValuesP{paraN, subN}{4-probNmerged}'];
                        tempYpL{paraN, probNmerged} = [tempYpL{paraN, probNmerged}; -yValuesPR{paraN, subN}{4-probNmerged}'];
                        tempYpR{paraN, probNmerged} = [tempYpR{paraN, probNmerged}; -yValuesPL{paraN, subN}{4-probNmerged}'];
                    elseif strcmp(checkParas{paraN}, 'choice')
                        tempYall{paraN, probNmerged} = [tempYall{paraN, probNmerged}; 1-yValuesAll{paraN, subN}{4-probNmerged}'];
                        tempYs{paraN, probNmerged} = [tempYs{paraN, probNmerged}; 1-yValuesS{paraN, subN}{4-probNmerged}'];
                        tempYp{paraN, probNmerged} = [tempYp{paraN, probNmerged}; 1-yValuesP{paraN, subN}{4-probNmerged}'];
                        tempYpL{paraN, probNmerged} = [tempYpL{paraN, probNmerged}; 1-yValuesPR{paraN, subN}{4-probNmerged}'];
                        tempYpR{paraN, probNmerged} = [tempYpR{paraN, probNmerged}; 1-yValuesPL{paraN, subN}{4-probNmerged}'];
                    else
                        tempYall{paraN, probNmerged} = [tempYall{paraN, probNmerged}; yValuesAll{paraN, subN}{4-probNmerged}'];
                        tempYs{paraN, probNmerged} = [tempYs{paraN, probNmerged}; yValuesS{paraN, subN}{4-probNmerged}'];
                        tempYp{paraN, probNmerged} = [tempYp{paraN, probNmerged}; yValuesP{paraN, subN}{4-probNmerged}'];
                        tempYpL{paraN, probNmerged} = [tempYpL{paraN, probNmerged}; yValuesPR{paraN, subN}{4-probNmerged}'];
                        tempYpR{paraN, probNmerged} = [tempYpR{paraN, probNmerged}; yValuesPL{paraN, subN}{4-probNmerged}'];
                    end
                else
                    tempProbAll{paraN, probNmerged} = [tempProbAll{paraN, probNmerged}; precedeProbAll{paraN, subN}{probNmerged}'];
                    tempYall{paraN, probNmerged} = [tempYall{paraN, probNmerged}; yValuesAll{paraN, subN}{probNmerged}'];
                    tempProbS{paraN, probNmerged} = [tempProbS{paraN, probNmerged}; precedeProbS{paraN, subN}{probNmerged}'];
                    tempYs{paraN, probNmerged} = [tempYs{paraN, probNmerged}; yValuesS{paraN, subN}{probNmerged}'];
                    tempProbP{paraN, probNmerged} = [tempProbP{paraN, probNmerged}; precedeProbP{paraN, subN}{probNmerged}'];
                    tempYp{paraN, probNmerged} = [tempYp{paraN, probNmerged}; yValuesP{paraN, subN}{probNmerged}'];
                    tempProbPL{paraN, probNmerged} = [tempProbPL{paraN, probNmerged}; precedeProbPL{paraN, subN}{probNmerged}'];
                    tempYpL{paraN, probNmerged} = [tempYpL{paraN, probNmerged}; yValuesPL{paraN, subN}{probNmerged}'];
                    tempProbPR{paraN, probNmerged} = [tempProbPR{paraN, probNmerged}; precedeProbPR{paraN, subN}{probNmerged}'];
                    tempYpR{paraN, probNmerged} = [tempYpR{paraN, probNmerged}; yValuesPR{paraN, subN}{probNmerged}'];
                end
            end
            % all trials
            [xProbMergedAll{paraN, probNmerged} ia ic] = unique(tempProbAll{paraN, probNmerged});
            yValuesSortedMergedAll{paraN, probNmerged} = accumarray(ic, tempYall{paraN, probNmerged}, [], @mean);
            % standard trials
            [xProbMergedS{paraN, probNmerged} ia ic] = unique(tempProbS{paraN, probNmerged});
            yValuesSortedMergedS{paraN, probNmerged} = accumarray(ic, tempYs{paraN, probNmerged}, [], @mean);
            % perceptual trials
            [xProbMergedP{paraN, probNmerged} ia ic] = unique(tempProbP{paraN, probNmerged});
            yValuesSortedMergedP{paraN, probNmerged} = accumarray(ic, tempYp{paraN, probNmerged}, [], @mean);
            % left trials
            [xProbMergedPL{paraN, probNmerged} ia ic] = unique(tempProbPL{paraN, probNmerged});
            yValuesSortedMergedPL{paraN, probNmerged} = accumarray(ic, tempYpL{paraN, probNmerged}, [], @mean);
            % right trials
            [xProbMergedPR{paraN, probNmerged} ia ic] = unique(tempProbPR{paraN, probNmerged});
            yValuesSortedMergedPR{paraN, probNmerged} = accumarray(ic, tempYpR{paraN, probNmerged}, [], @mean);
        end
        
        % plot
        if paraN==1
            cd(perceptFolder)
        elseif paraN<sacStart
            cd(pursuitFolder)
        else
            cd(saccadeFolder)
        end
        
        % perceptual trials, merged
        if paraN<sacStart %strcmp(checkParas{paraN}, 'choice') || strcmp(checkParas{paraN}, 'pursuit.gainX')
            figure
            for probNmerged = 1:3
                plot(xProbMergedP{paraN, probNmerged}, yValuesSortedMergedP{paraN, probNmerged}, 'color', colorProb(probNmerged+2, :))
                hold on
                %         xlim([0 1])
                %         ylim([-8 10])
            end
            legend(probNames{2}, 'box', 'off')
            xlabel('Preceded probability of right')
            ylabel(yLabels{paraN})
            title([' perceptual'])
            saveas(gca, ['precedeProbRightMerged_perceptualTrials_' pdfNames{paraN},  '_all_bin', num2str(trialBin), '.pdf'])
        end
        % not merged
        if paraN<sacStart %strcmp(checkParas{paraN}, 'choice') || strcmp(checkParas{paraN}, 'pursuit.gainX')
            figure
            for probNmerged = 1:3
                plot(xProbMergedPL{paraN, probNmerged}, yValuesSortedMergedPL{paraN, probNmerged}, '--', 'color', colorProb(probNmerged+2, :))
                hold on
                plot(xProbMergedPR{paraN, probNmerged}, yValuesSortedMergedPR{paraN, probNmerged}, '-', 'color', colorProb(probNmerged+2, :))
                %         xlim([0 1])
                %         ylim([-8 10])
            end
            legend({'50-left' '50-right' '70-left' '70-right' '90-left' '90-right'}, 'box', 'off')
            xlabel('Preceded probability of right')
            ylabel(yLabels{paraN})
            title([' perceptual'])
            saveas(gca, ['precedeProbRightMerged_perceptualTrialsLR_' pdfNames{paraN},  '_all_bin', num2str(trialBin), '.pdf'])
        end
        
%         if ~strcmp(checkParas{paraN}, 'choice') %|| strcmp(checkParas{paraN}, 'pursuit.gainX')
%             % standard trials, merged
%             figure
%             for probNmerged = 1:3
%                 plot(xProbMergedS{paraN, probNmerged}, yValuesSortedMergedS{paraN, probNmerged}, 'color', colorProb(probNmerged+2, :))
%                 hold on
%                 %         xlim([0 1])
%                 %         ylim([-8 10])
%             end
%             legend(probNames{2}, 'box', 'off')
%             xlabel('Preceded probability of right')
%             ylabel(yLabels{paraN})
%             title([' standard'])
%             saveas(gca, ['precedeProbRightMerged_standardTrials_' pdfNames{paraN},  '_all_bin', num2str(trialBin), '.pdf'])
%             
%             % all trials
%             figure
%             for probNmerged = 1:3
%                 plot(xProbMergedAll{paraN, probNmerged}, yValuesSortedMergedAll{paraN, probNmerged}, 'color', colorProb(probNmerged+2, :))
%                 hold on
%                 %         xlim([0 1])
%                 %         ylim([-8 10])
%             end
%             legend(probNames{2}, 'box', 'off')
%             xlabel('Preceded probability of right')
%             ylabel(yLabels{paraN})
%             title([' all trials'])
%             saveas(gca, ['precedeProbRightMerged_allTrials_' pdfNames{paraN},  '_all_bin', num2str(trialBin), '.pdf'])
%         end
    end
end