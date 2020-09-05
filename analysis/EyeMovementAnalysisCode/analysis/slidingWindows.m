initializeParas;

% only uncomment the experiment you want to look at
% Exp1, 10 people, main experiment
names = nameSets{1};
slidingWFolder = [slidingWFolder '\Exp1'];
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
% slidingWFolder = [slidingWFolder '\Exp2'];
% eyeTrialData = expAll{2}.eyeTrialData;
% RsaveFolder = [RFolder '\Exp2'];
% probTotalN = 2;

% % Exp3, 9 people, low-coh context trials
% expN = 3;
% names = nameSets{3};
% slidingWFolder = [slidingWFolder '\Exp3'];
% eyeTrialData = expAll{3}.eyeTrialData;
% RsaveFolder = [RFolder '\Exp3'];
% probTotalN = 2;

% % correct for mistakenly pressing the wrong key in standard trials
% idxT = find(eyeTrialData.trialType==1); % standard trials, same perceptual choice as visual
% eyeTrialData.choice(idxT) = eyeTrialData.rdkDir(idxT);

idxT = find(eyeTrialData.choice==0); % left coded as -1
eyeTrialData.choice(idxT) = -1;

% different parameters to look at
checkParas = {'choiceRatio' 'choice' 'pursuit.APvelocityX' 'pursuit.APvelocityX_interpol' ...
    'pursuit.initialMeanVelocityX' 'pursuit.initialPeakVelocityX' 'pursuit.initialMeanAccelerationX' 'pursuit.initialVelChangeX'...
    'pursuit.gainX' 'pursuit.gainX_interpol' ...
    'saccades.X.number' 'saccades.X.meanAmplitude' 'saccades.X.sumAmplitude'}; % field name in eyeTrialData
pdfNames = {'perceptionRatio' 'perception' 'APvelX' 'APvelXInterpolated'...
    'olpMeanVelX' 'olpPeakVelX' 'olpMeanAcceleration' 'olpVelChangeX'...
    'clpGainX' 'clpGainXInterpolated' ...
    'sacNumX' 'sacMeanAmpX' 'sacSumAmpX'}; % name for saving the pdf
sacStart = 10; % from the n_th parameter is saccade

allLength = 682; % length of all trials in one block
sLength = 500; % length of standard trials in one block
pLength = 182; % length of perceptual trials in one block
trialBin = 50; % window of trial numbers

% some settings
individualPlots = 1;
averagedPlots = 1;
yLabels = {'Probability of perceiving right/probability of right' 'Probability of perceiving right-probability of right' 'AP horizontal velocity (deg/s)' 'AP interpolated horizontal velocity (deg/s)'...
    'olp mean horizontal velocity (deg/s)' 'olp peak horizontal velocity (deg/s)' 'olp mean acceleration (deg/s2)' 'olp horizontal velocity change'...
    'clp gain (horizontal)' 'clp interpolated gain (horizontal)' ...
    'saccade number (horizontal)' 'saccade mean amplitude (horizontal)' 'saccade sum amplitude (horizontal)'};
% for plotting, each parameter has a specific y value range
minY = [-0.3; 0; ...
    -10; -15; ...
    0; ...
    0; 0; 0];
maxY = [0; 3; ...
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
    
    for paraN = 2:2%size(checkParas, 2) % automatically loop through the parameters
        yValuesAll{paraN, subN} = NaN(size(probSub, 2), allLength-trialBin+1);
        yValuesS{paraN, subN} = NaN(size(probSub, 2), sLength-trialBin+1);
        yValuesSL{paraN, subN} = NaN(size(probSub, 2), sLength-trialBin+1);
        yValuesSR{paraN, subN} = NaN(size(probSub, 2), sLength-trialBin+1);
        yValuesP{paraN, subN} = NaN(size(probSub, 2), pLength-trialBin+1);
        yValuesPL{paraN, subN} = NaN(size(probSub, 2), pLength-trialBin+1);
        yValuesPR{paraN, subN} = NaN(size(probSub, 2), pLength-trialBin+1);
        
        for probSubN = 1:size(probSub, 2)
            % all trials
            idxT = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0);
            for slideI = 1:(length(idxT)-trialBin+1)
                if strcmp(checkParas{paraN}, 'choice')
                    probRightNum = length(find(eyeTrialData.rdkDir(subN, idxT(slideI:(slideI+trialBin-1)))>0));
                    probRight = probRightNum/trialBin;
                    yValuesAll{paraN, subN}(probSubN, slideI) = length(find(eyeTrialData.choice(subN, idxT(slideI:(slideI+trialBin-1)))==1))/trialBin-probRight;
                elseif strcmp(checkParas{paraN}, 'choiceRatio')
                    probRightNum = length(find(eyeTrialData.rdkDir(subN, idxT(slideI:(slideI+trialBin-1)))>0));
                    yValuesAll{paraN, subN}(probSubN, slideI) = length(find(eyeTrialData.choice(subN, idxT(slideI:(slideI+trialBin-1)))==1))/probRightNum;
                else
                    eval(['yValuesAll{paraN, subN}(probSubN, slideI) = nanmean(eyeTrialData.' checkParas{paraN} '(subN, idxT(slideI:(slideI+trialBin-1))));']);
                end
            end
            
            % standard trials
            idxT = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & eyeTrialData.trialType(subN, :)==1);
            for slideI = 1:(length(idxT)-trialBin+1)
                if strcmp(checkParas{paraN}, 'choice')
                    probRightNum = length(find(eyeTrialData.rdkDir(subN, idxT(slideI:(slideI+trialBin-1)))>0));
                    probRight = probRightNum/trialBin;
                    yValuesS{paraN, subN}(probSubN, slideI) = length(find(eyeTrialData.choice(subN, idxT(slideI:(slideI+trialBin-1)))==1))/trialBin-probRight;
                elseif strcmp(checkParas{paraN}, 'choiceRatio')
                    probRightNum = length(find(eyeTrialData.rdkDir(subN, idxT(slideI:(slideI+trialBin-1)))>0));
                    yValuesS{paraN, subN}(probSubN, slideI) = length(find(eyeTrialData.choice(subN, idxT(slideI:(slideI+trialBin-1)))==1))/probRightNum;
                else
                    eval(['yValuesS{paraN, subN}(probSubN, slideI) = nanmean(eyeTrialData.' checkParas{paraN} '(subN, idxT(slideI:(slideI+trialBin-1))));']);
                end
            end
            %%seperate left and rightward trials
            % left
            idxTL = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & eyeTrialData.trialType(subN, :)==1 & eyeTrialData.rdkDir(subN, :)<0);
            for slideI = 1:(length(idxTL)-trialBin+1)
                if strcmp(checkParas{paraN}, 'choice')
                    probRight = 0;
                    yValuesSL{paraN, subN}(probSubN, slideI) = length(find(eyeTrialData.choice(subN, idxTL(slideI:(slideI+trialBin-1)))==1))/trialBin-probRight;
                elseif strcmp(checkParas{paraN}, 'choiceRatio')
                    disp('error: probability of right = 0')
                else
                    eval(['yValuesSL{paraN, subN}(probSubN, slideI) = nanmean(eyeTrialData.' checkParas{paraN} '(subN, idxTL(slideI:(slideI+trialBin-1))));']);
                end
            end
            % right
            idxTR = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & eyeTrialData.trialType(subN, :)==1  & eyeTrialData.rdkDir(subN, :)>0);
            for slideI = 1:(length(idxTR)-trialBin+1)
                if strcmp(checkParas{paraN}, 'choice')
                    probRight = 1;
                    yValuesSR{paraN, subN}(probSubN, slideI) = length(find(eyeTrialData.choice(subN, idxTR(slideI:(slideI+trialBin-1)))==1))/trialBin-probRight;
                elseif strcmp(checkParas{paraN}, 'choiceRatio')
                    probRightNum = trialBin;
                    yValuesSR{paraN, subN}(probSubN, slideI) = length(find(eyeTrialData.choice(subN, idxT(slideI:(slideI+trialBin-1)))==1))/probRightNum;
                else
                    eval(['yValuesSR{paraN, subN}(probSubN, slideI) = nanmean(eyeTrialData.' checkParas{paraN} '(subN, idxTR(slideI:(slideI+trialBin-1))));']);
                end
            end
            
            % perceptual trials
            idxT = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & eyeTrialData.trialType(subN, :)==0);
            for slideI = 1:(length(idxT)-trialBin+1)
                if strcmp(checkParas{paraN}, 'choice')
                    probRightNum = length(find(eyeTrialData.rdkDir(subN, idxT(slideI:(slideI+trialBin-1)))>0));
                    zeroNum = length(find(eyeTrialData.rdkDir(subN, idxT(slideI:(slideI+trialBin-1)))==0));
                    probRight = (probRightNum+zeroNum/2)/trialBin;
                    yValuesP{paraN, subN}(probSubN, slideI) = length(find(eyeTrialData.choice(subN, idxT(slideI:(slideI+trialBin-1)))==1))/trialBin-probRight;
                elseif strcmp(checkParas{paraN}, 'choiceRatio')
                    probRightNum = length(find(eyeTrialData.rdkDir(subN, idxT(slideI:(slideI+trialBin-1)))>0));
                    zeroNum = length(find(eyeTrialData.rdkDir(subN, idxT(slideI:(slideI+trialBin-1)))==0));
                    yValuesP{paraN, subN}(probSubN, slideI) = length(find(eyeTrialData.choice(subN, idxT(slideI:(slideI+trialBin-1)))==1))/(probRightNum+zeroNum/2);
                else
                    eval(['yValuesP{paraN, subN}(probSubN, slideI) = nanmean(eyeTrialData.' checkParas{paraN} '(subN, idxT(slideI:(slideI+trialBin-1))));']);
                end
            end
            %%seperate left and rightward trials
            % left
            idxTL = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & eyeTrialData.trialType(subN, :)==0 & eyeTrialData.rdkDir(subN, :)<0);
            for slideI = 1:(length(idxTL)-trialBin+1)
                if strcmp(checkParas{paraN}, 'choice')
                    probRight = 0;
                    yValuesPL{paraN, subN}(probSubN, slideI) = length(find(eyeTrialData.choice(subN, idxTL(slideI:(slideI+trialBin-1)))==1))/trialBin-probRight;
                elseif strcmp(checkParas{paraN}, 'choiceRatio')
                    disp('error: probability of right = 0')
                else
                    eval(['yValuesPL{paraN, subN}(probSubN, slideI) = nanmean(eyeTrialData.' checkParas{paraN} '(subN, idxTL(slideI:(slideI+trialBin-1))));']);
                end
            end
            % right
            idxTR = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                & eyeTrialData.trialType(subN, :)==0  & eyeTrialData.rdkDir(subN, :)>0);
            for slideI = 1:(length(idxTR)-trialBin+1)
                if strcmp(checkParas{paraN}, 'choice')
                    probRight = 1;
                    yValuesPR{paraN, subN}(probSubN, slideI) = length(find(eyeTrialData.choice(subN, idxTR(slideI:(slideI+trialBin-1)))==1))/trialBin-probRight;
                elseif strcmp(checkParas{paraN}, 'choiceRatio')
                    probRightNum = trialBin;
                    yValuesPR{paraN, subN}(probSubN, slideI) = length(find(eyeTrialData.choice(subN, idxT(slideI:(slideI+trialBin-1)))==1))/probRightNum;
                else
                    eval(['yValuesPR{paraN, subN}(probSubN, slideI) = nanmean(eyeTrialData.' checkParas{paraN} '(subN, idxTR(slideI:(slideI+trialBin-1))));']);
                end
            end
            
        end
        
        if individualPlots==1
            %             if paraN==1
            %                 cd([perceptFolder '\individuals'])
            %             elseif paraN<sacStart
            %                 cd([pursuitFolder '\individuals'])
            %             else
            cd([slidingWFolder '\individuals'])
            %             end
            
            % individual plot
            % perceptual trials
            if paraN<sacStart
                figure
                for probSubN = 1:size(probSub, 2)
                    probN = find(probCons==probSub(probSubN));
                    plot(yValuesP{paraN, subN}(probSubN, :), 'color', colorProb(probN, :))
                    hold on
                end
                legend(probNames{probNameI}, 'box', 'off')
                xlabel('Trial bin number')
                ylabel(yLabels{paraN})
                title(names{subN})
                saveas(gca, [pdfNames{paraN}, '_perceptualTrials_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
            end
            
            if ~strcmp(checkParas{paraN}, 'choice') && ~strcmp(checkParas{paraN}, 'choiceRatio')
                % standard trials
                figure
                for probSubN = 1:size(probSub, 2)
                    probN = find(probCons==probSub(probSubN));
                    plot(yValuesS{paraN, subN}(probSubN, :), 'color', colorProb(probN, :))
                    hold on
                end
                legend(probNames{probNameI}, 'box', 'off')
                xlabel('Trial bin number')
                ylabel(yLabels{paraN})
                title(names{subN})
                saveas(gca, [pdfNames{paraN}, '_standardTrials_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
                
                %                 % all trials
                %                 if ~strcmp(checkParas{paraN}, 'choice')
                %                     figure
                %                     for probSubN = 1:size(probSub, 2)
                %                         probN = find(probCons==probSub(probSubN));
                %                         plot(yValuesAll{paraN, subN}(probSubN, :), 'color', colorProb(probN, :))
                %                         hold on
                %                     end
                %                     legend(probNames{probNameI}, 'box', 'off')
                %                     xlabel('Trial bin number')
                %                     ylabel(yLabels{paraN})
                %                     title(names{subN})
                %                     saveas(gca, [pdfNames{paraN}, '_allTrials_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
                %                 end
            end
        end
    end
end

%% grouped values for sliding window...
close all
if averagedPlots==1
    for paraN = 2:2%sacStart-1%size(checkParas, 2)
        
        for probNmerged= 1:probTotalN % here probN is merged, 50 and 90
            tempMeanAll{paraN, probNmerged} = NaN(size(names, 2), allLength-trialBin+1); % standard trials
            tempMeanP{paraN, probNmerged} = NaN(size(names, 2), pLength-trialBin+1);
            for subN = 1:size(names, 2)
                
                probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
                if probSub(1)==10
                    if strcmp(checkParas{paraN}, 'pursuit.APvelocityX') || ...
                            strcmp(checkParas{paraN}, 'choice') || ...
                            strcmp(checkParas{paraN}, 'pursuit.APvelocityX_interpol') || ...
                            strcmp(checkParas{paraN}, 'initialMeanVelocityX') || ...
                            strcmp(checkParas{paraN}, 'pursuit.initialVelChangeX')
                        % flip direction for AP (these are not absolute values)
                        tempMeanAll{paraN, probNmerged}(subN, :) = -yValuesAll{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanS{paraN, probNmerged}(subN, :) = -yValuesS{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanSL{paraN, probNmerged}(subN, :) = -yValuesSR{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanSR{paraN, probNmerged}(subN, :) = -yValuesSL{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanP{paraN, probNmerged}(subN, :) = -yValuesP{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanPL{paraN, probNmerged}(subN, :) = -yValuesPR{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanPR{paraN, probNmerged}(subN, :) = -yValuesPL{paraN, subN}(probTotalN+1-probNmerged, :);
                    elseif strcmp(checkParas{paraN}, 'choiceRatio')
                        tempMeanAll{paraN, probNmerged}(subN, :) = 1-yValuesAll{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanS{paraN, probNmerged}(subN, :) = 1-yValuesS{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanSL{paraN, probNmerged}(subN, :) = 1-yValuesSR{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanSR{paraN, probNmerged}(subN, :) = 1-yValuesSL{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanP{paraN, probNmerged}(subN, :) = 1-yValuesP{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanPL{paraN, probNmerged}(subN, :) = 1-yValuesPR{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanPR{paraN, probNmerged}(subN, :) = 1-yValuesPL{paraN, subN}(probTotalN+1-probNmerged, :);
                    else
                        tempMeanAll{paraN, probNmerged}(subN, :) = yValuesAll{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanS{paraN, probNmerged}(subN, :) = yValuesS{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanSL{paraN, probNmerged}(subN, :) = yValuesSR{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanSR{paraN, probNmerged}(subN, :) = yValuesSL{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanP{paraN, probNmerged}(subN, :) = yValuesP{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanPL{paraN, probNmerged}(subN, :) = yValuesPR{paraN, subN}(probTotalN+1-probNmerged, :);
                        tempMeanPR{paraN, probNmerged}(subN, :) = yValuesPL{paraN, subN}(probTotalN+1-probNmerged, :);
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
            meanY_p{paraN}(probNmerged, :) = mean(tempMeanP{paraN, probNmerged}); % all trials
            steY_p{paraN}(probNmerged, :) = std(tempMeanP{paraN, probNmerged})/sqrt(size(names, 2)); % all trials
            meanY_pL{paraN}(probNmerged, :) = nanmean(tempMeanPL{paraN, probNmerged}); % left trials
            steY_pL{paraN}(probNmerged, :) = nanstd(tempMeanPL{paraN, probNmerged})/sqrt(size(names, 2)); % left trials
            meanY_pR{paraN}(probNmerged, :) = nanmean(tempMeanPR{paraN, probNmerged}); % right trials
            steY_pR{paraN}(probNmerged, :) = nanstd(tempMeanPR{paraN, probNmerged})/sqrt(size(names, 2)); % right trials
        end
        
        % plot
        %         if paraN==1
        %             cd(perceptFolder)
        %         elseif paraN<sacStart
        %             cd(pursuitFolder)
        %         else
        cd(slidingWFolder)
        %         end
        
        % perceptual trials, merged
        if paraN<sacStart %strcmp(checkParas{paraN}, 'choice') || strcmp(checkParas{paraN}, 'pursuit.gainX')
            figure
            for probNmerged = 1:probTotalN % merged prob
                plot(meanY_p{paraN}(probNmerged, :), 'color', colorProb(probNmerged+1, :))
                hold on
            end
            legend({'50' '90'}, 'box', 'off')
            title('perceptual trials')
            xlabel('Trial bin number')
            ylabel(yLabels{paraN})
            %             ylim([minY(paraN) maxY(paraN)])
            saveas(gca, [pdfNames{paraN}, '_perceptualTrials_all_bin', num2str(trialBin), '.pdf'])
        end
        
        %         % perceptual trials, not merged
        %         if paraN<sacStart %strcmp(checkParas{paraN}, 'choice') || strcmp(checkParas{paraN}, 'pursuit.gainX')
        %             figure
        %             for probNmerged = 1:probTotalN+ % merged prob
        %                 plot(meanY_pL{paraN}(probNmerged, :), '--', 'color', colorProb(probNmerged+2, :))
        %                 hold on
        %                 plot(meanY_pR{paraN}(probNmerged, :), '-', 'color', colorProb(probNmerged+2, :))
        %             end
        %             legend({'50-left' '50-right' '70-left' '70-right' '90-left' '90-right'}, 'box', 'off')
        %             title('perceptual trials')
        %             xlabel('Trial bin number')
        %             ylabel(yLabels{paraN})
        %             saveas(gca, [pdfNames{paraN}, '_perceptualTrials_LR_bin', num2str(trialBin), '.pdf'])
        %         end
        
        
        %         if ~strcmp(checkParas{paraN}, 'choice') %|| strcmp(checkParas{paraN}, 'pursuit.gainX')
        %             % standard trials, merged
        %             figure
        %             for probNmerged = 1:probTotalN % merged prob
        %                 plot(meanY_s{paraN}(probNmerged, :), 'color', colorProb(probNmerged+1, :))
        %                 hold on
        %             end
        %             legend({'50' '90'}, 'box', 'off')
        %             title('standard trials')
        %             xlabel('Trial bin number')
        %             ylabel(yLabels{paraN})
        %             saveas(gca, [pdfNames{paraN}, '_standardTrials_all_bin', num2str(trialBin), '.pdf'])
        %         end
        
        % %         % standard trials, not merged
        % %         if paraN<sacStart %strcmp(checkParas{paraN}, 'choice') || strcmp(checkParas{paraN}, 'pursuit.gainX')
        % %             figure
        % %             for probNmerged = 1:3 % merged prob
        % %                 plot(meanY_sL{paraN}(probNmerged, :), '--', 'color', colorProb(probNmerged+2, :))
        % %                 hold on
        % %                 plot(meanY_sR{paraN}(probNmerged, :), '-', 'color', colorProb(probNmerged+2, :))
        % %             end
        % %             legend({'50-left' '50-right' '70-left' '70-right' '90-left' '90-right'}, 'box', 'off')
        % %             title('standard trials')
        % %             xlabel('Trial bin number')
        % %             ylabel(yLabels{paraN})
        % %             saveas(gca, [pdfNames{paraN}, '_standardTrials_LR_bin', num2str(trialBin), '.pdf'])
        % %         end
        
        %             % all trials
        %             %         if ~strcmp(checkParas{paraN}, 'choice')
        %             figure
        %             for probNmerged = 1:3 % merged prob
        %                 plot(meanY_all{paraN}(probNmerged, :), 'color', colorProb(probNmerged+2, :))
        %                 hold on
        %             end
        %             legend({'50' '70' '90'}, 'box', 'off')
        %             title('all trials')
        %             xlabel('Trial bin number')
        %             ylabel(yLabels{paraN})
        %             saveas(gca, [pdfNames{paraN}, '_allTrials_all_bin', num2str(trialBin), '.pdf'])
        %         end
        
        % generate CSV trials
        for probNmerged = 1:probTotalN
            clear minLengthP
            % find the min length...
            for subN = 1:size(names, 2)
                probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
                if probSub(1)<50
                    probSubN = probTotalN+1-probNmerged;
                else
                    probSubN = probNmerged;
                end
                idxT = find(eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ...
                    & eyeTrialData.trialType(subN, :)==0);
                minLengthP(subN, 1) = length(idxT)-trialBin+1;
            end
            maxIdxP = min(minLengthP);
            
            slideSub = tempMeanP{paraN, probNmerged}(:, 1:maxIdxP);
            cd(RsaveFolder)
            csvwrite(['slidingW_', pdfNames{paraN}, '_', num2str(probCons(probNmerged+probTotalN-1)), '.csv'], slideSub)
        end
        
    end
end