function [JCS, robot_position] = tdms_extraction(data_in)
% tdms_extraction looks for the relevant cells in the cell array, in this
% case JCS and robot position. For the JCS kinematics it also finds and
% only outputs data at each degrees of flexion. If more datapoints are
% wanted, change flex_ind and ext_ind (line 51 and 52). Robot positions are
% output at each datapoints, as kinematics have to be calculated before
% extracting flexion based points

    flex_ind = [];
    ext_ind = [];
    ap_flex=[];
    ap_ext=[];
    ir_flex = [];
    ir_ext = [];
    vv_flex = [];
    vv_ext = [];
    si_flex = [];
    si_ext = [];
    ml_flex = [];
    ml_ext = [];

    robot_pos_x_flex = [];
    robot_pos_x_ext = [];
    robot_pos_y_flex = [];
    robot_pos_y_ext = [];
    robot_pos_z_flex = [];
    robot_pos_z_ext = [];
    robot_pos_pitch_flex = [];
    robot_pos_pitch_ext = [];
    robot_pos_roll_flex = [];
    robot_pos_roll_ext = [];
    robot_pos_yaw_flex = [];
    robot_pos_yaw_ext = [];

% Loop through cells in the cell array for JCS  
    for c = 1:numel(data_in)
        data = data_in{c};

        % Check for Desired translations and forces
        if contains(data_in{1, c}.Properties.VariableNames, "Desired")
            headers = data.Properties.VariableNames;
            for i = 1:length(headers)
                split_name= strsplit(headers{i}, ' ');
                field_name = split_name{1};
                if any(contains(headers, "Drawer"))
                    JCS.forces.desired.(field_name) = data.(headers{i});
                else
                    JCS.translations.desired.(field_name) = data.(headers{i});
                end
            end
        end
        % Check for JCS (actual) loads
        if contains(data_in{1, c}.Properties.VariableNames, "JCS Load")
            headers = data.Properties.VariableNames;
            for i = 1:length(headers)
                underscore = strsplit(headers{i}, '_'); % Split JCS Load_Lateral Drawer by the _.
                force_direction = strsplit(underscore{2}, ' '); % Split Lateral Drawer by whitespace
                field_name = force_direction{1};
                JCS.forces.actual.(field_name) = data.(headers{i});
            end
        end

        % Check for JCS translations (= position in optimised coordinate
        % system)
        if sum(strcmp('JCS_Posterior', data_in{1, c}.Properties.VariableNames)) == 1
            ap = data.JCS_Posterior;
            flex = data.JCS_Flexion;
            peakFlex = find(flex == max(flex));
            ir = data.("JCS_Internal Rotation");
            vv = data.("JCS_Valgus");
            ml=data.("JCS_Medial");
            si=data.("JCS_Superior");
%             disp(peakFlex)
            % Split into flexion and extension
            flex_flex = flex(1:peakFlex);
            flex_ext = flex(peakFlex:end);

            % Get indices of every degree
            % This should be changed to be a mean of the values between 2
            % indices. Also works as a low pass filter.
            flex_ind = [flex_ind, find_indices(flex_flex, 0:round(max(flex)))];
            ext_ind = [ext_ind, find_indices(flex_ext,round(max(flex)):-1:0)];

            JCS.translations.flexion.Flexion = flex_flex(flex_ind);
            JCS.translations.extension.Flexion = flex_ext(ext_ind);
            JCS.translations.flexion.Posterior = [ap_flex, ap(flex_ind)']';
            JCS.translations.extension.Posterior = [ap_ext, ap(peakFlex+ext_ind-1)']';
            JCS.translations.flexion.Internal = [ir_flex, ir(flex_ind)']';
            JCS.translations.extension.Internal = [ir_ext, ir(peakFlex+ext_ind-1)']';
            JCS.translations.flexion.Valgus = [vv_flex, vv(flex_ind)']';
            JCS.translations.extension.Valgus = [vv_ext, vv(peakFlex+ext_ind-1)']';
            JCS.translations.flexion.Medial = [ml_flex, ml(flex_ind)']';
            JCS.translations.extension.Medial = [ml_ext, ml(peakFlex+ext_ind-1)']';
            JCS.translations.flexion.Superior = [si_flex, si(flex_ind)']';
            JCS.translations.extension.Superior = [si_ext, si(peakFlex+ext_ind-1)']';
        end
    end
    
    % Initialize variables to store the entire 'Robot Position' columns
    robot_pos_x_all = [];
    robot_pos_y_all = [];
    robot_pos_z_all = [];
    robot_pos_pitch_all = [];
    robot_pos_roll_all = [];
    robot_pos_yaw_all = [];

    % Loop through cells in the cell array for Robot Position
    for c = 1:numel(data_in)
        data = data_in{c};
%         disp(['Checking for Robot Position in cell ', num2str(c)]);
        
        % Display the variable names in the current table
%         disp('Variable Names:');
%         disp(data.Properties.VariableNames);
        
        % Specify Robot Position column names
        robot_pos_x_col = 'Robot Position_x';
        robot_pos_y_col = 'Robot Position_y';
        robot_pos_z_col = 'Robot Position_z';
        robot_pos_pitch_col = 'Robot Position_pitch';
        robot_pos_roll_col = 'Robot Position_roll';
        robot_pos_yaw_col = 'Robot Position_yaw';
        
        % Check for Robot Position
        if any(contains(data.Properties.VariableNames, robot_pos_x_col))
%             disp('Robot Position found!');
            
            % Update indexing to handle cell arrays
            robot_pos_x_all = [robot_pos_x_all; data.(robot_pos_x_col)];
            robot_pos_y_all = [robot_pos_y_all; data.(robot_pos_y_col)];
            robot_pos_z_all = [robot_pos_z_all; data.(robot_pos_z_col)];
            robot_pos_pitch_all = [robot_pos_pitch_all; data.(robot_pos_pitch_col)];
            robot_pos_roll_all = [robot_pos_roll_all; data.(robot_pos_roll_col)];
            robot_pos_yaw_all = [robot_pos_yaw_all; data.(robot_pos_yaw_col)];
        else
%             disp('Robot Position not found in this cell.');
        end
    end
%  Process robot_pos_x, robot_pos_y, etc.
             robot_position.flexion.X = [robot_pos_x_flex,  robot_pos_x_all(flex_ind)];
            robot_position.extension.X = [robot_pos_x_ext,  robot_pos_x_all(peakFlex+ext_ind-1)];
            robot_position.flexion.Y = [robot_pos_y_flex,  robot_pos_y_all(flex_ind)];
            robot_position.extension.Y = [robot_pos_y_ext, robot_pos_y_all(peakFlex+ext_ind-1)];
            robot_position.flexion.Z = [robot_pos_z_flex,  robot_pos_z_all(flex_ind)];
            robot_position.extension.Z = [robot_pos_z_ext,  robot_pos_z_all(peakFlex+ext_ind-1)];
            robot_position.flexion.Pitch = [robot_pos_pitch_flex,  robot_pos_pitch_all(flex_ind)];
            robot_position.extension.Pitch = [robot_pos_pitch_ext, robot_pos_pitch_all(peakFlex+ext_ind-1)];
            robot_position.flexion.Roll = [robot_pos_roll_flex, robot_pos_roll_all(flex_ind)];
            robot_position.extension.Roll = [robot_pos_roll_ext, robot_pos_roll_all(peakFlex+ext_ind-1)];
            robot_position.flexion.Yaw = [robot_pos_yaw_flex,robot_pos_yaw_all(flex_ind)];
            robot_position.extension.Yaw = [robot_pos_yaw_ext, robot_pos_yaw_all(peakFlex+ext_ind-1)];

            % Convert the struct to table. Probably easier to work with,
            % but can just be commented out.
            robot_position.flexion = struct2table(robot_position.flexion);
            robot_position.extension = struct2table(robot_position.extension);

 robot_position.flexion_all = [robot_position.flexion.X robot_position.flexion.Y robot_position.flexion.Z robot_position.flexion.Roll robot_position.flexion.Pitch robot_position.flexion.Yaw];
 robot_position.extension_all = [robot_position.extension.X robot_position.extension.Y robot_position.extension.Z robot_position.extension.Roll robot_position.extension.Pitch robot_position.extension.Yaw];
%  robot_pos=[robot_pos_x_all,robot_pos_y_all,robot_pos_z_all,robot_pos_roll_all,robot_pos_pitch_all,robot_pos_yaw_all];
 
end

function indices = find_indices(signal, values)
    indices = arrayfun(@(val) max(find(abs(signal - val) == min(abs(signal - val)))), values);
end
