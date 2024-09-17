
robot_pos=RP_flex;


for i=1:size(robot_pos,1)

x=robot_pos(i,1);    
y=robot_pos(i,2);
z=robot_pos(i,3);
roll=robot_pos(i,4);
pitch=robot_pos(i,5);
yaw=robot_pos(i,6);

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


% Roll=30.5630;
% Pitch= 36.1142;
% Yaw=-21.1694;
% 
% RxRyRz=[Roll Pitch Yaw]

% Roll=Roll*pi/180;
% Pitch=Pitch*pi/180;
% Yaw=Yaw*pi/180;
