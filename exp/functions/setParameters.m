
function setParameters
% define all paramters used in the exp

% All display lengths are in degree of visual angle (dva), time in s,
% colour range 0-255, physical distances in cm

global prm

% physical parameters, in cm
prm.screen.viewDistance = 55; % 57.29 cm corresponds to 1cm on screen as 1 dva
prm.screen.monitorWidth = 39.6; % horizontal dimension of viewable screen (cm)
% 29.4 for the laptop; 36 for the torsion monitor in X717; 39.6 for
% the backroom monitor in X715; 38.4 for ASUS
prm.screen.monitorHeight = 29.7;
% 16.5 for the laptop; 27.1 for the torsion monitor in X717; 29.7 for
% the backroom monitor in X715; 21.6 for ASUS
prm.screen.waitFrames = 1; % for display timing; flip every n frames

% display settings
% prm.screen.backgroundColour = []; % background, currently set in openScreen

% probability conditions
prm.probCons = [50 30 10];
% prm.probCons = [50 70 90];
% will be randomized and saved for each participant when running the first block

% fixation
prm.fixation.dotRadius = 0.15; % in dva
prm.fixation.stdColour = [255 0 0]; % fixation colour for standard trials
prm.fixation.testColour = [0 255 0]; % fixation colour for standard trials
prm.fixation.durationBase = 0.6;
prm.fixation.durationJitter = 0.3;
% fixation duration before each block is base+rand*jitter

% gap
prm.gap.duration = 0.3;

% RDK stimulus
prm.rdk.duration = 0.7; % display duration of the whole RDK
prm.rdk.dotDensity = 1.5; % dot per dva
prm.rdk.lifeTime = 0.7; % noise dots change direction every new life time
prm.rdk.labelUpdateTime = 0.05; % change labels and assign new directions for all
% for Transparent motion, label update time >= the whole rdk duration;
% for Brownian motion, label update time = one frame
% ========================================================================
% Notice that whenever label changes, new directions will also be assigned,
% so be careful with the relationship between lifeTime and labelUpdateTime
% ========================================================================
prm.rdk.dotRadius = 0.14/2;
prm.rdk.apertureRadius = 10;
prm.rdk.speed = 10; % dva per sec
% prm.rdk.colour = prm.screen.whiteColour; % currently set after openScreen
prm.rdk.dotNumber = round(prm.rdk.dotDensity*pi*prm.rdk.apertureRadius^2);

% Eyelink parameters
prm.eyeLink.nDrift = 50; % drift correction every n trials

% warning beep for feedback on fixation maintainance
prm.beep.samplingRate = 44100;
prm.beep.sound = 0.9 * MakeBeep(300, 0.1, prm.beep.samplingRate);

% text size
prm.textSize = 25;
% prm.textColour = prm.screen.blackColour; % currently set after openScreen

%Coordinates and size of two virtual boxes surrounding the fixation target and the moving
%target (working as static gaze position tolerance window)
%Fixation box
prm.fixRange.radius = 2;

% Size of the Motion period tolerance window
prm.motionRange.xLength = 50; % can be defined relative to the size of the RDK or just "large enough"; can be a box
prm.motionRange.yLength = 50; % Height

% dynamic mask
prm.mask.duration = 0.6;
prm.mask.maxLum = 0.7; % max luminance in the mask
prm.mask.minLum = 0.3;

% block conditions
prm.ITI = 0.05; % inter-trial interval
prm.reminderTrialN = 50; % progress report every N trials
prm.blockN = 6; % total number of blocks

% key bindings
prm.stopKey = 'q';
prm.rightKey = 'RightArrow';
prm.leftKey = 'LeftArrow';
prm.calibrationKey = 'c';

% end
