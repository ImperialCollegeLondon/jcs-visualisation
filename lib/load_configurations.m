function config = load_configurations(filepath)
    fp_config = fullfile(filepath, "Configuration");
    unzip(fullfile(fp_config, 'Project.sVprj'), fp_config); 
    knee_state = fullfile(fp_config, "State.cfg");
    
    %% Extract relevant static matrices from cfg file
    config.W1_T_W2=Config_matrix(knee_state,'T_World1_World2'); % Transformation matrix between World 1 (Certus camera) and World 2 (Robot)
    config.S1_T_RB1=Config_matrix(knee_state,'T_Sensor1_RB1'); %Transformation from Certus to Rigid Body 1 (Femur)
    config.S2_T_RB2=Config_matrix(knee_state,'T_Sensor2_RB2'); %Transformation from Sensor 2 (Load Cell/Robot end effector) to Rigid Body 2 (Tibia)
    config.RB2opt_T_RB2orig=Config_matrix(knee_state,'T RB2-OPT_RB2-Orig'); % Transformation matrix 
    config.RB1opt_T_RB1orig=Config_matrix(knee_state,'T RB1-OPT_RB1-Orig');
    config.T_S1_RB1_Orig=Config_matrix(knee_state,'Initial T Sen1_RB1');
    config.T_S2_RB2_Orig=Config_matrix(knee_state,'Initial T Sen2_RB2');
    config.Position_offset=Config_matrix(knee_state,'Position Offset'); %Neutral position offset, defined as the zero point to calculate kinematics
    config.Position_offset=[config.Position_offset(1:3)*1000;config.Position_offset(4:6)*180/pi];
    config.Position_offset_orig=Config_matrix(knee_state,'Position Offset');
    config.Position_offset_orig=[config.Position_offset_orig(1:3)*1000;config.Position_offset_orig(4:6)*180/pi];
    
    %% Determine if left or right knee:
    setup = fullfile(fp_config, "Setup.cfg");
    config.is_right_knee = Config_matrix(setup, 'Specimen Side');
end