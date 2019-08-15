function runExp()
% clear all; close all; clc; 
% initialize exp info here: (subID--longest 4 letters--can be set in getInfo.m, or enter in GUI when you run the experiment)
% info.block: now it runs one block at a time; use 1-3 for experimental blocks, 0 for practice block
% currentTrial: can start with any trial number you like (in case being terminated before finishing the whole block), from 1-682
% prob: 50, 70, or 90 for experiment; enter 0 for the practice block (use practiceList), -1 for testList
% eyeTracker: 1-yes, 0-no
% eyeType: 1-pursuit, 0-fixation (fixation condition not implemented yet)
% info.block=3; info.currentTrial = 1; info.prob = 70; info.eyeTracker=1; info.eyeType = 1; 

% to use transparent/brownian motion, change line 332-339 in runTrial.m
% change other parameters in setParameters.m
% may need to change screen id in line 12 in openScreen.m
try
    global prm info list resp demoN imgDemo
    % prm--parameters, mostly defined in setParameters
    % display--all parameters (some pre-arranged) in the experiment, each block,
    % trial by trial
    % resp--the response, each block, trial by trial, what actually was
    % presented, including trials with invalid response/loss of fixation etc.

    % load trial info for the current block
    demoN = 0; % default not to record demo images
    if info.prob > 0
        load(['list', num2str(info.prob), 'prob.mat'])
    elseif info.prob == 0  % practice trials
        load('practiceList.mat')
    elseif info.prob == -1  % test trials
%         % for pilot
%         load('test100List.mat')
        load('testList.mat')
    elseif info.prob == -100 % demo trials
        load('demoList.mat')
        demoN = 0;
    else
        error('ERROR: condition table does not exist')
    end
    prm.trialPerCohLevel = length(find(list.coh==0)); % trial number per condition
    prm.trialPerBlock = size(list, 1);
    
    openScreen; % modify background color here
    prm.rdk.colour = prm.screen.whiteColour;
    prm.textColour = prm.screen.blackColour;
    
    HideCursor;
    
    % make the aperture
    Screen('BlendFunction', prm.screen.windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    [apertureRadiusX, apertureRadiusY] = dva2pxl(prm.rdk.apertureRadius, prm.rdk.apertureRadius);
    imgApt(:, :, 1) = ones(2*apertureRadiusY+1, 2*apertureRadiusX+1)*prm.screen.backgroundColour; % background layer
    transApt = zeros(2*apertureRadiusY+1, 2*apertureRadiusX+1); % transparency layer, now all transparent
    [x,y]=meshgrid(-apertureRadiusX:apertureRadiusX, -apertureRadiusY:apertureRadiusY);
    x = x/apertureRadiusX;
    y = y/apertureRadiusY;
    radiusA = sqrt(x.^2+y.^2);
    transApt(radiusA>1) = 255; % opaque out of the circle    
    imgApt(:, :, 2) = transApt;
    prm.aperture = Screen('MakeTexture', prm.screen.windowPtr, imgApt);
    
    % generate textures for the mask, the same size as the aperture
    maskFrameN = round(sec2frm(prm.mask.duration));
    for ii = 1:maskFrameN
        imgMask = unifrnd(prm.mask.minLum, prm.mask.maxLum, size(radiusA))*255;
        prm.mask.tex{ii} = Screen('MakeTexture', prm.screen.windowPtr, imgMask);
    end
    
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
        %% start the experiment
        % setting up filenames
        if info.trial==1
            prm.fileName.resp = [prm.fileName.folder, '\response', num2str(info.block), '_', info.fileNameTime];
        elseif info.trial>1
            prm.fileName.resp = [prm.fileName.folder, '\response', num2str(info.block), '_', num2str(info.trial), '_', info.fileNameTime];
        end
        % initialize the response
        resp = table(); % 1 = left, 2 = right
        
        trialN = info.trial; % the trial number to look up in random assignment
        %         tempN = 1; % number of trials presented so far
        %         trialMakeUp = [];
        %         makeUpN = 0;
        
        %% Initializes the connection with Eyelink
        if info.eyeTracker==1
            if EyelinkInit()~= 1; %
                error('Problems with Eyelink connection!');
                return;
            end
            prm.eyeLink.el=EyelinkInitDefaults(prm.screen.windowPtr);
            prm.eyeLink.el.backgroundcolour = 0;
            prm.eyeLink.el.foregroundcolour = 255;
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            % check which eye is recorded
            prm.eyeLink.eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
            if prm.eyeLink.eye_used == -1
                prm.eyeLink.eye_used = prm.eyeLink.el.RIGHT_EYE;
            end
            
            % make sure that we get gaze data from the Eyelink
            Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
            Eyelink('Command', 'link_update_interval = 50'); % extends the keep alive 
            % time for the network connection to make sure the connection stays active 
            % even during long pauses, nly need to set it once at the start of the experiment
            
            %             % open file to record data to
            %             if eyeTracker==1
            %                 % prepare eye recording
            %                 prm.eyeLink.edfName = [info.subID{:}, 'b', num2str(info.block), '.edf'];
            %                 if (size(prm.eyeLink.edfName, 2)-4>8)
            %                     error('edf filename is too long!'); % Security loop against Eyelink
            %                     % Un-registration of data if namefile
            %                 end
            %                 % open file to record data to
            %                 cd([prm.fileName.folder, '\'])
            %                 Eyelink('Openfile', prm.eyeLink.edfName);
            %             end
            
            % STEP 4
            % Calibrate the eye tracker
            EyelinkDoTrackerSetup(prm.eyeLink.el);
            
            % do a final check of calibration using driftcorrection
            EyelinkDoDriftCorrection(prm.eyeLink.el);
            %         elseif eyeTracker==0
            %             Eyelink('Initializedummy');
        end
        
        % initial welcome
        if trialN==1
            textBlock = ['Block ', num2str(info.block), '\n Press any key'];
            Screen('TextSize', prm.screen.windowPtr, prm.textSize);
            DrawFormattedText(prm.screen.windowPtr, textBlock,...
                'center', 'center', prm.textColour);        % if info.eyeType==0
            Screen('Flip', prm.screen.windowPtr);
            
            KbWait();
            WaitSecs(prm.ITI);
        end
        
        if info.eyeTracker==1
            % prepare eye recording
            prm.eyeLink.edfName = [info.subID{:}, 'b', num2str(info.block), '.edf'];
%             prm.eyeLink.edfName = [info.subID{:}, 'b', num2str(info.block), 't', num2str(trialN, '%03d'), '.edf'];
            if (size(prm.eyeLink.edfName, 2)-4>8)
                error('edf filename is too long!'); % Security loop against Eyelink
                % Un-registration of data if namefile
            end
            % open file to record data to
            cd([prm.fileName.folder, '\'])
            Eyelink('Openfile', prm.eyeLink.edfName);
        end
        
        % run trials
        Priority(2)
        while trialN<=prm.trialPerBlock
            clear KbCheck
           
            %
            % present the stimuli and recording response
            [key rt] = runTrial(info.block, trialN);
            % trialN is the index for looking up in list;
            
            % record responses
            if strcmp(key, prm.leftKey)
                resp.choice(trialN, 1) = 0;
            elseif strcmp(key, prm.rightKey)
                resp.choice(trialN, 1) = 1;
            elseif strcmp(key, prm.stopKey) % quit
                break
            elseif strcmp(key, 'std') % standard trials, no response
                resp.choice(trialN, 1) = 999;
            end
            resp.RTms(trialN, 1) = rt*1000; % in ms
            resp.prob(trialN, 1) = info.prob;
            resp.eyeType(trialN, 1) = info.eyeType;
            
            % save the response
            save(prm.fileName.resp, 'resp');
            
            trialN = trialN+1
        end
        Priority(0)
        
        text =['Finished! \n It will exit automatically...'];
        Screen('TextSize', prm.screen.windowPtr, prm.textSize);
        DrawFormattedText(prm.screen.windowPtr, text,...
            'center', 'center', prm.textColour);
        Screen('Flip', prm.screen.windowPtr);
        
        %
        if info.eyeTracker==1
            % eye recording output
%             Eyelink('Command','clear_screen 0'); % clears the box from the Eyelink-operator screen
%             Eyelink('Command', 'set_idle_mode');
            WaitSecs(0.5);
            Eyelink('CloseFile');
            try
                fprintf('Receiving data file ''%s''\n', prm.eyeLink.edfName);
                status=Eyelink('ReceiveFile');
                if status > 0
                    fprintf('ReceiveFile status %d\n', status);
                end
                if 2==exist(prm.eyeLink.edfName, 'file')
                    fprintf('Data file ''%s'' can be found in ''%s''\n', prm.eyeLink.edfName, prm.fileName.folder);
                end
            catch
                fprintf('Problem receiving data file ''%s''\n', prm.eyeLink.edfName, prm.fileName.folder);
            end
        end

    end
    
    if demoN>0
        cd([prm.expPath, '\demo'])
        for ii = 1:length(imgDemo)
            imwrite(imgDemo{ii}, ['frame', num2str(ii), '.jpg'])
        end
    end
    
    prm.fileName.prm = [prm.fileName.folder, '\parameters', num2str(info.block), '_', info.fileNameTime];
    save(prm.fileName.prm, 'prm');
%     save([prm.fileName.folder '\dotMatrices', num2str(info.block), '_', info.fileNameTime], 'dots'); % safe dot matrices if needed; very
%     large files...
    if info.eyeTracker==1
        Eyelink('ShutDown');
    end
    Screen('CloseAll')
    Screen('Close')
    
catch expME
    disp('Error in runExp: \n');
    rethrow(expME);
    Screen('CloseAll')
    Screen('Close')
    if info.eyeTracker==1
        Eyelink('StopRecording');
        Eyelink('ShutDown');
    end
end
% end
