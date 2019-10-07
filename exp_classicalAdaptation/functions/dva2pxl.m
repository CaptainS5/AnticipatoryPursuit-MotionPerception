function [lengthPixelX lengthPixelY] = dva2pxl(lengthX, lengthY)
% translate length in dva to in pixels
% the length is from fixation to one end, not center at the fixation
% if want to calculate a length centered at fixation, use length/2 for
% pixels, then multiply 2 to the pixel number calculated from length/2

global prm
% first calculate how much cm it is for the visual degree
lengthXcm = tan(lengthX/180*pi)*prm.screen.viewDistance;
lengthYcm = tan(lengthY/180*pi)*prm.screen.viewDistance;

% then calculate how many pixels
lengthPixelX = round(lengthXcm*prm.screen.ppcX);
lengthPixelY = round(lengthYcm*prm.screen.ppcY);

end

