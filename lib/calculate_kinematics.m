function output = calculate_kinematics(data, config)
    % Get data
    JCS_raw = extract_tdms(data, config);

    % Get important transforms from config
    W1_T_W2 = config.transforms.W1_T_W2;
    S1_T_RB1 = config.transforms.S1_T_RB1;
    S2_T_RB2 = config.transforms.S2_T_RB2;
    RB2opt_T_RB2orig = config.transforms.RB2opt_T_RB2orig; %toTt
    RB1opt_T_RB1orig = config.transforms.RB1opt_T_RB1orig; %foTf
    position_offset = config.transforms.position_offset;
   
    W2_T_S2 = coordinate2matrix(JCS_raw.robot_position); % End effector in Robot coordinate system throughout arc of flexion
    
    %% calculate transform from TIBIA (RB2) to FEMUR (RB1).
    % i.e., Tibia in femoral frame of reference.
    RB1_T_W2 = S1_T_RB1 \ W1_T_W2;
    RB1_T_S2 = pagemtimes(RB1_T_W2, W2_T_S2);
    RB1_T_RB2 = pagemtimes(RB1_T_S2,S2_T_RB2); % fTt
    RB1_T_RB2 = pagemtimes(RB1_T_RB2, position_offset);

    % Invert the optimisations
    RB1orig_T_RB2 = pagemldivide(RB1opt_T_RB1orig, RB1_T_RB2);
    RB1orig_T_RB2orig = pagemtimes(RB1orig_T_RB2, RB2opt_T_RB2orig);
    
    %% Prepare output
    output.specimen = string(JCS_raw.specimen);
    output.state = string(JCS_raw.state);
    output.loading_condition = string(JCS_raw.loading_condition);

    output.optimised_jcs = JCS_raw.translation.actual;
    
    output.kinematics = rotationsAndTranslations(RB1_T_RB2, config.is_right_knee);
    output.kinematics_orig = rotationsAndTranslations(RB1orig_T_RB2orig, config.is_right_knee);
   
    
    output.sensors = JCS_raw.sensor;
    
    output.forces_actual = JCS_raw.forces.actual;
    output.forces_desired = JCS_raw.forces.desired;

    output.RB2opt_T_RB2orig = config.transforms.RB2opt_T_RB2orig; %toTt
    output.RB1opt_T_RB1orig = config.transforms.RB1opt_T_RB1orig; %foTf
    % output.kinematics.flexion = config.transforms.shift_flex(output.kinematics.flexion); % Offset so extension is 0 deg
    % output.error = output.kinematics - JCS_raw.translations.actual;
end