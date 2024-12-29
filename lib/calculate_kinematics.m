function output = calculate_kinematics(input_path, config)
    W1_T_W2 = config.W1_T_W2;
    S1_T_RB1 = config.S1_T_RB1;
    S2_T_RB2 = config.S2_T_RB2;
    % RB2opt_T_RB2orig = transforms.RB2opt_T_RB2orig;
    % RB1opt_T_RB1orig = transforms.RB1opt_T_RB1orig;
    % T_S1_RB1_Orig = transforms.T_S1_RB1_Orig;
    % T_S2_RB2_Orig = transforms.T_S2_RB2_Orig;
    % Position_offset = transforms.Position_offset;
   
    input_file = tdmsread(input_path);
    
    %% Extract JCS kinematics and robot positions
    JCS_raw = tdms_extraction(input_file, config.step_size);
    W2_T_S2 = coordinate2matrix(JCS_raw.robot_position); % End effector in Robot coordinate system throughout arc of flexion
    
    %% calculate transform from TIBIA (RB2) to FEMUR (RB1).
    % i.e., Tibia in femoral frame of reference.
    RB1_T_W2 = S1_T_RB1 \ W1_T_W2;
    RB1_T_S2 = pagemtimes(RB1_T_W2, W2_T_S2);
    RB1_T_RB2 = pagemtimes(RB1_T_S2,S2_T_RB2); % f_T_t
    
    %% Calculate kinematics
    output.specimen = JCS_raw.specimen;
    output.state = JCS_raw.state;
    output.name = JCS_raw.loading_condition;
    output.optimised_jcs = JCS_raw.translations.actual;
    output.kinematics = rotationsAndTranslations(RB1_T_RB2, config.is_right_knee);
    output.kinematics.flexion = config.shift_flex(output.kinematics.flexion); % Offset so extension is 0 deg
    output.error = output.kinematics - JCS_raw.translations.actual;
end