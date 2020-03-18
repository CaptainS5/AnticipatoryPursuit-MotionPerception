% to examine the distribution of asp and see if we can separate the
% trials according to asp... not very likely though = =
initializeParas;
initializePSE;
% nbins = 10;
edges = [-6 -5 -4 -3:0.25:3 4 5 6 7 8 9];
yRange = [0 0.4];
chooseTrialN = 140; % how many trials in each sorted group
edgesCoh = [-0.175:0.05:0.175];
edgesIdx = [0:10:chooseTrialN+10];

%% first plot the distribution of asp in each block for each participant
subNexp = zeros(1, 3);
for subN = 1:size(nameSets{3}, 2)
    if ~strcmp(nameSets{3}{subN}, 'nan')% has data for exp3
        subNexp(1) = subN; % for exp 1
        subNexp(2) = subN; % for exp 1
        subNexp(3) = subNexp(3)+1; % for exp3
    end
    
    probSub = unique(expAll{3}.eyeTrialData.prob(subNexp(3), expAll{3}.eyeTrialData.errorStatus(subNexp(3), :)==0));
    if probSub(1)<50
        probNameI = 1;
        %         probSub = fliplr(probSub); % make it in the order of 50, 10
        %         probSub(probSub==30) = []; % only use 50 and 10
    else
        probNameI = 2;
        %         probSub(probSub==70) = []; % only use 50 and 90
    end
    probSubAll(subNexp(3), :) = probSub;
%     figure % each experiment is in one subplot
    for expN = 1:3
        if ~(expN==2 && subN==10)
%             subplot(3, 1, expN)
%             hold on
            
            for probSubN = 1:length(probSub)
                idxP = find(expAll{expN}.eyeTrialData.trialType(subNexp(expN), :)==0 ...
                    & expAll{expN}.eyeTrialData.errorStatus(subNexp(expN), :)==0 ...
                    & expAll{expN}.eyeTrialData.prob(subNexp(expN), :)==probSub(probSubN)); % perceptual trials
                % sort the asp values
                trialIdx{subNexp(3), expN}{probSubN} = idxP;
                choiceAll{subNexp(3), expN}{probSubN} = expAll{expN}.eyeTrialData.choice(subNexp(expN), idxP);
                cohAll{subNexp(3), expN}{probSubN} = expAll{expN}.eyeTrialData.coh(subNexp(expN), idxP);
                aspAll{subNexp(3), expN}{probSubN} = expAll{expN}.eyeTrialData.pursuit.APvelocityX(subNexp(expN), idxP);
                
%                 % plot the distributions
%                 p{subNexp(3), expN}{probSubN} = histogram(aspAll{subNexp(3), expN}{probSubN}, edges, 'Normalization','probability');
%                 if probSubN==1
%                     line([nanmean(aspAll{subNexp(3), expN}{probSubN}) nanmean(aspAll{subNexp(3), expN}{probSubN})], yRange, 'linestyle', '--', 'color', 'b')
%                 else
%                     line([nanmean(aspAll{subNexp(3), expN}{probSubN}) nanmean(aspAll{subNexp(3), expN}{probSubN})], yRange, 'linestyle', '--', 'color', 'r')
%                 end
            end
%             xlabel(['exp', num2str(expN), ' asp'])
%             ylim(yRange)
%             legend([p{subNexp(3), expN}{:}], probNames{probNameI})
        end
    end
%     cd(pursuitFolder)
%     saveas(gcf, ['aspDistribution_', names{subNexp(3)}, '.pdf'])
end

%% take trials with the lowest and highest asp to see if they are evenly distributed, and have reasonable numbers...
% would be hard since we didn't random trial orders
% close all
for subN = 1:subNexp(3)
    if probSubAll(subN, 1)<50
        probNameI = 1;
    else
        probNameI = 2;
    end
%     fig1 = figure;
%     fig2 = figure;
%     fig3 = figure;
    
    for ii = 1:2
        if ii==1
            expN=1;
        else
            expN=3;
        end
        tempASP1 = aspAll{subN, expN}{1};
        tempASP2 = aspAll{subN, expN}{2};
        [r1 aspI1] = sort(tempASP1); % sort the asp values from small to large
        [r2 aspI2] = sort(tempASP2);
        
        medianAll = median([tempASP1 tempASP2]);
        dis2median1 = sqrt((tempASP1-medianAll).^2);
        dis2median2 = sqrt((tempASP2-medianAll).^2);
        [dis1 medI1] = sort(dis2median1); % sort the distance from small to large
        [dis2 medI2] = sort(dis2median2);
        
        if expN==1
            % for exp1, take the most different groups
            tempI1 = aspI1(1:chooseTrialN); % smallest asps
            tempI2 = aspI2(end-chooseTrialN+1:end); % largest asps
        elseif expN==3
            % for exp3, take the most similar groups
            tempI1 = medI1(1:chooseTrialN);
            tempI2 = medI2(1:chooseTrialN);
        end
        aspSorted{subN, ii}(:, 1) = tempASP1(tempI1);
        aspSorted{subN, ii}(:, 2) = tempASP2(tempI2);
        trialISorted{subN, ii}(:, 1) = trialIdx{subN, expN}{1}(tempI1);
        trialISorted{subN, ii}(:, 2) = trialIdx{subN, expN}{2}(tempI2);
        cohSorted{subN, ii}(:, 1) = cohAll{subN, expN}{1}(tempI1);
        cohSorted{subN, ii}(:, 2) = cohAll{subN, expN}{2}(tempI2);
        choiceSorted{subN, ii}(:, 1) = choiceAll{subN, expN}{1}(tempI1);
        choiceSorted{subN, ii}(:, 2) = choiceAll{subN, expN}{2}(tempI2);
        
%         % plot asp distributions
%         figure(fig1)
%         subplot(2, 1, ii)
%         hold on
%         p1{1} = histogram(aspSorted{subN, ii}(:, 1), edges, 'Normalization','probability');
%         p1{2} = histogram(aspSorted{subN, ii}(:, 2), edges, 'Normalization','probability');
%         line([nanmean(aspSorted{subN, ii}(:, 1)) nanmean(aspSorted{subN, ii}(:, 1))], yRange, 'linestyle', '--', 'color', 'b')
%         line([nanmean(aspSorted{subN, ii}(:, 2)) nanmean(aspSorted{subN, ii}(:, 2))], yRange, 'linestyle', '--', 'color', 'r')
%         ylim(yRange)
%         xlabel(['exp', num2str(expN), ' asp'])
%         legend([p1{:}], probNames{probNameI})
%         hold off
%         
%         % plot trial distribution in time
%         figure(fig2)
%         subplot(2, 1, ii)
%         hold on
%         while trialISorted{subN, ii}(1, 1)>682
%             trialISorted{subN, ii}(:, 1) = trialISorted{subN, ii}(:, 1)-682;        
%         end
%         while trialISorted{subN, ii}(1, 2)>682
%             trialISorted{subN, ii}(:, 2) = trialISorted{subN, ii}(:, 2)-682;        
%         end
%         p2{1} = histogram(mod(682, trialISorted{subN, ii}(:, 1)-1)+1, edgesIdx);
%         p2{2} = histogram(mod(682, trialISorted{subN, ii}(:, 2))+1, edgesIdx);
%         legend([p2{:}], probNames{probNameI})
%         xlabel(['exp', num2str(expN), ' trial temporal distribution'])
%         hold off
%         
%         % plot trial distribution of coh
%         figure(fig3)
%         subplot(2, 1, ii)
%         hold on
%         p3{1} = histogram(cohSorted{subN, ii}(:, 1), edgesCoh);
%         p3{2} = histogram(cohSorted{subN, ii}(:, 2), edgesCoh);
%         xlabel(['exp', num2str(expN), ' trial coh'])
%         legend([p3{:}], probNames{probNameI})
%         hold off
    end
%     cd(pursuitFolder)
%     saveas(fig1, ['aspDistributionSorted_', names{subN}, '.pdf'])
%     saveas(fig2, ['temporalDistributionSorted_', names{subN}, '.pdf'])
%     saveas(fig3, ['cohDistributionSorted_', names{subN}, '.pdf'])
end

%% if all look good, go ahead to psychometric curve fitting
for subN = 1:subNexp(3)
    if probSubAll(subN, 1)<50 % flip...
        probNameI = 1;
        probSubAll(subN, :) = fliplr(probSubAll(subN, :));
        for ii = 1:2 % also make it 50, 10, 50, 10
            aspSorted{subN, ii} = -fliplr(aspSorted{subN, ii});
            cohSorted{subN, ii} = -fliplr(cohSorted{subN, ii});
            choiceSorted{subN, ii} = 1-fliplr(choiceSorted{subN, ii});
        end
    else
        probNameI = 2;
    end
    
    % psychometric functions
%     figure
%     hold on
    for expN = 1:2  
        for probSubN = 1:size(probSub, 2)
            % then fit the psychometric curves for each bin
            data.cohFit = cohSorted{subN, expN}(:, probSubN);
            data.choice = choiceSorted{subN, expN}(:, probSubN);
            
            probN = find(probCons==probSubAll(subN, probSubN));
            
            % sort data to prepare for fitting--when there's no need to
            % calculate the weighted probabilities...
            cohLevels = unique(data.cohFit); % stimulus levels, negative is left
            data.cohIdx = zeros(size(data.cohFit));
            for cohN = 1:length(cohLevels)
                data.cohIdx(data.cohFit==cohLevels(cohN), 1) = cohN;
            end
            numRight{(expN-1)*2+probSubN}(subN, :) = accumarray(data.cohIdx, data.choice, [], @sum); % choice 1=right, 0=left
            outOfNum{(expN-1)*2+probSubN}(subN, :) = accumarray(data.cohIdx, data.choice, [], @numel); % total trial numbers
            
            %Perform fit
            [paramsValues{subN, probSubN}{expN} LL exitflag] = PAL_PFML_Fit(cohLevels, numRight{(expN-1)*2+probSubN}(subN, :)', ...
                outOfNum{(expN-1)*2+probSubN}(subN, :)', searchGrid, paramsFree, PF);
            
            % plotting
            ProportionCorrectObserved=numRight{(expN-1)*2+probSubN}(subN, :)./outOfNum{(expN-1)*2+probSubN}(subN, :);
            StimLevelsFineGrain=[min(cohLevels):max(cohLevels)./1000:max(cohLevels)];
            ProportionCorrectModel = PF(paramsValues{subN, probSubN}{expN},StimLevelsFineGrain);
%             if expN==1
%                 f{(expN-1)*2+probSubN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'--','color', colorProb(probN, :), 'linewidth', 2);
%                 plot(cohLevels, ProportionCorrectObserved, 'o', 'color', colorProb(probN, :), 'markersize', 10);
%             else
%                 f{(expN-1)*2+probSubN} = plot(StimLevelsFineGrain, ProportionCorrectModel,'-','color', colorProb(probN, :), 'linewidth', 2);
%                 plot(cohLevels, ProportionCorrectObserved, '.', 'color', colorProb(probN, :), 'markersize', 30);
%             end
            
            % saving parameters
            dataPercept.alpha(subN, (expN-1)*2+probSubN) = paramsValues{subN, probSubN}{expN}(1); % threshold, or PSE
            dataPercept.beta(subN, (expN-1)*2+probSubN) = paramsValues{subN, probSubN}{expN}(2); % slope
            dataPercept.gamma(subN, (expN-1)*2+probSubN) = paramsValues{subN, probSubN}{expN}(3); % guess rate, or baseline
            dataPercept.lambda(subN, (expN-1)*2+probSubN) = paramsValues{subN, probSubN}{expN}(4); % lapse rate
            
            aspMean(subN, (expN-1)*2+probSubN) = nanmean(aspSorted{subN, expN}(:, probSubN));
        end
    end
%     set(gca, 'fontsize',16);
%     set(gca, 'Xtick',cohLevels);
%     axis([min(cohLevels) max(cohLevels) 0 1]);
%     title(names{subN})
%     xlabel('Stimulus Intensity');
%     ylabel('Proportion right');
%     legend([f{:}], probNames13{probNameI}, 'box', 'off', 'location', 'northwest')
%     
%     cd(perceptFolder)
%     saveas(gcf, ['pfSorted_exp1vs3_', names{subN}, '.pdf'])    
end

%% scatter plot
% figure;
% hold on
% for subN = 1:size(dataPercept.alpha, 1)
%     fS{subN, 1} = plot(dataPercept.alpha(subN, 1), aspMean(subN, 1), '.', 'color', markerC(subN, :), 'markerSize', 25);
%     fS{subN, 2} = plot(dataPercept.alpha(subN, 2), aspMean(subN, 2), '^', 'MarkerFaceColor', markerC(subN, :), 'MarkerEdgeColor', 'none', 'markerSize', 8);
%     fS{subN, 3} = plot(dataPercept.alpha(subN, 3), aspMean(subN, 3), 'd', 'MarkerFaceColor', markerC(subN, :), 'MarkerEdgeColor', 'none', 'markerSize', 8);
%     fS{subN, 4} = plot(dataPercept.alpha(subN, 4), aspMean(subN, 4), 's', 'MarkerFaceColor', markerC(subN, :), 'MarkerEdgeColor', 'none', 'markerSize', 8);
% end
% axis square
% xlabel('PSE')
% ylabel('ASP')
% legend([fS{3, :}], probNames13{2}, 'box', 'off', 'location', 'northwest')
% ah1=axes('position',get(gca,'position'), 'visible', 'off');
% legend(ah1, [fS{:, 1}], names, 'box', 'off', 'location', 'northeast')
% cd(perceptFolder)
% saveas(gcf, ['PSEvsASP_exp1vs3sorted_all.pdf'])

%% to use in R for plotting
cd ..
cd ..
cd('R')

diffData = table(); % actually not difference... anyway
count = 1;
for subN = 1:subNexp(3)
    for ii = 1:2
        if ii==1
            expN = 1;
        else
            expN = 3;
        end
        
        for probN = 1:2
            diffData.sub(count, 1) = subN;
            diffData.exp(count, 1) = expN;
            diffData.prob(count, 1) = probCons(probN+1);
            diffData.aspVel(count, 1) = aspMean(subN, (ii-1)*2+probN);
            diffData.PSE(count, 1) = dataPercept.alpha(subN, (ii-1)*2+probN);
            count = count+1;
        end
    end
end
writetable(diffData, 'compareExp13.csv')