function output = calculate_kinematics(data, config)
    W1_T_W2 = config.W1_T_W2;
    S1_T_RB1 = config.S1_T_RB1;
    S2_T_RB2 = config.S2_T_RB2;
    RB2opt_T_RB2orig = config.RB2opt_T_RB2orig; %toTt
    RB1opt_T_RB1orig = config.RB1opt_T_RB1orig; %foTf
    position_offset = config.position_offset;
   
    JCS_raw = extract_tdms(data, config);
    
    %% Extract JCS kinematics and robot positions
    W2_T_S2 = coordinate2matrix(JCS_raw.robot_position); % End effector in Robot coordinate system throughout arc of flexion
    
    %% calculate transform from TIBIA (RB2) to FEMUR (RB1).
    % i.e., Tibia in femoral frame of reference.
    RB1_T_W2 = S1_T_RB1 \ W1_T_W2;
    RB1_T_S2 = pagemtimes(RB1_T_W2, W2_T_S2);
    RB1_T_RB2 = pagemtimes(RB1_T_S2,S2_T_RB2); % foTto
    % RB1_T_RB2 = pagemldivide(RB1opt_T_RB1orig,RB1_T_RB2); % fTto
    % RB1_T_RB2 = pagemtimes(RB1_T_RB2, RB2opt_T_RB2orig); %fTt
    % RB1_T_RB2 = pagemtimes(RB1_T_RB2, position_offset);
    
    %% Calculate kinematics
    output.specimen = JCS_raw.specimen;
    output.state = JCS_raw.state;
    output.name = JCS_raw.loading_condition;
    output.optimised_jcs = JCS_raw.translation.actual;
    output.kinematics = rotationsAndTranslations(RB1_T_RB2, config.is_right_knee);
    % output.kinematics.flexion = config.shift_flex(output.kinematics.flexion); % Offset so extension is 0 deg
    % output.error = output.kinematics - JCS_raw.translations.actual;
end