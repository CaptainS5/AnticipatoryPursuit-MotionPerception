function startScript()
clc; clear all; close all;
%start GUI
%check whether there is a LogFiles folder on the same level as the
%experiment folder
try
    global prm info
    % set default values...
    currentBlock = 1;
    
    addpath(genpath(pwd))
    AssertOpenGL;
    % Key
    KbCheck;
    KbName('UnifyKeyNames');
    setParameters;
    cd ..
    
    cd('data\') 
    prm.resultPath = pwd;
    cd ..
    cd('exp_controlAdaptation\')
    prm.expPath = pwd;
    
    while(true)
        info = getInfo(currentBlock);
        runExp(); % baseline: block 0; experiment: block 1
        currentBlock = currentBlock+1;
        if currentBlock>3
            break
        end
    end
catch ME
    disp('Error in startScript');
    disp(ME.message);
    clear all;
    return;
end
end