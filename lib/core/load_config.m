function [is_right_knee, state, setup, transforms] = load_config(path)
    % Unzip the configuration
    fp_config = fullfile(path, "Configuration");
    unzip(fullfile(fp_config, "Project.sVprj"), fp_config);
    
    fp_knee_state = fullfile(fp_config, "State.cfg");
    fp_setup = fullfile(fp_config, "Setup.cfg");
    
    
    %% State: transforms, optimisations, etc
    state = serialise(fp_knee_state);

    % Get the bits we care about out of the serialised config
    % transforms.W1_T_W2 = state.JCS.T_World1_World2_for_Fiducials;
    transforms.W1_T_W2 = state.JCS.T_World1_World2_for_Fiducials;
    transforms.S1_T_RB1 = state.JCS.T_Sensor1_RB1; %Transformation from Certus to Rigid Body 1 (Femur)
    transforms.S2_T_RB2 = state.JCS.T_Sensor2_RB2; %Transformation from Sensor 2 (Load Cell/Robot end effector) to Rigid Body 2 (Tibia)
    transforms.RB2opt_T_RB2orig = state.JCS.T_RB2_OPT_RB2_Orig;
    transforms.RB1opt_T_RB1orig = state.JCS.T_RB1_OPT_RB1_Orig;

    identity = eye(4);
    transforms.is_optimised = ~all(state.JCS.T_RB2_OPT_RB2_Orig == identity, "all");

    transforms.T_S1_RB1_Orig = state.JCS.Initial_T_Sen1_RB1;
    transforms.T_S2_RB2_Orig = state.JCS.Initial_T_Sen2_RB2;
    position_offset = state.JCS.Position_Offset; %Neutral position offset, defined as the zero point to calculate kinematics
    transforms.position_offset = [position_offset(1:3)*1000; rad2deg(position_offset(4:6))];
    % position_offset = [position_offset(1:3); rad2deg(position_offset(4:6))];
    % transforms.position_offset = findTrackerFixedFrames(position_offset(4:6), position_offset(1:3));
    

    %% Setup: Sidedness and robot position

    setup = serialise(fp_setup);
    transforms.T_W1_Robot = setup.DefineRobotCoordinateSystem.T_WORLD1_ROB;
    transforms.robot_position = setup.DetermineNeutralPosition.Robot_Position;

    is_right_knee = strcmpi(setup.RecordSpecimenInfo.Specimen_Side, "right");


    %% Introspection
    femur = landmarks(state.JCS.Collected_Points_Rigid_Body_1);
    transforms.from_digitiser.gTf0 = defineBodyFixedFrameFemur(femur, is_right_knee);
    tibia = landmarks(state.JCS.Collected_Points_Rigid_Body_2);
    transforms.from_digitiser.gTt0 = defineBodyFixedFrameTibia(tibia, is_right_knee);


    figure
    visualise_landmark(tibia, femur, is_right_knee, '', '-', [0 0 0]);
    xlabel("x"); ylabel("y"); zlabel("z");

    figure
    visualise_matrix(transforms.from_digitiser.gTf0, '-');
    hold on;
    visualise_matrix(transforms.S1_T_RB1, '-');
    hold off;

    legend(["From digitisation", "From simvitro"]);

    figure;

    visualise_matrix(state.JCS.T_World1_World2_for_Fiducials);
    visualise_matrix(state.JCS.T_World1_World2);
    visualise_matrix(mat_to_left_handed(state.JCS.T_World1_World2));
    legend(["For fiducials", "Simvitro left knee", "flipped"]);


    transforms.gTee = setup.DefineRobotCoordinateSystem.T_WORLD1_ROB;
end
