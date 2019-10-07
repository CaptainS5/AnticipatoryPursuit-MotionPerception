function [lengthDvaX, lengthDvaY] = pxl2dva(coor, fixCoor)
% calculate degree of visual angle based on coordinates on the screen
% Input: coor--matrix of [x_leftTop, y_leftTop, x_rightBottom, y_rightBottom]
%        fixCoor--coordinates of the fixation point, [x y]
%   coordinates should be consistent with the screen rect info
%   in Psychtoolbox, origins at upper left
% Output: dva of the object in horizontal & vertical axes

global prm % need screen in pixels, in cm, and viewing distance from prm
% first calculate how much cm it is for the visual degree
if coor(1)<=fixCoor(1) && coor(3)<=fixCoor(1) % all to the leftsi
elseif coor(1)<fixCoor(1)<coor(3) % across fixation point
elseif coor(1)>=fixCoor(1) && coor(3)>=fixCoor(1) % all to the right
end
lengthXcm = tan(lengthX/180*pi)*prm.screen.viewDistance;
lengthYcm = tan(lengthY/180*pi)*prm.screen.viewDistance;

% then calculate how many pixels
lengthPixelX = lengthXcm*prm.screen.ppcX;
lengthPixelY = lengthYcm*prm.screen.ppcY;

end

