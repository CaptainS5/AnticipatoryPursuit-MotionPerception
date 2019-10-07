% generate list for adaptation...
clear; clc; close all
listTemp = load('perceptualList.mat');

trialN = 1;
list = table();
for ii = 1:size(listTemp.list, 1)
    list.coh(trialN, 1) = 0.2;
    list.rdkDir(trialN, 1) = 1;
    list.trialType(trialN, 1) = 1;
    trialN = trialN+1;
    
    list.coh(trialN, 1) = listTemp.list.coh(ii, 1);
    list.rdkDir(trialN, 1) = listTemp.list.rdkDir(ii, 1);
    list.trialType(trialN, 1) = listTemp.list.trialType(ii, 1);
    trialN = trialN+1;
end

save('testList.mat', 'list')