function matrices = CS_Extraction(config_file, experiment_run, right)


    % Load necessary transformation matrices
    T_W1_W2 = Config_matrix(config_file, 'T_World1_World2');
    T_S1_RB1 = Config_matrix(config_file, 'T_Sensor1_RB1');
    T_S2_RB2 = Config_matrix(config_file, 'T_Sensor2_RB2');
    T_S1_RB1_Orig = Config_matrix(config_file, 'Initial T Sen1_RB1');
    T_S2_RB2_Orig = Config_matrix(config_file, 'Initial T Sen2_RB2');
   

    %Extract JCS kinematics and robot positions
    [JCS_flex,JCS_ext,RP_flex,RP_ext]=tdms_extraction(experiment_run);

    %Convert robot position into transformation matrix
    T_W2_S2=coordinate2matrix(RP_flex);


    num_iterations = size(T_W2_S2, 1);
    angles = zeros(num_iterations, 3);
    XYZ = zeros(num_iterations, 3);
    angles_dig = zeros(num_iterations, 3);
    XYZ_dig = zeros(num_iterations, 3);
    Tibia_W2 = cell(num_iterations, 1);
    Femur_W2 = cell(num_iterations, 1);
    Tibia_W2_dig = cell(num_iterations, 1);
    Femur_W2_dig = cell(num_iterations, 1);
    
    for i = 1:num_iterations
        T_RB1_RB2{i,1} = T_S1_RB1 \ T_W1_W2 * T_W2_S2{i,1} * T_S2_RB2;
        T_RB1_RB2_dig{i,1} = T_S1_RB1_Orig \ T_W1_W2 * T_W2_S2{i,1} * T_S2_RB2_Orig;
        [angles(i,:), XYZ(i,:)] = rotationsAndTranslations_v2(T_RB1_RB2{i,1}, right);
        [angles_dig(i,:), XYZ_dig(i,:)] = rotationsAndTranslations_v2(T_RB1_RB2_dig{i,1}, right);

        Tibia_W2{i,1} =T_W2_S2{i,1} * T_S2_RB2;
        Femur_W2{i,1} =  T_W1_W2\T_S1_RB1;

        Tibia_W2_dig{i,1} = T_W2_S2{i,1} * T_S2_RB2_Orig;
        Femur_W2_dig{i,1} = T_W1_W2 \ T_S1_RB1_Orig;
    end
    matrices={Tibia_W2, Femur_W2, Tibia_W2_dig, Femur_W2_dig};
end
