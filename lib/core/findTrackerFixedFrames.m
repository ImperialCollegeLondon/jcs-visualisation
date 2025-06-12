function [ gTtiF ] = findTrackerFixedFrames(eulerAngles,XYZ)
% Creates 4 x 4 x m matrices, where each page is gTtiF (tracker in global
% frame of reference)
if nargin == 0
    gTtiF = [];
    return;
end
roll = eulerAngles(1);
pitch = eulerAngles(2);
yaw = eulerAngles(3);

Rx=[1   0         0             0
    0   cosd(roll)  -sind(roll) 0
    0   sind(roll)  cosd(roll)  0
    0   0         0             1];
% Rx(2, 2, :) = cosd(roll);
% Rx(2, 3, :) = -sind(roll);
% Rx(3, 2, :) = sind(roll);
% Rx(3, 3, :) = cosd(roll);

Ry=[cosd(pitch)    0   sind(pitch) 0
    0           1  0               0
    -sind(pitch)   0   cosd(pitch) 0
    0              0   0           1];
% Ry(1, 1, :) = cosd(pitch);
% Ry(1, 3, :) = sind(pitch);
% Ry(3, 1, :) = -sind(pitch);
% Ry(3, 3, :) = cosd(pitch);

Rz=[cosd(yaw)    -sind(yaw)   0 0
    sind(yaw)    cosd(yaw)    0 0
    0           0             1 0
    0           0             0 1];  
% Rz(1, 1, :) = cosd(yaw);
% Rz(1, 2, :) = -sind(yaw);
% Rz(2, 1, :) = sind(yaw);
% Rz(2, 2, :) = cosd(yaw);


rot = Rz * Ry * Rx;

trans = eye(4);
trans(1, 4) = XYZ(1);
trans(2, 4) = XYZ(2);
trans(3, 4) = XYZ(3);

gTtiF = trans * rot;

end