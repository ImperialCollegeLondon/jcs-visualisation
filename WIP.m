%% this code calculates the knee kinematics in both the original, digitised coordinate frame and the optimised coordinate frame
clear

%% Load in the Specimen folder
% State cfg file is used to create the transforms.

%% Load the digitised coordinate system files
digitised_root = uigetdir(".", "Pick the unoptimised trajectory");
config = fullfile(digitised_root, "Configuration");
unzip(fullfile(config, 'Project.sVprj'), config); 
state = fullfile(config, "State.cfg");

%% Extract relevant static matrices from cfg file
T_W1_W2=Config_matrix(state,'T_World1_World2'); % Transformation matrix between World 1 (Certus camera) and World 2 (Robot)
T_S1_RB1=Config_matrix(state,'T_Sensor1_RB1'); %Transformation from Certus to Rigid Body 1 (Femur)
T_S2_RB2=Config_matrix(state,'T_Sensor2_RB2'); %Transformation from Sensor 2 (Load Cell/Robot end effector) to Rigid Body 2 (Tibia)
% T_S1_RB1_Orig=Config_matrix(state,'Initial T Sen1_RB1');
% T_S2_RB2_Orig=Config_matrix(state,'Initial T Sen2_RB2');
Position_offset=Config_matrix(state,'Position Offset'); %Neutral position offset, defined as the zero point to calculate kinematics
Position_offset=[Position_offset(1:3)*1000;Position_offset(4:6)*180/pi];
% Position_offset_orig=Config_matrix(state,'Position Offset');
% Position_offset_orig=[Position_offset_orig(1:3)*1000;Position_offset_orig(4:6)*180/pi];

%% Determine if left or right knee:
setup = fullfile(config, "Setup.cfg");
right = Config_matrix(setup, 'Specimen Side');
clear setup state config 
%% Generate list of all trajectories
[root, ~, ~] = fileparts(digitised_root);
% trajectories = dir(fullfile(root, "**/*.tdms"));
trajectories = dir(fullfile(root, "**/*processed.tdms"));

input_path = fullfile({trajectories.folder}', {trajectories.name}');
[~, file_name, ~] = fileparts({trajectories.name}'); % Name without extension

% Find which ones are worth running
% Expects "_flex" in the name to be a real run, as well as one of the conditions mentioned below:
desiredOrder = {'ext', 'int', 'valg', 'var', 'ant', 'post', 'Neutral'};
run_conditions = extract_condition({trajectories.name}');
is_run = contains(run_conditions, desiredOrder);



%% load in experiment run

for j = 1:length(input_path)
    if ~is_run(j) || contains(file_name{j}, "IE_optimise") % These are usually runs pre optimisation. Comment out this block if all data should be processed.
        disp(strcat("Skipping: ", file_name{j}));
        continue
    end
    disp(strcat("Running: ", file_name{j}));
    input_file = tdmsread(input_path{j});

    %% Extract JCS kinematics and robot positions
    [JCS_flex,JCS_ext,RP_flex,RP_ext]=tdms_extraction(input_file);
    JCS_dig = [JCS_flex; JCS_ext];
    robot_pos = [RP_flex; RP_ext];
    T_W2_S2=coordinate2matrix(robot_pos);

    %% calculate TIBIA FROM ABOVE+JCS
    for i=1:size(T_W2_S2,1)
        T_RB1_RB2{i,1}=T_S1_RB1\T_W1_W2*T_W2_S2{i,1}*T_S2_RB2; %calculate transform from TIBIA (RB2) to FEMUR (RB1) 
        T_RB2_RB1{i,1}=T_RB1_RB2{i,1}^-1;
        [angles_dig(i,:),XYZ_dig(i,:)]=rotationsAndTranslations_v2(T_RB1_RB2{i,1},right);

        final_XYZ(i,:) = XYZ_dig(i,:)*1000; % Convert translation from m to mm
        % Tibia_W2{i,1}=T_W2_S2{i,1}*T_S2_RB2;
        % Femur_W2{i,1}=T_W1_W2\T_S1_RB1;
        %
        % Tibia_W2_dig{i,1}=T_W2_S2{i,1}*T_S2_RB2_Orig;
        % Femur_W2_dig{i,1}=T_W1_W2\T_S1_RB1_Orig;

    end

    %% Calculate JCS kinematics

    % Combine the matrices horizontally
    new_order=[4,2,1,3,6,5]; %change order of columns

    columnNames = {'Flexion', 'Posterior', 'Medial', 'Superior', 'Internal', 'Valgus'};
    kinematics_final=horzcat(final_XYZ,angles_dig);
    % kinematics_final=[flex_kinematics;ext_kinematics];
    kinematics_final=kinematics_final(:,new_order);
    kinematics_final=kinematics_final(1:length(JCS_dig),:);

    error=kinematics_final-JCS_dig;

    kinematics_final= array2table(kinematics_final, 'VariableNames', columnNames); 
    JCS_final=array2table(JCS_dig,'VariableNames', columnNames); 
    error=array2table(error,'VariableNames', columnNames); 

    all_kinematics{j} = kinematics_final;
    all_JCS{j}=JCS_final;
    all_error{j}=error;


    % Create a table with the combined matrix and assign column names
    JCS_final = array2table(JCS_final, 'VariableNames', columnNames);
    % JCS_dig_final= array2table(JCS_dig_final, 'VariableNames', columnNames);
    JCS_flex = array2table(JCS_flex, 'VariableNames', columnNames);
    JCS_ext =array2table(JCS_ext, 'VariableNames', columnNames);
    % error=array2table(error, 'VariableNames', columnNames);

%% Write to CSV
    traj_folder = {trajectories.folder}';
    writetable(all_kinematics{j}, fullfile(traj_folder{j}, file_name{j} + "_kinematics.csv"))
    writetable(all_JCS{j}, fullfile(traj_folder{j}, file_name{j} + "_jcs.csv"))
    writetable(all_error{j}, fullfile(traj_folder{j}, file_name{j} + "_error.csv"))
end

function term = extract_condition(names)
% Determine the running conditions. e.g, external, internal, anterior, etc.
% If it cannot find the term "flex" in the name, it copies a large chunk of text to give some clues of what it is.
term = cell(size(names));
for i = 1:numel(names)
    name = names{i};
    segments = strsplit(name, '_');

    cmp = strcmp(segments, 'flex');
    if any(cmp)
        id = find(cmp);
        term{i} = segments{id-1};
    else
        id = find(contains(segments, '1of1'));
        term{i} = strcat(segments{2:id - 1});
    end
end
end