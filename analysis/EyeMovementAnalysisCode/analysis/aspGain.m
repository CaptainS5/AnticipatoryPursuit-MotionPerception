% to calculate the ASP gain in experiments 1&3 and compare them
clear all; close all; clc

nameSets{1} = {'XW0' 'p2' 'p4' 'p5' 'p6' 'p8' 'p9' 'p10' 'p14' '015'}; % experiment 1
nameSets{2} = {'tFW' 'fh2' 'nan' 'fh5' 'fh6' 'fh8' 'fh9' 'fht' 'nan' 'p15'};
names = {'tFW' 'fh2' 'fh5' 'fh6' 'fh8' 'fh9' 'fht' 'p15'};

d{1} = load('eyeTrialData_all_cleaned126_exp1.mat');
d{2} = load('eyeTrialData_all_cleaned126_exp2.mat');
probCons = [50 90]; % to compare between the experiments

%% calculate ASP gain for each participant in prob 90 block
% asp for each trial is velocity-mean ASP velocity in the prob 50 block
for expN = 1:2
    aspGainTrial{expN, 1} = NaN(182, size(names, 2));
    aspTrial{expN, 1} = NaN(182, size(names, 2));
    aspGainTrial{expN, 2} = NaN(182, size(names, 2));
    aspTrial{expN, 2} = NaN(182, size(names, 2));
    %     meanCLPvelX{expN, 1} = NaN(182, 9);
    %     meanCLPvelX{expN, 2} = NaN(182, 9);
    for subN = 1:size(names, 2)
        if expN==1
            subNdata = find(strcmp(nameSets{2}, names{subN}));
        else
            subNdata = subN;
        end
        
        prob10Idx = find(d{expN}.eyeTrialData.prob(subNdata, :)==10);
        if ~isempty(prob10Idx) % flip everything...
            d{expN}.eyeTrialData.prob(subNdata, prob10Idx) = 90;
            if expN==1
                prob30Idx = find(d{expN}.eyeTrialData.prob(subNdata, :)==30);
                d{expN}.eyeTrialData.prob(subNdata, prob30Idx) = 70;
            end
            d{expN}.eyeTrialData.rdkDir(subNdata, :) = -d{expN}.eyeTrialData.rdkDir(subNdata, :);
            d{expN}.eyeTrialData.choice(subNdata, :) = 1-d{expN}.eyeTrialData.choice(subNdata, :);
            d{expN}.eyeTrialData.coh(subNdata, :) = -d{expN}.eyeTrialData.coh(subNdata, :);
            d{expN}.eyeTrialData.pursuit.APvelocityX(subNdata, :) = -d{expN}.eyeTrialData.pursuit.APvelocityX(subNdata, :);
            d{expN}.eyeTrialData.pursuit.closedLoopMeanVelX(subNdata, :) = -d{expN}.eyeTrialData.pursuit.closedLoopMeanVelX(subNdata, :);
        end
        
        for probN = 1:length(probCons)            
            allTrialIdx = find(d{expN}.eyeTrialData.errorStatus(subNdata, :)==0 & d{expN}.eyeTrialData.prob(subNdata, :)==probCons(probN));
            contextIdx = find(d{expN}.eyeTrialData.trialType(subNdata, :)==1 & d{expN}.eyeTrialData.errorStatus(subNdata, :)==0 ...
                & d{expN}.eyeTrialData.prob(subNdata, :)==probCons(probN)); % idx of valid context trials
            perceptIdx = find(d{expN}.eyeTrialData.trialType(subNdata, :)==0 & d{expN}.eyeTrialData.errorStatus(subNdata, :)==0 ...
                & ~isnan(d{expN}.eyeTrialData.pursuit.APvelocityX(subNdata, :)) & d{expN}.eyeTrialData.prob(subNdata, :)==probCons(probN)); % idx of valid perceptual trials
            %         meanCLPvelX(subN, expN) = nanmean(d{expN}.eyeTrialData.pursuit.closedLoopMeanVelX(subN, contextIdx).*d{expN}.eyeTrialData.rdkDir(subN, contextIdx));
            
            % calculate the gain as asp/mean closedloop velocity in previous
            % trials
            for perceptN = 1:length(perceptIdx)
                previousIdx = allTrialIdx(allTrialIdx<perceptIdx(perceptN));
                meanCLPvelX{expN, probN}(perceptN, subN) = nanmean(abs(d{expN}.eyeTrialData.pursuit.closedLoopMeanVelX(subNdata, previousIdx)));
                aspTrial{expN, probN}(perceptN, subN) = d{expN}.eyeTrialData.pursuit.APvelocityX(subNdata, perceptIdx(perceptN));
                aspGainTrial{expN, probN}(perceptN, subN) = aspTrial{expN, probN}(perceptN, subN)/meanCLPvelX{expN, probN}(perceptN, subN); % each column is one participant
            end
%             aspGainSub(subN, (expN-1)*2+probN) = nanmean(aspGainTrial{expN, probN}(:, subN)); % exp1-50, exp1-90, exp2-50, exp2-90
            aspVelSub(subN, (expN-1)*2+probN) = nanmean(aspTrial{expN, probN}(:, subN)); % velocity, not gain; exp1-50, exp1-90, exp2-50, exp2-90
        end
    end
end

%% plot
% figure
% hold on
% for subN = 1:9
%     plot([1 2], [aspGainSub(:, 2)-aspGainSub(:, 1), aspGainSub(:, 4)-aspGainSub(:, 3)], '--')
% end
% legend({'tXW' 'tDC' 'p7' 'p3' 'p9' 'p8' 'p6' 'p4' 'p5'})
% xlim([0.5, 2.5])
% xlabel('Experiment')
% ylabel('ASP gain diff')
% % saveas(gca, 'aspGainExp1vs2_minusBaseline.pdf')
% 
% [h, p, ci, stats] = ttest(aspGainSub(:, 2)-aspGainSub(:, 1), aspGainSub(:, 4)-aspGainSub(:, 3));
% p
% stats

% save('aspGain_minusBaseline.mat', 'aspGainSub')

%% generate csv file for plotting in R
cd ..
cd ..
cd('R')

data = table();
count = 1;
for ii = 1:2
    if ii==1
        expN = 1;
    else
        expN = 2;
    end
    for subN = 1:size(names, 2)
        for probN = 1:2
            data.sub(count, 1) = subN;
            data.exp(count, 1) = expN;
            data.prob(count, 1) = probCons(probN);
            data.aspVel(count, 1) = aspVelSub(subN, (ii-1)*2+probN);
            count = count+1;
        end
    end
end
writetable(data, 'aspVel_exp1vs2_cleaned126.csv')

% asp gain difference
data = table();
count = 1;
for subN = 1:size(names, 2)
    for ii = 1:2
        if ii==1
            expN = 1;
        else
            expN = 2;
        end
        data.sub(count, 1) = subN;
        data.exp(count, 1) = expN;
        data.aspVelDiff(count, 1) = aspVelSub(subN, ii*2)-aspVelSub(subN, ii*2-1);
        count = count+1;
    end
end
writetable(data, 'aspVelDiff_exp1vs2_cleaned126.csv')

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
