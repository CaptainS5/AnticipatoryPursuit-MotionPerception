%%%%%%%%% Create conditions table %%%%%%%%%
% script to create a condition table for anticipitory smooth pursuit RDK
% Xiuyun Wu - Nov 14 2018, slightly modifeid from Austin's version

% RDK options
directions = [1 -1]; % -1=left, 1=right % [0 180]; % 0 = RIGHT, 180 = LEFT
cohLevels = [0 0.04 0.08 0.12]; % dot coherence level [0...1]
trialsPerCohLevel =  [13 26 26 26]; % number of test trials per coherence level, [13 26 26 26]
rightProbability = 50/100; %probability of rightward movement for standard stimulus
NStandardTrials = 500;  % number of standard trials, 500
firstTrialN = 50; % the first n trials that should all be standard trials, 50
varNames = {'coh', 'rdkDir', 'trialType'}; % 1-R, 2-L

% number of trials for each type of stimulus
NRightStandardTrials = NStandardTrials * rightProbability; % number of rightward standard trials
NLeftStandardTrials = NStandardTrials - NRightStandardTrials; % number of leftward standard trials
NProbeTrials = length(directions) * sum(trialsPerCohLevel); % number of test trials
NTrials = NProbeTrials + NStandardTrials;  % total number of trials

% produce un-shuffled condition tables
% - table(:,1) = coherence level
% - table(:,2) = direction (0 = right, 180 = left)
% - table(:,3) = trial type (1 = standard trial, 0 = test trial)
probeList = zeros(NProbeTrials,3);  %condition table for test trials
standardList = zeros(NStandardTrials,3);   %condition table for standard trials
list = zeros(NTrials,3); % template for final condition table

% create probe condition table
for i = 1:NProbeTrials
    probeList(i,2) = directions(mod(i,length(directions))+1);
end

temp = [];
for ii = 1:length(cohLevels)
    temp = [temp; ones(2*trialsPerCohLevel(ii), 1)*cohLevels(ii)];
end
probeList(:,1) = temp;

% create standard condition table
for i = 1:NStandardTrials
    standardList(i,1) = 1;
    standardList(i,3) = 1;
    if i <= NRightStandardTrials
        standardList(i,2) = 1;
    else
        standardList(i,2) = -1;
    end
end

% shuffle condition tables
probeList(1:NProbeTrials,1:2) = probeList(randperm(NProbeTrials),1:2);
standardList(1:NStandardTrials,2) = standardList(randperm(NStandardTrials),2);

% combine standard and test trial tables to produce full condition table
probeRow = 1;
standardRow = 1;
for i = 1:NTrials
    if i<=NStandardTrials
        list(i,:) = standardList(standardRow,:);
        standardRow = standardRow + 1;
    else
        list(i,:) = probeList(probeRow,:);
        probeRow = probeRow + 1;
    end
end

% shuffle condition table, excluding first 50 rows
temp = list(firstTrialN+1:NTrials,:);
temp(1:NTrials-firstTrialN,:) = temp(randperm(NTrials-firstTrialN),:);
list = [list(1:firstTrialN,:); temp];

% look for consecutive probe trials, if found, swap row to random position
% in condition table until no consecutive probe trials exist
while sum(pairs(list)) > 0
    temp = pairs(list);
    for i = 1:length(temp)
        if temp(i) == 1
            row = ceil(rand(1)*(length(list)-firstTrialN))+firstTrialN; %find random row [50...length(list)] to swap to
            list([i row],:) = list([row i],:); %perform the swap
        end
    end
end

%% adding variable names and generate the final list table
list = mat2cell(list, size(list, 1), ones(1, 3));
list = table(list{:}, 'VariableNames', varNames);

save(['list', num2str(rightProbability*100), 'prob.mat'], 'list')
% list(list.trialType==0, :) = sortrows( list(list.trialType==0, :), 1, 'descend');
% save(['practiceList.mat'], 'list')
