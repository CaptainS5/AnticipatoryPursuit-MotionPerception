%%%%%%%%% Create conditions table %%%%%%%%%
% script to create a condition table for anticipitory smooth pursuit RDK
% Austin Rothwell - June 10 2016

%RDK options
directions = [0 180]; % 0 = RIGHT, 180 = LEFT
cohLevels = [0 0.05 0.15]; % dot coherence level [0...1]
trialsPerCohLevel = [10 20 20]; % number of test trials per coherence level
rightProbability = 62.5/100; %probability of rightward movement for standard stimulus
NStandardTrials = 500;  % number of standard trials

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
for i = 1:NProbeTrials; probeList(i,2) = directions(mod(i,length(directions))+1); end 
one = ones(20,1)*cohLevels(1);
two = ones(40,1)*cohLevels(2);
three = ones(40,1)*cohLevels(3);
probeList(:,1) = [one; two; three];

% create standard condition table
for i = 1:NStandardTrials
    standardList(i,1) = 1;
    standardList(i,3) = 1;
    if i <= NRightStandardTrials
        standardList(i,2) = 0;
    else
        standardList(i,2) = 180;
    end
end

% shuffle condition tables
probeList(1:NProbeTrials,1:2) = probeList(randperm(NProbeTrials),1:2);
standardList(1:NStandardTrials,2) = standardList(randperm(NStandardTrials),2);

% combine standard and test trial tables to produce full condition table
probeRow = 1;
standardRow = 1;
for i = 1:NTrials
    if i<=500
        list(i,:) = standardList(standardRow,:);
        standardRow = standardRow + 1;
    else
        list(i,:) = probeList(probeRow,:);
        probeRow = probeRow + 1;
    end
end

% shuffle condition table, excluding first 50 rows
temp = list(51:NTrials,:);
temp(1:NTrials-50,:) = temp(randperm(NTrials-50),:);
list = [list(1:50,:); temp];

% look for consecutive probe trials, if found, swap row to random position
% in condition table until no consecutive probe trials exist
while sum(pairs(list)) > 0 
    temp = pairs(list);
    for i = 1:length(temp)
        if temp(i) == 1
            row = ceil(rand(1)*(length(list)-50))+50; %find random row [50...length(list)] to swap to
            list([i row],:) = list([row i],:); %perform the swap
        end
    end
end
