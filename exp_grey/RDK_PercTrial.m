% script RDK_PercTrial
% we use it as a script for debugging purposes
% 7/6/2016 Anna Montagnini and Austin Rothwell
% adapted 11/1/2018 Xiuyun Wu
%% current parameters: refresh rate = 60 Hz, 1 frame = 17ms
% dot lifetime is one frame, presented again two frames after--three frames
% in a loop

% function trialres = RDK_PercTrial(stimcond)
% function that displays a RDK stimulus (generated through the Shadlen Dots-stimuli routines)
% and collect the subject's response (Right/Left key) corresponding to the
% perceived direction. argin "stimcond" specifies the coherence and direction of signal-dots in the RDK stimulus
clear all; close all; clc
global imgDemo demoN

try
    resultpath = 'D:\AnticipatoryPursuitMotionPerception\data';
    addpath(genpath(pwd))
    clear res;
%     Screen('Preference', 'SkipSyncTests', 1);
    
    %%%%%% parameters to be entered with line command or GUI %%%%%%
%     info = getInfo;
    subj = input('Number of the subject: ');
    if isempty(subj), subj = 0; end
    session = input('Session (a,b,c...): ', 's');
    if isempty(session), session = 'a'; end
    prop = input('Percentage of Right movements (default = 50): ');
    if isempty(prop), prop = 50; end
    eyeTracker = input('EyeTracker (0=no, 1=yes): ');
    if isempty(eyeTracker), eyeTracker = 0; end
    
    % load condition table
    if prop == 50
        load('UPDATEDlist50prob.mat')
    elseif prop == 75
        load('UPDATEDlist75prob.mat')
    elseif prop == 90
        load('UPDATEDlist90prob.mat')
    elseif prop == -1 % test trials
        load('testList.mat')
    else
        error('ERROR: that condition table does not exist')
    end
    
    % number of trials for each type of stimulus
    NTrials = length(list);
    nRem_trials = 50;   %  progress report trials (every nRem_trials)
    
    % % selects the lookup table corresponding to the current p-bias value
    % % load the NTrials table wrt the proportion of right movements
    
    %eval(sprintf('load list.mat'));
    % eval(sprintf('load list_%d.mat',prop)); % list contains 2 (? columns) -> this list has to specify for each trial all the information necessary to display the RDK
    %                                         % e.g. 0 = Rightward motion
    %                                         % 1 = Leftward motion
    %                                         % 2 = Rightward motion
    %                                         % 3 = Leftward motion
    %
    % list = list(1:NTrials);
    
    outres_filename = ['s' num2str(subj) 'AP' session num2str(prop)]; % name of oculomotor results file
    if (size(outres_filename,2)>8)
        error('edf filename is too long!');              % Security loop against Eyelink                                    % Un-registration of data if namefile
    end                                                  % is too long
    edfFile=[outres_filename, '.edf'];
    
    outres_filenameB = ['jal_' 's' num2str(subj) 'AP' session num2str(prop)]; % name of behavioural results file
    
    jal.cols = {'trial' 'coherence' 'RDK-dir (1=R;2=L)' 'Response (1=R;2=L)' 'Response Time' 'Trial Type (1=std;0=test)'};
    
    %%%%%%%%%%%%%%%%%%%%%%%% TRIAL FIXED PARAMETERS for DIRECTION DISCRIMINATION TRIALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    KbName('UnifyKeyNames');
    stopkey=KbName('ESCAPE'); % defines the keyboard command to manually stop
    StopCommand = 0;
    % the experiment (after saving existing data)
    RightKey = KbName('RightArrow');
    LeftKey = KbName('LeftArrow');
    
    %     cuecol = [255 0 0]; % color of the central cue (it has to signal the perceptual trials and differenciate them from standard pursuit trials)
    % ##do not use the cue for now
    cuecol = [0 255 0];
    fix_dur = 0.3 + unifrnd(0.3,0.6); % uniformly distributed random duration of central fixation
    gap_dur=0.3; % fixed gap duration
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%% DISPLAY and EYELINK PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nDrift = 50;
    
    % Initialize the screen
    screenInfo = openExperiment(49.5,57,0);
    
    %%DISPLAY center x and y coords
    [x,y] = RectCenter(screenInfo.screenRect);
    
    % Initialize dots
    % Check ./ShadlenDotsX/createMinDotInfo to change parameters
    dotInfo = createDotInfo(1);
    
    
    %%%%%%%%%%% WARNING BEEP %%%%%%%%%%%%
    
    %set beep for feedback on fix maintainance (within window)
    freq = 44100;
    beep2(1,:) = 0.9 * MakeBeep(300, 0.1, freq);
    
    %Coordinates and size of two virtual boxes surrounding the fixation target and the moving
    %target (working as static gaze position tolerance window)
    %Fixation box
    xsize = 400; % x-size in pixels 
    % ## (WE HAVE TO FIGURE OUT THE PIXEL TO DEGREES CONVERSION)--use
    % ## that change function here
    ysize = 400;
    FIX_BOX_COORDS = [(x-xsize/2) (y-ysize/2) (x+xsize/2) (y+ysize/2)];
    
    % Size of the Motion period tolerance window
    W_MW = 1200; % Width in pixels (it can be defined relative to the size of the RDK or just "large enough")
    H_MW = 400; % Height
    MOV_BOX_COORDS = [(x-W_MW/2) (y-H_MW/2) (x+W_MW/2) (y+H_MW/2)]; % Motion period box
    
    % Size of the fixation dot in pixels
    W = 10;
    H =10;    
    
    % Dynamic mask, generated before hand, just use random orders of
    % the textures
    maskTime = 0.7; % s
    maskFrameN = round(maskTime*screenInfo.monRefresh);
    for ii = 1:maskFrameN
        noise{ii} = round(rand(600,600))*255;
        noiseTexture{ii} = Screen('MakeTexture', screenInfo.curWindow, noise{ii});
    end
    
    %% Initializes the connection with Eyelink
    if eyeTracker==1
        if EyelinkInit()~= 1; %
            error('Problems with Eyelink connection!');
            return;
        end
        el=EyelinkInitDefaults(screenInfo.curWindow);
        el.backgroundcolour = 0;
        el.foregroundcolour = 255;
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % check which eye is recorded
        eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
        if eye_used == -1
            eye_used = el.RIGHT_EYE;
        end
        
        % make sure that we get gaze data from the Eyelink
        Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
        
        % open file to record data to
        
        Eyelink('Openfile', edfFile);
        
        % STEP 4
        % Calibrate the eye tracker
        EyelinkDoTrackerSetup(el);
        
        % do a final check of calibration using driftcorrection
        EyelinkDoDriftCorrection(el);
    else
        Eyelink('Initializedummy');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%% EXPERIMENT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    demoN = 1;
    for trial=1:NTrials
        WaitSecs(0.05);
        res(trial,1) = trial;
        res(trial,2) = list(trial,1); % RDK coherence
        if list(trial,2) == 0 % RDK direction (1 = Right; 2 = Left)
            res(trial,3) = 1;
        else
            res(trial,3) = 2;
        end
        res(trial,6) = list(trial,3); % Trial Type (1 = Standard; 0 = Test)
        
        trialInfo = sprintf('%d %d %d',trial,list(trial,1),list(trial,2));
        %
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Eyelink('message', 'Trialinfo: %s', trialInfo);
        WaitSecs(0.05);
        Eyelink('Command', 'set_idle_mode'); %it puts the tracker into offline mode
        WaitSecs(0.05); % it waits for 50ms before calling the startRecording function
        Eyelink('StartRecording');
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Black screen
        %Screen('FillRect', screenInfo.curWindow, black);
        Screen('FillRect', screenInfo.curWindow, screenInfo.bckgnd);
        
                
        if trial~=1
            demoN = 0;
        end
        if demoN > 0
            imgDemo{demoN} = Screen('GetImage', screenInfo.curWindow, [], 'backbuffer');
            demoN = demoN + 1;
        end
        [VBL StimulusOnsetTime] = Screen('Flip', screenInfo.curWindow);
        [x,y] = RectCenter(screenInfo.screenRect);
        positionOfMainCircle=[(x-W/2) (y-H/2) (x+W/2) (y+H/2)]; % position of the fixation target
        
        if list(trial,3) == 1
            Screen('FillArc',screenInfo.curWindow, cuecol, positionOfMainCircle, 0 ,360);
        else
            Screen('FillArc',screenInfo.curWindow, [0 255 0], positionOfMainCircle, 0 ,360);
        end        

        if demoN > 0
            imgDemo{demoN} = Screen('GetImage', screenInfo.curWindow, [], 'backbuffer');
            demoN = demoN + 1;
        end
        [VBL StimulusOnsetTime]=Screen('Flip', screenInfo.curWindow);
        
        % Eyelink('message', 'StimulusOn');
        
        %% draw gaze position tolerance window on the operator (Eyelink host) PC
        Eyelink('command','clear_screen 0'); % clears the box from the Eyelink-operator screen
        Eyelink('command','draw_box %d %d %d %d 7', FIX_BOX_COORDS(1),FIX_BOX_COORDS(2),FIX_BOX_COORDS(3),FIX_BOX_COORDS(4));
        
        FixTime = 0;
        
        % %%%% Check for presence of the eye position signal within the tolerance
        % %%%% window and wait for a random interval before the Gap-screen %%%%
        
        while (FixTime < fix_dur)
            CurrentTime = GetSecs; % GetSecs returns the time in seconds (based on internal clock)
            FixTime = CurrentTime - StimulusOnsetTime;
            % check for keyboard press
            [keyIsDown,secs,keyCode] = KbCheck;
            % if spacebar was pressed stop display
            if keyCode(stopkey)
                StopCommand = 1;
                break;
            end
            
            % check for presence of a new sample update
            if Eyelink( 'NewFloatSampleAvailable') > 0
                % get the sample in the form of an event structure
                evt = Eyelink( 'NewestFloatSample');
                xeye = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                yeye = evt.gy(eye_used+1);
                
                % !!!!   CHECK WHAT IS EYE_USED DURING THE MOUSE SIMULATION    !!!
                % [xeye, yeye, buttons]=GetMouse(screenInfo.curWindow) % It does NOT work,
                % it checks the Display PC mouse
                
                %% do we have valid data and is the pupil visible?
                if xeye~=el.MISSING_DATA & yeye~=el.MISSING_DATA & evt.pa(eye_used+1)>0
                    % if data is valid, compare gaze position with the
                    % limits of the tolerance window
                    diffx = abs(xeye) - abs(positionOfMainCircle(1) + xsize/2);
                    diffy = abs(yeye) - abs(positionOfMainCircle(2) + ysize/2);
                    diffx = abs(xeye - positionOfMainCircle(1)) - xsize/2;
                    diffy = abs(yeye - positionOfMainCircle(2)) - ysize/2;
                    if (diffx > 0 || diffy > 0)
                        Snd('Play', beep2, freq, 16); %Plays the sound in case
                        %of wrong fixation
                        Screen('Flip', screenInfo.curWindow);
                        
                        WaitSecs(0.1);
                        Screen('FillArc',screenInfo.curWindow, 255, positionOfMainCircle, 0 ,360);
                        [VBL StimulusOnsetTime] = Screen('Flip', screenInfo.curWindow);
                        WaitSecs(0.1);
                        % SkipTrial = 1;
                        FixTime = 0;
                    end
                else
                    % if data is invalid (e.g. during a blink), clear display
                    Screen('FillRect', screenInfo.curWindow, screenInfo.bckgnd);
                    Screen('Flip', screenInfo.curWindow);
                    
                    WaitSecs(0.2);
                    Screen('FillArc',screenInfo.curWindow, screenInfo.bckgnd, positionOfMainCircle, 0 ,360);
                    [VBL StimulusOnsetTime] = Screen('Flip', screenInfo.curWindow);
                    WaitSecs(0.1);
                    % SkipTrial = 1;
                    FixTime = 0;
                    % I need a WARNING to be able to correct eye signal!!!
                end
            else
                error=Eyelink('CheckRecording');
                if(error~=0)
                    WaitSecs(0.5);
                end
            end % if sample available
        end %end of while loop on fixation
        
        if StopCommand==1
            break;
        end
        %%%% GAP period %%%%
        % Grey screen
        Screen('FillRect', screenInfo.curWindow, screenInfo.bckgnd);        
        
        if demoN > 0
            imgDemo{demoN} = Screen('GetImage', screenInfo.curWindow, [], 'backbuffer');
            demoN = demoN + 1;
        end
        [VBL StimulusOnsetTime] = Screen('Flip', screenInfo.curWindow);
        
        Eyelink('message', 'StimulusOff');
        WaitSecs(gap_dur);
        
        Eyelink('command','draw_box %d %d %d %d 7',MOV_BOX_COORDS(1),MOV_BOX_COORDS(2),MOV_BOX_COORDS(3),MOV_BOX_COORDS(4));
        
        
        %%%%%%%%%%%%%%%%%%%%%%%% RDK display %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        %%%%%%% RDK %%%%%%%
        
        % update cohesion and direction from condition table
        dotInfo.coh = list(trial,1);
        dotInfo.dir = list(trial,2);
        
        %mark zero-plot time in data file
        Eyelink('Message', 'SYNCTIME');
        Eyelink('message', 'TargetOn');
        
        % make rdk
        [frames, rseed, start_time, end_time, response, response_time] = ...
            dotsX(screenInfo, dotInfo);
        
        Eyelink('message', 'TargetOff');
        WaitSecs(0.05);
        Eyelink('command','clear_screen'); % clears the box from the Eyelink-operator screen
        Eyelink('StopRecording');
        
        
        %%%%%%%%%%%%%%%%%%%%%%%% RESPONSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % response iff it is a test trial
        if list(trial,3) == 0
            % Collect keyboard press for manual response: Right Landolt or Left Landolt
            % (Left Key for Left Landolt and Right Key for Right Landolt)
            while KbCheck; end % Wait until all keys are released.
            
            % black=BlackIndex(screenInfo.curWindow); %value for white pixel%color value for text
            
            line1 = 'LEFT or RIGHT?';
            Screen('TextSize', screenInfo.curWindow, 55);
            DrawFormattedText(screenInfo.curWindow, [line1],...
                'center',350, [0 0 0]);            
            
            if demoN > 0
                imgDemo{demoN} = Screen('GetImage', screenInfo.curWindow, [], 'backbuffer');
                demoN = demoN + 1;
            end
            Screen('Flip', screenInfo.curWindow);
            
            startSecs = GetSecs;
            dummy = 0;
            while (dummy==0)
                % Check the state of the keyboard.
                [ keyIsDown, seconds, keyCode ] = KbCheck;
                
                % If the user is pressing a key, then display its code number and name.
                if keyIsDown
                    if (keyCode(RightKey)||keyCode(LeftKey))
                        choice = KbName(keyCode);
                        choice_RT = seconds - startSecs;
                        dummy = 1;
                        %break;
                    end
                end
            end
            
            if strcmp(choice,'RightArrow')
                answer=1;   %answer=1 means RIGHT
                res(trial,4) = answer;
            elseif strcmp(choice,'LeftArrow')
                answer=2;  %answer=2 means LEFT
                res(trial,4) = answer;
            end
            res(trial,5) = choice_RT;
            
            % if answer==res(trial,3)
            %     Snd('Play', beep, freq_OK, 16);
            %     Score=Score+1;
            % else
            %     Snd('Play', beep, freq_BAD, 16);
            %     Score=Score-1;
            % end
        end
        
        
        %%%%%%%%%%%%%%%%% Loop for trials countdown %%%%%%%%%%%%%%%%%%%
        if (rem(trial,nRem_trials)==0 && (NTrials-trial>1))
            drift=0;
            %EyelinkDoDriftCorrection(el)
            nn=NTrials-trial;
            eval(sprintf('text1=''%d trials remaining''',nn));
            Screen('DrawText', screenInfo.curWindow, text1,800,400,[0 0 0]);            
            
            if demoN > 0
                imgDemo{demoN} = Screen('GetImage', screenInfo.curWindow, [], 'backbuffer');
                demoN = demoN + 1;
            end
            Screen('Flip', screenInfo.curWindow);
            
            WaitSecs(0.8);
        end
        
        if (rem(trial,nDrift)==0 && (NTrials-trial>1))
            % do a periodic driftcorrection
            EyelinkDoDriftCorrection(el);
        end
        
        Screen('BlendFunction', screenInfo.curWindow, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
        
        % Make an aperature
        objCirc = floor(createTRect(dotInfo.apXYD, screenInfo));
        aperature = Screen('OpenOffscreenwindow', screenInfo.curWindow, screenInfo.bckgnd, screenInfo.screenRect);
        Screen('FillOval', aperature, [255 255 255 100], objCirc);
        
        % present dynamic mask
        % random order of the textures
        maskIdx = randperm(maskFrameN);
        for maskF = 1:maskFrameN
            Screen('DrawTextures', screenInfo.curWindow, noiseTexture{maskIdx(maskF)});
            Screen('DrawTexture', screenInfo.curWindow, aperature);
            
            if demoN > 0
                imgDemo{demoN} = Screen('GetImage', screenInfo.curWindow, [], 'backbuffer');
                demoN = demoN + 1;
            end
            [VBL StimulusOnsetTime] = Screen('Flip', screenInfo.curWindow);
            
        end
        % background
        Screen('FillRect', screenInfo.curWindow, screenInfo.bckgnd);      
        if demoN > 0
        imgDemo{demoN} = Screen('GetImage', screenInfo.curWindow, [], 'backbuffer');
        demoN = demoN + 1;
        end
        [VBL StimulusOnsetTime] = Screen('Flip', screenInfo.curWindow);
         
    end % end of while-loop on NTrials trials
    
    for ii = 1:length(imgDemo)
        imwrite(imgDemo{ii}, ['frame', num2str(ii), '.jpg'])
    end
    
    %%%%%% Following command creates files with colimns Rmotion and Lmotion %%%%%%
    
    Eyelink('CloseFile');
    
    jal.data = res;
    cd(resultpath);
    save(outres_filenameB,'jal');
    
    try
        %         cd(resultpath);
        
        fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
    catch
        fprintf('Problem receiving data file ''%s''\n', edfFile );
    end
    
    Eyelink('ShutDown');
    
    Screen('CloseAll');
    
catch
    Screen('CloseAll')
    
end
