% function transform2csv
% to use in R
clear; close all; clc

dataRaw{1} = load('dataPercept_all_exp1.mat');
dataRaw{2} = load('dataPercept_all_exp2.mat');
dataRaw{3} = load('dataPercept_all_exp3.mat');
probCons = [50 90];

% merge and save csv
cd ..
cd('R')

%% exp1 vs. exp2
nameSets{2} = {'tFW' 'fh2' 'nan' 'fh5' 'fh6' 'fh8' 'fh9' 'fht' 'nan' 'p15'};
names = {'tFW' 'fh2' 'fh5' 'fh6' 'fh8' 'fh9' 'fht' 'p15'};

data = table();
count = 1;
for expN = 1:2
    for subN = 1:size(dataRaw{2}.dataPercept.alpha, 1)
        if expN==1
            subNdata = find(strcmp(nameSets{2}, names{subN}));
        else
            subNdata = subN;
        end
        
        for probN = 1:2
            if expN==1 && probN==2
                probN2 = 3;
            else
                probN2 = probN;
            end
            data.sub(count, 1) = subN;
            data.exp(count, 1) = expN;
            data.prob(count, 1) = probCons(probN);
            data.PSE(count, 1) = dataRaw{expN}.dataPercept.alpha(subNdata, probN2);
            data.slope(count, 1) = dataRaw{expN}.dataPercept.beta(subNdata, probN2);
            count = count+1;
        end
    end
end
writetable(data, 'PSE_exp1vs2.csv')

% asp gain difference
data = table();
count = 1;
for subN = 1:size(dataRaw{2}.dataPercept.alpha, 1)
    for ii = 1:2
        if ii==1
            expN = 1;
            probH = 3;
            probL = 1;
        else
            expN = 2;
            probH = 2;
            probL = 1;
        end
        
        if expN==1
            subNdata = find(strcmp(nameSets{2}, names{subN}));
        else
            subNdata = subN;
        end
        data.sub(count, 1) = subN;
        data.exp(count, 1) = expN;
        data.PSEdiff(count, 1) = dataRaw{expN}.dataPercept.alpha(subNdata, probH)-dataRaw{expN}.dataPercept.alpha(subNdata, probL);
        data.slopeDiff(count, 1) = dataRaw{expN}.dataPercept.beta(subNdata, probH)-dataRaw{expN}.dataPercept.beta(subNdata, probL);
        count = count+1;
    end
end
writetable(data, 'PSEdiff_exp1vs2.csv')

%% exp1 vs. exp3
data = table();
count = 1;
for ii = 1:2
    if ii==1
        expN = 1;
    else
        expN = 3;
    end
    for subN = 1:size(dataRaw{3}.dataPercept.alpha, 1)
        for probN = 1:2
            if expN==1 && probN==2
                probN2 = 3;
            else
                probN2 = probN;
            end
            data.sub(count, 1) = subN;
            data.exp(count, 1) = expN;
            data.prob(count, 1) = probCons(probN);
            data.PSE(count, 1) = dataRaw{expN}.dataPercept.alpha(subN, probN2);
            data.slope(count, 1) = dataRaw{expN}.dataPercept.beta(subN, probN2);
            count = count+1;
        end
    end
end
writetable(data, 'PSE_exp1vs3.csv')

% asp gain difference
data = table();
count = 1;
for subN = 1:9
    for ii = 1:2
        if ii==1
            expN = 1;
            probH = 3;
            probL = 1;
        else
            expN = 3;
            probH = 2;
            probL = 1;
        end
        data.sub(count, 1) = subN;
        data.exp(count, 1) = expN;
        data.PSEdiff(count, 1) = dataRaw{expN}.dataPercept.alpha(subN, probH)-dataRaw{expN}.dataPercept.alpha(subN, probL);
        data.slopeDiff(count, 1) = dataRaw{expN}.dataPercept.beta(subN, probH)-dataRaw{expN}.dataPercept.beta(subN, probL);
        count = count+1;
    end
end
writetable(data, 'PSEdiff_exp1vs3.csv')