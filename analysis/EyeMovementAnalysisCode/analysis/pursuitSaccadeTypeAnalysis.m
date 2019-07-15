% more analysis during the close-loop pursuit
initializeParas;

% flip every direction... to collapse left and right probability
% blocks
for subN = 1:length(names)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));
    if probSub(1)<50
        eyeTrialData.rdkDir(subN, :) = -eyeTrialData.rdkDir(subN, :);
        eyeTrialData.choice(subN, :) = 1-eyeTrialData.choice(subN, :); % flip left (0) and right (1)
        eyeTrialData.coh(subN, :) = -eyeTrialData.coh(subN, :);
        eyeTrialData.pursuit.APvelocityX(subN, :) = -eyeTrialData.pursuit.APvelocityX(subN, :);
        eyeTrialData.pursuit.APvelocityX_interpol(subN, :) = -eyeTrialData.pursuit.APvelocityX_interpol(subN, :);
    end
end

%% proportion of trials according to eye movement behaviour
% some pursuit, no pursuit but saccade, or no pursuit nor saccade trials
% intialize
trialEyeCount{1} = zeros(length(names), 3); % each cell is one probability, merged
trialEyeCount{2} = zeros(length(names), 3);
trialEyeCount{3} = zeros(length(names), 3);
trialEyeIdx{1} = cell(length(names), 3);
trialEyeIdx{2} = cell(length(names), 3);
trialEyeIdx{3} = cell(length(names), 3);
% each row is a participant; the three columns are pursuit,
% no pursuit but saccade, and no eye movements trials

for subN = 1:size(names, 2)
    probSub = unique(eyeTrialData.prob(subN, :));
    
    for probSubN = 1:3
        if probSub(1)<50
            probNmerged = 4-probSubN;
        else
            probNmerged = probSubN;
        end
        idxP{subN, probNmerged} = find(eyeTrialData.trialType(subN, :)==0 & eyeTrialData.errorStatus(subN, :)==0 ...
            & eyeTrialData.prob(subN, :)==probSub(probSubN)); % all perceptual trials to be sorted
        
        for trialI = 1:length(idxP{subN, probNmerged})
            if abs(eyeTrialData.pursuit.gainX(subN, idxP{subN, probNmerged}(trialI))) > 0.1
                eyeTI = 1; % trials with pursuit
            elseif isnan(eyeTrialData.saccades.X_right.number(subN, idxP{subN, probNmerged}(trialI))) ...
                    && isnan(eyeTrialData.saccades.X_left.number(subN, idxP{subN, probNmerged}(trialI)))
                eyeTI = 3; % trials also with no saccades
            else
                eyeTI = 2; % trials with not enough pursuit but "clp" saccades
            end
            if isempty(trialEyeIdx{probNmerged}{subN, eyeTI})
                trialEyeIdx{probNmerged}{subN, eyeTI} = idxP{subN, probNmerged}(trialI);
            else
                trialEyeIdx{probNmerged}{subN, eyeTI} = [trialEyeIdx{probNmerged}{subN, eyeTI}; idxP{subN, probNmerged}(trialI)];
            end
            trialEyeCount{probNmerged}(subN, eyeTI) = trialEyeCount{probNmerged}(subN, eyeTI)+1;
        end
    end
end

% % plot the distribution of trial types
% for probNmerged = 1:3
%         meanCount(probNmerged, :) = mean(trialEyeCount{probNmerged});
%         steCount(probNmerged, :) = std(trialEyeCount{probNmerged})/sqrt(length(names));
% end
% errorbar_groups(meanCount, steCount,  ...
%     'bar_width',0.75,'errorbar_width',0.5, ...
%     'bar_names',{'pursuit','saccade only','no eye'});
% legend({'50' '70' '90'}, 'location', 'best')
% xlabel('Trial''s eye movement type');
% ylabel('Count');
% cd(saccadeFolder)
% saveas(gcf, ['eyeMovementTrialCount_all.pdf'])

%% saccade analysis
% get latency and direction of first saccade
sacLatency = NaN(size(eyeTrialData.coh));
sacDir = NaN(size(eyeTrialData.coh)); % merged direction
for subN = 1:length(names)
    probSub = unique(eyeTrialData.prob(subN, eyeTrialData.errorStatus(subN, :)==0));

    for trialI = 1:size(eyeTrialData.coh, 2)
        if eyeTrialData.errorStatus(subN, trialI)==0
            if ~isempty(eyeTrialData.saccades.X_left.onsets_pursuit{subN, trialI}) ...
                    || ~isempty(eyeTrialData.saccades.X_right.onsets_pursuit{subN, trialI})

                sacOnsets = nanmin([eyeTrialData.saccades.X_left.onsets_pursuit{subN, trialI}; ...
                    eyeTrialData.saccades.X_right.onsets_pursuit{subN, trialI}]);
                sacLatency(subN, trialI) = sacOnsets-eyeTrialData.pursuit.onset(subN, trialI);
                % again, needs to flip the direction...
                if probSub(1)<50
                    leftMin = nanmin(eyeTrialData.saccades.X_right.onsets_pursuit{subN, trialI});
                    rightMin = nanmin(eyeTrialData.saccades.X_left.onsets_pursuit{subN, trialI});
                else
                    leftMin = nanmin(eyeTrialData.saccades.X_left.onsets_pursuit{subN, trialI});
                    rightMin = nanmin(eyeTrialData.saccades.X_right.onsets_pursuit{subN, trialI});
                end
                
                if sacOnsets==leftMin
                    sacDir(subN, trialI) = -1;
                elseif sacOnsets==rightMin
                    sacDir(subN, trialI) = 1;
                end
            end
        end
    end
end

% separate saccade-only trials by whether the first saccade direction is
% consistent/inconsistent with the perception\
for probNmerged = 1:3
    % the first column is consistent, second column is inconsistent
    eyePerceptCount{probNmerged} = zeros(length(names), 2);
    eyePerceptIdx{probNmerged} = cell(length(names), 2);
    for subN = 1:length(names)
        for idxI = 1:length(trialEyeIdx{probNmerged}{subN, 2})
            idxTrial = trialEyeIdx{probNmerged}{subN, 2}(idxI);
            if (sacDir(subN, idxTrial)<0 && eyeTrialData.choice(subN, idxTrial)==0) ||...
                    (sacDir(subN, idxTrial)>0 && eyeTrialData.choice(subN, idxTrial)==1) % consistent trials
                eyePerceptCount{probNmerged}(subN, 1) = eyePerceptCount{probNmerged}(subN, 1)+1;
                if isempty(eyePerceptIdx{probNmerged}{subN, 1})
                    eyePerceptIdx{probNmerged}{subN, 1} = idxTrial;
                else
                    eyePerceptIdx{probNmerged}{subN, 1} = [eyePerceptIdx{probNmerged}{subN, 1}; idxTrial];
                end
            else
                eyePerceptCount{probNmerged}(subN, 2) = eyePerceptCount{probNmerged}(subN, 2)+1;
                if isempty(eyePerceptIdx{probNmerged}{subN, 2})
                    eyePerceptIdx{probNmerged}{subN, 2} = idxTrial;
                else
                    eyePerceptIdx{probNmerged}{subN, 2} = [eyePerceptIdx{probNmerged}{subN, 1}; idxTrial];
                end
            end
        end
    end
end

% plot the distribution of trial types
clear meanCount steCount
for probNmerged = 1:3
        meanCount(probNmerged, :) = mean(eyePerceptCount{probNmerged});
        steCount(probNmerged, :) = std(eyePerceptCount{probNmerged})/sqrt(length(names));
end
errorbar_groups(meanCount, steCount,  ...
    'bar_width',0.75,'errorbar_width',0.5, ...
    'bar_names',{'consistent','inconsistent'});
legend({'50' '70' '90'}, 'location', 'best')
xlabel('Choice and first sac dir');
ylabel('Count');
cd(saccadeFolder)
saveas(gcf, ['sacPerceptTrialCount_all.pdf'])

% plot the difference of consistent and inconsistent trials
clear meanCount steCount
for probNmerged = 1:3
        meanCount(probNmerged, 1) = mean(eyePerceptCount{probNmerged}(:, 1)-eyePerceptCount{probNmerged}(:, 2));
        steCount(probNmerged, 1) = std(eyePerceptCount{probNmerged}(:, 1)-eyePerceptCount{probNmerged}(:, 2))/sqrt(length(names));
end
errorbar_groups(meanCount', steCount',  ...
    'bar_width',0.75,'errorbar_width',0.5, ...
    'bar_names', {'50' '70' '90'});
xlabel('Consistent-inconsistent trials');
ylabel('Count');
cd(saccadeFolder)
saveas(gcf, ['sacPerceptTrialCountDiff_all.pdf'])

% plot the latency of trial types
clear meanCount steCount
for probNmerged = 1:3
    for subN = 1:length(names)
        for sacEye = 1:2
            sacLatencySub{probNmerged}(subN, sacEye) = nanmean(sacLatency(subN, eyePerceptIdx{probNmerged}{subN, sacEye}));
        end
    end
    meanCount(probNmerged, :) = nanmean(sacLatencySub{probNmerged});
    steCount(probNmerged, :) = nanstd(sacLatencySub{probNmerged})/sqrt(length(names));
end
errorbar_groups(meanCount, steCount,  ...
    'bar_width',0.75,'errorbar_width',0.5, ...
    'bar_names',{'consistent','inconsistent'});
legend({'50' '70' '90'}, 'location', 'best')
xlabel('Choice and first sac dir');
ylabel('First saccade latency');
cd(saccadeFolder)
saveas(gcf, ['sacPerceptLatency_all.pdf'])