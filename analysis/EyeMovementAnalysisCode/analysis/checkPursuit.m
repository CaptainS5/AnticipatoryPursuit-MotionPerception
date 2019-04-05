% use eyeDataAll to do more analysis with pursuit
% check pursuit properties based on trial condition/perceptual
% response

clear all; close all; clc

names = {'XW0'};
sampleRate = 1000;
% % for plotting
% minVel = [-6];
% maxVel = [12];
% folder = pwd;
% 
% % dirCons = [-1 1]; % -1=left, 1=right
% % dirNames = {'left' 'right'};
% colorPlotting = [255 182 135; 137 126 255; 113 204 100]/255; % each row is one colour for one probability

for subN = 1:size(names, 2)
    cd(folder)
    load(['eyeData_' names{subN} '.mat']);
    probCons = unique(eyeTrialData.prob(eyeTrialData.errorStatus==0));
    cd ..
    
    % build up of AP? sliding window across trials, 20 trials bins
    
    % sort trials by preceeding probability of right, plot AP
    
    % sort trials by perceptual responses, plot AP and steady-state
    % pursuit    
    
end