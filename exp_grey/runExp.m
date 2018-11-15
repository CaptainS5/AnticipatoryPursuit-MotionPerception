% function currentBlock = runExp(currentBlock, eyeType, prob, eyeTracker)
clear all; close all; clc; currentBlock=1; eyeType = 1; prob = 75; eyeTracker=0;% debugging
try
    global prm display resp info
    % prm--parameters, mostly defined in setParameters
    % display--all parameters (some pre-arranged) in the experiment, each block,
    % trial by trial
    % resp--the response, each block, trial by trial, what actually was
    % presented, including trials with invalid response/loss of fixation etc.
    addpath(genpath(pwd))
    AssertOpenGL;
    
    setParameters;
    cd ..
    cd('data\')
    prm.resultPath = pwd;
    cd ..
    cd('exp_grey\')
    prm.expPath = pwd;
    
    info = getInfo(currentBlock, eyeType, prob, eyeTracker);
    
    % creating saving path and filenames
    prm.fileName.folder = [prm.resultPath, '\', info.subID{1}];
    mkdir(prm.fileName.folder)
    % save info for the current block
    save([prm.fileName.folder, '\Info', num2str(currentBlock), '_', info.fileNameTime], 'info')
    
    % load trial info for the current block
    if info.prob == 50
        load('list50prob.mat')
    elseif info.prob == 75
        load('list75prob.mat')
    elseif info.prob == 90
        load('list90prob.mat')
    elseif info.prob == -1 % test trials
        load('testList.mat')
    else
        error('ERROR: condition table does not exist')
    end
    prm.trialPerCohLevel = length(find(list.coh==0)); % trial number per condition
    prm.trialPerBlock = size(list, 1);
    
    openScreen; % modify background color here
    % Key
    KbCheck;
    KbName('UnifyKeyNames');
    HideCursor;
    
    %     generate textures for the mask
    for ii = 1:maskFrameN
        imgMask = unifrnd(prm.mask.minLum, prm.mask.maxLum)*255;
        prm.mask.tex{ii} = Screen('MakeTexture', prm.screen.windowPtr, imgMask);
    end
    
    % allow transparency
    Screen('BlendFunction', prm.screen.windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    if strcmp(info.subID{1}, 'luminance')
        % testing monitor luminance
        Screen('FillRect', prm.screen.windowPtr, prm.screen.backgroundColour); % fill background
        Screen('Flip', prm.screen.windowPtr);
        KbWait();
        clear KbCheck
        % WaitSecs(0.2);
        %
        % Screen('FillRect', prm.screen.windowPtr, prm.grating.lightest); % fill background
        % Screen('Flip', prm.screen.windowPtr);
        % KbWait();
    else
        % start the experiment
        info.block = info.block;
        % setting up filenames
        prm.fileName.resp = [prm.fileName.folder, '\response', num2str(info.block), '_', info.fileNameTime];
        % initialize the response
        resp = table(); % 1 = left, 2 = right
        % initialize the randomization that will be made in each trial
        resp.fixDuration = zeros(prm.trialPerBlock, 1);
        
        trialN = 1; % the trial number to look up in random assignment
        tempN = 1; % number of trials presented so far
        trialMakeUp = [];
        makeUpN = 0;
        
        % initial welcome
        textBlock = ['Block ', num2str(info.block)];
        Screen('DrawText', prm.screen.windowPtr, textBlock, prm.screen.center(1)-60, prm.screen.center(2), prm.screen.whiteColour);
        % if info.eyeType==0
        %     reportInstruction = 'Report LOWER';
        % elseif info.eyeType==1
        %     reportInstruction = 'Report HIGHER';
        % else
        %     eyeType = 'Wrong! Get experimenter.'
        % end
        %         Screen('DrawText', prm.screen.windowPtr, reportInstruction, prm.screen.center(1)-100, prm.screen.center(2)+50, prm.screen.whiteColour);
        Screen('Flip', prm.screen.windowPtr);
        KbWait();
        WaitSecs(prm.ITI);
        
        % run trials
        while tempN<=prm.trialPerBlock+makeUpN
            clear KbCheck
            if tempN>prm.trialPerBlock
                trialN = trialMakeUp(tempN-prm.trialPerBlock);
            end
            % present the stimuli and recording response
            [key rt] = runTrial(info.block, trialN, tempN);
            % trialN is the index for looking up in list;
            % tempN is the actual trial number, including invalid trials
            resp.trialIdx(tempN, 1) = trialN; % index for the condition used
            if strcmp(key, 'LeftArrow')
                resp.choice(tempN, 1) = 0;
            elseif strcmp(key, 'RightArrow') %
                resp.choice(tempN, 1) = 1;
                %             elseif strcmp(key, 'void') % no response
                %                 resp{info.block}.choice(trialN, 1) = 0;
                
            elseif strcmp(key, 'ESCAPE') % quit
                break
            else % wrong key
                % % repeat this trial at the end of the block
                % makeUpN = makeUpN + 1;
                % trialMakeUp(makeUpN) = trialN;
                resp.choice(tempN, 1) = 999;
                % feedback on the screen
                respText = 'Invalid Key';
                Screen('DrawText', prm.screen.windowPtr, respText, prm.screen.center(1)-80, prm.screen.center(2), prm.screen.whiteColour);
                Screen('Flip', prm.screen.windowPtr);
            end
            resp.RTms(tempN, 1) = rt*1000; % in ms
            
            % save the response
            save(prm.fileName.resp, 'resp');
            
            trialN = trialN+1
            tempN = tempN+1;
            
            % ITI
            Screen('Flip', prm.screen.windowPtr);
            WaitSecs(prm.ITI);
        end
    end
    prm.fileName.prm = [prm.fileName.folder, '\parameters', num2str(info.block), '_', info.fileNameTime];
    save(prm.fileName.prm, 'prm');
    
    Eyelink('ShutDown');
    Screen('CloseAll')
    
catch expME
    disp('Error in runExp: \n');
    disp(expME.message);
    Screen('CloseAll')
    Eyelink('StopRecording');
    Eyelink('ShutDown');
end
% end
