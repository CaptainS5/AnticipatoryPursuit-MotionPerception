function openScreen
% function to set up screen parameters in CRS

% 01/11/2019 by Xiuyun Wu

global prm CRS

vsgInit;
% set degree unit
crsSetViewDistMM(prm.screen.viewDistance*10);
crsSetSpatialUnits(CRS.DEGREEUNIT);

% set colours
prm.screen.blackColour = [0 0 0];
prm.screen.whiteColour = [1 1 1];
prm.screen.backgroundColour = floor(prm.screen.whiteColour/2*256);
crsSetBackgroundColour(prm.screen.backgroundColour);

% monitor dimensions and center
prm.screen.widthPxl = crsGetScreenWidthPixels;
prm.screen.heightPxl = crsGetScreenHeightPixels;
prm.screen.center(1) = prm.screen.widthPxl/2;
prm.screen.center(2) = prm.screen.heightPxl/2;

% refresh rate of the monitor
prm.screen.refreshRate = crsGetFrameRate; % in Hz (frames per second: fps)

end
