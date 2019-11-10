%% tree plots of the short-term trial history... priming effects, Exp1
% not including trials preceded by perceptual trials (n-2 might be
% perceptual trial)
% for both eye movements and perception
% for perception, the "magnitude" is choice minus motion coherence
initializeParas;
individualPlots = 1;
averagedPlots = 1;
eyeTrialData.choice(eyeTrialData.choice==0) = -1; % left is -1, right is 1
% flip every direction... to collapse left and right probability blocks
for subN = 1:length(names)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50        
        eyeTrialData.choice(subN, :) = -eyeTrialData.choice(subN, :); % flip left (-1) and right (1)
        eyeTrialData.coh(subN, :) = -eyeTrialData.coh(subN, :);
        eyeTrialData.rdkDir(subN, :) = -eyeTrialData.rdkDir(subN, :);
        eyeTrialData.pursuit.APvelocityX(subN, :) = -eyeTrialData.pursuit.APvelocityX(subN, :);
    end
end
probNames{1} = fliplr(probNames{1});

for subN = 1:size(names, 2)
    probSub = unique(eyeTrialData.prob(subN, :));
    if probSub(1)<50
        probSub = fliplr(probSub);
        probNameSub = probNames{1};
    else
        probNameSub = probNames{2};
    end
    for probN = 1:size(probNameSub, 2)
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
        drawPlot(subN, nodesPermeanSub, nodesPerstdSub, 'Trial', 'Choice-coh', probNameSub, 'treePlotPerception_Exp1_bootstrap_', names{subN}, [])
        % pursuit plots
        cd(pursuitFolder)
        % anticipatory pursuit
        drawPlot(subN, nodesPmeanSub, nodesPstdSub, 'Trial', 'Anticipatory pursuit velocity (deg/s)', probNameSub, 'treePlotPursuit_Exp1_bootstrap_', names{subN}, [])
%         close all
    end
end

%% generate the lines for averaged data
for probN = 1:size(probNameSub, 2)
    [nodesPmean{probN, 1} nodesPste{probN, 1}] = sortForPlot({treeNodesP{probN, 1} treeNodesP{probN, 2} treeNodesP{probN, 3}}, sqrt(size(names, 2)), 2); % asp
    [nodesPermean{probN, 1} nodesPerste{probN, 1}] = sortForPlot({treeNodesPer{probN, 1} treeNodesPer{probN, 2} treeNodesPer{probN, 3}}, sqrt(size(names, 2)), 2); % perception
end

%% averaged plots
if averagedPlots==1
    % perception plots
    cd(perceptFolder)
    drawPlot(1, nodesPermean, nodesPerste, 'Trial', 'Choice-coh', probNames{2}, 'treePlotPerception_Exp1_bootstrap_', 'all', [])
    
    % pursuit plots
    cd(pursuitFolder)
    % anticipatory pursuit
    drawPlot(1, nodesPmean, nodesPste, 'Trial', 'Anticipatory pursuit velocity (deg/s)', probNames{2}, 'treePlotPursuit_Exp1_bootstrap_', 'all', [])
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

% also bootstrap the first one
lastY = y(validI); % the original vector
sampleSize = length(lastY);
resampleIdx = randi(sampleSize, [sampleSize, 1000]);
newSamples = lastY(resampleIdx);
bsMeanAll = nanmean(newSamples);
outputMean(:, 2) = repmat(nanmean(bsMeanAll), length(xCons), 1);
outputStd(:, 2) = repmat(nanstd(bsMeanAll), length(xCons), 1);

% % directly compute
% outputMean(:, 2) = repmat(nanmean(y(validI)), length(xCons), 1);
% outputStd(:, 2) = repmat(nanstd(y(validI)), length(xCons), 1);

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

% bootstrapping! do 1000 times
for conI = 1:length(xCons)
    if ~isempty(tempY{conI})
        sampleSize = length(tempY{conI});
        resampleIdx = randi(sampleSize, [sampleSize, 1000]);
        newSamples = tempY{conI}(resampleIdx);
        bsMeanAll = nanmean(newSamples);
        %     % plot the distribution, show the calculated mean
        %     figure
        %     histogram(bsMeanAll)
        %     title(['mean=', num2str(nanmean(bsMeanAll)), ' median=', num2str(nanmedian(bsMeanAll))])
        %     pause
        %     close
        outputMean(conI, 1) = nanmean(bsMeanAll);
        outputStd(conI, 1) = nanstd(bsMeanAll);
    else
        outputMean(conI, 1) = NaN;
        outputStd(conI, 1) = NaN;
    end
end

% % directly compute the mean
% for conI = 1:length(xCons)
%     outputMean(conI, 1) = nanmean(tempY{conI});
%     outputStd(conI, 1) = nanstd(tempY{conI});
% end
end

function [nodesMean nodesSte] = sortForPlot(treeNodes, sqrtN, n) % mainly for average plot
% --treeNodes is the outputMean calculated by splitNode
% --sqrtN is used to calculate standard error, N equals number of
%   participants
% --n is how many conditions a node is splitted by
nodesMean(1:2*n, 1) = nanmean(treeNodes{1}, 1)';
nodesSte(1:2*n, 1) = nanstd(treeNodes{1}, 0, 1)'/sqrtN;

meanTemp = repmat(nanmean(treeNodes{2}, 1), 2, 1);
nodesMean(1:2*n, 2) = meanTemp(:);
stdTemp = repmat(nanstd(treeNodes{2}, 0, 1), 2, 1);
nodesSte(1:2*n, 2) = stdTemp(:)/sqrtN;

nodesMean(1:2*n, 3) = repmat(nanmean(treeNodes{3}, 1), 4, 1);
nodesSte(1:2*n, 3) = repmat(nanstd(treeNodes{3}, 0, 1), 4, 1)/sqrtN;
end

function drawPlot(subN, meanY, steY, xlabelName, ylabelName, subConNames, pdfName, subName, dirConName)
% --subN is the index of the current participant; use 1 for average across
%   participants
% --meanY and steY should be sorted by the previous functions...
figure
% find a proper range for all subplots
YUpall = [];
YDownall = [];
for subConI = 1:length(subConNames)
    YUpall = [YUpall; meanY{subConI, subN} + steY{subConI, subN}];
    YDownall = [YDownall; meanY{subConI, subN} - steY{subConI, subN}];
end
rangeY = [min(YDownall(:)) max(YUpall(:))];

for subConI = 1:length(subConNames)
    subplot(1, length(subConNames), subConI)
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
    ylim(rangeY)
end
saveas(gca, [pdfName subName dirConName '.pdf'])
end