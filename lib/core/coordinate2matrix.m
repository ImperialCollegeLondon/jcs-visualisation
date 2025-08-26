function transform = coordinate2matrix(data)



x = data.x/1000;
y = data.y/1000;
z = data.z/1000;

translation = repmat(eye(4), 1, 1, numel(x));
translation(1, 4, :) = x;
translation(2, 4, :) = y;
translation(3, 4, :) = z;

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

rotation = pagemtimes(pagemtimes(Qz, Qy), Qx);

transform = pagemtimes(translation, rotation);
end