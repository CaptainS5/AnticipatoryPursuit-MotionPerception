% draw plots of Exp1 and 3 together
initializeParas;
initializePSE;

drawIndividualPlots = 1;
drawAveragePlots = 1;

% % flip every direction... to collapse left and right probability blocks
% subNexp3 = 0; % when exp3 data collection is not finished, count the subNexp3...
% for subN = 1:size(names, 2)
%     if ~strcmp(names{subN}, 'nan')% has data for exp3
%         subNexp1 = subN;
%         subNexp3 = subNexp3+1;
%         probSub = unique(eyeTrialData.prob(subNexp3, eyeTrialData.errorStatus(subNexp3, :)==0));
%         if probSub(1)<50
%             % for exp3
%             eyeTrialData.rdkDir(subNexp3, :) = -eyeTrialData.rdkDir(subNexp3, :);
%             eyeTrialData.choice(subNexp3, :) = 1-eyeTrialData.choice(subNexp3, :); % flip left (0) and right (1)
%             eyeTrialData.coh(subNexp3, :) = -eyeTrialData.coh(subNexp3, :);
%             eyeTrialData.pursuit.APvelocityX(subNexp3, :) = -eyeTrialData.pursuit.APvelocityX(subNexp3, :);
%             eyeTrialData.pursuit.APvelocityX_interpol(subNexp3, :) = -eyeTrialData.pursuit.APvelocityX_interpol(subNexp3, :);
%             % for exp1
%             exp1.eyeTrialData.rdkDir(subNexp1, :) = -exp1.eyeTrialData.rdkDir(subNexp1, :);
%             exp1.eyeTrialData.choice(subNexp1, :) = 1-exp1.eyeTrialData.choice(subNexp1, :); % flip left (0) and right (1)
%             exp1.eyeTrialData.coh(subNexp1, :) = -exp1.eyeTrialData.coh(subNexp1, :);
%             exp1.eyeTrialData.pursuit.APvelocityX(subNexp1, :) = -exp1.eyeTrialData.pursuit.APvelocityX(subNexp1, :);
%             exp1.eyeTrialData.pursuit.APvelocityX_interpol(subNexp1, :) = -exp1.eyeTrialData.pursuit.APvelocityX_interpol(subNexp1, :);
%         end
%     end
% end

%% individual plots
% one variable corresponds to one matrix
% each row is a participant, each column is:
% Exp1-50, Exp1-90/10, Exp3-50, Exp3-90/10
if drawIndividualPlots
    subNexp = zeros(1, 3); % when exp3 data collection is not finished, count the subNexp3...
    for subN = 1:size(names, 2)
        if ~strcmp(names{subN}, 'nan')% has data for exp3
            subNexp(1) = subN; % for exp 1
            subNexp(3) = subNexp(3)+1; % for exp3
            
            %% psychometric functions and ASP values
            figure
            hold on
            for ii = 1:2
                if ii==1
                    expN = ii;
                else
                    expN = 3;
                end
                probSub = unique(expAll{expN}.eyeTrialData.prob(subNexp(expN), expAll{expN}.eyeTrialData.errorStatus(subNexp(expN), :)==0));
                if probSub(1)<50
                    probNameI = 1;
                    probSub = fliplr(probSub); % make it in the order of 50, 10
                    probSub(probSub==30) = []; % only use 50 and 10
                else
                    probNameI = 2;
                    probSub(probSub==70) = []; % only use 50 and 90
                end
                dataPercept.probSub(subNexp(3), 1:length(probSub)) = probSub;
                
                for probSubN = 1:size(probSub, 2)
                    idxP = find(expAll{expN}.eyeTrialData.trialType(subNexp(expN), :)==0 ...
                        & expAll{expN}.eyeTrialData.errorStatus(subNexp(expN), :)==0 ...
                        & expAll{expN}.eyeTrialData.prob(subNexp(expN), :)==probSub(probSubN)); % perceptual trials
                    
                    % then fit the psychometric curves for each bin
                    data.cohFit = expAll{expN}.eyeTrialData.coh(subNexp(expN), idxP)';
                    data.choice = expAll{expN}.eyeTrialData.choice(subNexp(expN), idxP)';
                    
                    probN = find(probCons==probSub(probSubN));
                    
                    % sort data to prepare for fitting--when there's no need to
                    % calculate the weighted probabilities...
                    cohLevels = unique(data.cohFit); % stimulus levels, negative is left
                    data.cohIdx = zeros(size(data.cohFit));
                    for cohN = 1:length(cohLevels)
                        data.cohIdx(data.cohFit==cohLevels(cohN), 1) = cohN;
                    end
                    numRight{(expN-1)*2+probSubN}(subNexp(3), :) = accumarray(data.cohIdx, data.choice, [], @sum); % choice 1=right, 0=left
                    outOfNum{(expN-1)*2+probSubN}(subNexp(3), :) = accumarray(data.cohIdx, data.choice, [], @numel); % total trial numbers
                    
                    %Perform fit
                    [paramsValues{subNexp(3), probSubN}{expN} LL exitflag] = PAL_PFML_Fit(cohLevels, numRight{(expN-1)*2+probSubN}(subNexp(3), :)', ...
                        outOfNum{(expN-1)*2+probSubN}(subNexp(3), :)', searchGrid, paramsFree, PF);
                    
                    % plotting
                    ProportionCorrectObserved=numRight{(expN-1)*2+probSubN}(subNexp(3), :)./outOfNum{(expN-1)*2+probSubN}(subNexp(3), :);
                    StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
                    ProportionCorrectModel = PF(paramsValues{subNexp(3), probSubN}{expN},StimLevelsFineGrain);
                    if expN==1
                        f{(expN-1)*2+probSubN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'--','color', colorProb(probN, :), 'linewidth', 2);
                        plot(cohLevels, ProportionCorrectObserved, 'o', 'color', colorProb(probN, :), 'markersize', 10);
                    else
                        f{(expN-1)*2+probSubN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', colorProb(probN, :), 'linewidth', 2);
                        plot(cohLevels, ProportionCorrectObserved, '.', 'color', colorProb(probN, :), 'markersize', 30);
                    end
                    
                    % saving parameters
                    dataPercept.alpha(subNexp(3), (expN-1)*2+probSubN) = paramsValues{subNexp(3), probSubN}{expN}(1); % threshold, or PSE
                    dataPercept.beta(subNexp(3), (expN-1)*2+probSubN) = paramsValues{subNexp(3), probSubN}{expN}(2); % slope
                    dataPercept.gamma(subNexp(3), (expN-1)*2+probSubN) = paramsValues{subNexp(3), probSubN}{expN}(3); % guess rate, or baseline
                    dataPercept.lambda(subNexp(3), (expN-1)*2+probSubN) = paramsValues{subNexp(3), probSubN}{expN}(4); % lapse rate
                    
                    aspMean(subNexp(3), (expN-1)*2+probSubN) = nanmean(expAll{expN}.eyeTrialData.pursuit.APvelocityX(subNexp(expN), idxP));
                end
            end
            set(gca, 'fontsize',16);
            set(gca, 'Xtick',cohLevels);
            axis([min(cohLevels) max(cohLevels) 0 1]);
            title(names{subN})
            xlabel('Stimulus Intensity');
            ylabel('Proportion right');
            legend([f{:}], probNames{probNameI}, 'box', 'off', 'location', 'northwest')
            
            cd(perceptFolder)
            saveas(gcf, ['pf_exp1vs3_', names{subN}, '.pdf'])
        end
    end
end

% flip every direction... to collapse left and right probability blocks
% for PSE and asp...
subNexp = zeros(1, 3); % when exp3 data collection is not finished, count the subNexp3...
for subN = 1:size(names, 2)
    if ~strcmp(names{subN}, 'nan')% has data for exp3
        subNexp(1) = subN; % for exp 1
        subNexp(3) = subNexp(3)+1; % for exp3
        probSub = unique(expAll{1}.eyeTrialData.prob(subNexp(1), expAll{1}.eyeTrialData.errorStatus(subNexp(1), :)==0));
        if probSub(1)<50
            % PSE
            dataPercept.alpha(subNexp(3), :) = -dataPercept.alpha(subNexp(3), :);
            for ii = 1:4
                numRight{ii}(subNexp(3), :) = outOfNum{ii}(subNexp(3), :)-numRight{ii}(subNexp(3), :); % choice 1=right, 0=left
                numRight{ii}(subNexp(3), :) = fliplr(numRight{ii}(subNexp(3), :));
            end
            % ASP
            aspMean(subNexp(3), :) = -aspMean(subNexp(3), :);
        end
    end
end

%% average plots--needs to be fixed...
if drawAveragePlots
    %% PSE
    PSEmean = mean(dataPercept.alpha);
    figure
    hold on
    for ii = 1:size(PSEmean, 2) % four curves...
        if mod(ii, 2)==1
            probN = 2;
        else
            probN = 3;
        end
        % merge directions        
        numRightAll{ii} = mean(numRight{ii}./outOfNum{ii})*100;
        outOfNumAll{ii} = 100*ones(size(numRightAll{ii}));
        
        % fitting averaged psychometric function
        [paramsValuesAll{ii} LLAll exitflagAll] = PAL_PFML_Fit(cohLevels, numRightAll{ii}', ...
            outOfNumAll{ii}', searchGrid, paramsFree, PF);
        dataPercept.alpha_all(ii) = paramsValuesAll{ii}(1);
        dataPercept.beta_all(ii) = paramsValuesAll{ii}(2);
        dataPercept.gamma_all(ii) = paramsValuesAll{ii}(3);
        dataPercept.lambda_all(ii) = paramsValuesAll{ii}(4);
        
        % plotting
        ProportionCorrectObserved=numRightAll{ii}./outOfNumAll{ii};
        StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
        ProportionCorrectModel = PF(paramsValuesAll{ii},StimLevelsFineGrain);
        if ii<=2 % exp1
            fAll{ii} = plot(StimLevelsFineGrain, ProportionCorrectModel,'--','color', colorProb(probN, :), 'linewidth', 2);
            plot(cohLevels, ProportionCorrectObserved,'o', 'color', colorProb(probN, :), 'markersize', 10);
        else
            fAll{ii} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', colorProb(probN, :), 'linewidth', 2);
            plot(cohLevels, ProportionCorrectObserved,'.', 'color', colorProb(probN, :), 'markersize', 30);
        end
    end
    set(gca, 'fontsize',16);
    set(gca, 'Xtick',cohLevels);
    axis([min(cohLevels) max(cohLevels) 0 1]);
    title('all')
    xlabel('Stimulus Intensity');
    ylabel('Proportion right');
    legend([fAll{:}], probNames{2}, 'box', 'off', 'location', 'northwest')
    cd(perceptFolder)
    saveas(gcf, ['pf_exp1vs3_all.pdf'])
    
    %% Scatter plot of ASP vs. PSE
    figure;
    hold on
    for subN = 1:size(dataPercept.alpha, 1)
        fS{subN, 1} = plot(dataPercept.alpha(subN, 1), aspMean(subN, 1), '.', 'color', markerC(subN, :), 'markerSize', 25);
        fS{subN, 2} = plot(dataPercept.alpha(subN, 2), aspMean(subN, 2), '^', 'MarkerFaceColor', markerC(subN, :), 'MarkerEdgeColor', 'none', 'markerSize', 8);
        fS{subN, 3} = plot(dataPercept.alpha(subN, 3), aspMean(subN, 3), 'd', 'MarkerFaceColor', markerC(subN, :), 'MarkerEdgeColor', 'none', 'markerSize', 8);
        fS{subN, 4} = plot(dataPercept.alpha(subN, 4), aspMean(subN, 4), 's', 'MarkerFaceColor', markerC(subN, :), 'MarkerEdgeColor', 'none', 'markerSize', 8);
    end
    axis square
    xlabel('PSE')
    ylabel('ASP')
    legend([fS{3, :}], probNames{2}, 'box', 'off', 'location', 'northwest')
    ah1=axes('position',get(gca,'position'), 'visible', 'off');
    legend(ah1, [fS{:, 1}], names2, 'box', 'off', 'location', 'northeast')    
    cd(perceptFolder)
    saveas(gcf, ['PSEvsASP_exp1vs3_all.pdf'])
end