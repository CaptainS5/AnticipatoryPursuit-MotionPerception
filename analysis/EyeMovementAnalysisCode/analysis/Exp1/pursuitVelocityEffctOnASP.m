% to have a sense of whether steady-state pursuit velocity affects ASP
initializeParas;
cohCons = [0.2, 0.3];
% first, whether steady-state pursuit velocity differs between 20% and 30%
% coherence; then, see if different CLP velocity affects ASP 
clpVelXmean = NaN(size(names, 2), 2); % first column is 30%, second column is 20%
aspVelXmean = NaN(size(names, 2), 2); % first column is 30%, second column is 20%
clpVelXstd = NaN(size(names, 2), 2); % first column is 30%, second column is 20%
aspVelXstd = NaN(size(names, 2), 2); % first column is 30%, second column is 20%
for subN = 1:size(names, 2)
    probSub = unique(eyeTrialData.prob(subN, :));
    if probSub(1)==50
        sign = 1;
    else
        sign = -1;
    end
    
    for cohI = 1:2
        idxCLP = find(abs(eyeTrialData.coh(subN, :))==cohCons(cohI));
        clpVelXmean(subN, cohI) = nanmean(abs(eyeTrialData.pursuit.closedLoopMeanVelX(subN, idxCLP)));
        clpVelXstd(subN, cohI) = nanstd(abs(eyeTrialData.pursuit.closedLoopMeanVelX(subN, idxCLP)));
        idxASP = idxCLP+1;
        idxASP(idxASP==683) = [];
        idxASP(idxASP==1365) = [];
        aspVelXmean(subN, cohI) = nanmean(eyeTrialData.pursuit.APvelocityX(subN, idxASP)*sign);
        aspVelXstd(subN, cohI) = nanstd(eyeTrialData.pursuit.APvelocityX(subN, idxASP)*sign);
    end
end
% CLP velocity figure
figure
hold on
for subN = 1:size(names, 2)
    errorbar([0.2, 0.3], clpVelXmean(subN, :), clpVelXstd(subN, :), '--')
end
xlim([0.18, 0.32])
xlabel('Coherence of the current trial')
ylabel('Abs CLP horizontal velocity (deg/s)')
% saveas(gca, 'coherence_pursuitVel_contextTrials.pdf')

% ASP figure
figure
hold on
for subN = 1:size(names, 2)
    errorbar([0.2, 0.3], aspVelXmean(subN, :), aspVelXstd(subN, :), '--')
end
xlim([0.18, 0.32])
xlabel('Coherence of the previous trial')
ylabel('ASP horizontal velocity (deg/s)')
% saveas(gca, 'previousContextTrialCoherence_ASP.pdf')