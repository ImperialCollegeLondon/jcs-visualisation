function self = add_end_effector_correction(self, control_name, forced_angle)
    arguments
        self Experiment
        control_name {mustBeText}
        forced_angle = [];
    end
    all_trajectory_sets = self.RawTrajectorySets;
    specimens = unique([all_trajectory_sets.specimen]);
    all_states = unique([all_trajectory_sets.state]);
    
    i = 1;
    correction_matrix = repmat({eye(4)}, 1, numel(all_states) * numel(specimens));
    for sp = 1:numel(specimens)
        specimen = specimens(sp);
        is_specimen = [all_trajectory_sets.specimen] == specimen;
        trajectory_sets = all_trajectory_sets(is_specimen);
        states = [trajectory_sets.state];
        is_control = states == control_name;
        if ~any(is_control)
            error("'%s' is not a valid control. Try one of: %s", control_name, join(states, ', '));
        end
    
        control = trajectory_sets(is_control);
        figure;
        sgtitle(specimen);
        grid on;

        plots = gobjects(1, numel(states));
        for st = 1:numel(states)
            state = states(st);
            rTt = trajectory_sets(st).JCS.JCS.Initial_T_Sen2_RB2; % Equivalent to JCS_digitised.T_Sensor2_RB2;
            control_rTt = control.JCS.JCS.Initial_T_Sen2_RB2; % Equivalent to JCS_digitised.T_Sensor2_RB2;
            theta = get_angle(control_rTt, rTt);

            if ~isempty(forced_angle)
                theta = deg2rad(forced_angle);
            end

            plots(st) = visualise_matrix(rTt);


            mat = eye(4);
            mat(1,1) = cos(theta);
            mat(2,1) = sin(theta);
            mat(1,2) = -sin(theta);
            mat(2,2) = cos(theta);

            correction_matrix{i} = rTt \ mat * rTt; % From end-effector CS to tibial CS.



            rTt_corrected = correction_matrix{i} * rTt;

            % Draw
            c_centre = control_rTt(1:3, 4);
            start_point = c_centre + rTt(1:3, 2);
            arc = draw_arc(c_centre, start_point, [0 0 1], theta(1), 50);
    
            corrected(st) = visualise_matrix(rTt_corrected, ":");

            hold on;
            plot3(arc(1, :), arc(2, :), arc(3, :), ':');
            hold off;

            i = i + 1;

        end
        legend(plots, state_regex_inv(states));
    end
    [self.RawTrajectorySets.correction_matrix] = deal(correction_matrix{:});
end

function theta = get_angle(mat1, mat2)
    arguments
        mat1 (4,4)
        mat2 (4,4)
    end
    % q1 = rotm2quat(mat1(1:3, 1:3));
    % q2 = rotm2quat(mat2(1:3, 1:3));
    % 
    % q = quatmultiply(q2, conj(q1));
    % theta = quat2eul(q, 'ZYX');
    % From http://www.boris-belousov.net/2016/12/01/quat-dist/
    p = mat1(1:3, 1:3);
    q = mat2(1:3, 1:3);

    R = p*q';

    % Rotation about Z: Rz = 
    % ( cos  -sin   0 ]
    % [ sin  cos    0 ]
    % [ 0    0      1 ]
    % We can extract angle from finding calling atan on sin/cos, but the sign is ambiguous. So we use atan2. 
    theta = atan2(R(2,1), R(1,1));

    % v1 = mat1(1:3,1);
    % v2 = mat2(1:3,1);
    % 
    % theta = acos(dot(v1 / norm(v1), v2 / norm(v2)));
end

function arc = draw_arc(centre, start, axis, theta, n_points)
    arguments
        centre (1,3)
        start (1,3)
        axis (1,3)
        theta (1,1)
        n_points (1,1) = 10
    end

    axis = axis / norm(axis); 
    start = start - centre; 
    r = norm(start);
    start = start/r;

    t = linspace(0, theta, n_points); 
    arc = zeros(3, n_points);

    for i = 1:n_points
        % Rodrigues rotation formula
        v = start*cos(t(i)) + cross(axis, start)*sin(t(i)) + (axis)*dot(axis,start)*(1 - cos(t(i)));
        arc(:,i) = centre(:) + v(:);
    end

    if abs(theta) > deg2rad(5)
        v_end = arc(:, end) - centre(:);
        tangent = cross(axis(:), v_end);
        tangent = tangent/norm(tangent);
        tangent = tangent * sign(theta);
        arrow_length = 0.2 * r;
        arrow_vec = tangent * arrow_length;
        arrow_base = arc(:,end);
        hold on;
        quiver3(arrow_base(1), arrow_base(2), arrow_base(3), ...
            arrow_vec(1), arrow_vec(2), arrow_vec(3), ...
            0, 'LineWidth', 2, 'MaxHeadSize', 2);
    end
end
