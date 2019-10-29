% to compare the perceptual bias between the two experiments
clear all; close all; clc

d{1} = load('dataPercept_all_exp1.mat');
d{2} = load('dataPercept_all_exp2.mat');

% first calculate a bias for each participant
% row: participants
% column: experiments
perceptBias = NaN(9, 2);
for expN = 1:2
    if expN == 1
        endN = 3; % column of the highest probability condition
    else
        endN = 2;
    end
    
    for subN = 1:9
       perceptBias(subN, expN) = d{expN}.dataPercept.alpha(subN, endN)-d{expN}.dataPercept.alpha(subN, 1); % already flipped and merged, it's 50-(70-)90 for each participant
       PSEall{expN}(subN, 1) = d{expN}.dataPercept.alpha(subN, 1); % prob 50%
       PSEall{expN}(subN, 2) = d{expN}.dataPercept.alpha(subN, endN); % prob 90%
    end
end

figure
hold on
for subN = 1:9
    plot([1 2], perceptBias(subN, :), '--')
end
legend({'tXW' 'tDC' 'p7' 'p3' 'p9' 'p8' 'p6' 'p4' 'p5'})
xlim([0.5, 2.5])
xlabel('Experiment')
ylabel('Difference in PSE')
saveas(gca, 'perceptBiasExp1vs2.pdf')

save('perceptBias.mat', 'perceptBias')

%% generate csv file for R
% cd(analysisFolder)
cd ..
cd('R')

data = table();
count = 1;
for subN = 1:9
    for expN = 1:2
        data.sub(count, 1) = subN;
        data.exp(count, 1) = expN;
        data.PSEbias(count, 1) = perceptBias(subN, expN);
        count = count+1;
    end
end
writetable(data, 'comparePSEbias.csv')

%%
% figure
% hold on
% for subN = 1:9
%     plot([1 2 3 4], [PSEall{1}(subN, :) PSEall{2}(subN, :)], '--')
% %     plot([3 4], PSEall{2}(subN, :), '--')
% end
% xlim([0.5, 4.5])
% set(gca, 'XTick', [1 2 3 4], 'XTickLabels', {'Exp1-50%', 'Exp1-90%', 'Exp2-50%', 'Exp2-90%'})
% ylabel('PSE')

% t-test
