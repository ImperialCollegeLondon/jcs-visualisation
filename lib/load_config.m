function [config, state, setup] = load_config(path, config)
    % Unzip the configuration
    fp_config = fullfile(path, "Configuration");
    unzip(fullfile(fp_config, "Project.sVprj"), fp_config);
    
    fp_knee_state = fullfile(fp_config, "State.cfg");
    fp_setup = fullfile(fp_config, "Setup.cfg");
    
    
    state = serialise(fp_knee_state);

    % Get the bits we care about out of the serialised config
    config.transforms.W1_T_W2 = state.JCS.T_World1_World2;
    config.transforms.S1_T_RB1 = state.JCS.T_Sensor1_RB1; %Transformation from Certus to Rigid Body 1 (Femur)
    config.transforms.S2_T_RB2 = state.JCS.T_Sensor2_RB2; %Transformation from Sensor 2 (Load Cell/Robot end effector) to Rigid Body 2 (Tibia)
    config.transforms.RB2opt_T_RB2orig = state.JCS.T_RB2_OPT_RB2_Orig;
    config.transforms.RB1opt_T_RB1orig = state.JCS.T_RB1_OPT_RB1_Orig;
    config.transforms.T_S1_RB1_Orig = state.JCS.Initial_T_Sen1_RB1;
    config.transforms.T_S2_RB2_Orig = state.JCS.Initial_T_Sen2_RB2;
    position_offset = state.JCS.Position_Offset; %Neutral position offset, defined as the zero point to calculate kinematics
    position_offset = [position_offset(1:3)*1000; rad2deg(position_offset(4:6))];
    % position_offset = [position_offset(1:3); rad2deg(position_offset(4:6))];
    config.transforms.position_offset = findTrackerFixedFrames(position_offset(4:6), position_offset(1:3));
    
    setup = serialise(fp_setup);
    config.transforms.T_W1_Robot = setup.DefineRobotCoordinateSystem.T_WORLD1_ROB;
    config.transforms.robot_position = setup.DetermineNeutralPosition.Robot_Position;
    if strcmpi(setup.RecordSpecimenInfo.Specimen_Side, "right")
        config.is_right_knee = true;
    else
        config.is_right_knee = false;
    end
end