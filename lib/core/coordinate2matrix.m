function transform = coordinate2matrix(data)
translation = repmat(eye(4), 1, 1, height(data));
translation(1, 4, :) = data.x/1000;
translation(2, 4, :) = data.y/1000;
translation(3, 4, :) = data.z/1000;

roll=deg2rad(data.roll); % Rx 
pitch=deg2rad(data.pitch); % Ry
yaw=deg2rad(data.yaw); % Rz

Qx = repmat(eye(4), 1, 1, numel(roll));
Qy = repmat(eye(4), 1, 1, numel(pitch));
Qz = repmat(eye(4), 1, 1, numel(yaw));
%% Qx
% 1                                   0                                0
                         Qx(2, 2, :) = cos(roll);           Qx(2, 3, :) = -sin(roll);
                         Qx(3, 2, :) = sin(roll);           Qx(3, 3, :) = cos(roll);
%% Qy
Qy(1, 1, :) = cos(pitch);                                   Qy(1, 3, :) = sin(pitch);
% 0                                   1                                0
Qy(3, 1, :) = -sin(pitch);                                  Qy(3, 3, :) = cos(pitch);

%% Qz
Qz(1, 1, :) = cos(yaw);  Qz(1, 2, :) = -sin(yaw);%                     0
Qz(2, 1, :) = sin(yaw);  Qz(2, 2, :) = cos(yaw);%                      0
% 0                                   0                                1

% rotation = pagemtimes(pagemtimes(Qz, Qy), Qx);
rotation = pagemtimes(pagemtimes(Qx, Qy), Qz);
transform = pagemtimes(translation, rotation);
end
