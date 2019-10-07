% function sortRawData
% to use in R, also to generate the raw data for palamedes
% Xiuyun Wu, 09/16/2019
clear all; close all; clc

%% basic setting
folder = pwd;
names = {'tA0'};
data = table();

%%
for sub = 1:size(names, 2)
    % Read all raw data
    % read Experiment data
    cd ..
    cd ..
    cd(['data\' names{sub}])
    % get the filenames to load
    fileResp = dir('response*.mat');
    % combine all response files for later use in eye data analysis
    parameters = [];
    for logN = 1:length(fileResp)
        load(fileResp(logN).name)
        parameters = [parameters; resp];
        parameters.trialIdx = [1:height(parameters)]';
    end
    save('parametersAll', 'parameters')
    
    % sort perceptual data
    fileResp = struct2cell(fileResp);
    % load raw data into dataRaw
    dataRaw = table();
    for jj = 1:size(fileResp, 2)
        load(fileResp{1, jj})
        if jj==1
%             resp.prob = 0.5*ones(size(resp, 1), 1);
            dataRaw = resp;
        else
%             resp.prob = 0.9*ones(size(resp, 1), 1);
            dataRaw = [dataRaw; resp];
        end
    end    
    dataRaw.sub = sub*ones(size(dataRaw, 1), 1);
    dataRaw.eyeType = ones(size(dataRaw, 1), 1);
%     dataRaw.fixDuration = [];
    cd(folder) 
    save(['dataRaw_', names{sub}], 'dataRaw')

    %% collapse all data
%     if ii==1
%         dataRawAll = dataRaw; % experiment
% %         dataRawBaseAll = dataRawBase; % baseline
%     else
%         dataRawAll = [dataRawAll; dataRaw]; % experiment
% %         dataRawBaseAll = [dataRawBaseAll; dataRawBase]; % baseline
%     end    
end
% save(['dataRaw_all', num2str(size(names, 2))], 'dataRawAll')
    
%     data.sub(dataIdx, 1) = 0;
%     data.trial(dataIdx, 1) = d1.jal.data(sub, 1);
%     data.coh(dataIdx, 1) = d1.jal.data(sub, 2);
%     data.dir(dataIdx, 1) = d1.jal.data(sub, 3); % 1-R, 2-L
%     data.resp(dataIdx, 1) = d1.jal.data(sub, 4); % 1-R, 2-L
%     data.rt(dataIdx, 1) = d1.jal.data(sub, 5);
%     data.trialType(dataIdx, 1) = d1.jal.data(sub, 6); % 1-std, 2-test
%     data.prob(dataIdx, 1) = .75;
%     dataIdx = dataIdx + 1;

% save csv
% writetable(dataRaw, 'psychometricFunctionData.csv');
