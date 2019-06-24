% to quickly check the relative motion hypothesis
% separate trials into two bins: lower AP trials, and higher AP trials
% if relative motion during AP plays a role, we may expect different
% psychometric functions of the two bins of trials
initializeParas;
initializePSE;

% flip every direction... to collapse left and right probability
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

%% do the fitting for each bin
for subN = 1:length(names)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        probNameI = 1;
    else
        probNameI = 2;
    end
    dataPercept.probSub(subN, 1:length(probSub)) = probSub;
    
    % plot the AP velocity distribution as a sanity check
    figure
    for probSubN = 1:size(probSub, 2)
        idxP = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.errorStatus(subN, :)==0 ...
            & eyeTrialData.prob(subN, :)==probSub(probSubN) & ~isnan(eyeTrialData.pursuit.APvelocityX_interpol(subN, :))); % perceptual trials
        % first, as a sanity check, later to plot the distribution of AP 
        % to see if the separation of bins is meaningful--if AP velocities 
        % are fairly wide-spread
        apDis{subN, probSubN} = eyeTrialData.pursuit.APvelocityX_interpol(subN, idxP);
        % and get median to split the bins later
        medianAP{subN, probSubN} = median(eyeTrialData.pursuit.APvelocityX_interpol(subN, idxP));
        
        % figure out the direction of trials included...
        idxL = find(eyeTrialData.trialType(subN, :)==0 & ( eyeTrialData.errorStatus(subN, :)~=0 ...
            | isnan(eyeTrialData.pursuit.APvelocityX_interpol(subN, :)) )...
            & eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.rdkDir < 0); % left trials excluded
        idxR = find(eyeTrialData.trialType(subN, :)==0 & ( eyeTrialData.errorStatus(subN, :)~=0 ...
            | isnan(eyeTrialData.pursuit.APvelocityX_interpol(subN, :)) )...
            & eyeTrialData.prob(subN, :)==probSub(probSubN) & eyeTrialData.rdkDir > 0); % right trials excluded
        
        subplot(3, 1, probSubN)
        histogram(apDis{subN, probSubN}, 'NumBins', 30, 'normalization', 'probability')
        hold on
        line([medianAP{subN, probSubN} medianAP{subN, probSubN}], [0 0.2], 'color', 'r')
        ylabel('AP velocity X interpolated')
        title([num2str(probSub(probSubN)) ' left ' num2str(length(idxL)) ' out, right ' num2str(length(idxR)) ' out'])
    end
    saveas(gcf, ['apVelXinterpol_histogram_', names{subN}, '.pdf'])
    
    figure
    hold on
    for probSubN = 1:size(probSub, 2)
        % slower trials (more leftwards) in lefter blocks corresponds to
        % faster trials (more rightwards) in righter blocks, which is always 
        % the second bin
%         if probSub(1)<50 % lefter blocks
%             idxT{2} = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.errorStatus(subN, :)==0 ...
%                 & eyeTrialData.prob(subN, :)==probSub(probSubN) & ~isnan(eyeTrialData.pursuit.APvelocityX_interpol(subN, :)) ...
%                 & eyeTrialData.pursuit.APvelocityX_interpol(subN, :) <= medianAP{subN, probSubN}); % ap < median
%             idxT{1} = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.errorStatus(subN, :)==0 ...
%                 & eyeTrialData.prob(subN, :)==probSub(probSubN) & ~isnan(eyeTrialData.pursuit.APvelocityX_interpol(subN, :)) ...
%                 & eyeTrialData.pursuit.APvelocityX_interpol(subN, :) > medianAP{subN, probSubN}); % ap > median
%         else
            idxT{1} = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.errorStatus(subN, :)==0 ...
                & eyeTrialData.prob(subN, :)==probSub(probSubN) & ~isnan(eyeTrialData.pursuit.APvelocityX_interpol(subN, :)) ...
                & eyeTrialData.pursuit.APvelocityX_interpol(subN, :) <= medianAP{subN, probSubN}); % ap < median
            idxT{2} = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.errorStatus(subN, :)==0 ...
                & eyeTrialData.prob(subN, :)==probSub(probSubN) & ~isnan(eyeTrialData.pursuit.APvelocityX_interpol(subN, :)) ...
                & eyeTrialData.pursuit.APvelocityX_interpol(subN, :) > medianAP{subN, probSubN}); % ap > median
%         end
                
        % then fit the psychometric curves for each bin
        for binN = 1:2
            data.cohFit = eyeTrialData.coh(subN, idxT{binN})';
            data.choice = eyeTrialData.choice(subN, idxT{binN})';
            
            probN = find(probCons==probSub(probSubN));
            
            % sort data to prepare for fitting--when there's no need to
            % calculate the weighted probabilities...
            cohLevels = unique(data.cohFit); % stimulus levels, negative is left
            data.cohIdx = zeros(size(data.cohFit));
            for cohN = 1:length(cohLevels)
                data.cohIdx(data.cohFit==cohLevels(cohN), 1) = cohN;
            end
            numRight{probN, binN}(subN, :) = accumarray(data.cohIdx, data.choice, [], @sum); % choice 1=right, 0=left
            outOfNum{probN, binN}(subN, :) = accumarray(data.cohIdx, data.choice, [], @numel); % total trial numbers
            
%             conWeight = eyeTrialData.rdkDir(subN, idxT{binN})';% in case of uneven number of left/right trials, calculate
%             % weighted probability for the fitting
%             % can use con = ones() as no weighted
%             [numRight{probN, binN}(subN, :) outOfNum{probN, binN}(subN, :) stimLevelOut conOut] ...
%                 = weightedProbPF(conWeight, data.cohFit, data.choice);
            
            %Perform fit
            [paramsValues{subN, probSubN}{binN} LL{subN, probSubN}{binN} exitflag{subN, probSubN}{binN}] = PAL_PFML_Fit(cohLevels, numRight{probN, binN}(subN, :)', ...
                outOfNum{probN, binN}(subN, :)', searchGrid, paramsFree, PF);
            
            % plotting
            ProportionCorrectObserved=numRight{probN, binN}(subN, :)./outOfNum{probN, binN}(subN, :);
            StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
            ProportionCorrectModel = PF(paramsValues{subN, probSubN}{binN},StimLevelsFineGrain);
            if binN==1
                plot(StimLevelsFineGrain, ProportionCorrectModel,'--','color', colorProb(probN, :), 'linewidth', 2);
            else
                f{probSubN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', colorProb(probN, :), 'linewidth', 2);
            end
            plot(cohLevels, ProportionCorrectObserved,'.', 'color', colorProb(probN, :), 'markersize', 30);
            
            % saving parameters
            if probSub(1)<50
                probNmerged = 4-probN;
                paramsValues{subN, probSubN}{binN}(1) = -paramsValues{subN, probSubN}{binN}(1); % also flip PSE
            else
                probNmerged = probN-2;
            end
            dataPercept.alpha{binN}(subN, probNmerged) = paramsValues{subN, probSubN}{binN}(1); % threshold, or PSE
            dataPercept.beta{binN}(subN, probNmerged) = paramsValues{subN, probSubN}{binN}(2); % slope
            dataPercept.gamma{binN}(subN, probNmerged) = paramsValues{subN, probSubN}{binN}(3); % guess rate, or baseline
            dataPercept.lambda{binN}(subN, probNmerged) = paramsValues{subN, probSubN}{binN}(4); % lapse rate
        end
        set(gca, 'fontsize',16);
        set(gca, 'Xtick',cohLevels);
        axis([min(cohLevels) max(cohLevels) 0 1]);
        title(['slower (dashed) vs faster (solid) AP trials'])
        xlabel('Stimulus Intensity');
        ylabel('Proportion right');
        legend([f{:}], probNames{probNameI}, 'box', 'off', 'location', 'northwest')
        
        cd(perceptFolder)
        saveas(gcf, ['pf_APbins_', names{subN}, '.pdf'])
    end
end
save('dataPercept_APbins', 'dataPercept');

%% plot bars of the difference between the two bins in each probability
diffMean = mean(dataPercept.alpha{2}-dataPercept.alpha{1});
diffSte = std(dataPercept.alpha{2}-dataPercept.alpha{1})/sqrt(length(names));
% box plot
figure
boxplot(dataPercept.alpha{2}-dataPercept.alpha{1}, 'Labels', {'50','70','90'})
xlabel('Probability of right');
ylabel('Higher AP trials-lower AP trials PSE (right is positive)');
cd(perceptFolder)
saveas(gcf, ['PSE_APbins_box.pdf'])

% bar plot
errorbar_groups(diffMean, diffSte,  ...
    'bar_width',0.75,'errorbar_width',0.5, ...
    'bar_names',{'50','70','90'})
xlabel('Probability of right');
ylabel('Higher AP trials-lower AP trials PSE (right is positive)');
cd(perceptFolder)
saveas(gcf, ['PSE_APbins_bar.pdf'])