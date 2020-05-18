% function transform2csv
% to use for bootstrapping in python
initializeParas;

%% extract data of perceptual trials
% each row is one trial
data = table();
for expN = 1:3
    dataT = table();
    eyeTrialData = expAll{expN}.eyeTrialData;
    if expN==2 % need to adjust the participant index...
        eyeTrialData.sub(eyeTrialData.sub==8) = 10;
        eyeTrialData.sub(eyeTrialData.sub>=3 & eyeTrialData.sub<=7) = eyeTrialData.sub(eyeTrialData.sub>=3 & eyeTrialData.sub<=7)+1;
    end
    idx = find(eyeTrialData.trialType==0 & eyeTrialData.errorStatus ==0 & ~isnan(eyeTrialData.pursuit.APvelocityX));
    dataT.sub = eyeTrialData.sub(idx);
    dataT.exp = repmat(expN, size(idx));
    dataT.prob = eyeTrialData.prob(idx);
    dataT.rdkDir = eyeTrialData.rdkDir(idx);
    dataT.coh = eyeTrialData.coh(idx);
    dataT.choice = eyeTrialData.choice(idx);
    dataT.aspVelX = eyeTrialData.pursuit.APvelocityX(idx);
    data = [data; dataT];
end

cd(RFolder)
writetable(data, 'perceptualTrialsAllExps_AXP.csv')