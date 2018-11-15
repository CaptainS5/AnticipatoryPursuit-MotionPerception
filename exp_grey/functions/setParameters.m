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


% Eyelink parameters
prm.eyelink.nDrift = 50;

% warning beep for feedback on fixation maintainance
prm.beep.freq = 44100;

% dynamic mask
prm.mask.duration = 0.6;
prm.mask.maxLum = 0.7; % max luminance in the mask
prm.mask.minLum = 0;
prm.mask.matrixSize = [600, 600];

% block conditions
prm.ITI = 0.2; % inter-trial interval
prm.reminderTrialN = 50; % progress report every N trials
prm.blockN = 6; % total number of blocks

% end
