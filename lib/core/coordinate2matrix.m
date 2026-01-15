function transform = coordinate2matrix(data, right)
    % Expects DATA to have fields X,Y,Z,ROLL,PITCH,YAW, XYZ in meters; angles in degrees.

    translation = repmat(eye(4), 1, 1, height(data));
    Qx = repmat(eye(4), 1, 1, height(data));
    Qy = repmat(eye(4), 1, 1, height(data));
    Qz = repmat(eye(4), 1, 1, height(data));

    translation(1, 4, :) = data.x/1000;
    translation(2, 4, :) = data.y/1000;
    translation(3, 4, :) = data.z/1000;

    roll = data.roll; % Rx
    pitch = data.pitch; % Ry
    yaw = data.yaw; % Rz

    if ~right
        translation(1, 4, :) = -translation(1, 4, :);
        roll=-roll;
        pitch=-pitch;
    end


    %% Qx
    Qx(2, 2, :) = cosd(roll);
    Qx(2, 3, :) = -sind(roll);
    Qx(3, 2, :) = sind(roll);
    Qx(3, 3, :) = cosd(roll);
    %% Qy
    Qy(1, 1, :) = cosd(pitch);
    Qy(1, 3, :) = sind(pitch);
    Qy(3, 1, :) = -sind(pitch);
    Qy(3, 3, :) = cosd(pitch);

    %% Qz
    Qz(1, 1, :) = cosd(yaw);
    Qz(1, 2, :) = -sind(yaw);
    Qz(2, 1, :) = sind(yaw);
    Qz(2, 2, :) = cosd(yaw);

    rotation = pagemtimes(pagemtimes(Qz, Qy), Qx);
    transform = pagemtimes(translation, rotation);



    %% Definitions from documentation:
    % transform2 = repmat(eye(4), 1, 1, height(data));
    % transform2(1, 1, :) = cos(yaw).*cos(pitch);
    % transform2(2, 1, :) = sin(yaw).*cos(pitch);
    % transform2(3, 1, :) = -sin(pitch);
    %
    % transform2(1, 2, :) = cos(yaw).*sin(pitch).*sin(roll) - sin(yaw).*cos(roll);
    % transform2(2, 2, :) = sin(yaw).*sin(pitch).*sin(roll) + cos(yaw).*cos(roll);
    % transform2(3, 2, :) = cos(pitch).*sin(roll);
    %
    % transform2(1, 3, :) = cos(yaw).*sin(pitch).*cos(roll) + sin(yaw).*sin(roll);
    % transform2(2, 3, :) = sin(yaw).*sin(pitch).*cos(roll)-cos(yaw).*sin(roll);
    % transform2(3, 3, :) = cos(pitch).*cos(roll);
    %
    % transform2(1, 4, :) = translation(1,4,:);
    % transform2(2, 4, :) = translation(2,4,:);
    % transform2(3, 4, :) = translation(3,4,:);
    %
    % transform2(:,:, 1)
    % transform(:, :, 1)
    % assert(all(transform2(:, :, 1) == transform(:, :, 1), "all"))

end
