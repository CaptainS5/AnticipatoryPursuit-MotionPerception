% mostly generating csv files for R
initializeParas;

%% compare between the experiments
% probCons = [50 90]; 
% cd(RFolder)
% cd('Exp1')
% % d{1} = readtable('dataAPvelX_exp1.csv');
% d{1} = readtable('dataclpGainX_exp1.csv');
% d{1}(d{1}.prob==70, :) = [];
% d{1}.exp = ones(size(d{1}.sub));
% % cd ..
% % cd('Exp2')
% % d{2} = readtable('dataAPvelX_exp2.csv');
% % d{2}.exp = 2*ones(size(d{2}.sub));
% cd ..
% cd('Exp3')
% % d{3} = readtable('dataAPvelX_exp3.csv');
% d{3} = readtable('dataclpGainX_exp3.csv');
% d{3}.exp = 3*ones(size(d{3}.sub));
% cd ..
% 
% % experiment 1 and 2
% % % asp velocity
% % % find the correct participants from exp1
% % nanI = find(strcmp(nameSets{2}, 'nan'));
% % tempD1 = d{1};
% % for ii = 1:length(nanI)
% %     tempD1(tempD1.sub==nanI(ii), :) = [];
% % end
% % for ii = 1:length(nanI)
% %     tempD1.sub(tempD1.sub>nanI(ii)-ii+1, 1) = tempD1.sub(tempD1.sub>nanI(ii)-ii+1, 1)-1;
% % end
% % 
% % data = [tempD1; d{2}];
% % writetable(data, 'aspVel_exp1vs2.csv')
% 
% % experiment 1 and 3
% % asp velocity
% % find the correct participants from exp1
% tempD1 = d{1}(d{1}.sub<=9, :);
% data = [tempD1; d{3}];
% writetable(data, 'clpGain_exp1vs3.csv')

%% organize data for steady-state pursuit, separated by visual x perceived motion in probe trials
cd(RFolder)
cd('Exp1')
probCons = [50 70 90];
dir = [-1 1];

% calculate gain from the velocity values...
d = readtable('clpMeanVelX_perceptualVisualByPerceived_exp1.csv');
d.measure = d.measure./10.*d.visualDir;
writetable(d, 'clpGainX_perceptualVisualByPerceived_exp1.csv')

% % first, organize the absolute values for each participant--to see if we need
% % to exclude any
% dAbs = readtable('dataclpAbsMeanVelX_perceptualVisualLperceived_exp1.csv');
% dAbs.visualDir = -ones(size(dAbs.sub));
% dAbsT = readtable('dataclpAbsMeanVelX_perceptualVisualRperceived_exp1.csv');
% dAbsT.visualDir = ones(size(dAbsT.sub));
% dAbs = [dAbs; dAbsT]; % dir is perceived direction
% writetable(dAbs, 'clpAbsMeanVelX_perceptualVisualByPerceived_exp1.csv')

% then, organize the mean values
% d = readtable('dataclpMeanVelX_perceptualVisualLperceived_exp1.csv');
% d.visualDir = -ones(size(d.sub));
% dT = readtable('dataclpMeanVelX_perceptualVisualRperceived_exp1.csv');
% dT.visualDir = ones(size(dT.sub));
% d = [d; dT]; % dir is perceived direction
% % writetable(d, 'clpMeanVelX_perceptualVisualByPerceived_exp1.csv')

% d = readtable('dataclpMeanVelX_correctPerceptualPerceived_exp1.csv');
% d.visualConsistency = ones(size(d.sub));
% dT = readtable('dataclpMeanVelX_wrongPerceptualPerceived_exp1.csv');
% dT.visualConsistency = zeros(size(dT.sub))-1;
% d = [d; dT]; % dir is perceived direction
% writetable(d, 'clpMeanVelX_perceptualPerceivedVisualConsistency_exp1.csv')

% % lastly, group trials by motion consistency between visual and perceived
% % directions; just flip visual left trials first, then average
% dMerge = table();
% count1 = 1;
% count2 = 1;
% for subN = 1:10
%     for probN = 1:3
%         for visualDirN = 1:2
%             dMerge.sub(count1, 1) = subN;
%             dMerge.prob(count1, 1) = probCons(probN);
%             if visualDirN==1
%                 % visual left, not including 0-coh trials
%                 idxLL = find(d.sub==subN & d.prob==probCons(probN) & d.visualDir==-1 & d.dir==-1);
%                 idxLR = find(d.sub==subN & d.prob==probCons(probN) & d.visualDir==-1 & d.dir==1);
%                 dMerge.visualDir(count1, 1) = -1;
%                 dMerge.perceptEffect(count1, 1) = -(d.measure(idxLL, 1)-d.measure(idxLR, 1));
%                 
% %                 % visual left, including 0-coh trials
% %                 idxLCon = find(d.sub==subN & d.prob==probCons(probN) & d.visualConsistency==1 & d.dir==-1);
% %                 idxLIncon = find(d.sub==subN & d.prob==probCons(probN) & d.visualConsistency==-1 & d.dir==1);
% %                 dDiff.visualDir(count, 1) = -1;
% %                 dDiff.perceptEffect(count, 1) = -(d.measure(idxLCon, 1)-d.measure(idxLIncon, 1));
%             else
%                 % visual right, not including 0-coh trials
%                 idxRR = find(d.sub==subN & d.prob==probCons(probN) & d.visualDir==1 & d.dir==1);
%                 idxRL = find(d.sub==subN & d.prob==probCons(probN) & d.visualDir==1 & d.dir==-1);
%                 dMerge.visualDir(count1, 1) = 1;
%                 dMerge.perceptEffect(count1, 1) = d.measure(idxRR, 1)-d.measure(idxRL, 1);
%                 
% %                 % visual right, including 0-coh trials
% %                 idxRCon = find(d.sub==subN & d.prob==probCons(probN) & d.visualConsistency==1 & d.dir==1);
% %                 idxRIncon = find(d.sub==subN & d.prob==probCons(probN) & d.visualConsistency==-1 & d.dir==-1);
% %                 dDiff.visualDir(count, 1) = 1;
% %                 dDiff.perceptEffect(count, 1) = d.measure(idxRCon, 1)-d.measure(idxRIncon, 1);
%             end
%             count1 = count1+1;            
%         end
%         
%         dDiffMerge.sub(count2, 1) = subN;
%         dDiffMerge.prob(count2, 1) = probCons(probN);
%         dDiffMerge.perceptEffect(count2, 1) = nanmean([dMerge.perceptEffect(count1-2, 1); dMerge.perceptEffect(count1-1, 1)]);
%         count2 = count2+1; 
%     end
% end
% writetable(dMerge, 'clpMeanVelX_effectOfPerception_no0cohTrials_exp1.csv')

%% extract data of perceptual trials to use for bootstrapping in python
% % each row is one trial
% data = table();
% for expN = 1:3
%     dataT = table();
%     eyeTrialData = expAll{expN}.eyeTrialData;
%     if expN==2 % need to adjust the participant index...
%         eyeTrialData.sub(eyeTrialData.sub==8) = 10;
%         eyeTrialData.sub(eyeTrialData.sub>=3 & eyeTrialData.sub<=7) = eyeTrialData.sub(eyeTrialData.sub>=3 & eyeTrialData.sub<=7)+1;
%     end
%     idx = find(eyeTrialData.trialType==0 & eyeTrialData.errorStatus ==0 & ~isnan(eyeTrialData.pursuit.APvelocityX));
%     dataT.sub = eyeTrialData.sub(idx);
%     dataT.exp = repmat(expN, size(idx));
%     dataT.prob = eyeTrialData.prob(idx);
%     dataT.rdkDir = eyeTrialData.rdkDir(idx);
%     dataT.coh = eyeTrialData.coh(idx);
%     dataT.choice = eyeTrialData.choice(idx);
%     dataT.aspVelX = eyeTrialData.pursuit.APvelocityX(idx);
%     data = [data; dataT];
% end
% 
% cd(RFolder)
% writetable(data, 'perceptualTrialsAllExps_AXP.csv')