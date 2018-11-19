function [key rt] = runTrial(blockN, trialN, tempN)

global prm info resp list

% Initialization
% fill the background
Screen('FillRect', prm.screen.windowPtr, prm.screen.backgroundColour); % fill background
resp.trialIdx(tempN, 1) = trialN; % index for the current trial

% set up fixation
resp.fixationDuration(tempN, 1) = prm.fixation.durationBase+rand*prm.fixation.durationJitter;
fixFrames = round(sec2frm(resp.fixationDuration(tempN, 1)));
[rectSizeDotX rectSizeDotY] = dva2pxl(prm.fixation.dotRadius, prm.fixation.dotRadius);
rectSizeDotX = round(rectSizeDotX);
rectSizeDotY = round(rectSizeDotY);
rectFixDot = [prm.screen.center(1)-rectSizeDotX,...
    prm.screen.center(2)-rectSizeDotY,...
    prm.screen.center(1)+rectSizeDotX,...
    prm.screen.center(2)+rectSizeDotY];
[fixRangeRadius, ] = round(dva2pxl(prm.fixRange.radius, prm.fixRange.radius)); % radius in pxl

% set up Gap
gapFrames = round(sec2frm(prm.gap.duration));

% set up RDK
coh = list.coh(trialN, 1);
resp.coh(tempN, 1) = coh;
rdkDir = list.rdkDir(trialN, 1); % -1=left, 1=right
resp.rdkDir(tempN, 1) = rdkDir;
trialType = list.trialType(trialN, 1); % 1 = standard trial, 0 = test trial
resp.trialType(tempN, 1) = trialType;
rdkFrames = round(sec2frm(prm.rdk.duration));

[dots.diameterX, ] = dva2pxl(2*prm.rdk.dotRadius, 2*prm.rdk.dotRadius);
[apertureRadiusX, apertureRadiusY] = dva2pxl(2*prm.rdk.apertureRadius, 2*prm.rdk.apertureRadius);

% Postion dots in a circular aperture
dots.distanceToCenterX = apertureRadiusX * sqrt((rand(prm.rdk.dotNumber, 1))); % distance of dots from center
dots.distanceToCenterX = max(dots.distanceToCenterX-dots.diameterX/2, 0); % make sure that dots do not overlap outer border
theta = 2 * pi * rand(prm.rdk.dotNumber,1); % values between 0 and 2pi (2pi ~ 6.28)
dots.positionTheta = [cos(theta) sin(theta)];  % values between -1 and 1
dots.position = dots.positionTheta .* [dots.distanceToCenterX dots.distanceToCenterX/prm.screen.ppdX*prm.screen.ppdY];
% initialize dot presentation time
dots.showTime = round(rand(1, prm.rdk.dotNumber)*sec2frm(prm.rdk.lifeTime)); % in frames

% dots movement distance in each frame, depends on coherence
moveTheta = 2 * pi * rand(prm.rdk.dotNumber, 1); % all random directions except 0/2pi, or the horizontal right
idx = randperm(prm.rdk.dotNumber); % random order of the dots
percentTarget = round(coh*prm.rdk.dotNumber); % number of dots should be moving coherently
moveTheta(idx(1:percentTarget), 1) = 0; % assign the dots to be coherently moving rightwards
moveTheta = [cos(moveTheta) sin(moveTheta)];

[moveDistanceToCenterX, ] = dva2pxl(prm.rdk.speed, prm.rdk.speed);
dots.movementPerFrame = rdkDir*moveTheta/prm.screen.refreshRate.*[moveDistanceToCenterX moveDistanceToCenterX/prm.screen.ppdX*prm.screen.ppdY];

% set up mask
maskFrameN = round(sec2frm(prm.mask.duration));

% Make an aperature
Screen('BlendFunction', prm.screen.windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
apertureRect = [prm.screen.center(1)-apertureRadiusX,...
    prm.screen.center(2)-apertureRadiusY,...
    prm.screen.center(1)+apertureRadiusX,...
    prm.screen.center(2)+apertureRadiusY];
aperature = Screen('OpenOffscreenwindow', prm.screen.windowPtr, prm.screen.backgroundColour, prm.screen.size);
Screen('FillOval', aperature, [255 255 255 100], apertureRect);

% set up eye position tolerance spatial windows
% tolerance of fixation
[xSizeF ySizeF]= dva2pxl(prm.fixRange.radius, prm.fixRange.radius);
fixRange = [(prm.screen.center(1)-xSizeF) (prm.screen.center(2)-ySizeF) (prm.screen.center(1)+xSizeF) (prm.screen.center(2)+ySizeF)];
% Size of the Motion period tolerance window
[xSizeM ySizeM]= dva2pxl(prm.motionRange.xLength, prm.motionRange.yLength);
motionRange = [(prm.screen.center(1)-xSizeM/2) (prm.screen.center(2)-ySizeM/2) (prm.screen.center(1)+xSizeM/2) (prm.screen.center(2)+ySizeM/2)];

trialInfo = sprintf('%d %d %d',trialN, list.coh(trialN,1), list.rdkDir(trialN,1));
if info.eyeTracker==1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Eyelink('message', 'Trialinfo: %s', trialInfo);
    WaitSecs(0.05);
    % Before recording, we place reference graphics on the host display
    % Must be in offline mode to transfer image to Host PC
    Eyelink('Command', 'set_idle_mode'); %it puts the tracker into offline mode
    WaitSecs(0.05); % it waits for 50ms before calling the startRecording function
    Eyelink('StartRecording');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%% start display
% blank screen
Screen('FillRect', prm.screen.windowPtr, prm.screen.backgroundColour); % fill background
Screen('Flip', prm.screen.windowPtr);

%% draw gaze position tolerance window on the operator (Eyelink host) PC
% if info.eyeTracker==1
%     Eyelink('command','clear_screen 0'); % clears the box from the Eyelink-operator screen
%     Eyelink('command','draw_box %d %d %d %d 7', fixRange(1), fixRange(2), fixRange(3), fixRange(4));
% %     Screen('FrameOval', prm.screen.windowPtr, prm.screen.whiteColour, fixRange);
% %     Screen('Flip', prm.eyeLink.el.window, [], 1); % don't erase
% end

%% draw fixation at the beginning of each trial
% Check for presence of the eye position signal within the tolerance
% window and wait for a random interval before the Gap-screen
frameN = 1;
initialF = 0;
StopCommand = 0;
while frameN<=fixFrames
    % check for keyboard press
    [keyIsDown, secs, keyCode] = KbCheck;
    % if stopkey was pressed stop display
    if keyIsDown
        key = KbName(keyCode)
        if strcmp(key, prm.stopKey)
            StopCommand = 1;
            break;
        end
    end
    
    if info.eyeTracker==1
        % check for presence of a new sample update
        if Eyelink( 'NewFloatSampleAvailable') > 0
            %         if info.eyeTracker==1% get the sample in the form of an event structure
            evt = Eyelink( 'NewestFloatSample');
            xeye = evt.gx(prm.eyeLink.eye_used+1); % +1 as we're accessing MATLAB array
            yeye = evt.gy(prm.eyeLink.eye_used+1);
            % !!!!   CHECK WHAT IS EYE_USED DURING THE MOUSE SIMULATION    !!!
            % [xeye, yeye, buttons]=GetMouse(screenInfo.curWindow) % It does NOT work,
            % it checks the Display PC mouse
            
            %% do we have valid data and is the pupil visible?
            if xeye~=prm.eyeLink.el.MISSING_DATA & yeye~=prm.eyeLink.el.MISSING_DATA & evt.pa(prm.eyeLink.eye_used+1)>0
                % if data is valid, compare gaze position with the limits of the tolerance window
                diffFix = sqrt((xeye-prm.screen.center(1))^2+((yeye-prm.screen.center(2))/prm.screen.ppdY*prm.screen.ppdX)^2);
                if diffFix <= fixRangeRadius || info.eyeTracker==0 % fixation ok
                    if trialType==1
                        Screen('FillOval', prm.screen.windowPtr, prm.fixation.stdColour, rectFixDot);
                    elseif trialType==0
                        Screen('FillOval', prm.screen.windowPtr, prm.fixation.testColour, rectFixDot);
                    end
                elseif diffFix > fixRangeRadius % fixation out of range, show warning
                    Snd('Play', prm.beep.sound, prm.beep.samplingRate, 16);
                    % Plays the sound in case of wrong fixation
                    Screen('FillOval', prm.screen.windowPtr, prm.screen.whiteColour, rectFixDot);
                    frameN = frameN - 1;
                end
                if initialF==0
                    [VBL fixOnTime] = Screen('Flip', prm.screen.windowPtr);
                    initialF = 1;
                    if info.eyeTracker==1
                        Eyelink('message', 'fixationOn');
                    end
                else
                    Screen('Flip', prm.screen.windowPtr);
                end
                frameN = frameN + 1;
            else
                % if data is invalid (e.g. during a blink), redo the calibration
                EyelinkDoTrackerSetup(prm.eyeLink.el);
                frameN = 1;
            end
        else
            error=Eyelink('CheckRecording');
            if(error~=0)
                disp('EyeLink CheckRecording Error')
            end
            StopCommand = 1;
        end % if sample available
    else
        if trialType==1
            Screen('FillOval', prm.screen.windowPtr, prm.fixation.stdColour, rectFixDot);
        elseif trialType==0
            Screen('FillOval', prm.screen.windowPtr, prm.fixation.testColour, rectFixDot);
        end
        if initialF==0
            [VBL fixOnTime] = Screen('Flip', prm.screen.windowPtr);
            initialF = 1;
        else
            Screen('Flip', prm.screen.windowPtr);
        end
        frameN = frameN + 1;
    end
    if StopCommand==1
        break;
    end
end

if StopCommand==1
    key='ESCAPE'; rt=0;
    return;
end
% imgF = Screen('GetImage', prm.screen.windowPtr);
% imwrite(imgF, 'fixation.jpg')

%% Gap period
initialG = 0;
for frameN = 1:gapFrames
    Screen('FillRect', prm.screen.windowPtr, prm.screen.backgroundColour); % fill background
    if initialG == 0
        [VBL fixOffTime] = Screen('Flip', prm.screen.windowPtr);
        initialG = 1;
        if info.eyeTracker==1
            Eyelink('message', 'fixationOff');
        end
    else
        Screen('Flip', prm.screen.windowPtr);
    end
end
resp.fixationDurationTrue(tempN, 1) = fixOffTime-fixOnTime;

% if info.eyeTracker==1
%     Eyelink('command','clear_screen 0'); % clears the box from the Eyelink-operator screen
% %     Screen('FrameOval', prm.screen.windowPtr, prm.screen.whiteColour, motionRange);
% %     Screen('Flip', prm.eyeLink.el.window, [], 1); % don't erase
% end

%% RDK
for frameN = 1:rdkFrames
    if info.eyeTracker==1
        %mark zero-plot time in data file
        Eyelink('Message', 'SYNCTIME');
        Eyelink('message', 'rdkOn');
    end
    
    %Draw dots on screen
    % DKP changed to get antialiased dots  Try 1 or 2 (1 may give less jitter)
    Screen('DrawDots', prm.screen.windowPtr, transpose(dots.position),...
        dots.diameterX, prm.rdk.colour, prm.screen.center, 1);  % change 1 to 0 to draw square dots
    %     Screen('DrawTexture', prm.screen.windowPtr, aperature);
    if frameN==1
        [VBL rdkOnTime] = Screen('Flip', prm.screen.windowPtr);
    else
        Screen('Flip', prm.screen.windowPtr);
    end
    
    % Updated positions (similar to initial dot placement)
    dots.position = dots.position + dots.movementPerFrame;
    dotDist = dots.position(:, 1).^2 + (dots.position(:, 2)*prm.screen.ppdX/prm.screen.ppdY).^2;
    outDots = find(dotDist>apertureRadiusX^2);
    %     outN = length(outDots)
    % replace dots out of the aperture
    dots.distanceToCenterX(outDots) = apertureRadiusX * sqrt((rand(length(outDots),1)));
    dots.distanceToCenterX(outDots) = max(dots.distanceToCenterX(outDots)-dots.diameterX/2, 0);
    % generate new positions
    dots.position(outDots, :) = dots.positionTheta(outDots, :) .* [dots.distanceToCenterX(outDots) dots.distanceToCenterX(outDots)/prm.screen.ppdX*prm.screen.ppdY];
    dots.showTime(outDots) = round(sec2frm(prm.rdk.lifeTime)) + 1;
    
    % Update dot lifetime and replace dots with expired lifetime
    dots.showTime = dots.showTime-1;
    expiredDots = find(dots.showTime <=0);
    %     expN = length(expiredDots)
    dots.distanceToCenterX(expiredDots) = apertureRadiusX * sqrt((rand(length(expiredDots),1)));
    dots.distanceToCenterX(expiredDots) = max(dots.distanceToCenterX(expiredDots)-dots.diameterX/2, 0);
    % generate new positions
    dots.position(expiredDots, :) = dots.positionTheta(expiredDots, :) .* [dots.distanceToCenterX(expiredDots) dots.distanceToCenterX(expiredDots)/prm.screen.ppdX*prm.screen.ppdY];
    dots.showTime(expiredDots) = round(sec2frm(prm.rdk.lifeTime));
    
    if info.eyeTracker==1
        Eyelink('message', 'rdkOff');
        WaitSecs(0.05);
        Eyelink('command','clear_screen'); % clears the box from the Eyelink-operator screen
        Eyelink('StopRecording');
    end
end

% rdkOffsetTime = GetSecs; % here is actually the offset time

if trialType==1 % present dynamic mask if it's standard trial
    %% Mask
    % random order of the textures
    maskIdx = randperm(maskFrameN);
    for maskF = 1:maskFrameN
        Screen('DrawTextures', prm.screen.windowPtr, prm.mask.tex{maskIdx(maskF)});
        Screen('DrawTexture', prm.screen.windowPtr, aperature);
        
        % if demoN > 0
        %     imgDemo{demoN} = Screen('GetImage', prm.screen.windowPtr, [], 'backbuffer');
        %     demoN = demoN + 1;
        % end
        [VBL rdkOffTime] = Screen('Flip', prm.screen.windowPtr);
    end
    key = 'std'; rt = 0;
elseif trialType==0 % record response in test trials
    %% Response
    while KbCheck; end % Wait until all keys are released
    % response instruction
    textResp = ['LEFT or RIGHT?'];
    Screen('TextSize', prm.screen.windowPtr, 55);
    DrawFormattedText(prm.screen.windowPtr, textResp, 'center', 350, prm.screen.blackColour);
    
    [VBL rdkOffTime] = Screen('Flip', prm.screen.windowPtr);
    
    % record response, won't continue until a response is recorded
    recordFlag=0;
    startSecs = GetSecs;
    while recordFlag==0
        %% button response
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
        if keyIsDown
            key = KbName(keyCode);
            rt = secs-rdkOffTime;
            recordFlag = 1;
            % break
        end
        %% end of button response
    end
end
resp.rdkDuration(tempN, 1) = rdkOffTime-rdkOnTime;

% %%%%%%%%%%%%%%%%% Loop for trials countdown %%%%%%%%%%%%%%%%%%%
if rem(trialN, prm.reminderTrialN)==0
    trialsLeft = prm.trialPerBlock-trialN;
    text =[num2str(trialsLeft), ' trials remaining'];
    Screen('TextSize', prm.screen.windowPtr, prm.textSize);
    DrawFormattedText(prm.screen.windowPtr, text,...
        'center', 'center', prm.textColour);
    Screen('Flip', prm.screen.windowPtr);
    WaitSecs(0.8);
end

if info.eyeTracker==1 && rem(trialN, prm.eyeLink.nDrift)==0
    % do a periodic driftcorrection
    EyelinkDoDriftCorrection(prm.eyeLink.el);
end

% blank screen
Screen('FillRect', prm.screen.windowPtr, prm.screen.backgroundColour); % fill background
Screen('Flip', prm.screen.windowPtr);
