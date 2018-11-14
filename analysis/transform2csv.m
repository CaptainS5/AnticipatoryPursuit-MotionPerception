% function transform2csv
% to use in R

cd ..
cd('data\')

d1 = load('jal_s00APp75');
% d2 = load('jal_s0APp90');
data = table();

dataIdx = 1;
for ii = 1:size(d1.jal.data, 1)
    data.sub(dataIdx, 1) = 0;
    data.trial(dataIdx, 1) = d1.jal.data(ii, 1);
    data.coh(dataIdx, 1) = d1.jal.data(ii, 2);
    data.dir(dataIdx, 1) = d1.jal.data(ii, 3); % 1-R, 2-L
    data.resp(dataIdx, 1) = d1.jal.data(ii, 4); % 1-R, 2-L
    data.rt(dataIdx, 1) = d1.jal.data(ii, 5);
    data.trialType(dataIdx, 1) = d1.jal.data(ii, 6); % 1-std, 2-test
    data.prob(dataIdx, 1) = .75;
    dataIdx = dataIdx + 1;
end

% for ii = 1:size(d2.jal.data, 1)
%     data.sub(dataIdx, 1) = 0;
%     data.trial(dataIdx, 1) = d2.jal.data(ii, 1);
%     data.coh(dataIdx, 1) = d2.jal.data(ii, 2);
%     data.dir(dataIdx, 1) = d2.jal.data(ii, 3); % 1-R, 2-L
%     data.resp(dataIdx, 1) = d2.jal.data(ii, 4); % 1-R, 2-L
%     data.rt(dataIdx, 1) = d2.jal.data(ii, 5);
%     data.trialType(dataIdx, 1) = d2.jal.data(ii, 6); % 1-std, 2-test
%     data.prob(dataIdx, 1) = .9;
%     dataIdx = dataIdx + 1;
% end

% merge and save csv
cd('E:\XiuyunWu\AnticipatoryPursuit-MotionPerception\analysis')
writetable(data, 'pilot00.csv')
