function info = getInfo(currentBlock, currentTrial, eyeType, prob, eyeTracker)
% using GUI to gather sub information/manipulate parameters

global info

info.dateTime = clock;

% questions and defaults
n = 1;
q{n} = 'subID'; defaults{n} = 'tE'; n = n+1;
q{n} = 'Eyetracker(1) or not(0)'; defaults{n} = num2str(eyeTracker); n = n+1;
q{n} = 'Probability of right (%)'; defaults{n} = num2str(prob); n = n+1; %L-lower; H-higher
q{n} = 'Block'; defaults{n} = num2str(currentBlock); n = n+1;
q{n} = 'Trial'; defaults{n} = num2str(currentTrial); n = n+1;
q{n} = 'Eye condition (0=fixation, 1-pursuit)'; defaults{n} = num2str(eyeType); n = n+1;

answer = inputdlg(q, 'Experiment basic information', 1, defaults);

% return value
n = 1;
info.subID = answer(n); n = n+1;
info.eyeTracker = str2num(answer{n}); n = n+1;
info.prob = str2num(answer{n}); n = n+1;
info.block = str2num(answer{n}); n = n+1;
info.trial = str2num(answer{n}); n = n+1;
info.eyeType = str2num(answer{n}); n = n+1;

info.fileNameTime = [info.subID{1}, '_', sprintf('%d-%d-%d_%d%d', info.dateTime(1:5))];

% save(['Info_', info.fileNameTime], 'info')

end
