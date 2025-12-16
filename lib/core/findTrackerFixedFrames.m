function [ gTtiF ] = findTrackerFixedFrames(eulerAngles,XYZ)
arguments
    eulerAngles (:, 3)
    XYZ (:, 3)
end
% Creates 4 x 4 x m matrices, where each page is gTtiF (tracker in global
% frame of reference)
if nargin == 0
    gTtiF = [];
    return;
end

identity_mat = @(n) repmat(eye(4), 1, 1, n);

n = height(eulerAngles);
Rx = identity_mat(n);
Ry = identity_mat(n);
Rz = identity_mat(n);

roll = eulerAngles(:, 1);
pitch = eulerAngles(:, 2);
yaw = eulerAngles(:, 3);

% Rx=[1   0         0             0
%     0   cosd(roll)  -sind(roll) 0
%     0   sind(roll)  cosd(roll)  0
%     0   0         0             1];
Rx(2, 2, :) = cosd(roll);
Rx(2, 3, :) = -sind(roll);
Rx(3, 2, :) = sind(roll);
Rx(3, 3, :) = cosd(roll);

% Ry=[cosd(pitch)    0   sind(pitch) 0
%     0           1  0               0
%     -sind(pitch)   0   cosd(pitch) 0
%     0              0   0           1];
Ry(1, 1, :) = cosd(pitch);
Ry(1, 3, :) = sind(pitch);
Ry(3, 1, :) = -sind(pitch);
Ry(3, 3, :) = cosd(pitch);

% Rz=[cosd(yaw)    -sind(yaw)   0 0
%     sind(yaw)    cosd(yaw)    0 0
%     0           0             1 0
%     0           0             0 1];  
Rz(1, 1, :) = cosd(yaw);
Rz(1, 2, :) = -sind(yaw);
Rz(2, 1, :) = sind(yaw);
Rz(2, 2, :) = cosd(yaw);


rot = pagemtimes(Rz, pagemtimes(Ry, Rx));

trans = identity_mat(n);
trans(1:3, 4, :) = XYZ';

gTtiF = pagemtimes(trans, rot);

end