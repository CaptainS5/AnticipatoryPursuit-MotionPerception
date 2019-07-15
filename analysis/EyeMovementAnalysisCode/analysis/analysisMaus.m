% to redo the analysis of AP and perception as in Maus et. al., 2015
initializeParas;
% initializePSE;
wMax = 50; % largest window size, how many trials before
binMax = 5; % number of bins

% recode the direction and perceptual choices
idxT = find(eyeTrialData.rdkDir==0); % 0 coherence coded as 0.5
eyeTrialData.rdkDir(idxT) = 0.5;
idxT = find(eyeTrialData.rdkDir==-1); % left coded as 0
eyeTrialData.rdkDir(idxT) = 0;
% idxT = find(eyeTrialData.choice==0); % left coded as -1
% eyeTrialData.choice(idxT) = -1;

% correct for mistakenly pressing the wrong key in standard trials
idxT = find(eyeTrialData.trialType==1); % standard trials, same perceptual choice as visual
eyeTrialData.choice(idxT) = eyeTrialData.rdkDir(idxT);

% also flip every direction... to collapse left and right probability
% blocks
for subN = 1:length(names)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        eyeTrialData.rdkDir(subN, :) = 1-eyeTrialData.rdkDir(subN, :);
        eyeTrialData.choice(subN, :) = 1-eyeTrialData.choice(subN, :); % flip left (0) and right (1)
        eyeTrialData.coh(subN, :) = -eyeTrialData.coh(subN, :);
        eyeTrialData.pursuit.APvelocityX(subN, :) = -eyeTrialData.pursuit.APvelocityX(subN, :);
        eyeTrialData.pursuit.APvelocityX_interpol(subN, :) = -eyeTrialData.pursuit.APvelocityX_interpol(subN, :);
    end
end

%% sort into bins and calculate correlation, also get AP values
for windowSize = 1:wMax
    if windowSize<binMax-1
        binMaxTemp = windowSize+1;
    else
        binMaxTemp = binMax;
    end
    
    for subN = 1:length(names)
        probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
        if probSub(1)<50
            probNameI = 1;
        else
            probNameI = 2;
        end
        dataM.probSubUnmerged(subN, 1:length(probSub)) = probSub;
        % NOTICE that in dataM everything else (later) is already merged
        % probability order, so 50, 70, and 90
        
        for probSubN = 1:size(probSub, 2)            
            probN = find(probCons==probSub(probSubN));
            % for saving the parameters, collapse left and right
            % probabilities, flip visual and perceptual directions
            if probSub(1)<50
                probNmerged = 4-probN;
            else
                probNmerged = probN-2;
            end
            
            idxP = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ); % perceptual trials
            idxPRand = idxP(randperm(length(idxP)));
            
            for pI = 1:length(idxP) % loop through perceptual trials
                % get the average direction value of previous trials
                % when right=1, left=0, based on perceptual response
                motionDprevious{windowSize, probNmerged}{subN}(pI, 1) = mean(eyeTrialData.choice(subN, idxP(pI)-windowSize:idxP(pI)-1)); % based on participant's choice
                %                 motionDprevious{windowSize, probNmerged}{subN}(pI, 1) = mean(eyeTrialData.rdkDir(subN, idxP(pI)-windowSize:idxP(pI)-1)); % based on visual motion
                idxPP = find(eyeTrialData.trialType(subN, idxP(pI)-windowSize:idxP(pI)-1)==0);
                perceptRate{windowSize, probNmerged}{subN}(pI, 1) = length(idxPP)/windowSize; % proportion of perceptual trials in previous trials
                
%                 % random previous motion...
%                 motionDprevious{windowSize, probNmerged}{subN}(pI, 1) = mean(eyeTrialData.choice(subN, idxPRand(pI)-windowSize:idxPRand(pI)-1)); % based on participant's choice
%                 %                 motionDprevious{windowSize, probNmerged}{subN}(pI, 1) = mean(eyeTrialData.rdkDir(subN, idxP(pI)-windowSize:idxP(pI)-1)); % based on visual motion
%                 idxPP = find(eyeTrialData.trialType(subN, idxPRand(pI)-windowSize:idxPRand(pI)-1)==0);
%                 perceptRate{windowSize, probNmerged}{subN}(pI, 1) = length(idxPP)/windowSize; % proportion of perceptual trials in previous trials
                                
                % when right=1, left=-1, based on perceptual response
                % %                 motionDprevious(pI, 1) = mean(eyeTrialData.choice(subN, idxP(pI)-windowSize:idxP(pI)-1)); % based on participant's choice
%                 motionDprevious(pI, 1) = mean(eyeTrialData.rdkDir(subN, idxP(pI)-windowSize:idxP(pI)-1)); % based on visual motion
                
                % get the value of the current trial 
                %             ap(pI, 1) = eyeTrialData.pursuit.APvelocityX(subN, idxP(pI));
            end
            medianAP = nanmedian(eyeTrialData.pursuit.APvelocityX_interpol(subN, idxP));
            minPreviousD = min(motionDprevious{windowSize, probNmerged}{subN});
            maxPreviousD = max(motionDprevious{windowSize, probNmerged}{subN});
            binDis = (maxPreviousD-minPreviousD)/binMaxTemp;
            previousDrange{windowSize, probNmerged}(subN, 1:2) = [minPreviousD maxPreviousD];
            
            % find the idx for each bin
            for binN = 1:binMaxTemp
                % sort them into bins and save the idx, first get the idx
                % range according to mean direction
                if binN==1
                    idxTemp = find(motionDprevious{windowSize, probNmerged}{subN} >= minPreviousD+binDis*(binN-1) & motionDprevious{windowSize, probNmerged}{subN} <= minPreviousD+binDis*binN);
                else
                    idxTemp = find(motionDprevious{windowSize, probNmerged}{subN} > minPreviousD+binDis*(binN-1) & motionDprevious{windowSize, probNmerged}{subN} <= minPreviousD+binDis*binN);
                end
%                 % from "lefter" previous mean direction to "righter"
%                 % sort the orders to be from left most to right most
%                 [motionDpreviousTempSorted idxTempSorted] = sort(motionDprevious(idxTemp));   
%                 
                idxBins{windowSize, probNmerged}{subN, binN} = idxP(idxTemp);
                previousDbins{windowSize, probNmerged}(subN, binN) = mean(motionDprevious{windowSize, probNmerged}{subN}(idxTemp));
%             end
%             
%             for binN = 1:binMaxTemp
%                 % first check if trial numbers in the bin is okay...
%                 if isempty(idxBins{windowSize, probNmerged}{subN, binN}) || length(idxBins{windowSize, probNmerged}{subN, binN}<=5)
%                     if binN==1
%                         if length(idxBins{windowSize, probNmerged}{subN, binN+1}) > 10
%                     elseif binN==binMaxTemp
%                     else % "borrow" trials from before and after this bin... 
%                     end
%                 end
                
                %% perception
%                 % sort coh idx for accumarray
                data.cohFit = eyeTrialData.coh(subN, idxBins{windowSize, probNmerged}{subN, binN})';
                data.choice = eyeTrialData.choice(subN, idxBins{windowSize, probNmerged}{subN, binN})';
%                 cohLevels = unique(data.cohFit); % stimulus levels, negative is left
%                 data.cohIdx = zeros(size(data.cohFit));
%                 for cohN = 1:length(cohLevels)
%                     data.cohIdx(data.cohFit==cohLevels(cohN), 1) = cohN;
%                 end
%                 dataM.percept.cohLevels{windowSize, probNmerged}{binN, subN} = cohLevels;
%                 
%                 %% perception
%                 dataM.percept.numRight{windowSize, probNmerged}{binN, subN} = accumarray(data.cohIdx, data.choice, [], @sum); % choice 1=right, 0=left
%                 dataM.percept.outOfNum{windowSize, probNmerged}{binN, subN} = accumarray(data.cohIdx, data.choice, [], @numel); % total trial numbers
%                 dataM.percept.ProportionCorrectObserved{windowSize, probNmerged}{binN, subN} = ...
%                     dataM.percept.numRight{windowSize, probNmerged}{binN, subN}./ ...
%                     dataM.percept.outOfNum{windowSize, probNmerged}{binN, subN};
                
                dataM.percept.propotionMoreRight{windowSize, probNmerged}(subN, binN) = ...
                    (length(find(data.choice==1))-length(find(data.cohFit>0))-length(find(data.cohFit==0))/2)/length(data.cohFit); 
                % proportion of perceiving right - proportion of rightward
                % motion
                
                %% AP
                % generate binary AP
                dataM.AP.binary{windowSize, probNmerged}{binN, subN} = eyeTrialData.pursuit.APvelocityX_interpol(subN, idxBins{windowSize, probNmerged}{subN, binN})';
                idxTL = find(dataM.AP.binary{windowSize, probNmerged}{binN, subN}<=medianAP);
                idxTR = find(dataM.AP.binary{windowSize, probNmerged}{binN, subN}>medianAP);
                dataM.AP.binary{windowSize, probNmerged}{binN, subN}(idxTL) = 0; % "left"
                dataM.AP.binary{windowSize, probNmerged}{binN, subN}(idxTR) = 1; % "right"
                
                dataM.AP.numRight{windowSize, probNmerged}(subN, binN) = length(find(dataM.AP.binary{windowSize, probNmerged}{binN, subN}==1)); % choice 1=right, 0=left
                dataM.AP.outOfNum{windowSize, probNmerged}(subN, binN) = length(dataM.AP.binary{windowSize, probNmerged}{binN, subN}); % total trial numbers
                dataM.AP.proportionRight{windowSize, probNmerged}(subN, binN) = ...
                    dataM.AP.numRight{windowSize, probNmerged}(subN, binN)./ ...
                    dataM.AP.outOfNum{windowSize, probNmerged}(subN, binN);
            end
        end
    end
    
    % calculte correlations
    for probNmerged = 1:3
        % perception
        idxNaN = find(isnan(dataM.percept.propotionMoreRight{windowSize, probNmerged}(:)));
        xD = previousDbins{windowSize, probNmerged}(:);
        xD(idxNaN) = [];
        yP = dataM.percept.propotionMoreRight{windowSize, probNmerged}(:);
        yP(idxNaN) = [];
        [corrM.percept.rho(windowSize, probNmerged) corrM.percept.pValue(windowSize, probNmerged)] = corr(xD, ...
            yP);
        % AP
        % first get rid of NaN values...
        idxNaN = find(isnan(dataM.AP.proportionRight{windowSize, probNmerged}(:)));
        xD = previousDbins{windowSize, probNmerged}(:);
        xD(idxNaN) = [];
        yAP = dataM.AP.proportionRight{windowSize, probNmerged}(:);
        yAP(idxNaN) = [];
        [corrM.AP.rho(windowSize, probNmerged) corrM.AP.pValue(windowSize, probNmerged)] = corr(xD, ...
            yAP);
        
        % calculate the sum of differences between bins... might be more
        % reliable than correlation?
        % perception
        diffP = diff(dataM.percept.propotionMoreRight{windowSize, probNmerged});
        sumDiff.percept.sub{windowSize}(:, probNmerged) = nansum(diffP, 2);
        sumDiff.percept.mean(windowSize, probNmerged) = nanmean(nansum(diffP, 2));
        % AP
        % first get rid of NaN values...
        diffAP = diff(dataM.AP.proportionRight{windowSize, probNmerged});
        sumDiff.AP.sub{windowSize}(:, probNmerged) = nansum(diffAP, 2);
        sumDiff.AP.mean(windowSize, probNmerged) = nanmean(nansum(diffAP, 2));        
    end
end
save(['percept_AP_binMax', num2str(binMax)], 'idxBins', 'previousDbins', ...
    'previousDrange', 'motionDprevious', 'perceptRate', 'dataM', 'corrM', 'sumDiff')
% % again, remember that in dataM everything is merged probability blocks