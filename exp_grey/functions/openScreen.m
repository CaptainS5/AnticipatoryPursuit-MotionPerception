function openScreen
% function to Open screen in psychotoolbox

% 09/08/2015 jgc, edited 09/26/2017 by Xiuyun Wu

global prm

Screen('Preference', 'SkipSyncTests', 1);

% open window
prm.screen.whichscreen = max(Screen('Screens'));
[prm.screen.windowPtr, prm.screen.size] = Screen('OpenWindow', prm.screen.whichscreen);
% % for debug
% [prm.screen.windowPtr, prm.screen.size] = Screen('OpenWindow', prm.screen.whichscreen, [], [100, 100, 900, 700]);
% Screen(prm.screen.window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

prm.screen.blackColour = BlackIndex(prm.screen.windowPtr);
prm.screen.whiteColour = WhiteIndex(prm.screen.windowPtr);

prm.screen.backgroundColour = floor(prm.screen.whiteColour/2);

Screen('FillRect', prm.screen.windowPtr, prm.screen.backgroundColour);
Priority(MaxPriority(prm.screen.windowPtr));
Screen('Flip', prm.screen.windowPtr);

% monitor dimensions and center
prm.screen.resolution = Screen(prm.screen.windowPtr,'Resolution');
[prm.screen.center(1), prm.screen.center(2)] = RectCenter(prm.screen.size);
prm.screen.refreshRate = 1/Screen('GetFlipInterval', prm.screen.windowPtr); % refresh rate of the monitor
% in Hz (frames per second: fps)

% pixels per degree, calculated horizontally
prm.screen.ppdX = pi * (prm.screen.size(3)-prm.screen.size(1)) / atan(prm.screen.monitorWidth/2/prm.screen.viewDistance) / 360;
% pixels per degree, calculated vertically
prm.screen.ppdY = pi * (prm.screen.size(4)-prm.screen.size(2)) / atan(prm.screen.monitorHeight/2/prm.screen.viewDistance) / 360;

prm.screen.pixelRationWidthPerHeight = (prm.screen.monitorWidth/(prm.screen.size(3)-prm.screen.size(1)))/(prm.screen.monitorHeight/(prm.screen.size(4)-prm.screen.size(2)));

end
