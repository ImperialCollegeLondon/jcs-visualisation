function output = calculate_kinematics(tdms, transforms, config, is_right_knee)
    %
    % S1: Sensor 1 (Certus)
    % S2: Sensor 2 (Load Cell/Robot end effector)
    % W1: World 1 (Certus world coordinate system)
    % W2: World 2 (Robot world coordinate system)
    % RB1: Rigid Body 1 (Femur)
    % RB2: Rigid Body 2 (Tibia)

    data = extract_tdms(tdms, config);

    % Get important transforms from config
    W1_T_W2 = transforms.W1_T_W2;
    S1_T_RB1opt = transforms.S1_T_RB1;
    S2_T_RB2opt = transforms.S2_T_RB2;
    RB2opt_T_RB2orig = transforms.RB2opt_T_RB2orig; %toTt
    RB1opt_T_RB1orig = transforms.RB1opt_T_RB1orig; %foTf
    position_offset = transforms.position_offset;
    % position_offset_tab = array2table(position_offset(:)', 'VariableNames', {'medial', 'posterior', 'superior', 'flexion', 'valgus', 'internal'});
   
    robot_position = data.robot_position;
    % robot_position.yaw = atan2d_north_to_east(JCS_raw.robot_position.yaw);
    % robot_position.roll = atan2d_north_to_east(JCS_raw.robot_position.roll);

    W2_T_S2 = coordinate2matrix(robot_position, is_right_knee); % End effector in Robot coordinate system throughout arc of flexion
    S1_T_W1 = eye(4);
    %% calculate transform from TIBIA (RB2) to FEMUR (RB1).
    % i.e., Tibia in femoral frame of reference.


    [RB1_T_RB2, RB1opt_T_RB2opt] = calculate_relative_motion(W1_T_W2, W2_T_S2, S1_T_W1, S1_T_RB1opt, S2_T_RB2opt, RB2opt_T_RB2orig, RB1opt_T_RB1orig);


    %% Prepare output
    name = string(data.specimen);
    state = string(data.state);
    loading_condition = string(data.loading_condition);
    is_optimised = transforms.is_optimised;
    output = Trajectory(name, state, loading_condition, is_optimised, is_right_knee);
    

    output.add_data("load_cell", data.load_cell);
    output.add_data("jcs_optimised", data.translation.actual);
    try
        output.add_data("jcs_digitised", data.translation.digitised);
    catch
    end 

    %%
    % Correctly unwrap robot pos
    robot_pos = rotationsAndTranslations(W2_T_S2, is_right_knee);
    robot_pos_arr = unwrap(table2array(robot_pos));
    output.add_data("robot_pos", array2table(robot_pos_arr, "VariableNames", robot_pos.Properties.VariableNames));
    kinematics = rotationsAndTranslations(RB1opt_T_RB2opt, is_right_knee);
    kinematics.medial = kinematics.medial * 1000;
    kinematics.superior = kinematics.superior * 1000;
    kinematics.posterior = kinematics.posterior * 1000;
    output.add_data("kinematics_opt", kinematics - position_offset);
    output.add_data("kinematics_orig", rotationsAndTranslations(RB1_T_RB2, is_right_knee));
   
    output.add_transforms("fTt", RB1opt_T_RB2opt);
    output.add_transforms("rTt", S2_T_RB2opt);



    fTt = RB1_T_RB2;
    gTf0 = S1_T_RB1opt * RB1opt_T_RB1orig;
    gTt = pagemtimes(gTf0, fTt);

    gTtt = transforms.landmarks.tibia_digitisation.pre_multiply(gTt);

    output.add_landmark("tibia", gTtt);
    

    % output.add_data("reconstructed", rotationsAndTranslations(fTt, is_right_knee));

    % output.add_data("sensors", JCS_raw.sensor);
    % 
    % output.add_data("forces_actual", JCS_raw.forces.actual);
    % output.add_data("forces_desired", JCS_raw.forces.desired);

    % output.RB2opt_T_RB2orig = transforms.RB2opt_T_RB2orig; %toTt
    % output.RB1opt_T_RB1orig = transforms.RB1opt_T_RB1orig; %foTf
    % output.kinematics.flexion = transforms.shift_flex(output.kinematics.flexion); % Offset so extension is 0 deg
    % output.error = output.kinematics - JCS_raw.translations.actual;
end
