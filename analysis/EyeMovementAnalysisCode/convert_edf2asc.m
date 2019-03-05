%% script to convert Eyelink's edf data to matlab compatible asc files
% this script is structured in two steps
% (1) edf files are converted containing all events and massages
%     relevant experiment info is read out and stored in variables
% (2) edf files are then converted into pure samples

% history
% 01-11-2016	JF created convert2ascSynch.m
% 10-07-2018	JF edited the conversion script to a more general function
%               that can be used by future VPOM students

% for questions email jolande.fooken@rwth-aachen.de

close all;
clear all;

%% STEP 1
% Define different folder and data structure 
startFolder = [pwd '\'];  % Eyelink's edf2asc executable has to be in this folder
cd ..
cd ..
dataPath = fullfile(pwd,'data\'); %assuming that the data folder is in the start folder
folderNames = dir(dataPath); % this will be a list of all folders in the data folder, e.g. a list of all subjects
currentSubject = {};

%% STEP 2
<<<<<<< HEAD
% select folder by hand
cd(startFolder)
currentFolder = selectSubject(dataPath);
cd(currentFolder);

% or Loop over all subjects and convert
% for i = 3:3%3:length(folderNames) % we are starting at 3 because matlab always has 2 empty entries for the dir command
%     % define current subject/folder
%     currentSubject{i-2} = folderNames(i).name;        
%     currentFolder = [dataPath currentSubject{i-2}];
%     cd(currentFolder);  
=======
% Loop over all subjects and convert
for i = 3:length(folderNames) % we are starting at 3 because matlab always has 2 empty entries for the dir command
    % define current subject/folder
    currentSubject{i-2} = folderNames(i).name;        
    currentFolder = [dataPath currentSubject{i-2}];
    cd(currentFolder);  
>>>>>>> parent of 02672d1... improve saccade...
    % Step 2.1
    % this step converts edf to asc containing all information
    [res, stat] = system([startFolder 'edf2asc -y ' currentFolder '\*.edf']);
    cd(startFolder);
    % create a list of all converted files
    ascfiles = dir([currentFolder '\*.asc']);
    nHeader = 26; % this number depends on data collection; for EyeCatch/Strike it is 25
    % declare variables that you want to read out
    eventLog = table();
    % STEP 2.2
    % loop over all asc files for 1 subject/data folder
    for j = 1:length(ascfiles)
        ascfile = ascfiles(j).name;
        path = fullfile(currentFolder, ascfile);
        fid = fopen(path);
        % skip the header and then search for messages
        textscan(fid, '%*[^\n]', nHeader);
        entries = textscan(fid, '%s %s %s %*[^\n]');
        for lineN = 1:size(entries{1}, 1)
            if strcmp(entries{1}{lineN}, 'MSG')
                if strcmp(entries{3}{lineN}, 'fixationOn')
                    eventLog.fixationOn(j, 1) = str2num(entries{2}{lineN}); % read frame idx in original data
                elseif strcmp(entries{3}{lineN}, 'fixationOff')
                    eventLog.fixationOff(j, 1) = str2num(entries{2}{lineN});
                elseif strcmp(entries{3}{lineN}, 'rdkOn')
                    eventLog.rdkOn(j, 1) = str2num(entries{2}{lineN});
                elseif strcmp(entries{3}{lineN}, 'rdkOff')
                    eventLog.rdkOff(j, 1) = str2num(entries{2}{lineN});
                end
            end
        end
        %         label = strfind(entries{:}, 'MSG');
        %         idx = find(not(cellfun('isempty', label)));
        fclose(fid);
    end
    cd(currentFolder)
    save('eventLog', 'eventLog')
    cd(startFolder)
    % STEP 2.3
    % convert data into samples only and replace missing values with 9999
    [res, stat] = system([startFolder 'edf2asc -y -s -miss 9999 -nflags ' currentFolder '\*.edf']);
% end
