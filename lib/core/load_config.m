function [is_right_knee, state, setup, transforms] = load_config(path)
    % Unzip the configuration
    fp_config = fullfile(path, "Configuration");
    unzip(fullfile(fp_config, "Project.sVprj"), fp_config);
    
    fp_knee_state = fullfile(fp_config, "State.cfg");
    fp_setup = fullfile(fp_config, "Setup.cfg");
    
    %% Setup: Sidedness and robot position
    setup = serialise(fp_setup);
    is_right_knee = strcmpi(setup.RecordSpecimenInfo.Specimen_Side, "right");
   
    transforms.T_W1_Robot = setup.DefineRobotCoordinateSystem.T_WORLD1_ROB;

    robot_pos_neutral = setup.DetermineNeutralPosition.Robot_Position;
    robot_position.x = robot_pos_neutral(1);
    robot_position.y = robot_pos_neutral(2);
    robot_position.z = robot_pos_neutral(3);
    robot_position.roll = robot_pos_neutral(4);
    robot_position.pitch = robot_pos_neutral(5);
    robot_position.yaw = robot_pos_neutral(6);
    transforms.robot_position_neutral = coordinate2matrix(robot_position, is_right_knee);
    
    %% State: transforms, optimisations, etc
    state = serialise(fp_knee_state);

    % Get the bits we care about out of the serialised config
    % transforms.W1_T_W2 = state.JCS.T_World1_World2; % Left-handed
    transforms.W1_T_W2 = state.JCS.T_World1_World2_for_Fiducials; % Always right-handed
    transforms.S1_T_RB1 = state.JCS.T_Sensor1_RB1; %Transformation from Certus to Rigid Body 1 (Femur)
    transforms.S2_T_RB2 = state.JCS.T_Sensor2_RB2; %Transformation from Sensor 2 (Load Cell/Robot end effector) to Rigid Body 2 (Tibia)
    transforms.RB2opt_T_RB2orig = state.JCS.T_RB2_OPT_RB2_Orig;
    transforms.RB1opt_T_RB1orig = state.JCS.T_RB1_OPT_RB1_Orig;

    identity = eye(4);
    transforms.is_optimised = ~all(state.JCS.T_RB2_OPT_RB2_Orig == identity, "all");

    transforms.T_S1_RB1_init = state.JCS.Initial_T_Sen1_RB1;
    transforms.T_S2_RB2_init = state.JCS.Initial_T_Sen2_RB2;
    position_offset = state.JCS.Position_Offset; %Neutral position offset, defined as the zero point to calculate kinematics

    offset = table();
    offset.medial     = position_offset(1)*1000; 
    offset.posterior     = position_offset(2)*1000;
    offset.superior     = position_offset(3)*1000;
    offset.flexion  = position_offset(4); 
    offset.valgus = position_offset(5);
    offset.internal_rotation   = position_offset(6);

    transforms.position_offset = offset;
    % transforms.position_offset = [position_offset(1:3)*1000; rad2deg(position_offset(4:6))];

    %% Introspection
    femur = landmarks(state.JCS.Collected_Points_Rigid_Body_1);
    transforms.from_digitiser.gTf0 = defineBodyFixedFrameFemur(femur, is_right_knee);
    tibia = landmarks(state.JCS.Collected_Points_Rigid_Body_2);
    transforms.from_digitiser.gTt0 = defineBodyFixedFrameTibia(tibia, is_right_knee);

    gTf0 = transforms.from_digitiser.gTf0;

    visualise_matrix(transforms.from_digitiser.gTf0);
    xlabel("x"); ylabel("y"); zlabel("z");
    axis equal; grid on; view(30,30);
    hold on;
    visualise_matrix(state.JCS_digitised.T_Sensor1_RB1);
    if is_right_knee
        legend(["Correct", "Simvitro"]);
        title("Both should overlap")
    else
        gTf0_left_handed = mat_to_left_handed(gTf0);
        assert(all(state.JCS_digitised.T_Sensor1_RB1 - gTf0_left_handed < 1e-6, "all"))
        visualise_matrix(gTf0_left_handed);     legend(["Correct","Simvitro","Correct => Left-hand"]);
    end
    hold off; axis equal;



    transforms.gTr = setup.DefineRobotCoordinateSystem.T_WORLD1_ROB;
end
