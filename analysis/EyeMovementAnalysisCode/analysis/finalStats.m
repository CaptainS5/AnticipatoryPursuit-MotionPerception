% doing some final stats for the manuscript
clear; clc; close all

%% number of valid trials
for expN = 2:3
    clear excludeN
    dataAll{expN} = load(['eyeTrialData_all_set1_exp', num2str(expN), '.mat']);
    for subN = 1:size(dataAll{expN}.eyeTrialData.sub, 1)
        excludeN(subN, 1) = length(find(dataAll{expN}.eyeTrialData.errorStatus(subN, :)~=0 & dataAll{expN}.eyeTrialData.trialType(subN, :)==0));
    end
    excludeRatio = excludeN/length(find(dataAll{expN}.eyeTrialData.trialType(subN, :)==0));
    meanN = mean(excludeRatio);
    stdN = std(excludeRatio);
    disp(['Exp', num2str(expN), ' excluded blink trials %: ', num2str(meanN*100), '+-', num2str(stdN*100)])
end

%%