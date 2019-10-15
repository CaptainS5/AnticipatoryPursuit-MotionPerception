%% tree plots of the short-term trial history... priming effects
% not including trials preceded by perceptual trials (n-2 might be
% perceptual trial)
% for both eye movements and perception
% for perception, the "magnitude" is choice minus motion coherence
initializeParas;
individualPlots = 1;
averagedPlots = 0;
eyeTrialData.choice(eyeTrialData.choice==0) = -1; % left is -1, right is 1

for subN = 1:size(names, 2)
    probSub = unique(eyeTrialData.prob(subN, :));
    if probSub(1)<50
        probNameSub = probNames{1};
    else
        probNameSub = probNames{2};
    end
    for probN = 1:2
        [, dataIdx] = find(eyeTrialData.prob(subN, :)==probSub(probN) & eyeTrialData.errorStatus(subN, :)==0);
        [, perceptualIdx] = find(eyeTrialData.trialType(subN, dataIdx)==0); % locate perceptual trials
        % make sure that all preceding trials are context trials...
        deleteI{subN} = [];
        for pI = 1:length(perceptualIdx)
            dataIdxT = eyeTrialData.trialIdx(subN, dataIdx);
            dataTypeT = eyeTrialData.trialType(subN, dataIdx);
            twoBackI = find(dataIdxT==(dataIdxT(perceptualIdx(pI))-2) );
            if ~isempty(twoBackI) && dataTypeT(twoBackI)==0
                deleteI{subN} = [deleteI{subN}; pI];
            end
        end
        perceptualIdx(deleteI{subN}) = [];
        
        % anticipatory pursuit
        [lastP lastPstd idxOutPL{probN, subN}] = splitNode(eyeTrialData.trialIdx(subN, dataIdx), eyeTrialData.rdkDir(subN, dataIdx), [-1 1], eyeTrialData.pursuit.APvelocityX(subN, dataIdx), perceptualIdx, 1); % the last two nodes in the tree plot
        [firstP(1:2, :) firstPstd(1:2, :) idxOutPFl{probN, subN}]= splitNode(eyeTrialData.trialIdx(subN, dataIdx), eyeTrialData.rdkDir(subN, dataIdx), [-1 1], eyeTrialData.pursuit.APvelocityX(subN, dataIdx), idxOutPL{probN, subN}{1}, 2); 
        [firstP(3:4, :) firstPstd(3:4, :) idxOutPFr{probN, subN}]= splitNode(eyeTrialData.trialIdx(subN, dataIdx), eyeTrialData.rdkDir(subN, dataIdx), [-1 1], eyeTrialData.pursuit.APvelocityX(subN, dataIdx), idxOutPL{probN, subN}{2}, 2); 
        treeNodesP{probN, 1}(subN, 1:4) = firstP(1:4, 1)'; % the first column, four nodes, n-2, diff-diff, same-diff, diff-same, same-same
        treeNodesP{probN, 2}(subN, 1:2) = lastP(1:2, 1)'; % the second column, two nodes, n-1, diff, same
        treeNodesP{probN, 3}(subN, 1) = lastP(1, 2); % the third column, 1 node, mean of all
        
        treeNodesPstd{probN, 1}(subN, 1:4) = firstPstd(1:4, 1)'; % the first column, four nodes, n-2, diff-diff, same-diff, diff-same, same-same
        treeNodesPstd{probN, 2}(subN, 1:2) = lastPstd(1:2, 1)'; % the second column, two nodes, n-1, diff, same
        treeNodesPstd{probN, 3}(subN, 1) = lastPstd(1, 2); % the third column, 1 node, mean of all
        
        [nodesPmeanSub{probN, subN}] = ...
            sortForPlot({treeNodesP{probN, 1}(subN, :) treeNodesP{probN, 2}(subN, :) treeNodesP{probN, 3}(subN, :)}, 1, 2);
        [nodesPstdSub{probN, subN}] = ...
            sortForPlot({treeNodesPstd{probN, 1}(subN, :) treeNodesPstd{probN, 2}(subN, :) treeNodesPstd{probN, 3}(subN, :)}, 1, 2);% pursuit
        
        % perception
        [lastPer lastPerstd idxOutPerL{probN, subN}] = splitNode(eyeTrialData.trialIdx(subN, dataIdx), eyeTrialData.rdkDir(subN, dataIdx), [-1 1], eyeTrialData.choice(subN, dataIdx)-eyeTrialData.coh(subN, dataIdx), perceptualIdx, 1); % the last two nodes in the tree plot
        [firstPer(1:2, :) firstPerstd(1:2, :) idxOutPerFl{probN, subN}]= splitNode(eyeTrialData.trialIdx(subN, dataIdx), eyeTrialData.rdkDir(subN, dataIdx), [-1 1], eyeTrialData.choice(subN, dataIdx)-eyeTrialData.coh(subN, dataIdx), idxOutPerL{probN, subN}{1}, 2); 
        [firstPer(3:4, :) firstPerstd(3:4, :) idxOutPerFr{probN, subN}]= splitNode(eyeTrialData.trialIdx(subN, dataIdx), eyeTrialData.rdkDir(subN, dataIdx), [-1 1], eyeTrialData.choice(subN, dataIdx)-eyeTrialData.coh(subN, dataIdx), idxOutPerL{probN, subN}{2}, 2); 
        treeNodesPer{probN, 1}(subN, 1:4) = firstPer(1:4, 1)'; % the first column, four nodes, n-2, diff-diff, same-diff, diff-same, same-same
        treeNodesPer{probN, 2}(subN, 1:2) = lastPer(1:2, 1)'; % the second column, two nodes, n-1, diff, same
        treeNodesPer{probN, 3}(subN, 1) = lastPer(1, 2); % the third column, 1 node, mean of all
        
        treeNodesPerstd{probN, 1}(subN, 1:4) = firstPerstd(1:4, 1)'; % the first column, four nodes, n-2, diff-diff, same-diff, diff-same, same-same
        treeNodesPerstd{probN, 2}(subN, 1:2) = lastPerstd(1:2, 1)'; % the second column, two nodes, n-1, diff, same
        treeNodesPerstd{probN, 3}(subN, 1) = lastPerstd(1, 2); % the third column, 1 node, mean of all
        
        [nodesPermeanSub{probN, subN}] = ...
            sortForPlot({treeNodesPer{probN, 1}(subN, :) treeNodesPer{probN, 2}(subN, :) treeNodesPer{probN, 3}(subN, :)}, 1, 2);
        [nodesPerstdSub{probN, subN}] = ...
            sortForPlot({treeNodesPerstd{probN, 1}(subN, :) treeNodesPerstd{probN, 2}(subN, :) treeNodesPerstd{probN, 3}(subN, :)}, 1, 2);% pursuit
    end
    
    %% plots of individual data
    if individualPlots==1
        cd(perceptFolder)
        drawPlot(subN, nodesPermeanSub, nodesPerstdSub, 'Trial', 'Choice-coh', probNameSub, 'treePlotPerception_Exp2_', names{subN}, [])
        % pursuit plots
        cd(pursuitFolder)
        % anticipatory pursuit
        drawPlot(subN, nodesPmeanSub, nodesPstdSub, 'Trial', 'Anticipatory pursuit velocity (deg/s)', probNameSub, 'treePlotPursuit_Exp2_', names{subN}, [])
%         close all
    end
end

% generate the lines for averaged data
% for probN = 1:size(probCons, 2)
%     [nodesPmean{probN, 1} nodesPste{probN, 1}] = sortForPlot({treeNodesP{probN, 1} treeNodesP{probN, 2} treeNodesP{probN, 3}}, sqrt(size(names, 2)), 2); % torsion
% end

%% averaged plots
if averagedPlots==1
    % pursuit plots
    cd(pursuitFolder)
    % anticipatory pursuit
    drawPlot(1, nodesPmean, nodesPste, 'Trial', 'Anticipatory pursuit velocity (deg/s)', {'Left' 'Right'}, 'trialHistory_anticipatoryP_', 'Exp3_all', [])
end


%% functions used
function [outputMean outputStd idxOut] = splitNode(trialIdx, x, xCons, y, validI, n)
% calculate mean of all trials, and mean of all trials splitted by moving
% direction of the previous trial (if possible)
% Input:
%   trialIdx-to trace back trials
%   x-split based on values in x
% 	xCon-values for each condition to split
%   y-values to calculate mean
%   validI-only use y from these trials; but can search previous trials in
%   the whole table...
%   n-to split by the n_th trial back
% Output:
%   output-length(xCons) x 2 matrix; the first column is the mean of splitted trials;
%       the second column is the mean of all trials (should be identical numbers)
%   idxOut-each cell contains the idx of each split condition
outputMean(:, 2) = repmat(nanmean(y(validI)), length(xCons), 1);
outputStd(:, 2) = repmat(nanstd(y(validI)), length(xCons), 1);

tempY = cell(1, length(xCons));
idxOut = cell(1, length(xCons));
for idxT = 1:length(validI) % loop through all trials
    nBackI = find(trialIdx==(trialIdx(validI(idxT))-n));
    if nBackI % sort by the n-back trial
        conI = find(xCons==x(nBackI)); % left/right
        if conI
            tempY{conI} = [tempY{conI}; y(validI(idxT))];
            idxOut{conI} = [idxOut{conI}; validI(idxT)];
        end
    end    
end

for conI = 1:length(xCons)
    outputMean(conI, 1) = nanmean(tempY{conI});
    outputStd(conI, 1) = nanstd(tempY{conI});
end
end

function [nodesMean nodesSte] = sortForPlot(treeNodes, sqrtN, n) % mainly for average plot
% --treeNodes is the outputMean calculated by splitNode
% --sqrtN is used to calculate standard error, N equals number of
%   participants
% --n is how many conditions a node is splitted by
nodesMean(1:2*n, 1) = mean(treeNodes{1}, 1)';
nodesSte(1:2*n, 1) = std(treeNodes{1}, 0, 1)'/sqrtN;

meanTemp = repmat(mean(treeNodes{2}, 1), 2, 1);
nodesMean(1:2*n, 2) = meanTemp(:);
stdTemp = repmat(std(treeNodes{2}, 0, 1), 2, 1);
nodesSte(1:2*n, 2) = stdTemp(:)/sqrtN;

nodesMean(1:2*n, 3) = repmat(mean(treeNodes{3}, 1), 4, 1);
nodesSte(1:2*n, 3) = repmat(std(treeNodes{3}, 0, 1), 4, 1)/sqrtN;
end

function drawPlot(subN, meanY, steY, xlabelName, ylabelName, subConNames, pdfName, subName, dirConName)
% --subN is the index of the current participant; use 1 for average across
%   participants
% --meanY and steY should be sorted by the previous functions...
figure
for subConI = 1:length(subConNames)
    subplot(length(subConNames), 1, subConI)
    hold on
        % left, negative--dashed and circle dot; right, positive--solid line and dot
        p{1} = errorbar([1 2 3], meanY{subConI, subN}(1, :)', steY{subConI, subN}(1, :)', '--ok');
        errorbar([1 2], meanY{subConI, subN}(2, 1:2)', steY{subConI, subN}(2, 1:2)', '-k')
        errorbar([1 2], meanY{subConI, subN}(3, 1:2)', steY{subConI, subN}(3, 1:2)', '--ok')
        p{2} = errorbar([1 2 3], meanY{subConI, subN}(4, :)', steY{subConI, subN}(4, :)', '-ok', 'MarkerFaceColor', 'k'); % all same, positive
        plot([1], meanY{subConI, subN}(2, 1)', 'ok', 'MarkerFaceColor', 'k')

    xlim([0.5 3.5])
%     ylim([-0.5 0.8])
    title([subConNames(subConI)])
    legend([p{:}], {'Left (negative)' 'Right (positive)'}, 'location', 'best')
    set(gca, 'XTick', [1, 2, 3], 'XTickLabels', {'n-2', 'n-1', 'n'})
    xlabel(xlabelName)
    ylabel(ylabelName)
    %     ylim([-1 0.6])
end
saveas(gca, [pdfName subName dirConName '.pdf'])
end