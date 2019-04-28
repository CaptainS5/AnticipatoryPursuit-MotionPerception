initializeParas;

%% sort trials by perceptual responses, plot pursuit
for subN = 1:size(names, 2)
    probSub = unique(eyeTrialDataLog.prob(subN, :));
    
    for probI = 1:size(probSub, 2)
        % low coherece trials perceived as moving to the right
        idxR = find(eyeTrialData.prob(subN, :)==probSub(probI) & eyeTrialData.errorStatus(subN, :)==0 ...
            & eyeTrialData.choice(subN, :)==1 & abs(eyeTrialData.coh(subN, :))<0.15);
        % low coherece trials perceived as moving to the left
        idxL = find(eyeTrialData.prob(subN, :)==probSub(probI) & eyeTrialData.errorStatus(subN, :)==0 ...
            & eyeTrialData.choice(subN, :)==0 & abs(eyeTrialData.coh(subN, :))<0.15);
        
        apChoice.mean{subN}(probI, 1) = nanmean(eyeTrialData.pursuit.AP(subN, idxL)); % choosing left
        apChoice.std{subN}(probI, 1) = nanstd(eyeTrialData.pursuit.AP(subN, idxL)); % choosing left
        apChoice.mean{subN}(probI, 2) = nanmean(eyeTrialData.pursuit.AP(subN, idxR)); % choosing right
        apChoice.std{subN}(probI, 2) = nanstd(eyeTrialData.pursuit.AP(subN, idxR)); % choosing right
        
        olpChoice.mean{subN}(probI, 1) = nanmean(eyeTrialData.pursuit.initialMeanVelocity(subN, idxL)); % choosing left
        olpChoice.std{subN}(probI, 1) = nanstd(eyeTrialData.pursuit.initialMeanVelocity(subN, idxL)); % choosing left
        olpChoice.mean{subN}(probI, 2) = nanmean(eyeTrialData.pursuit.initialMeanVelocity(subN, idxR)); % choosing right
        olpChoice.std{subN}(probI, 2) = nanstd(eyeTrialData.pursuit.initialMeanVelocity(subN, idxR)); % choosing right
        
        clpChoice.mean{subN}(probI, 1) = nanmean(eyeTrialData.pursuit.closedLoopMeanVel(subN, idxL)); % choosing left
        clpChoice.std{subN}(probI, 1) = nanstd(eyeTrialData.pursuit.closedLoopMeanVel(subN, idxL)); % choosing left
        clpChoice.mean{subN}(probI, 2) = nanmean(eyeTrialData.pursuit.closedLoopMeanVel(subN, idxR)); % choosing right
        clpChoice.std{subN}(probI, 2) = nanstd(eyeTrialData.pursuit.closedLoopMeanVel(subN, idxR)); % choosing right
        
    end
%     individual plot
    % AP
    figure
    for probI = 1:size(probSub, 2)
        %         subplot(1, 3, probI)
        errorbar([-1 1], apChoice.mean{subN}(probI, :), apChoice.std{subN}(probI, :), '--o', 'color', colorProb(probI, :))
        hold on
        %         xlim([0 1])
        %         ylim([-8 10])
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Perceptual choice (-1=left, 1=right)')
    ylabel('AP')
    title([names{subN}])
    %     end
    saveas(gca, ['choice_AP_', names{subN}, '.pdf'])
    
    %     % OLP
    %     figure
    %         for probI = 1:size(probCons, 2)
    %             %         subplot(1, 3, probI)
    %             errorbar([-1 1], olpChoice.mean{subN}(probI, :), olpChoice.std{subN}(probI, :), '--o', 'color', colorProb(probI, :))
    %             hold on
    %     %         xlim([0 1])
    %     %         ylim([-8 10])
    %         end
    %         legend({'50' '70' '90'}, 'box', 'off')
    %         xlabel('Perceptual choice (-1=left, 1=right)')
    %         ylabel('Open-loop mean velocity')
    %         title([names{subN}])
    %         %     end
    %         saveas(gca, ['choice_OLPmeanV_', names{subN}, '.pdf'])
    
    % closed-loop
    figure
    for probI = 1:size(probSub, 2)
        %         subplot(1, 3, probI)
        errorbar([-1 1], clpChoice.mean{subN}(probI, :), clpChoice.std{subN}(probI, :), '--o', 'color', colorProb(probI, :))
        hold on
        %         xlim([0 1])
        %         ylim([-8 10])
    end
    legend({'50' '70' '90'}, 'box', 'off')
    xlabel('Perceptual choice (-1=left, 1=right)')
    ylabel('Closed-loop mean velocity')
    title([names{subN}])
    %     end
    saveas(gca, ['choice_CLPmeanV_', names{subN}, '.pdf'])
end