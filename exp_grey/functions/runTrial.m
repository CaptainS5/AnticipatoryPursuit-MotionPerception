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
% fixation range for eye tracker--tolerance of fixation offset
[xSizeF ySizeF]= dva2pxl(prm.fixRange.radius, prm.fixRange.radius);
fixRange = [(prm.screen.center(1)-xSizeF) (prm.screen.center(2)-ySizeF) (prm.screen.center(1)+xSizeF) (prm.screen.center(2)+ySizeF)];

% set up Gap
gapFrames = round(sec2frm(prm.gap.duration));

% set up RDK
coh = list.coh(trialN, 1);
resp.coh(tempN, 1) = coh;
rdkDir = list.rdkDir(trialN, 1); % 0 = RIGHT, 180 = LEFT
resp.rdkDir(tempN, 1) = rdkDir;
trialType = list.trialType(trialN, 1); % 1 = standard trial, 0 = test trial
resp.trialType(tempN, 1) = trialType;
rdkFrames = round(sec2frm(prm.rdk.duration));

[dots.diameterX, ] = dva2pxl(2*prm.rdk.dotRadius, 2*prm.rdk.dotRadius);
[apetureRadiusX, ] = dva2pxl(2*prm.rdk.apetureRadius, 2*prm.rdk.apetureRadius);

% Postion dots in a circular aperture
dots.distanceToCenterX = apetureRadiusX * sqrt((rand(prm.rdk.dotNumber, 1))); %distance of dots from center
dots.distanceToCenterX = max(dots.distanceToCenterX-dots.diameterX/2, 0); %make sure that dots do not overlap outer border
theta = 2 * pi * rand(prm.rdk.dotNumber,1); %values between 0 and 2pi (2pi ~ 6.28)
dots.position = [cos(theta) sin(theta)];  %values between -1 and 1
dots.position = dots.position .* [dots.distanceToCenterX dots.distanceToCenterX/prm.screen.ppdX*prm.screen.ppdY];

% Size of the Motion period tolerance window
[xSizeM ySizeM]= dva2pxl(prm.motionRange.xLength, prm.motionRange.yLength);
motionRange = [(prm.screen.center(1)-xSizeM/2) (prm.screen.center(2)-ySizeM/2) (prm.screen.center(1)+xSizeM/2) (prm.screen.center(2)+ySizeM/2)];

trialInfo = sprintf('%d %d %d',trialN, list.coh(trialN,1), list.rdkDir(trialN,2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Eyelink('message', 'Trialinfo: %s', trialInfo);
WaitSecs(0.05);
Eyelink('Command', 'set_idle_mode'); %it puts the tracker into offline mode
WaitSecs(0.05); % it waits for 50ms before calling the startRecording function
Eyelink('StartRecording');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% start display
% blank screen
Screen('FillRect', prm.screen.windowPtr, prm.screen.backgroundColour); % fill background
Screen('Flip', prm.screen.windowPtr);

%% draw gaze position tolerance window on the operator (Eyelink host) PC
Eyelink('command','clear_screen 0'); % clears the box from the Eyelink-operator screen
% Eyelink('command','draw_box %d %d %d %d 7', FIX_BOX_COORDS(1),FIX_BOX_COORDS(2),FIX_BOX_COORDS(3),FIX_BOX_COORDS(4));
Screen('FrameOval', prm.screen.windowPtr, prm.screen.whiteColour, fixRange);
Screen('Flip', prm.eyeLink.el.window, [], 1); % don't erase

%% draw fixation at the beginning of each trial
% Check for presence of the eye position signal within the tolerance
% window and wait for a random interval before the Gap-screen
frameN = 1;
initialF = 0;
while frameN<=fixFrames
    % check for keyboard press
    [keyIsDown, secs, key] = KbCheck;
    % if spacebar was pressed stop display
    if strcmp(key, 'ESCAPE')
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
            % if data is valid, compare gaze position with the limits of the tolerance window
            diffFix = sqrt((xeye-prm.screen.center(1))^2+(yeye-prm.screen.center(2))^2);
            if diffFix <= prm.fixRange.radius % fixation ok
                if trialType==1
                    Screen('FillOval', prm.screen.windowPtr, prm.fixation.stdColour, rectFixDot);
                elseif trialType==0
                    Screen('FillOval', prm.screen.windowPtr, prm.fixation.testColour, rectFixDot);
                end
            elseif diffFix > prm.fixRange.radius % fixation out of range, show warning
                Snd('Play', prm.beep.sound, prm.beep.samplingRate, 16);
                % Plays the sound in case of wrong fixation
                Screen('FillOval', prm.screen.windowPtr, prm.screen.whiteColour, rectFixDot);
                frameN = frameN - 1;
            end
            if initialF==0
                [VBL fixOnTime] = Screen('Flip', prm.screen.windowPtr);
                initialF = 1;
                % Eyelink('message', 'StimulusOn');
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
            break;
        end
    end % if sample available
end

if StopCommand==1
    return;
end
% imgF = Screen('GetImage', prm.screen.windowPtr);
% imwrite(imgF, 'fixation.jpg')

%% Gap period
initialG = 0;
for frameN = 1:gapFrames
Screen('FillRect', prm.screen.windowPtr, prm.screen.backgroundColour); % fill background
if initialG = 0
[VBL fixOffTime] = Screen('Flip', prm.screen.windowPtr);
initialG = 1;
% Eyelink('message', 'StimulusOff');
else
    Screen('Flip', prm.screen.windowPtr);
end
end
resp.fixationDurationTrue(tempN, 1) = fixOffTime-fixOnTime;

Eyelink('command','clear_screen 0'); % clears the box from the Eyelink-operator screen
Screen('FrameOval', prm.screen.windowPtr, prm.screen.whiteColour, motionRange);
Screen('Flip', prm.eyeLink.el.window, [], 1); % don't erase

%% RDK
for frameN = 1:rdkFrames
    %mark zero-plot time in data file
            Eyelink('Message', 'SYNCTIME');
            Eyelink('message', 'TargetOn');

            %Draw dots on screen
% DKP changed to get antialiased dots  Try 1 or 2 (1 may give less jitter)
        Screen('DrawDots', prm.screen.windowPtr, transpose(dots.position),...
            dots.diameterX, prm.rdk.colour, prm.screen.center, 1);  % change 1 to 0 to draw square dots

            Eyelink('message', 'TargetOff');
            WaitSecs(0.05);
            Eyelink('command','clear_screen'); % clears the box from the Eyelink-operator screen
            Eyelink('StopRecording');
end


StimulusOffsetTime = GetSecs; % here is actually the offset time

%% Mask

%% Response
% response instruction
% if info.reportStyle==-1
%     textResp = ['Flash on which side is lower?'];
% elseif info.reportStyle==1
%     textResp = ['Flash on which side is higher?'];
% else
%     textResp = ['Wrong input. Please ask the experimenter.'];
% end
% Screen('DrawText', prm.screen.windowPtr, textResp, prm.screen.center(1)-200, prm.screen.center(2), prm.screen.whiteColour);

Screen('Flip', prm.screen.windowPtr);

% record response, won't continue until a response is recorded
recordFlag=0;
while quitFlag==0
    %     % response window
    %     if info.eyeTracker==1 && secs-StimulusOnsetTime>=prm.recording.stopDuration && recordFlag==0 % stop recording after a certain duration after offset
    %         trigger.stopRecording();
    %         recordFlag = 1;
    %     end
    % for quitting at any time
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
    if keyIsDown
        key = KbName(keyCode);
        break
    end
    %% mouse response
    % display the stimuli, random starting angle
    if isempty(x) % the first loop, random angle
        % show the cursor; put it at the start angle everytime
        respAngle = 90*rand-45;
        SetMouse(xCenter+cos((respAngle-90)/180*pi)*ecc, ...
            yCenter+sin((respAngle-90)/180*pi)*ecc, ...
            prm.screen.windowPtr);
    else % changing the angle of the next loop according to the cursor position
        respAngle = atan2(y-yCenter, x-xCenter)/pi*180+90;
    end
    %             ShowCursor('CrossHair',  prm.screen.windowPtr); % draw a text instead, which you can control thr color...
    if respAngle>180
        respAngle = respAngle-180;
    elseif respAngle<0
        respAngle = respAngle+180;
    end
    if fix(info.expType)~=info.expType % control torsion
        if display{blockN}.flashDisplaceLeft(trialN)==-1 % report the left
            rectFixResp=rectRotationL;
        elseif display{blockN}.flashDisplaceLeft(trialN)==1 % report the right
            rectFixResp=rectRotationR;
        end
    end
    Screen('DrawTexture', prm.screen.windowPtr, prm.resp.tex{sizeN}, [], rectFixResp, respAngle);
    %     if fix(info.expType)==info.expType
    Screen('FillOval', prm.screen.windowPtr, prm.fixation.colour, rectFixDot); % center of the wheel
    %     end
    Screen('DrawText', prm.screen.windowPtr, '+', x0, y0, prm.screen.blackColour);
    Screen('Flip', prm.screen.windowPtr);
    %     if trialN==1
    %     frameN = frameN+1;
    %     imgR = Screen('GetImage', prm.screen.windowPtr);
    %     imwrite(imgR, ['frame', num2str(frameN), '.jpg'])
    %     end
    %         Screen('AddFrameToMovie', prm.screen.windowPtr, [], [], mPtr);

    if ~isempty(x)
        x0 = x; % record "old" position
        y0 = y;
    end
    % get new mouse position
    [x, y, buttons, focus, valuators, valinfo] = GetMouse(prm.screen.windowPtr);

    if any(buttons) % record the last mouse position
        rt = GetSecs-StimulusOffsetTime;
        resp.reportAngle(tempN, 1) = respAngle;
        quitFlag = 1;
    end
    buttons = [];
    %% end of mouse response

    %     %% button response
    %         [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
    %     if keyIsDown
    %         %         if frameN>=rotationFrames/2+flashOnset
    %         if info.eyeTracker==1 && recordFlag==0 % stop recording after a certain duration after offset
    %             trigger.stopRecording();
    %             recordFlag = 1;
    %         end
    %         key = KbName(keyCode);
    %         rt = secs-StimulusOnsetTime;
    %         StimulusOnsetTime = [];
    %         quitFlag = 1;
    %         %         % draw fixation
    %         %         Screen('FrameOval', prm.screen.windowPtr, prm.fixation.colour, rectFixRing, dva2pxl(0.05), dva2pxl(0.05));
    %         %         Screen('FillOval', prm.screen.windowPtr, prm.fixation.colour, rectFixDot);
    %         %
    % %         Screen('Flip', prm.screen.windowPtr);
    %         %         else
    %         %             key = KbName(keyCode);
    %         %             rt = -1;
    %         %         end
    %         %         break
    %         %     elseif frameN==rotationFrames
    %         %         key = 'void';
    %         %         rt = 0;
    %     end
    %     %% end of button response
end
% end

% end
