% to calculate the ASP gain in both experiments and compare them
clear all; close all; clc

d{1} = load('eyeTrialData_all_set1_exp1.mat');
d{2} = load('eyeTrialData_all_set1_exp2.mat');
probCons = [50 90]; % to compare between the experiments

%% calculate ASP gain for each participant in prob 90 block
% asp for each trial is velocity-mean ASP velocity in the prob 50 block
for expN = 1:2
    aspGainTrial{expN, 1} = NaN(182, 9);
    aspTrial{expN, 1} = NaN(182, 9);
    aspGainTrial{expN, 2} = NaN(182, 9);
    aspTrial{expN, 2} = NaN(182, 9);
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
        
        for probN = 1:2            
            allTrialIdx = find(d{expN}.eyeTrialData.errorStatus(subN, :)==0 & d{expN}.eyeTrialData.prob(subN, :)==probCons(probN));
            contextIdx = find(d{expN}.eyeTrialData.trialType(subN, :)==1 & d{expN}.eyeTrialData.errorStatus(subN, :)==0 ...
                & d{expN}.eyeTrialData.prob(subN, :)==probCons(probN)); % idx of valid context trials
            perceptIdx = find(d{expN}.eyeTrialData.trialType(subN, :)==0 & d{expN}.eyeTrialData.errorStatus(subN, :)==0 ...
                & ~isnan(d{expN}.eyeTrialData.pursuit.APvelocityX(subN, :)) & d{expN}.eyeTrialData.prob(subN, :)==probCons(probN)); % idx of valid perceptual trials
            %         meanCLPvelX(subN, expN) = nanmean(d{expN}.eyeTrialData.pursuit.closedLoopMeanVelX(subN, contextIdx).*d{expN}.eyeTrialData.rdkDir(subN, contextIdx));
            
            % calculate the gain as asp/mean closedloop velocity in previous
            % trials
            for perceptN = 1:length(perceptIdx)
                previousIdx = allTrialIdx(allTrialIdx<perceptIdx(perceptN));
                meanCLPvelX{expN, probN}(perceptN, subN) = nanmean(abs(d{expN}.eyeTrialData.pursuit.closedLoopMeanVelX(subN, previousIdx)));
                aspTrial{expN, probN}(perceptN, subN) = d{expN}.eyeTrialData.pursuit.APvelocityX(subN, perceptIdx(perceptN));
                aspGainTrial{expN, probN}(perceptN, subN) = aspTrial{expN, probN}(perceptN, subN)/meanCLPvelX{expN, probN}(perceptN, subN); % each column is one participant
            end
            aspGainSub(subN, (expN-1)*2+probN) = nanmean(aspGainTrial{expN, probN}(:, subN)); % exp1-50, exp1-90, exp2-50, exp2-90
        end
    end
end

%% plot
figure
hold on
for subN = 1:9
    plot([1 2], [aspGainSub(:, 2)-aspGainSub(:, 1), aspGainSub(:, 4)-aspGainSub(:, 3)], '--')
end
legend({'tXW' 'tDC' 'p7' 'p3' 'p9' 'p8' 'p6' 'p4' 'p5'})
xlim([0.5, 2.5])
xlabel('Experiment')
ylabel('ASP gain diff')
saveas(gca, 'aspGainExp1vs2_minusBaseline.pdf')

[h, p, ci, stats] = ttest(aspGainSub(:, 2)-aspGainSub(:, 1), aspGainSub(:, 4)-aspGainSub(:, 3));
p
stats

save('aspGain_minusBaseline.mat', 'aspGainSub')

%% generate csv file for plotting in R
cd ..
cd ..
cd('R')

data = table();
count = 1;
for subN = 1:9
    for expN = 1:2
        data.sub(count, 1) = subN;
        data.exp(count, 1) = expN;
        data.aspGainDiff(count, 1) = aspGainSub(subN, expN*2)-aspGainSub(subN, expN*2-1);
        count = count+1;
    end
end
writetable(data, 'aspGainCompare.csv')

%% check correlation... no you only have 9 points = =
% load('perceptBias')
% figure
% hold on
% % for expN = 1:2
%     scatter(aspGainSub(:, 2)-aspGainSub(:, 1), perceptBias(:, 2)-perceptBias(:, 1))
% % end
% % legend({'Exp1', 'Exp2'})
% xlabel('Change in ASP gain')
% ylabel('Change in perceptual bias')
% axis square
% saveas(gca, 'changeCorr_minusBaseline.pdf')
% % [h, p] = ttest(perceptBias(:, 2), perceptBias(:, 1));
% [R,P,RLO,RUP] = corrcoef(aspGainSub(:, 2)-aspGainSub(:, 1), perceptBias(:, 2)-perceptBias(:, 1), 'alpha', 0.05)
