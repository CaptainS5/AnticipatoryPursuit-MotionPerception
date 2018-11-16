function setParameters
% define all paramters used in the exp

% All display lengths are in degree of visual angle (dva), time in s,
% colour range 0-255, physical distances in cm

global prm

% physical parameters, in cm
prm.screen.viewDistance = 45; % 57.29 cm corresponds to 1cm on screen as 1 dva
prm.screen.monitorWidth = 35.2; % horizontal dimension of viewable screen (cm)
% 29.4 for the laptop; 36 for the torsion monitor in X717
prm.screen.monitorHeight = 27;
% 16.5 for the laptop; 27.1 for the torsion monitor in X717

% display settings
% prm.backgroundColour = []; % background, currently set in openScreen

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
prm.rdk.dotNumber = 150;
prm.rdk.lifeTime = 0.016;
prm.rdk.dotRadius = 0.15;
prm.rdk.apetureRadius = 10;
% prm.rdk.colour = prm.screen.whiteColour; % currently set after openScreen

% Eyelink parameters
prm.eyeLink.nDrift = 50;

% warning beep for feedback on fixation maintainance
prm.beep.samplingRate = 44100;
prm.beep.sound = 0.9 * MakeBeep(300, 0.1, prm.beep.samplingRate);

%Coordinates and size of two virtual boxes surrounding the fixation target and the moving
    %target (working as static gaze position tolerance window)
    %Fixation box
    prm.fixRange.radius = 1;

    % Size of the Motion period tolerance window
    prm.motionRange.xLength = 50; % can be defined relative to the size of the RDK or just "large enough"; can be a box
    prm.motionRange.yLength = 50; % Height

% dynamic mask
prm.mask.duration = 0.6;
prm.mask.maxLum = 0.7; % max luminance in the mask
prm.mask.minLum = 0;
prm.mask.matrixSize = [600, 600];

% block conditions
prm.ITI = 0.05; % inter-trial interval
prm.reminderTrialN = 50; % progress report every N trials
prm.blockN = 6; % total number of blocks

% end
