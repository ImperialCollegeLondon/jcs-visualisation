function output = calculate_kinematics(tdms, config)
    % Get data
    data = extract_tdms(tdms, config);

    % Get important transforms from config
    W1_T_W2 = config.transforms.W1_T_W2;
    S1_T_RB1 = config.transforms.S1_T_RB1;
    S2_T_RB2 = config.transforms.S2_T_RB2;
    RB2opt_T_RB2orig = config.transforms.RB2opt_T_RB2orig; %toTt
    RB1opt_T_RB1orig = config.transforms.RB1opt_T_RB1orig; %foTf
    position_offset = config.transforms.position_offset;
   
    robot_position = data.robot_position;
    % robot_position.yaw = atan2d_north_to_east(JCS_raw.robot_position.yaw);
    % robot_position.roll = atan2d_north_to_east(JCS_raw.robot_position.roll);

    W2_T_S2 = coordinate2matrix(robot_position); % End effector in Robot coordinate system throughout arc of flexion
    
    %% calculate transform from TIBIA (RB2) to FEMUR (RB1).
    % i.e., Tibia in femoral frame of reference.
    RB1_T_W2 = S1_T_RB1 \ W1_T_W2;
    RB1_T_S2 = pagemtimes(RB1_T_W2, W2_T_S2); % End effector in Femur CS
    RB1_T_RB2 = pagemtimes(RB1_T_S2,S2_T_RB2); % fTt
    % RB1_T_RB2 = pagemtimes(RB1_T_RB2, position_offset);

    % Invert the optimisations
    RB1orig_T_RB2 = pagemldivide(RB1opt_T_RB1orig, RB1_T_RB2);
    RB1orig_T_RB2orig = pagemtimes(RB1orig_T_RB2, RB2opt_T_RB2orig);
    
    %% Prepare output
    name = string(data.specimen);
    state = string(data.state);
    loading_condition = string(data.loading_condition);
    is_optimised = config.transforms.is_optimised;
    output = Trajectory(name, state, loading_condition, is_optimised);
    

    output.add_data("load_cell", data.load_cell);
    output.add_data("jcs_optimised", data.translation.actual);
    try
        output.add_data("jcs_digitised", data.translation.digitised);
    catch
    end

    % Correctly unwrap robot pos
    robot_pos = rotationsAndTranslations(W2_T_S2, config.is_right_knee);
    robot_pos_arr = unwrap(table2array(robot_pos));
    output.add_data("robot_pos", array2table(robot_pos_arr, "VariableNames", robot_pos.Properties.VariableNames));
    output.add_data("kinematics", rotationsAndTranslations(RB1_T_RB2, config.is_right_knee));
    output.add_data("kinematics_orig", rotationsAndTranslations(RB1orig_T_RB2orig, config.is_right_knee));
   
    output.add_transforms("tTf", pageinv(RB1_T_RB2));
    
    % output.add_data("sensors", JCS_raw.sensor);
    % 
    % output.add_data("forces_actual", JCS_raw.forces.actual);
    % output.add_data("forces_desired", JCS_raw.forces.desired);

    % output.RB2opt_T_RB2orig = config.transforms.RB2opt_T_RB2orig; %toTt
    % output.RB1opt_T_RB1orig = config.transforms.RB1opt_T_RB1orig; %foTf
    % output.kinematics.flexion = config.transforms.shift_flex(output.kinematics.flexion); % Offset so extension is 0 deg
    % output.error = output.kinematics - JCS_raw.translations.actual;
end
