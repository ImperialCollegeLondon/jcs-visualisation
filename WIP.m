%% this code calculates the knee kinematics in both the original, digitised coordinate frame and the optimised coordinate frame
clear

%% Load in the Specimen folder
% State cfg file is used to create the transforms.
% Setup cfg file determines if it's a left or right knee.
root = uigetdir(".", "Pick a Trajectory folder");
config = fullfile(root, "Configuration");

% Unzip the configuration files
unzip(fullfile(config, 'Project.sVprj'), config);

state = fullfile(config, "State.cfg");
setup = fullfile(config, "Setup.cfg");
file_path = fullfile(root, "Data");
% Generate full list of .tdms files inside the directory
files_tdms = {dir(fullfile(file_path, "*.tdms")).name}'; %File names with extensions
input_path = fullfile(file_path, files_tdms); % Full path
[~, file_name, ~] = fileparts(input_path); % Name without extension

%% Extract relevant static matrices from cfg file
T_W1_W2=Config_matrix(state,'T_World1_World2'); % Transformation matrix between World 1 (Certus camera) and World 2 (Robot)
T_S1_RB1=Config_matrix(state,'T_Sensor1_RB1'); %Transformation from Certus to Rigid Body 1 (Femur)
T_S2_RB2=Config_matrix(state,'T_Sensor2_RB2'); %Transformation from Sensor 2 (Load Cell/Robot end effector) to Rigid Body 2 (Tibia)
T_S1_RB1_Orig=Config_matrix(state,'Initial T Sen1_RB1');
T_S2_RB2_Orig=Config_matrix(state,'Initial T Sen2_RB2');
Position_offset=Config_matrix(state,'Position Offset'); %Neutral position offset, defined as the zero point to calculate kinematics
Position_offset_orig=Config_matrix(state,'Position Offset');
Position_offset=[Position_offset(1:3)*1000;Position_offset(4:6)*180/pi];
Position_offset_orig=[Position_offset_orig(1:3)*1000;Position_offset_orig(4:6)*180/pi];

%% Determine if left or right knee:
right = Config_matrix(setup, 'Specimen Side');

%% load in experiment run

for j = 1:length(input_path)
    input_file = tdmsread(input_path{j});

    %% Extract JCS kinematics and robot positions
    [JCS_flex,JCS_ext,RP_flex,RP_ext]=tdms_extraction(input_file);
    [JCS_flex_test,JCS_ext_test,JCS_flex_dig,JCS_ext_dig]=tdms_data_extraction_optvsdig(input_file);

    %% Convert robot position into transformation matrix
    T_W2_S2_flex=coordinate2matrix(RP_flex);
    T_W2_S2_ext=coordinate2matrix(RP_ext);
    T_W2_S2=[T_W2_S2_flex;T_W2_S2_ext];

    %% calculate TIBIA FROM ABOVE+JCS
    for i=1:size(T_W2_S2,1)

        T_RB1_RB2{i,1}=T_S1_RB1\T_W1_W2*T_W2_S2{i,1}*T_S2_RB2;
        T_RB1_RB2_dig{i,1}=T_S1_RB1_Orig\T_W1_W2*T_W2_S2{i,1}*T_S2_RB2_Orig;
        [angles(i,:),XYZ(i,:)]=rotationsAndTranslations_v2(T_RB1_RB2{i,1},right);
        [angles_dig(i,:),XYZ_dig(i,:)]=rotationsAndTranslations_v2(T_RB1_RB2_dig{i,1},right);


        Tibia_W2{i,1}=T_W2_S2{i,1}*T_S2_RB2;
        Femur_W2{i,1}=T_W1_W2\T_S1_RB1;

        Tibia_W2_dig{i,1}=T_W2_S2{i,1}*T_S2_RB2_Orig;
        Femur_W2_dig{i,1}=T_W1_W2\T_S1_RB1_Orig;

    end

    %% Calculate JCS kinematics

    xyz=XYZ_dig*1000;
    xyz_dig=XYZ_dig*1000;
    % Combine the matrices horizontally
    JCS_no_offset = horzcat(xyz,angles_dig);

    JCS_dig=[JCS_flex_dig;JCS_ext_dig];
    % JCS_dig=horzcat(xyz_dig,angles_dig);
    new_order=[4,2,1,3,6,5]; %change order of columns
    dig_order=[1,2,5,6,3,4];
    JCS_final = zeros(size(JCS_no_offset));
    for k=1:size(xyz,1)
        JCS_final(k,:)=JCS_no_offset(k,:)-Position_offset_orig';
        %     JCS_dig_final(k,:)=JCS_dig(k,:)-Position_offset_orig';
    end

    JCS_final=JCS_final(:,new_order);
    JCS_no_offset=JCS_no_offset(:,new_order);
    % JCS_dig_final=JCS_dig(:,dig_order);

    %check difference between SimVitro output and calculated output

    % error= JCS_final-[JCS_flex;JCS_ext];
    % error= JCS_final-JCS_dig_final;
    offset_error=JCS_no_offset-[JCS_flex;JCS_ext];

columnNames = {'Flexion', 'Posterior', 'Medial', 'Superior', 'Internal', 'Valgus'};

    % Create a table with the combined matrix and assign column names
    JCS_final = array2table(JCS_final, 'VariableNames', columnNames);
    % JCS_dig_final= array2table(JCS_dig_final, 'VariableNames', columnNames);
    JCS_flex = array2table(JCS_flex, 'VariableNames', columnNames);
    JCS_ext =array2table(JCS_ext, 'VariableNames', columnNames);
    % error=array2table(error, 'VariableNames', columnNames);

%% Write to CSV

    writetable(JCS_final, fullfile(file_path, file_name{j} + "_jcs_final.csv"))
    writetable(JCS_flex, fullfile(file_path, file_name{j} + "_jcs_flex.csv"))
    writetable(JCS_ext, fullfile(file_path, file_name{j} + "_jcs_ext.csv"))
end

 %% Code graveyard
