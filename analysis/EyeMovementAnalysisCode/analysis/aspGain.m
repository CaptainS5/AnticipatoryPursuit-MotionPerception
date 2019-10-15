% to calculate the ASP gain in both experiments and compare them
clear all; close all; clc

d{1} = load('eyeTrialData_all_set1_exp1.mat');
d{2} = load('eyeTrialData_all_set1_exp2.mat');
probCons = [50 90]; % to compare between the experiments

%% calculate ASP gain for each participant in prob 90 block
% asp for each trial is velocity-mean ASP velocity in the prob 50 block
for expN = 1:2
    aspGainTrial{expN} = NaN(182, 9);
    aspTrial{expN} = NaN(182, 9);
%     meanCLPvelX{expN, 1} = NaN(182, 9);
%     meanCLPvelX{expN, 2} = NaN(182, 9);
    for subN = 1:9
        prob10Idx = find(d{expN}.eyeTrialData.prob(subN, :)==10);
        if ~isempty(prob10Idx) % flip everything...
            d{expN}.eyeTrialData.prob(subN, prob10Idx) = 90;
            d{expN}.eyeTrialData.rdkDir(subN, :) = -d{expN}.eyeTrialData.rdkDir(subN, :);
            d{expN}.eyeTrialData.choice(subN, :) = 1-d{expN}.eyeTrialData.choice(subN, :);
            d{expN}.eyeTrialData.coh(subN, :) = -d{expN}.eyeTrialData.coh(subN, :);
            d{expN}.eyeTrialData.pursuit.APvelocityX(subN, :) = -d{expN}.eyeTrialData.pursuit.APvelocityX(subN, :);
            d{expN}.eyeTrialData.pursuit.closedLoopMeanVelX(subN, :) = -d{expN}.eyeTrialData.pursuit.closedLoopMeanVelX(subN, :);
        end
        
        % calculate the mean ASP in prob 50 as a baseline...
        baselineIdx = find(d{expN}.eyeTrialData.trialType(subN, :)==0 & d{expN}.eyeTrialData.errorStatus(subN, :)==0 ...
            & d{expN}.eyeTrialData.prob(subN, :)==50);
        baselineASP(subN, expN) = nanmean(d{expN}.eyeTrialData.pursuit.APvelocityX(subN, baselineIdx));
        
        allTrialIdx = find(d{expN}.eyeTrialData.errorStatus(subN, :)==0 & d{expN}.eyeTrialData.prob(subN, :)==90);
        contextIdx = find(d{expN}.eyeTrialData.trialType(subN, :)==1 & d{expN}.eyeTrialData.errorStatus(subN, :)==0 ...
            & d{expN}.eyeTrialData.prob(subN, :)==90); % idx of valid perceptual trials
        perceptIdx = find(d{expN}.eyeTrialData.trialType(subN, :)==0 & d{expN}.eyeTrialData.errorStatus(subN, :)==0 ...
            & ~isnan(d{expN}.eyeTrialData.pursuit.APvelocityX(subN, :)) & d{expN}.eyeTrialData.prob(subN, :)==90); % idx of valid perceptual trials
%         meanCLPvelX(subN, expN) = nanmean(d{expN}.eyeTrialData.pursuit.closedLoopMeanVelX(subN, contextIdx).*d{expN}.eyeTrialData.rdkDir(subN, contextIdx));

        % calculate the gain as asp(minus baseline)/mean closedloop velocity in previous
        % trials
        for perceptN = 1:length(perceptIdx)
            previousIdx = allTrialIdx(allTrialIdx<perceptIdx(perceptN));
            meanCLPvelX{expN}(perceptN, subN) = nanmean(abs(d{expN}.eyeTrialData.pursuit.closedLoopMeanVelX(subN, previousIdx)));
            aspTrial{expN}(perceptN, subN) = d{expN}.eyeTrialData.pursuit.APvelocityX(subN, perceptIdx(perceptN)); %-baselineASP(subN, expN);
            aspGainTrial{expN}(perceptN, subN) = aspTrial{expN}(perceptN, subN)/meanCLPvelX{expN}(perceptN, subN); % each column is one participant
        end
        aspGainSub(subN, expN) = nanmean(aspGainTrial{expN}(:, subN)); % exp1-50, exp1-90, exp2-50, exp2-90
    end
end

%% plot
figure
hold on
for subN = 1:9
    plot([1 2], aspGainSub(subN, :), '--')
end
legend({'tXW' 'tDC' 'p7' 'p3' 'p9' 'p8' 'p6' 'p4' 'p5'})
xlim([0.5, 2.5])
xlabel('Experiment')
ylabel('ASP gain')
saveas(gca, 'aspGainExp1vs2.pdf')

[h, p] = ttest(aspGainSub(:, 2), aspGainSub(:, 1))

save('aspGain.mat', 'aspGainSub')
load('perceptBias')

%% check correlation... no you only have 9 points = = 
figure
hold on
% for expN = 1:2
    scatter(aspGainSub(:, 2)-aspGainSub(:, 1), perceptBias(:, 2)-perceptBias(:, 1))
% end
% legend({'Exp1', 'Exp2'})
xlabel('Change in ASP gain')
ylabel('Change in perceptual bias')
axis square
saveas(gca, 'changeCorr.pdf')
% [h, p] = ttest(perceptBias(:, 2), perceptBias(:, 1));
[R,P,RLO,RUP] = corrcoef(aspGainSub(:, 2)-aspGainSub(:, 1), perceptBias(:, 2)-perceptBias(:, 1), 'alpha', 0.05)
