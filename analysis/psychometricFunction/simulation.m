% run a simulation to see if short-term repulsive effect only would result
% in a change in slope.

clear all; close all; clc

list{1} = load('list50prob.mat');
list{2} = load('list90prob.mat');
probCons = [50 90];
probNames = {'50%' '90%'};
colorProb = [198,219,239;8,48,107]/255; % all blue hues
% "fake" threshold and slope
beta = 20;
alpha = 0;
lambda = 0;
bias = -0.01; % bias of threshold induced by probability

% fitting settings
PF = @PAL_Logistic;  %Alternatives: PAL_Gumbel, PAL_Weibull,
%PAL_Quick, PAL_logQuick, PAL_Logistic
%PAL_CumulativeNormal, PAL_HyperbolicSecant

%Threshold, Slope, and lapse rate are free parameters, guess is fixed
paramsFree = [1 1 0 1];  %1: free parameter, 0: fixed parameter

%Parameter grid defining parameter space through which to perform a
%brute-force search for values to be used as initial guesses in iterative
%parameter search.
searchGrid.alpha = 0.01:.001:.11;
searchGrid.beta = logspace(0,3,101);
searchGrid.gamma = 0;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0:0.001:0.05;  %ditto

% simulate data
count = 1;
data = table();
data.coh = [list{1}.list.coh; list{2}.list.coh];
data.rdkDir = [list{1}.list.rdkDir; list{2}.list.rdkDir];
data.trialType = [list{1}.list.trialType; list{2}.list.trialType];
data.prob = [50*ones(size(list{1}.list.coh)); 90*ones(size(list{2}.list.coh))];
data.choice = data.rdkDir;
for probN = 1:2
    idx = find(data.prob==probCons(probN) & data.trialType==0);
    if probN==1
        probThre = (1-lambda).*1./(1+exp(-beta.*(data.rdkDir(idx, 1).*data.coh(idx, 1)-alpha)));
    else
        aftereffect = -data.rdkDir(idx-1, 1)*0.01;
        probThre = (1-lambda).*1./(1+exp(-beta.*(data.rdkDir(idx, 1).*data.coh(idx, 1)+bias+aftereffect-alpha)));
    end
    rollChoice = rand(size(idx));
    idxR = idx(rollChoice<=probThre);
    idxL = idx(rollChoice>probThre);
    data.choice(idxR) = 1;
    data.choice(idxL) = 0;
end

%% fitting the simulated data
subN = 1;
trialN = 26;

figure
hold on
for probN = 1:length(probCons)
    % sort data
    idx = find(data.trialType==0 & data.prob==probCons(probN));
    dataT = data(idx, :);
    dataT.cohFit = dataT.coh.*dataT.rdkDir;
    cohLevels = unique(dataT.cohFit); % stimulus levels, negative is left
    dataT.cohIdx = zeros(size(dataT.cohFit));
    for ii = 1:length(cohLevels)
        dataT.cohIdx(dataT.cohFit==cohLevels(ii), 1) = ii;
    end
    numRight{probN}(subN, :) = accumarray(dataT.cohIdx, dataT.choice, [], @sum); % choice 1=right, 0=left
    outOfNum{probN}(subN, :) = trialN*ones(size(cohLevels)); % total trial numbers
    
    %Perform fit
    [paramsValues{subN, probN} LL{subN, probN} exitflag{subN, probN}] = PAL_PFML_Fit(cohLevels, numRight{probN}(subN, :)', ...
        outOfNum{probN}(subN, :)', searchGrid, paramsFree, PF);
    
    % plotting
    ProportionCorrectObserved=numRight{probN}(subN, :)./outOfNum{probN}(subN, :);
    StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
    ProportionCorrectModel = PF(paramsValues{subN, probN},StimLevelsFineGrain);
    
    f{probN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', colorProb(probN, :), 'linewidth', 2);
    plot(cohLevels, ProportionCorrectObserved,'.', 'color', colorProb(probN, :), 'markersize', 30);
end
set(gca, 'fontsize',16);
set(gca, 'Xtick',cohLevels);
axis([min(cohLevels) max(cohLevels) 0 1]);
xlabel('Stimulus Intensity');
ylabel('Proportion right');
legend([f{:}], probNames, 'box', 'off', 'location', 'northwest')
%
saveas(gcf, ['pfSimulated_halfAftrereffect.pdf'])