function [transform_matrix]= coordinate2matrix (robot_pos)


transform_matrix=[];
for i=1:size(robot_pos,1)

x=robot_pos(i,1)/1000;    
y=robot_pos(i,2)/1000;
z=robot_pos(i,3)/1000;
roll=deg2rad(robot_pos(i,4));
pitch=deg2rad(robot_pos(i,5));
yaw=deg2rad(robot_pos(i,6));

%set up rotation matrices
Qx=[1   0         0
    0   cos(roll)  -sin(roll)
    0   sin(roll)  cos(roll)];

Qy=[cos(pitch)    0   sin(pitch)
    0           1   0
    -sin(pitch)   0   cos(pitch)];

Qz=[cos(yaw)    -sin(yaw)   0
    sin(yaw)    cos(yaw)    0
    0           0           1];

rotation_Matrix=Qz*Qy*Qx;
rotation_Matrix=[rotation_Matrix,[0 0 0]';0 0 0 1];

translation_Matrix=[1 0 0 x;
                    0 1 0 y;
                    0 0 1 z;
                    0 0 0 1];

transform_matrix{i,1}=translation_Matrix*rotation_Matrix;
end
end

% Roll=30.5630;
% Pitch= 36.1142;
% Yaw=-21.1694;
% 
% RxRyRz=[Roll Pitch Yaw]

% Roll=Roll*pi/180;
% Pitch=Pitch*pi/180;
% Yaw=Yaw*pi/180;
