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
individualPlots = 1;
averagedPlots = 0;
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
        end
        
        if individualPlots==1
            if paraN==1
                cd(perceptFolder)
            elseif paraN<sacStart
                cd(pursuitFolder)
            else
                cd(saccadeFolder)
            end
            
            % individual plot
            % perceptual trials
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
            
            if ~strcmp(checkParas{paraN}, 'choice')
                % standard trials
                figure
                for probSubN = 1:size(probSub, 2)
                    probN = find(probCons==probSub(probSubN));
                    plot(xProbS{paraN, subN}{probSubN}, yValuesSortedS{paraN, subN}{probSubN}, 'color', colorProb(probN, :))
                    hold on
                    %         xlim([0 1])
                    %         ylim([-8 10])
                end
                legend(probNames{probNameI}, 'box', 'off')
                xlabel('Preceded probability of right')
                ylabel(yLabels{paraN})
                title([names{subN}, ' standard'])
                saveas(gca, ['precedeProbRight_standardTrials_' pdfNames{paraN},  '_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
                
                % all trials
                figure
                for probSubN = 1:size(probSub, 2)
                    probN = find(probCons==probSub(probSubN));
                    plot(xProbAll{paraN, subN}{probSubN}, yValuesSortedAll{paraN, subN}{probSubN}, 'color', colorProb(probN, :))
                    hold on
                    %         xlim([0 1])
                    %         ylim([-8 10])
                end
                legend(probNames{probNameI}, 'box', 'off')
                xlabel('Preceded probability of right')
                ylabel(yLabels{paraN})
                title([names{subN}, ' all'])
                saveas(gca, ['precedeProbRight_allTrials_' pdfNames{paraN},  '_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
                
            end
        end
    end
end

%% grouped values for sliding window...
if averagedPlots==1
    for paraN = 1:sacStart-1%size(checkParas, 2)
        for probNmerged= 1:3 % here probN is merged, 50, 70, and 90
            tempMeanAll{paraN, probNmerged} = NaN(size(names, 2), allLength-trialBin+1); % standard trials
            tempMeanP{paraN, probNmerged} = NaN(size(names, 2), pLength-trialBin+1);
            for subN = 1:size(names, 2)
                if strcmp(checkParas{paraN}, 'pursuit.initialMeanVelocityX') % flip direction to merge the left and right trials
                    yValuesAll{paraN, subN} = abs(yValuesAll{paraN, subN});
                    yValuesS{paraN, subN} = abs(yValuesS{paraN, subN});
                    yValuesSL{paraN, subN} = abs(yValuesSL{paraN, subN});
                    yValuesSR{paraN, subN} = abs(yValuesSR{paraN, subN});
                    yValuesP{paraN, subN} = abs(yValuesP{paraN, subN});
                    yValuesPL{paraN, subN} = abs(yValuesPL{paraN, subN});
                    yValuesPR{paraN, subN} = abs(yValuesPR{paraN, subN});
                end
                
                probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
                if probSub(1)==10
                    if strcmp(checkParas{paraN}, 'pursuit.APvelocityX') ||  strcmp(checkParas{paraN}, 'choice')
                        % flip direction for AP (these are not absolute values) and perceptual choices
                        tempMeanAll{paraN, probNmerged}(subN, :) = -yValuesAll{paraN, subN}(4-probNmerged, :);
                        tempMeanS{paraN, probNmerged}(subN, :) = -yValuesS{paraN, subN}(4-probNmerged, :);
                        tempMeanSL{paraN, probNmerged}(subN, :) = -yValuesSR{paraN, subN}(4-probNmerged, :);
                        tempMeanSR{paraN, probNmerged}(subN, :) = -yValuesSL{paraN, subN}(4-probNmerged, :);
                        tempMeanP{paraN, probNmerged}(subN, :) = -yValuesP{paraN, subN}(4-probNmerged, :);
                        tempMeanPL{paraN, probNmerged}(subN, :) = -yValuesPR{paraN, subN}(4-probNmerged, :);
                        tempMeanPR{paraN, probNmerged}(subN, :) = -yValuesPL{paraN, subN}(4-probNmerged, :);
                    else
                        tempMeanAll{paraN, probNmerged}(subN, :) = yValuesAll{paraN, subN}(4-probNmerged, :);
                        tempMeanS{paraN, probNmerged}(subN, :) = yValuesS{paraN, subN}(4-probNmerged, :);
                        tempMeanSL{paraN, probNmerged}(subN, :) = yValuesSR{paraN, subN}(4-probNmerged, :);
                        tempMeanSR{paraN, probNmerged}(subN, :) = yValuesSL{paraN, subN}(4-probNmerged, :);
                        tempMeanP{paraN, probNmerged}(subN, :) = yValuesP{paraN, subN}(4-probNmerged, :);
                        tempMeanPL{paraN, probNmerged}(subN, :) = yValuesPR{paraN, subN}(4-probNmerged, :);
                        tempMeanPR{paraN, probNmerged}(subN, :) = yValuesPL{paraN, subN}(4-probNmerged, :);
                    end
                else
                    tempMeanAll{paraN, probNmerged}(subN, :) = yValuesAll{paraN, subN}(probNmerged, :);
                    tempMeanS{paraN, probNmerged}(subN, :) = yValuesS{paraN, subN}(probNmerged, :);
                    tempMeanSL{paraN, probNmerged}(subN, :) = yValuesSL{paraN, subN}(probNmerged, :);
                    tempMeanSR{paraN, probNmerged}(subN, :) = yValuesSR{paraN, subN}(probNmerged, :);
                    tempMeanP{paraN, probNmerged}(subN, :) = yValuesP{paraN, subN}(probNmerged, :);
                    tempMeanPL{paraN, probNmerged}(subN, :) = yValuesPL{paraN, subN}(probNmerged, :);
                    tempMeanPR{paraN, probNmerged}(subN, :) = yValuesPR{paraN, subN}(probNmerged, :);
                end
            end
            % all trials
            meanY_all{paraN}(probNmerged, :) = nanmean(tempMeanAll{paraN, probNmerged}); % all trials
            steY_all{paraN}(probNmerged, :) = nanstd(tempMeanAll{paraN, probNmerged})/sqrt(size(names, 2)); % all trials
            
            % standard trials
            meanY_s{paraN}(probNmerged, :) = nanmean(tempMeanS{paraN, probNmerged}); % all trials
            steY_s{paraN}(probNmerged, :) = nanstd(tempMeanS{paraN, probNmerged})/sqrt(size(names, 2)); % all trials
            meanY_sL{paraN}(probNmerged, :) = nanmean(tempMeanSL{paraN, probNmerged}); % left trials
            steY_sL{paraN}(probNmerged, :) = nanstd(tempMeanSL{paraN, probNmerged})/sqrt(size(names, 2)); % left trials
            meanY_sR{paraN}(probNmerged, :) = nanmean(tempMeanSR{paraN, probNmerged}); % right trials
            steY_sR{paraN}(probNmerged, :) = nanstd(tempMeanSR{paraN, probNmerged})/sqrt(size(names, 2)); % right trials
            
            % perceptual trials
            meanY_p{paraN}(probNmerged, :) = nanmean(tempMeanP{paraN, probNmerged}); % all trials
            steY_p{paraN}(probNmerged, :) = nanstd(tempMeanP{paraN, probNmerged})/sqrt(size(names, 2)); % all trials
            meanY_pL{paraN}(probNmerged, :) = nanmean(tempMeanPL{paraN, probNmerged}); % left trials
            steY_pL{paraN}(probNmerged, :) = nanstd(tempMeanPL{paraN, probNmerged})/sqrt(size(names, 2)); % left trials
            meanY_pR{paraN}(probNmerged, :) = nanmean(tempMeanPR{paraN, probNmerged}); % right trials
            steY_pR{paraN}(probNmerged, :) = nanstd(tempMeanPR{paraN, probNmerged})/sqrt(size(names, 2)); % right trials
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
            for probNmerged = 1:3 % merged prob
                plot(meanY_p{paraN}(probNmerged, :), 'color', colorProb(probNmerged+2, :))
                hold on
            end
            legend({'50' '70' '90'}, 'box', 'off')
            title('perceptual trials')
            xlabel('Trial bin number')
            ylabel(yLabels{paraN})
            saveas(gca, [pdfNames{paraN}, '_perceptualTrials_all_bin', num2str(trialBin), '.pdf'])
        end
        
        if ~strcmp(checkParas{paraN}, 'choice') %|| strcmp(checkParas{paraN}, 'pursuit.gainX')
            % standard trials, merged
            figure
            for probNmerged = 1:3 % merged prob
                plot(meanY_s{paraN}(probNmerged, :), 'color', colorProb(probNmerged+2, :))
                hold on
            end
            legend({'50' '70' '90'}, 'box', 'off')
            title('standard trials')
            xlabel('Trial bin number')
            ylabel(yLabels{paraN})
            saveas(gca, [pdfNames{paraN}, '_standardTrials_all_bin', num2str(trialBin), '.pdf'])
            %         end
            
            % all trials
            %         if ~strcmp(checkParas{paraN}, 'choice')
            figure
            for probNmerged = 1:3 % merged prob
                plot(meanY_all{paraN}(probNmerged, :), 'color', colorProb(probNmerged+2, :))
                hold on
            end
            legend({'50' '70' '90'}, 'box', 'off')
            title('all trials')
            xlabel('Trial bin number')
            ylabel(yLabels{paraN})
            saveas(gca, [pdfNames{paraN}, '_allTrials_all_bin', num2str(trialBin), '.pdf'])
        end
    end
end