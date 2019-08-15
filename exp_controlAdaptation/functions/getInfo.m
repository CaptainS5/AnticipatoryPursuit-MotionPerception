function info = getInfo(currentBlock)
% using GUI to gather sub information/manipulate parameters

global prm

info.dateTime = clock;

% questions and defaults
n = 1;
q{n} = 'subID'; defaults{n} = 'tXW'; n = n+1;
q{n} = 'Eyetracker(1) or not(0)'; defaults{n} = num2str(1); n = n+1;
q{n} = 'Eye condition (0=fixation, 1-pursuit)'; defaults{n} = num2str(1); n = n+1;
q{n} = 'Block'; defaults{n} = num2str(currentBlock); n = n+1;
q{n} = 'Trial'; defaults{n} = num2str(1); n = n+1;
% q{n} = 'Probability of right (%)'; defaults{n} = num2str(0); n = n+1; % 50, 70, or 90

answer = inputdlg(q, 'Experiment basic information', 1, defaults);

% return value
n = 1;
info.subID = answer(n); n = n+1;
info.eyeTracker = str2num(answer{n}); n = n+1;
info.eyeType = str2num(answer{n}); n = n+1;
info.block = str2num(answer{n}); n = n+1;
info.trial = str2num(answer{n}); n = n+1;
% info.prob = str2num(answer{n}); n = n+1;

% creating saving path and filenames
if info.block==0 % pracrice block, save in the practive folder
    prm.fileName.folder = [prm.resultPath, '\', info.subID{1}, '\practice'];
else
    prm.fileName.folder = [prm.resultPath, '\', info.subID{1}];
end
mkdir(prm.fileName.folder)
info.fileNameTime = [info.subID{1}, '_', sprintf('%d-%d-%d_%d%d', info.dateTime(1:5))];

% prob: 50, 70, or 90 for experiment; 
% 0 for the practice block (use practiceList), -1 for testList,
% -100 for demoList
if info.block==0
    info.prob = 0;
else
    if info.block==1 && info.trial==1
        rng shuffle
        probCons = prm.probCons;
        randIdx = randperm(length(probCons));
        probCons = probCons(randIdx);
        % save prob order for the current block
        save([prm.fileName.folder, '\probOrder_', info.subID{1}], 'probCons')
    else
        load([prm.fileName.folder, '\probOrder_', info.subID{1}])
    end
    info.prob = probCons(info.block);
end

% % for pilot
% info.prob= -1;

% save info for the current block
save([prm.fileName.folder, '\Info', num2str(info.block), '_', info.fileNameTime], 'info')

end
