%%%%%%%%% Create conditions table %%%%%%%%%
% script to create a condition table for anticipitory smooth pursuit RDK
% Xiuyun Wu - Jun 24 2019, modifeid for the control experiment
% RDK options
directions = [1 -1]; % -1=left, 1=right % [0 180]; % 0 = RIGHT, 180 = LEFT
cohLevelsTest = [0]; % dot coherence level [0...1]; probability of directions always half and half
cohLevelsStandard = [0.10 0.15]; % probability of directions changes across blocks
trialsPerCohLevelTest =  [50]; % number of test trials per coherence level per direction
trialsPerCohLevelStandard = [200 200]; % number of standard trials per coh level, all directions
rightProbability = 10/100; %probability of rightward movement for standard stimulus
firstTrialN = 50; % the first n trials that should all be standard trials, 50
varNames = {'coh', 'rdkDir', 'trialType'}; % 1-R, 2-L

% number of trials for each type of stimulus
NStandardTrials = sum(trialsPerCohLevelStandard);
NProbeTrials = length(directions) * sum(trialsPerCohLevelTest); % number of test trials
NTrials = NProbeTrials + NStandardTrials;  % total number of trials

% produce un-shuffled condition tables
% - table(:,1) = coherence level
% - table(:,2) = direction (0 = right, 180 = left)
% - table(:,3) = trial type (1 = standard trial, 0 = test trial)
probeList = zeros(NProbeTrials,3);  %condition table for test trials
standardList = ones(NStandardTrials,3);   %condition table for standard trials
list = zeros(NTrials,3); % template for final condition table

% create probe condition table
for ii = 1:NProbeTrials
    probeList(ii,2) = directions(mod(ii,length(directions))+1);
end

temp = [];
for ii = 1:length(cohLevelsTest)
    temp = [temp; ones(2*trialsPerCohLevelTest(ii), 1)*cohLevelsTest(ii)];
end
probeList(:,1) = temp;

% create standard condition table
for ii = 1:length(cohLevelsStandard)
    if ii==1
        idxStart = 1;
        idxL = round((1-rightProbability)*trialsPerCohLevelStandard(ii));
        idxEnd = trialsPerCohLevelStandard(ii);
    else
        idxStart = 1+sum(trialsPerCohLevelStandard(1:(ii-1)));
        idxL = (1-rightProbability)*trialsPerCohLevelStandard(ii)+sum(trialsPerCohLevelStandard(1:(ii-1)));
        idxEnd = sum(trialsPerCohLevelStandard(1:ii));
    end
    
    % coherence level
    standardList(idxStart:idxEnd,1) = cohLevelsStandard(ii)*ones(trialsPerCohLevelStandard(ii), 1);
    % direction
    standardList(idxStart:idxL,2) = -ones(round((1-rightProbability)*trialsPerCohLevelStandard(ii)), 1); % left
    standardList(idxL+1:idxEnd,2) = ones(round(rightProbability*trialsPerCohLevelStandard(ii)), 1); % right
end

% shuffle condition tables
probeList(1:NProbeTrials,1:2) = probeList(randperm(NProbeTrials),1:2);
standardList(1:NStandardTrials,1:2) = standardList(randperm(NStandardTrials),1:2);

% combine standard and test trial tables to produce full condition table
probeRow = 1;
standardRow = 1;
for ii = 1:NTrials
    if ii<=NStandardTrials
        list(ii,:) = standardList(standardRow,:);
        standardRow = standardRow + 1;
    else
        list(ii,:) = probeList(probeRow,:);
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
    for ii = 1:length(temp)
        if temp(ii) == 1
            row = ceil(rand(1)*(length(list)-firstTrialN))+firstTrialN; %find random row [50...length(list)] to swap to
            list([ii row],:) = list([row ii],:); %perform the swap
        end
    end
end

%% adding variable names and generate the final list table
list = mat2cell(list, size(list, 1), ones(1, 3));
list = table(list{:}, 'VariableNames', varNames);

save(['list', num2str(rightProbability*100), 'prob.mat'], 'list')
% list(list.trialType==0, :) = sortrows( list(list.trialType==0, :), 1, 'descend');
% save(['practiceList.mat'], 'list')
