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
pLength = 182; % length of perceptual trials in one block
trialBin = 50; % window of trial numbers

% some settings
individualPlots = 1;
averagedPlots = 1;
yLabels = {'Probability of perceiving right' 'AP horizontal velocity (deg/s)' ...
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

%% building up of long-term effect, sliding window across trials
% get sliding AP for each bock
for subN = 1:size(names, 2)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        probNameI = 1;
    else
        probNameI = 2;
    end
    
    for paraN = 1:5%size(checkParas, 2) % automatically loop through the parameters
        yValuesAll{paraN, subN} = NaN(size(probSub, 2), allLength-trialBin+1);
        yValuesP{paraN, subN} = NaN(size(probSub, 2), pLength-trialBin+1);
        
        for probSubN = 1:size(probSub, 2)
            % all trials
            idxT = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0);
            for slideI = 1:(length(idxT)-trialBin+1)
                eval(['yValuesAll{paraN, subN}(probSubN, slideI) = nanmean(eyeTrialData.' checkParas{paraN} '(subN, idxT(slideI:(slideI+trialBin-1))));']);
            end
            
            % perceptual trials
            idxT = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & abs(eyeTrialData.coh(subN, :))~=1);
            for slideI = 1:(length(idxT)-trialBin+1)
                eval(['yValuesP{paraN, subN}(probSubN, slideI) = nanmean(eyeTrialData.' checkParas{paraN} '(subN, idxT(slideI:(slideI+trialBin-1))));']);
            end
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
            if strcmp(checkParas{paraN}, 'choice') || strcmp(checkParas{paraN}, 'pursuit.gainX')
                figure
                for probSubN = 1:size(probSub, 2)
                    probN = find(probCons==probSub(probSubN));
                    plot(yValuesP{paraN, subN}(probSubN, :), 'color', colorProb(probN, :))
                    hold on
                end
                legend(probNames{probNameI}, 'box', 'off')
                xlabel('Trial number')
                ylabel(yLabels{paraN})
                title(names{subN})
                saveas(gca, [pdfNames{paraN}, '_perceptualTrials_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
            end
            
            if ~strcmp(checkParas{paraN}, 'choice')
                figure
                for probSubN = 1:size(probSub, 2)
                    probN = find(probCons==probSub(probSubN));
                    plot(yValuesAll{paraN, subN}(probSubN, :), 'color', colorProb(probN, :))
                    hold on
                end
                legend(probNames{probNameI}, 'box', 'off')
                xlabel('Trial number')
                ylabel(yLabels{paraN})
                title(names{subN})
                saveas(gca, [pdfNames{paraN}, '_allTrials_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
            end
        end
    end
end

%% grouped values for sliding window...
if averagedPlots==1
    for paraN = 1:5%size(checkParas, 2)        
        for probN= 1:3 % here probN is merged, 50, 70, and 90
            tempMeanAll{paraN, probN} = NaN(size(names, 2), allLength-trialBin+1); % standard trials
            tempMeanP{paraN, probN} = NaN(size(names, 2), pLength-trialBin+1);
            for subN = 1:size(names, 2)
                if strcmp(checkParas{paraN}, 'pursuit.initialMeanVelocityX') % flip direction to merge the left and right trials
                    yValuesAll{paraN, subN} = abs(yValuesAll{paraN, subN});
                    yValuesP{paraN, subN} = abs(yValuesP{paraN, subN});
                end
                
                probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
                if probSub(1)==10
                    % flip direction for AP (these are not absolute values)
                    if strcmp(checkParas{paraN}, 'pursuit.APvelocityX')
                        tempMeanAll{paraN, probN}(subN, :) = -yValuesAll{paraN, subN}(4-probN, :);
                        tempMeanP{paraN, probN}(subN, :) = -yValuesP{paraN, subN}(4-probN, :);
                    else
                        tempMeanAll{paraN, probN}(subN, :) = yValuesAll{paraN, subN}(4-probN, :);
                        tempMeanP{paraN, probN}(subN, :) = yValuesP{paraN, subN}(4-probN, :);
                    end
                else
                    tempMeanAll{paraN, probN}(subN, :) = yValuesAll{paraN, subN}(probN, :);
                    tempMeanP{paraN, probN}(subN, :) = yValuesP{paraN, subN}(probN, :);
                end
            end
            % all trials
            meanY_all{paraN}(probN, :) = nanmean(tempMeanAll{paraN, probN}); % all trials
            steY_all{paraN}(probN, :) = nanstd(tempMeanAll{paraN, probN})/sqrt(size(names, 2)); % all trials
            
            % perceptual trials
            meanY_p{paraN}(probN, :) = nanmean(tempMeanP{paraN, probN}); % all trials
            steY_p{paraN}(probN, :) = nanstd(tempMeanP{paraN, probN})/sqrt(size(names, 2)); % all trials
        end
        
        % plot
        if paraN==1
            cd(perceptFolder)
        elseif paraN<sacStart
            cd(pursuitFolder)
        else
            cd(saccadeFolder)
        end
        
        if strcmp(checkParas{paraN}, 'choice') || strcmp(checkParas{paraN}, 'pursuit.gainX')
            figure
            for probN = 1:3 % merged prob
                plot(meanY_p{paraN}(probN, :), 'color', colorProb(probN, :))
                hold on
            end
            legend({'50' '70' '90'}, 'box', 'off')
            title('perceptual trials')
            xlabel('Trial number')
            ylabel(yLabels{paraN})
            saveas(gca, [pdfNames{paraN}, '_perceptualTrials_all_bin', num2str(trialBin), '.pdf'])
        end
        
        if ~strcmp(checkParas{paraN}, 'choice')
            figure
            for probN = 1:3 % merged prob
                plot(meanY_all{paraN}(probN, :), 'color', colorProb(probN, :))
                hold on
            end
            legend({'50' '70' '90'}, 'box', 'off')
            title('all trials')
            xlabel('Trial number')
            ylabel(yLabels{paraN})
            saveas(gca, [pdfNames{paraN}, '_allTrials_all_bin', num2str(trialBin), '.pdf'])
        end
    end
end