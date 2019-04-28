initializeParas;

%% sort trials by preceeding probability of right, plot AP
trialBin = 5; % window of trial numbers; needs to be smaller than 50 for now
clear precedeProbPercept precedeProb perceptProbR clpProbR olpProbR apProbR xProb yAP yOLP yCLP xProbPercept yPercept
for subN = 1:size(names, 2)
    probSub = unique(eyeTrialData.prob(subN, :));
    %     precedeProb{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
    %     apProbR{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
    %     olpProbR{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
    %     clpProbR{subN} = NaN(size(probCons, 2), size(eyeTrialData.prob, 2)/size(probCons, 2)-trialBin);
    for probI = 1:size(probSub, 2)
        % eye movements
        idxT = find(eyeTrialData.prob(subN, :)==probSub(probI) & eyeTrialData.errorStatus(subN, :)==0 ...
            & ~isnan(eyeTrialData.pursuit.AP(subN, :)) & ~isnan(eyeTrialData.pursuit.closedLoopMeanVel(subN, :)) & abs(eyeTrialDataLog.coh(subN, :))<1);
        % true preceding trials
        for slideI = 1:length(idxT)
            rightN = length(find(eyeTrialData.rdkDir(subN, (idxT(slideI)-trialBin):(idxT(slideI)-1))==1)); % counting on perceptual choice, true preceding trials
            precedeProb{subN}(probI, slideI) = rightN/trialBin;
            apProbR{subN}(probI, slideI) = eyeTrialData.pursuit.AP(subN, idxT(slideI));
            olpProbR{subN}(probI, slideI) = eyeTrialData.pursuit.initialMeanVelocity(subN, idxT(slideI));
            clpProbR{subN}(probI, slideI) = eyeTrialData.pursuit.closedLoopGain(subN, idxT(slideI));
            perceptProbR{subN}(probI, slideI) = eyeTrialData.choice(subN, idxT(slideI));
        end
        %     % preceding trials in the list
        %     for slideI = (trialBin+1):length(idxT)
        %         rightN = length(find(eyeTrialData.rdkDir(subN, idxT((slideI-trialBin):(slideI-1)))==1));
        %         precedeProb{subN}(probI, slideI-trialBin) = rightN/trialBin;
        %         apProbR{subN}(probI, slideI-trialBin) = eyeTrialData.pursuit.AP(subN, idxT(slideI));
        %         olpProbR{subN}(probI, slideI-trialBin) = eyeTrialData.pursuit.initialMeanVelocity(subN, idxT(slideI));
        %         clpProbR{subN}(probI, slideI-trialBin) = eyeTrialData.pursuit.closedLoopGain(subN, idxT(slideI));
        %         perceptProbR{subN}(probI, slideI-trialBin) = eyeTrialData.choice(subN, idxT(slideI));
        %     end
        [xProb{subN, probI} ia ic] = unique(precedeProb{subN}(probI, :));
        yAP{subN, probI} = accumarray(ic, apProbR{subN}(probI, :)', [], @mean); % mean AP of the corresponding probability
        yOLP{subN, probI} = accumarray(ic, olpProbR{subN}(probI, :)', [], @mean);
        yCLP{subN, probI} = accumarray(ic, clpProbR{subN}(probI, :)', [], @mean);
        yPercept{subN, probI} = accumarray(ic, perceptProbR{subN}(probI, :)', [], @mean); % mean AP of the corresponding probability
    end
    % individual plot
    % AP
    figure
    for probI = 1:size(probSub, 2)
        %         subplot(1, 3, probI)
        plot(xProb{subN, probI}, yAP{subN, probI}, 'color', colorProb(probI, :))
        hold on
        %         xlim([0 1])
        %         ylim([-8 10])
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Preceded probability of right')
    ylabel('AP')
    title([names{subN}])
    %     end
    saveas(gca, ['precedeProbRight_AP_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    %
    %     % OLP
    %     figure
    %     for probI = 1:size(probCons, 2)
    %         %         subplot(1, 3, probI)
    %         plot(xProb{subN, probI}, yOLP{subN, probI}, 'color', colorProb(probI, :))
    %         hold on
    %         %         xlim([0 1])
    %         %         ylim([-8 10])
    %     end
    %     legend({'50' '70' '90'}, 'box', 'off')
    %     xlabel('Preceded probability of right')
    %     ylabel('Open-loop pursuit mean velocity')
    %     title([names{subN}])
    %     %     end
    %     saveas(gca, ['precedeProbRight_OLPmeanV_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    
    % closed loop
    figure
    for probI = 1:size(probSub, 2)
        %         subplot(1, 3, probI)
        plot(xProb{subN, probI}, yCLP{subN, probI}, 'color', colorProb(probI, :))
        hold on
        %         xlim([0 1])
        %         ylim([-8 10])
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Preceded probability of right')
    ylabel('Closed-loop pursuit gain')
    title([names{subN}])
    %     end
    saveas(gca, ['precedeProbRight_CLPgain_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
    
    % perception
    figure
    for probI = 1:size(probSub, 2)
        %         subplot(1, 3, probI)
        plot(xProb{subN, probI}, yPercept{subN, probI}, 'color', colorProb(probI, :))
        hold on
        %         xlim([0 1])
        %         ylim([-8 10])
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Preceded probability of right')
    ylabel('Probability of perceiving right')
    title([names{subN}])
    %     %     end
    saveas(gca, ['precedeProbRight_perception_', names{subN}, '_bin', num2str(trialBin), '.pdf'])
end