function [JCS_flex,JCS_ext,robot_pos_flex,robot_pos_ext] = tdms_extraction_digvscalc(data_in)
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
%         disp(['Checking for JCS in cell ', num2str(c)]);
        
        % Check for JCS
        if sum(strcmp('JCS_digitised_Posterior', data_in{1, c}.Properties.VariableNames)) == 1
            ap = data.JCS_digitised_Posterior;
            flex = data.JCS_digitised_Flexion;
            peakFlex = find(flex == max(flex));
            ir = data.("JCS_digitised_Internal Rotation");
            vv = data.("JCS_digitised_Valgus");
            ml=data.("JCS_digitised_Medial");
            si=data.("JCS_digitised_Superior");
%             disp(peakFlex)
            % Split into flexion and extension
            flex_flex = flex(1:peakFlex);
            flex_ext = flex(peakFlex:end);

            % Get indices of every degree
            flex_ind = [flex_ind, find_indices(flex_flex, 0:round(max(flex)))];
            ext_ind = [ext_ind, find_indices(flex_ext,round(max(flex)):-1:0)];
%             disp(ext_ind(90))
%             disp(length(flex_flex))
%             disp(length(flex_ext))
            ap_flex = [ap_flex, ap(flex_ind)'];
            ap_ext = [ap_ext, ap((peakFlex+ext_ind-1))'];
            ir_flex = [ir_flex, ir(flex_ind)'];
            ir_ext = [ir_ext, ir((peakFlex+ext_ind-1))'];
            vv_flex = [vv_flex, vv(flex_ind)'];
            vv_ext = [vv_ext, vv((peakFlex+ext_ind-1))'];
            ml_flex = [ml_flex, ml(flex_ind)'];
            ml_ext = [ml_ext, ml((peakFlex+ext_ind-1))'];
            si_flex = [si_flex, si(flex_ind)'];
            si_ext = [si_ext, si((peakFlex+ext_ind-1))'];
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
            robot_pos_x_flex = [robot_pos_x_flex,  robot_pos_x_all(flex_ind)];
            robot_pos_x_ext = [robot_pos_x_ext,  robot_pos_x_all(peakFlex+ext_ind-1)];
            robot_pos_y_flex = [robot_pos_y_flex,  robot_pos_y_all(flex_ind)];
            robot_pos_y_ext = [robot_pos_y_ext, robot_pos_y_all(peakFlex+ext_ind-1)];
            robot_pos_z_flex = [robot_pos_z_flex,  robot_pos_z_all(flex_ind)];
            robot_pos_z_ext = [robot_pos_z_ext,  robot_pos_z_all(peakFlex+ext_ind-1)];
            robot_pos_pitch_flex = [robot_pos_pitch_flex,  robot_pos_pitch_all(flex_ind)];
            robot_pos_pitch_ext = [robot_pos_pitch_ext, robot_pos_pitch_all(peakFlex+ext_ind-1)];
            robot_pos_roll_flex = [robot_pos_roll_flex, robot_pos_roll_all(flex_ind)];
            robot_pos_roll_ext = [robot_pos_roll_ext, robot_pos_roll_all(peakFlex+ext_ind-1)];
            robot_pos_yaw_flex = [robot_pos_yaw_flex,robot_pos_yaw_all(flex_ind)];
            robot_pos_yaw_ext = [robot_pos_yaw_ext, robot_pos_yaw_all(peakFlex+ext_ind-1)];
%     disp(flex_ext(ext_ind))
 JCS_flex=[flex_flex(flex_ind),ap_flex',ml_flex',si_flex',ir_flex',vv_flex'];
 JCS_ext=[flex_ext(ext_ind),ap_ext',ml_ext',si_ext',ir_ext',vv_ext'];
 robot_pos_flex=[robot_pos_x_flex,robot_pos_y_flex,robot_pos_z_flex,robot_pos_roll_flex,robot_pos_pitch_flex,robot_pos_yaw_flex];
 robot_pos_ext=[robot_pos_x_ext,robot_pos_y_ext,robot_pos_z_ext,robot_pos_roll_ext,robot_pos_pitch_ext,robot_pos_yaw_ext];
 
%  robot_pos=[robot_pos_x_all,robot_pos_y_all,robot_pos_z_all,robot_pos_roll_all,robot_pos_pitch_all,robot_pos_yaw_all];
 
end

function indices = find_indices(signal, values)
    indices = arrayfun(@(val) max(find(abs(signal - val) == min(abs(signal - val)))), values);
end
