% to quickly check the relative motion hypothesis
% separate trials into two bins: lower AP trials, and higher AP trials
% if relative motion during AP plays a role, we may expect different
% psychometric functions of the two bins of trials
initializeParas;

initializePSE;

%% do the fitting for each bin
for subN = 1:length(names)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        probNameI = 1;
    else
        probNameI = 2;
    end
    dataPercept.probSub(subN, 1:length(probSub)) = probSub;
    
    figure
    hold on
    for probSubN = 1:size(probSub, 2)
        idxP = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.errorStatus(subN, :)==0 ...
            & eyeTrialData.prob(subN, :)==probSub(probSubN) & ~isnan(eyeTrialData.pursuit.APvelocityX(subN, :))); % perceptual trials
        medianAP = median(eyeTrialData.pursuit.APvelocityX(subN, idxP));
        idxT{1} = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.errorStatus(subN, :)==0 ...
            & eyeTrialData.prob(subN, :)==probSub(probSubN) & ~isnan(eyeTrialData.pursuit.APvelocityX(subN, :)) ...
            & eyeTrialData.pursuit.APvelocityX(subN, :) < medianAP); % ap < median
        idxT{2} = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.errorStatus(subN, :)==0 ...
            & eyeTrialData.prob(subN, :)==probSub(probSubN) & ~isnan(eyeTrialData.pursuit.APvelocityX(subN, :)) ...
            & eyeTrialData.pursuit.APvelocityX(subN, :) > medianAP); % ap > median
        
        % then fit the psychometric curves for each bin
        for ii = 1:2
            data.cohFit = eyeTrialData.coh(subN, idxT{ii})';
            data.choice = eyeTrialData.choice(subN, idxT{ii})';
            
            if probSub(1)<50
                probB = 1;
            else
                probB = 2;
            end        
            
            probN = find(probCons==probSub(probSubN));
            % sort data
            cohLevels = unique(data.cohFit); % stimulus levels, negative is left
            data.cohIdx = zeros(size(data.cohFit));
            for cohN = 1:length(cohLevels)
                data.cohIdx(data.cohFit==cohLevels(cohN), 1) = cohN;
            end
            numRight{probN, ii}(subN, :) = accumarray(data.cohIdx, data.choice, [], @sum); % choice 1=right, 0=left
            outOfNum{probN, ii}(subN, :) = accumarray(data.cohIdx, data.choice, [], @numel); % total trial numbers
            
            %Perform fit
            [paramsValues{subN, probSubN}{ii} LL{subN, probSubN}{ii} exitflag{subN, probSubN}{ii}] = PAL_PFML_Fit(cohLevels, numRight{probN, ii}(subN, :)', ...
                outOfNum{probN, ii}(subN, :)', searchGrid, paramsFree, PF);
            
            % plotting
            ProportionCorrectObserved=numRight{probN, ii}(subN, :)./outOfNum{probN, ii}(subN, :);
            StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
            ProportionCorrectModel = PF(paramsValues{subN, probSubN}{ii},StimLevelsFineGrain);
            if ii==1
                plot(StimLevelsFineGrain, ProportionCorrectModel,'--','color', colorProb(probN, :), 'linewidth', 2);
            else
                f{probSubN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', colorProb(probN, :), 'linewidth', 2);
            end
            plot(cohLevels, ProportionCorrectObserved,'.', 'color', colorProb(probN, :), 'markersize', 30);
            
            % saving parameters
            if probSub(1)<50
                probNmerged = 4-probN;
                paramsValues{subN, probSubN}{ii}(1) = -paramsValues{subN, probSubN}{ii}(1); % also flip PSE
            else
                probNmerged = probN-2;
            end
            dataPercept.alpha{ii}(subN, probNmerged) = paramsValues{subN, probSubN}{ii}(1); % threshold, or PSE
            dataPercept.beta{ii}(subN, probNmerged) = paramsValues{subN, probSubN}{ii}(2); % slope
            dataPercept.gamma{ii}(subN, probNmerged) = paramsValues{subN, probSubN}{ii}(3); % guess rate, or baseline
            dataPercept.lambda{ii}(subN, probNmerged) = paramsValues{subN, probSubN}{ii}(4); % lapse rate
        end
        set(gca, 'fontsize',16);
        set(gca, 'Xtick',cohLevels);
        axis([min(cohLevels) max(cohLevels) 0 1]);
        title(['slower (dashed) vs faster (solid) AP trials'])
        xlabel('Stimulus Intensity');
        ylabel('Proportion right');
        legend([f{:}], probNames{probB}, 'box', 'off', 'location', 'northwest')
        
        cd(perceptFolder)
        saveas(gcf, ['pf_APbins_', names{subN}, '.pdf'])
    end
end

%% plot bars of the difference between the two bins in each probability
diffMean = mean(dataPercept.alpha{2}-dataPercept.alpha{1});
diffSte = std(dataPercept.alpha{2}-dataPercept.alpha{1})/sqrt(length(names));
figure
boxplot(dataPercept.alpha{2}-dataPercept.alpha{1}, 'Labels', {'50','70','90'})
% errorbar_groups(diffMean, diffSte,  ...
%     'bar_width',0.75,'errorbar_width',0.5, ...
%     'bar_names',{'50','70','90'})
xlabel('Probability of right');
ylabel('Higher AP trials-lower AP trials PSE (right is positive)');
cd(perceptFolder)
saveas(gcf, ['PSE_APbins.pdf'])

save('dataPercept_APbins', 'dataPercept');