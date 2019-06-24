function [numRight outOfNum stimLevelOut conOut] = weightedProbPF(con, stimLevel, data)
% to be used in psychometric function fitting using palamedes
% Input:
% --cons: the condition matrix; x will be sorted by the unique row in cons,
% and then the sum of weighted probabilities in all cons will be calculated
% --stimLevels: stimulus intensity level, x axis in psychometric curves
% --data: 0 or 1, 1 will be treated as the "correct" response
%
% Output:
% from the weighted probability, generate the numbers to be used in the
% fitting
% --numRight: the approximated number of "correct" response; each row is one
% condition specified in conOut, and each column is one cohLevel
% --outOfNum: the total trial number; numRight/outOfNum equals the calculated
% weighted probability...
% --stimLevelsOut: the coherence level for each column
% --conOut: the condition for each row

% first, sort the cons
conOut = unique(con, 'rows');
stimLevelOut = unique(stimLevel);

for conI = 1:size(conOut, 1) % loop through each specific set of data
    idxCon = find(all(repmat(conOut(conI, :), size(con, 1), 1)==con, 2)); % all trials of the specific condition
    dataT = data(idxCon);
    stimLevelT = stimLevel(idxCon);
    
    stimLevelCon{conI} = unique(stimLevel(idxCon)); % all stimulus levels of this condition
    stimIdx = zeros(size(dataT));
    for stimI = 1:length(stimLevelCon{conI})
        stimIdx(stimLevelT==stimLevelCon{conI}(stimI), 1) = stimI;
    end % code the stimulus levels to be integers
    
    numRightCons{conI} = accumarray(stimIdx, dataT, [], @sum)'; % choice 1=right, 0=left
    outOfNumCons{conI} = accumarray(stimIdx, dataT, [], @numel)'; % total trial numbers
    proportionCons(conI) = length(dataT)/length(data);
end

% then generate the numbers for each stimulus level
% initialize the matrices
probRight = zeros(size(stimLevelOut)); % will be added at each stimulus level
outOfNum = 100*ones(size(stimLevelOut)); % just a random "all trials" number...
for stimI = 1:length(stimLevelOut)
    for conI = 1:size(conOut, 1)
        for stimConI = 1:length(stimLevelCon{conI})
            if ~isempty(find(stimLevelOut==stimLevelCon{conI}(stimConI)))
                probRight(stimI) = probRight(stimI)+(numRightCons{conI}(stimConI)/outOfNumCons{conI}(stimConI))*proportionCons(conI);
            end
        end
    end
end
numRight = round(probRight.*outOfNum);
