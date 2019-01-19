function [coor] = dva2pxl(lengthX, lengthY, center)
% calculate coordinates on the screen based on degree of visual angle
% Input: lengthX, lengthY-- dva of the object in horizontal & vertical axes
%        center--coordinates of the center point of the object, [x y]
% Output: coor-matrix of [x_leftTop, y_leftTop, x_rightBottom, y_rightBottom]
%   coordinates should be consistent with the screen rect info
%   in Psychtoolbox, origins at upper left

global prm
% first calculate how much cm it is for the visual degree
lengthXcm = tan(lengthX/180*pi)*prm.screen.viewDistance;
lengthYcm = tan(lengthY/180*pi)*prm.screen.viewDistance;

% then calculate how many pixels
lengthPixelX = lengthXcm*prm.screen.ppcX;
lengthPixelY = lengthYcm*prm.screen.ppcY;

end

