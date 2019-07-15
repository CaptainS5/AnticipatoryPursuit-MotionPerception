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

%% sort into bins and fit psychometric functions for perception, also get AP values
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
            clear motionDprevious
            
            probN = find(probCons==probSub(probSubN));
            % for saving the parameters, collapse left and right
            % probabilities, flip visual and perceptual directions
            if probSub(1)<50
                probNmerged = 4-probN;
            else
                probNmerged = probN-2;
            end
            
            idxP = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0 ); % perceptual trials
            wholeParts = floor(length(idxP)/binMaxTemp);
            leftOvers = mod(length(idxP), binMaxTemp); % these are for the calculation of bin size
            for pI = 1:length(idxP) % loop through perceptual trials
                % get the average direction value of previous trials
                % when right=1, left=0, based on perceptual response
                motionDprevious(pI, 1) = mean(eyeTrialData.choice(subN, idxP(pI)-windowSize:idxP(pI)-1)); % based on participant's choice
                motionDprevious(pI, 1) = mean(eyeTrialData.rdkDir(subN, idxP(pI)-windowSize:idxP(pI)-1)); % based on visual motion
%                 % when right=1, left=-1, based on perceptual response
% %                 motionDprevious(pI, 1) = mean(eyeTrialData.choice(subN, idxP(pI)-windowSize:idxP(pI)-1)); % based on participant's choice
%                 motionDprevious(pI, 1) = mean(eyeTrialData.rdkDir(subN, idxP(pI)-windowSize:idxP(pI)-1)); % based on visual motion
                
                % get the value of the current trial
                %             ap(pI, 1) = eyeTrialData.pursuit.APvelocityX(subN, idxP(pI));
            end
            medianAP = nanmedian(eyeTrialData.pursuit.APvelocityX_interpol(subN, idxP));
            
            % get the idx for each bin and average previous motion ready
            [motionDpreviousSorted idxSort] = sort(motionDprevious);
            
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
                previousDbins{windowSize, probNmerged}(subN, binN) = mean(motionDpreviousSorted(binIdxStart:binIdxEnd));
                
                % sort coh idx for accumarray
                data.cohFit = eyeTrialData.coh(subN, idxBins{windowSize, probNmerged}{subN, binN})';
                data.choice = eyeTrialData.choice(subN, idxBins{windowSize, probNmerged}{subN, binN})';
                data.AP_interpol = eyeTrialData.pursuit.APvelocityX_interpol(subN, idxBins{windowSize, probNmerged}{subN, binN})';
                cohLevels = unique(data.cohFit); % stimulus levels, negative is left
                data.cohIdx = zeros(size(data.cohFit));
                for cohN = 1:length(cohLevels)
                    data.cohIdx(data.cohFit==cohLevels(cohN), 1) = cohN;
                end
                dataM.percept.cohLevels{windowSize, probNmerged}{binN, subN} = cohLevels;
                
                %% perception
                dataM.percept.numRight{windowSize, probNmerged}{binN, subN} = accumarray(data.cohIdx, data.choice, [], @sum); % choice 1=right, 0=left
%                 for cohI = 1:length(cohLevels)
%                     dataM.percept.numRight{windowSize, probNmerged}{binN, subN}(cohI, 1) = ...
%                         length(find(data.choice==1 & data.cohFit==cohLevels(cohI)));
%                 end
                dataM.percept.outOfNum{windowSize, probNmerged}{binN, subN} = accumarray(data.cohIdx, data.choice, [], @numel); % total trial numbers
                dataM.percept.ProportionCorrectObserved{windowSize, probNmerged}{binN, subN} = ...
                    dataM.percept.numRight{windowSize, probNmerged}{binN, subN}./ ...
                    dataM.percept.outOfNum{windowSize, probNmerged}{binN, subN};
                
                %Perform fit
                [paramsValues{windowSize, probNmerged}{subN, binN} LL exitflag] ...
                    = PAL_PFML_Fit(cohLevels, dataM.percept.numRight{windowSize, probNmerged}{binN, subN}, ...
                    dataM.percept.outOfNum{windowSize, probNmerged}{binN, subN}, searchGrid, paramsFree, PF);

                % saving parameters
                dataM.percept.alpha{windowSize, probNmerged}(subN, binN) = paramsValues{windowSize, probNmerged}{subN, binN}(1); % threshold, or PSE
                dataM.percept.beta{windowSize, probNmerged}(subN, binN) = paramsValues{windowSize, probNmerged}{subN, binN}(2); % slope
                dataM.percept.gamma{windowSize, probNmerged}(subN, binN) = paramsValues{windowSize, probNmerged}{subN, binN}(3); % guess rate, or baseline
                dataM.percept.lambda{windowSize, probNmerged}(subN, binN) = paramsValues{windowSize, probNmerged}{subN, binN}(4); % lapse rate
                
                %% AP
                % generate binary AP
                dataM.AP.binary{windowSize, probNmerged}{binN, subN} = data.AP_interpol;
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
    
    % fit to all data...
    for probNmerged = 1:3
        % get the mean proportion right for each coherence
        % level...
        %         probTemp = NaN(size(names, 2)*binMaxTemp, length(cohLevels));
        cohLevels = unique(eyeTrialData.coh(1, eyeTrialData.trialType(1, :)==0))';
        probTemp = NaN(size(names, 2), length(cohLevels));
        for subN = 1:size(names, 2)
            probSub = unique(eyeTrialData.prob(subN, :));
            if probSub(1)<50
                probSubN = 4-probNmerged;
            else
                probSubN = probNmerged;
            end
            % average of all trials
            for cohI = 1:length(cohLevels)
                idxP = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.coh(subN, :)==cohLevels(cohI) &...
                    eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.errorStatus(subN, :)==0);
                probTemp(subN, cohI) = length(find(eyeTrialData.choice(subN, idxP)==1))/length(idxP);
            end
            % average of bins
%             for binN = 1:binMaxTemp
%                 for cohSub = 1:length(dataM.percept.cohLevels{windowSize, probNmerged}{binN, subN})
%                     cohI = find(cohLevels==dataM.percept.cohLevels{windowSize, probNmerged}{binN, subN}(cohSub));
%                     if ~isempty(cohI)
%                         probTemp((subN-1)*binMaxTemp+binN, cohI) = dataM.percept.ProportionCorrectObserved{windowSize, probNmerged}{binN, subN}(cohSub);
%                     end
%                 end
%             end
        end
        dataM.percept.outOfNumAll{probNmerged} = 100*ones(size(cohLevels));
        dataM.percept.numRightAll{probNmerged} = nanmean(probTemp)'.*dataM.percept.outOfNumAll{probNmerged};
        
        %Perform fit
        [dataM.percept.paramsValuesAll{probNmerged} LL exitflag] ...
            = PAL_PFML_Fit(cohLevels, dataM.percept.numRightAll{probNmerged}, ...
            dataM.percept.outOfNumAll{probNmerged}, searchGrid, paramsFree, PF);
        
%         dataM.percept.fittedValuesAll{probNmerged} = PF(dataM.percept.paramsValuesAll{probNmerged}, cohLevels);
    end
    
    % then calculate perceptual residuals, summing the absolute values
    for subN = 1:length(names)
        for probSubN = 1:size(probSub, 2)
            probN = find(probCons==probSub(probSubN));
            % for saving the parameters, collapse left and right
            % probabilities, flip visual and perceptual directions
            if probSub(1)<50
                probNmerged = 4-probN;
            else
                probNmerged = probN-2;
            end

            for binN = 1:binMaxTemp
                data.cohFit = eyeTrialData.coh(subN, idxBins{windowSize, probNmerged}{subN, binN})';
                cohLevels = unique(data.cohFit);
                fittedValues = PF(dataM.percept.paramsValuesAll{probNmerged}, cohLevels);
                dataM.percept.residuals{windowSize, probNmerged}(subN, binN) = ...
                    sum(fittedValues-dataM.percept.ProportionCorrectObserved{windowSize, probNmerged}{binN, subN});
            end
        end
    end
    
    % calculte correlations for perception
    for probNmerged = 1:3
        % perception
        [corrM.percept.rho(windowSize, probNmerged) corrM.percept.pValue(windowSize, probNmerged)] = corr(previousDbins{windowSize, probNmerged}(:), ...
            dataM.percept.residuals{windowSize, probNmerged}(:));
        % AP
        [corrM.AP.rho(windowSize, probNmerged) corrM.AP.pValue(windowSize, probNmerged)] = corr(previousDbins{windowSize, probNmerged}(:), ...
            dataM.AP.proportionRight{windowSize, probNmerged}(:));
    end
end
save(['percept_AP_binMax', num2str(binMax)], 'idxBins', 'previousDbins', 'dataM', 'corrM')
% again, remember that in dataM everything is merged probability blocks