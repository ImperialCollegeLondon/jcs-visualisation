function [config, setup] = load_config(path, config)
    % Unzip the configuration
    fp_config = fullfile(path, "Configuration");
    unzip(fullfile(fp_config, "Project.sVprj"), fp_config);
    
    fp_knee_state = fullfile(fp_config, "State.cfg");
    fp_setup = fullfile(fp_config, "Setup.cfg");
    
    
    knee_state = serialise(fp_knee_state);

    % Get the bits we care about out of the serialised config
    config.W1_T_W2 = knee_state.JCS.T_World1_World2;
    config.S1_T_RB1 = knee_state.JCS.T_Sensor1_RB1; %Transformation from Certus to Rigid Body 1 (Femur)
    config.S2_T_RB2 = knee_state.JCS.T_Sensor2_RB2; %Transformation from Sensor 2 (Load Cell/Robot end effector) to Rigid Body 2 (Tibia)
    config.RB2opt_T_RB2orig = knee_state.JCS.T_RB2_OPT_RB2_Orig;
    config.RB1opt_T_RB1orig = knee_state.JCS.T_RB1_OPT_RB1_Orig;
    config.T_S1_RB1_Orig = knee_state.JCS.Initial_T_Sen1_RB1;
    config.T_S2_RB2_Orig = knee_state.JCS.Initial_T_Sen2_RB2;
    position_offset = knee_state.JCS.Position_Offset; %Neutral position offset, defined as the zero point to calculate kinematics
    position_offset = [position_offset(1:3)*1000; rad2deg(position_offset(4:6))];
    config.position_offset = findTrackerFixedFrames(position_offset(4:6), position_offset(1:3));
    
    setup = serialise(fp_setup);
    config.T_W1_Robot = setup.DefineRobotCoordinateSystem.T_WORLD1_ROB;
    config.robot_position = setup.DetermineNeutralPosition.Robot_Position;
    if strcmpi(setup.RecordSpecimenInfo.Specimen_Side, "right")
        config.is_right_knee = true;
    else
        config.is_right_knee = false;
    end

end
