% to redo the analysis of AP and perception as in Maus et. al., 2015
initializeParas;
initializePSE;
wMax = 50; % largest window size, how many trials before
binMax = 3; % number of bins

% recode the direction and perceptual choices
idxT = find(eyeTrialData.rdkDir==0); % 0 coherence coded as 0.5
eyeTrialData.rdkDir(idxT) = 0.5;
idxT = find(eyeTrialData.rdkDir==-1); % left coded as 0
eyeTrialData.rdkDir(idxT) = 0;

% correct for mistakenly pressing the wrong key in standard trials
idxT = find(eyeTrialData.trialType==1); % standard trials, same perceptual choice as visual
eyeTrialData.choice(idxT) = eyeTrialData.rdkDir(idxT);

% also flip every direction... to collapse left and right probability
% blocks
for subN = 1:length(names)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50        
        eyeTrialData.choice(subN, :) = 1-eyeTrialData.choice(subN, :); % flip left (0) and right (1)
        eyeTrialData.coh(subN, :) = -eyeTrialData.coh(subN, :);
        eyeTrialData.pursuit.APvelocityX(subN, :) = -eyeTrialData.pursuit.APvelocityX(subN, :);
        eyeTrialData.pursuit.APvelocityX_interpol(subN, :) = -eyeTrialData.pursuit.APvelocityX_interpol(subN, :);
    end
end

%% sort into bins and fit psychometric functions for perception, also get AP values
for windowSize = 1:wMax

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
            clear motionDperceived
            
            probN = find(probCons==probSub(probSubN));
            % for saving the parameters, collapse left and right
            % probabilities, flip visual and perceptual directions
            if probSub(1)<50
                probNmerged = 4-probN;
            else
                probNmerged = probN-2;
            end
            
            idxP = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ); % perceptual trials
            for pI = 1:length(idxP) % loop through perceptual trials
                % get the average direction value of previous trials
                % always right=1, left=0, based on perceptual response
                motionDperceived(pI, 1) = sum(eyeTrialData.choice(subN, idxP(pI)-windowSize:idxP(pI)-1))/windowSize; % based on participant's choice
                % get the value of the current trial
                %             ap(pI, 1) = eyeTrialData.pursuit.APvelocityX(subN, idxP(pI));
            end
            medianAP = nanmedian(eyeTrialData.pursuit.APvelocityX_interpol(subN, idxP));
            
            % get the idx for each bin and average previous motion ready
            [motionDPerceivedSorted idxSort] = sort(motionDperceived);
            if windowSize<binMax-1
                binMaxTemp = windowSize+1;
            else
                binMaxTemp = binMax;
            end
            wholeParts = floor(length(idxP)/binMaxTemp);
            leftOvers = mod(length(idxP), binMaxTemp);
            
            % fit the psychometric curves for each bin
            for binN = 1:binMaxTemp
                % sort them into bins and save the idx, first get the idx
                % range according to bin numbers
                if binN<=leftOvers
                    binIdxStart = wholeParts*(binN-1)+binN;
                    binIdxEnd = binIdxStart+wholeParts;
                else
                    binIdxStart = wholeParts*(binN-1)+leftOvers+1;
                    binIdxEnd = binIdxStart+wholeParts-1;
                end
                % from "lefter" previous mean direction to "righter"
                idxBins{windowSize, probNmerged}{subN, binN} = idxP(idxSort(binIdxStart:binIdxEnd));
                previousDbins{windowSize, probNmerged}(subN, binN) = mean(motionDPerceivedSorted(binIdxStart:binIdxEnd));
                
                % sort coh idx for accumarray
                data.cohFit = eyeTrialData.coh(subN, idxBins{windowSize, probNmerged}{subN, binN})';
                data.choice = eyeTrialData.choice(subN, idxBins{windowSize, probNmerged}{subN, binN})';
                data.AP_interpol = eyeTrialData.pursuit.APvelocityX_interpol(subN, idxBins{windowSize, probNmerged}{subN, binN})';
                cohLevels = unique(data.cohFit); % stimulus levels, negative is left
                data.cohIdx = zeros(size(data.cohFit));
                for cohN = 1:length(cohLevels)
                    data.cohIdx(data.cohFit==cohLevels(cohN), 1) = cohN;
                end
                
                %% perception             
                dataM.percept.numRight{windowSize, probNmerged}{binN}(subN, :) = accumarray(data.cohIdx, data.choice, [], @sum); % choice 1=right, 0=left
                dataM.percept.outOfNum{windowSize, probNmerged}{binN}(subN, :) = accumarray(data.cohIdx, data.choice, [], @numel); % total trial numbers
                dataM.percept.ProportionCorrectObserved{windowSize, probNmerged}{binN}(subN, :) = ...
                    dataM.percept.numRight{windowSize, probNmerged}{binN}(subN, :)./ ...
                    dataM.percept.outOfNum{windowSize, probNmerged}{binN}(subN, :);
                
                %Perform fit
                [paramsValues{windowSize, probNmerged}{subN, binN} LL exitflag] ...
                    = PAL_PFML_Fit(cohLevels, dataM.percept.numRight{windowSize, probNmerged}{binN}(subN, :)', ...
                    dataM.percept.outOfNum{windowSize, probNmerged}{binN}(subN, :)', searchGrid, paramsFree, PF);
                if probSub(1)<50 % flip according to the left/right probabilities--all "right more" probabilities
                    paramsValues{windowSize, probNmerged}{subN, binN}(1) = -paramsValues{windowSize, probNmerged}{subN, binN}(1); % also flip PSE
                end

                % saving parameters
                dataM.percept.alpha{windowSize, probNmerged}(subN, binN) = paramsValues{windowSize, probNmerged}{subN, binN}(1); % threshold, or PSE
                dataM.percept.beta{windowSize, probNmerged}(subN, binN) = paramsValues{windowSize, probNmerged}{subN, binN}(2); % slope
                dataM.percept.gamma{windowSize, probNmerged}(subN, binN) = paramsValues{windowSize, probNmerged}{subN, binN}(3); % guess rate, or baseline
                dataM.percept.lambda{windowSize, probNmerged}(subN, binN) = paramsValues{windowSize, probNmerged}{subN, binN}(4); % lapse rate
                
                % then calculate residuals, summing the absolute values
                fittedValues = PF(paramsValues{windowSize, probNmerged}{subN, binN}, cohLevels);
                dataM.percept.residuals{windowSize, probNmerged}(subN, binN) = sum(abs(fittedValues-dataM.percept.ProportionCorrectObserved{windowSize, probNmerged}{binN}(subN, :)'));
            
                %% AP
                % generate binary AP
                dataM.AP.binary{windowSize, probNmerged}{binN, subN} = data.AP_interpol;
                idxTL = find(dataM.AP.binary{windowSize, probNmerged}{binN, subN}<=medianAP);
                idxTR = find(dataM.AP.binary{windowSize, probNmerged}{binN, subN}>medianAP);
                dataM.AP.binary{windowSize, probNmerged}{binN, subN}(idxTL) = 0; % "left"
                dataM.AP.binary{windowSize, probNmerged}{binN, subN}(idxTR) = 1; % "right"
                
                dataM.AP.numRight{windowSize, probNmerged}(subN, binN) = nansum(dataM.AP.binary{windowSize, probNmerged}{binN, subN}); % choice 1=right, 0=left
                dataM.AP.outOfNum{windowSize, probNmerged}(subN, binN) = length(dataM.AP.binary{windowSize, probNmerged}{binN, subN}); % total trial numbers
                dataM.AP.proportionRight{windowSize, probNmerged}(subN, binN) = ...
                    dataM.AP.numRight{windowSize, probNmerged}(subN, binN)./ ...
                    dataM.AP.outOfNum{windowSize, probNmerged}(subN, binN);                
            end
        end
    end
    
    % calculte correlations for perception
    for probNmerged = 1:3
        % perception
        [corrM.percept.rho(windowSize, probNmerged) corrM.percept.pValue(windowSize, probNmerged)] = corr(previousDbins{windowSize, probNmerged}(:), dataM.percept.residuals{windowSize, probNmerged}(:));
        % AP
        [corrM.AP.rho(windowSize, probNmerged) corrM.AP.pValue(windowSize, probNmerged)] = corr(previousDbins{windowSize, probNmerged}(:), ...
            dataM.AP.proportionRight{windowSize, probNmerged}(:));
    end
end
save(['percept_AP_binMax', num2str(binMax)], 'idxBins', 'previousDbins', 'dataM', 'corrM')
% again, remember that in dataM everything is merged probability blocks