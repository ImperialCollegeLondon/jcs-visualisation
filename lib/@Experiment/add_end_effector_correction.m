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
            theta = get_angle(rTt, control_rTt);

            if ~isempty(forced_angle)
                theta = forced_angle;
            end

            mat = eye(4);
            mat(1,1) = cos(theta);
            mat(2,1) = sin(theta);
            mat(1,2) = -sin(theta);
            mat(2,2) = cos(theta);

            correction_matrix{i} = mat;


            rTt_corrected = rTt * correction_matrix{i};


            % Draw
            c_centre = control_rTt(1:3, 4);
            start_point = c_centre + control_rTt(1:3, 2);
            arc = draw_arc(c_centre, start_point, [0 0 1], theta(1), 50);
    
            plots(st) = visualise_matrix(rTt);
            visualise_matrix(rTt_corrected, ":");

            hold on;
            plot3(arc(1, :), arc(2, :), arc(3, :), ':');
            hold off;

            i = i + 1;
        end
        legend(plots, states);
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
    v1 = mat1(1:3,1);
    v2 = mat2(1:3,1);

    theta = acos(dot(v1 / norm(v1), v2 / norm(v2)));
end

function arc = draw_arc(center, start, axis, theta, n_points)
    arguments
        center (1,3)
        start (1,3)
        axis (1,3)
        theta (1,1)
        n_points (1,1) = 10
    end

    axis = axis / norm(axis); 
    start = start - center; 
    r = norm(start);
    start = start/r;

    t = linspace(0, theta, n_points); 
    arc = zeros(3, n_points);

    for i = 1:n_points
        % Rodrigues rotation formula
        v = start*cos(t(i)) + cross(-axis, start)*sin(t(i)) + (-axis)*dot(-axis,start)*(1 - cos(t(i)));
        arc(:,i) = center(:) + v(:);
    end
end
