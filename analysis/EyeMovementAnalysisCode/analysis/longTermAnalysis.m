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

% for plotting, each parameter has a specific y value range
yLabels = {'Probability of perceiving right' 'AP horizontal velocity (deg/s)' ...
    'olp mean horizontal velocity (deg/s)' 'olp peak horizontal velocity (deg/s)' ...
    'clp gain (horizontal)' ...
    'saccade number (horizontal)' 'saccade mean amplitude (horizontal)' 'saccade sum amplitude (horizontal)'};
minY = [0; -3; ...
    -10; -15; ...
    0; ...
    0; 0; 0];
maxY = [1; 3; ...
    10; 15; ...
    1.5; ...
    5; 2; 5];

%% building up of long-term effect, sliding window across trials
trialBin = 30; % window of trial numbers
% get sliding AP for each bock
for subN = 1:size(names, 2)
    probSub = unique(eyeTrialData.prob(subN, :));
    slidingAP{subN} = NaN(size(probSub, 2), size(eyeTrialData.prob, 2)/size(probSub, 2)-trialBin);
    slidingOLP{subN} = NaN(size(probSub, 2), size(eyeTrialData.prob, 2)/size(probSub, 2)-trialBin);
    slidingCLP{subN} = NaN(size(probSub, 2), size(eyeTrialData.prob, 2)/size(probSub, 2)-trialBin);
    slidingPercept{subN} = NaN(size(probSub, 2), size(eyeTrialData.prob, 2)/size(probSub, 2)-trialBin);
    slidingCLPp{subN} = NaN(size(probSub, 2), size(eyeTrialData.prob, 2)/size(probSub, 2)-trialBin);
    for probI = 1:size(probSub, 2)
        idxT = find(eyeTrialData.prob(subN, :)==probSub(probI) & eyeTrialData.errorStatus(subN, :)==0);
        for slideI = 1:length(idxT)-trialBin
            slidingAP{subN}(probI, slideI) = nanmean(eyeTrialData.pursuit.AP(subN, idxT(slideI:(slideI+trialBin-1))));
            slidingOLP{subN}(probI, slideI) = nanmean(eyeTrialData.pursuit.initialMeanVelocity(subN, idxT(slideI:(slideI+trialBin-1)))); % open loop pursuit
            slidingCLP{subN}(probI, slideI) = nanmean(eyeTrialData.pursuit.closedLoopGain(subN, idxT(slideI:(slideI+trialBin-1)))); % close loop pursuit gain
        end
        
        idxT = find(eyeTrialData.prob(subN, :)==probSub(probI) & eyeTrialData.errorStatus(subN, :)==0 ...
            & abs(eyeTrialData.coh(subN, :))~=1);
        for slideI = 1:length(idxT)-trialBin+1
            slidingPercept{subN}(probI, slideI) = nanmean(eyeTrialData.choice(subN, idxT(slideI:(slideI+trialBin-1))));
            slidingCLPp{subN}(probI, slideI) = nanmean(eyeTrialData.pursuit.closedLoopGain(subN, idxT(slideI:(slideI+trialBin-1)))); % close loop pursuit gain
        end
    end
%     % individual plot
    % AP
    figure
    for probI = 1:size(probSub, 2)
        plot(slidingAP{subN}(probI, :), 'color', colorProb(probI, :))
        hold on
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Trial number')
    ylabel('AP')
    title(names{subN})
    saveas(gca, ['slidingAP_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    
    % OLP
    figure
    for probI = 1:size(probSub, 2)
        plot(slidingOLP{subN}(probI, :), 'color', colorProb(probI, :))
        hold on
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Trial number')
    ylabel('Open-loop pursuit mean velocity')
    title(names{subN})
    saveas(gca, ['slidingOLPmeanV_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    %
    % CLP
    figure
    for probI = 1:size(probSub, 2)
        plot(slidingCLP{subN}(probI, :), 'color', colorProb(probI, :))
        hold on
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Trial number')
    ylabel('Closed-loop pursuit gain')
    title(names{subN})
    saveas(gca, ['slidingCLPgain_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    
    % CLP in perceptual trials
    figure
    for probI = 1:size(probSub, 2)
        plot(slidingCLPp{subN}(probI, :), 'color', colorProb(probI, :))
        hold on
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Trial number (only perceptual trials)')
    ylabel('Closed-loop pursuit gain')
    title(names{subN})
    saveas(gca, ['slidingCLPgain_perceptualTrials_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    
    % Perception
    figure
    for probI = 1:size(probSub, 2)
        plot(slidingPercept{subN}(probI, :), 'color', colorProb(probI, :))
        hold on
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Trial number')
    ylabel('Probability of perceiving right')
    title(names{subN})
    saveas(gca, ['slidingPercept_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
end