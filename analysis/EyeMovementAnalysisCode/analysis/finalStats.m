% doing some final stats for the manuscript
clear; clc; close all
analysisFolder = pwd;

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

%% accuracy in context trials
for expN = 1:3
    clear trialTotalN correctN
    dataAll{expN} = load(['eyeTrialData_all_set1_exp', num2str(expN), '.mat']);
    for subN = 1:size(dataAll{expN}.eyeTrialData.sub, 1)
        trialTotalN(subN, 1) = length(find(dataAll{expN}.eyeTrialData.trialType(subN, :)==1));
        correctN(subN, 1) = length(find((dataAll{expN}.eyeTrialData.trialType(subN, :)==1 ...
            & dataAll{expN}.eyeTrialData.rdkDir(subN, :)>0 & dataAll{expN}.eyeTrialData.choice(subN, :)==1)...
            | (dataAll{expN}.eyeTrialData.trialType(subN, :)==1 ...
            & dataAll{expN}.eyeTrialData.rdkDir(subN, :)<0 & dataAll{expN}.eyeTrialData.choice(subN, :)==0)));
    end
    accuracy{expN} = correctN./trialTotalN;
    meanN = mean(accuracy{expN});
    stdN = std(accuracy{expN});
    disp(['Exp', num2str(expN), ' accuracy: ', num2str(meanN), '+-', num2str(stdN)])
end

[h, p, ci, stats] = ttest(accuracy{1}(1:9),accuracy{3});
cohensD = (mean(accuracy{1}(1:9))-mean(accuracy{3}))/std(accuracy{1}(1:9)-accuracy{3});

%% t test for left & right conditions in Exp1
cd(analysisFolder)
load eyeTrialData_all_exp1
cd ..
cd ..
cd('psychometricFunction')
load dataPercept_all_exp1
cd(analysisFolder)

% first, group participants
minSubProb = min(eyeTrialData.prob, [], 2);
leftI = find(minSubProb==10);
rightI = find(minSubProb==50);

% asp
for subN = 1:10
    trialI = find(eyeTrialData.errorStatus(subN, :)==0 & eyeTrialData.trialType(subN, :)==0);
    aspMean(subN, 1) = nanmean(eyeTrialData.pursuit.APvelocityX(subN, trialI));
end
leftAsp = -aspMean(leftI, 1);
rightAsp = aspMean(rightI, 1);
[h,p,ci,stats] = ttest(leftAsp, rightAsp);
cohensD = (mean(leftAsp)-mean(rightAsp))/sqrt((var(leftAsp)+var(rightAsp))/8);
display(['asp: t(', num2str(stats.df), ')=', num2str(stats.tstat), ', p=', num2str(p), ', Cohen''s d=', num2str(cohensD)])

% perception
for subN = 1:10
    pseMean(subN, 1) = mean(dataPercept.alpha(subN, :));
end
leftPSE = -pseMean(leftI, 1);
rightPSE = pseMean(rightI, 1);
[h,p,ci,stats] = ttest(leftPSE, rightPSE);
cohensD = (mean(leftPSE)-mean(rightPSE))/sqrt((var(leftPSE)+var(rightPSE))/8);
display(['pse: t(', num2str(stats.df), ')=', num2str(stats.tstat), ', p=', num2str(p), ', Cohen''s d=', num2str(cohensD)])
