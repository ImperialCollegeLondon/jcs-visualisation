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
W1_T_W2=Config_matrix(state,'T_World1_World2'); % Transformation matrix between World 1 (Certus camera) and World 2 (Robot)
S1_T_RB1=Config_matrix(state,'T_Sensor1_RB1'); %Transformation from Certus to Rigid Body 1 (Femur)
S2_T_RB2=Config_matrix(state,'T_Sensor2_RB2'); %Transformation from Sensor 2 (Load Cell/Robot end effector) to Rigid Body 2 (Tibia)
RB2opt_T_RB2orig=Config_matrix(state,'T RB2-OPT_RB2-Orig'); % Transformation matrix 
RB1opt_T_RB1orig=Config_matrix(state,'T RB1-OPT_RB1-Orig');
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

    robot_pos = [RP_flex; RP_ext];
    W2_T_S2=coordinate2matrix(robot_pos); % End effector in Robot coordinate system

    %% calculate transform from TIBIA (RB2) to FEMUR (RB1).
     % i.e., femur in tibial frame of reference.
    for i=1:size(W2_T_S2,1)
        t_T_f{i,1} = ...
            S1_T_RB1 \ W1_T_W2 * ... % == RB1_T_W2; Robot in tibia frame of reference
            W2_T_S2{i,1}*S2_T_RB2; % == W2_T_RB2; Tibia in Robot frame of reference
                                    % Inverting the optimisation would go here
        kinematics_local(i,:) = rotationsAndTranslations_v3(t_T_f{i,1},right);
        
    end
    %% Calculate kinematics
    JCS{j} = [struct2table(JCS_flex); struct2table(JCS_ext)];
    kinematics_local=kinematics_local(1:height(JCS{j}),:);
    kinematics{j}= struct2table(kinematics_local);
    % Evidence of two errors:
    % 1: Kinematics flexion angle is negative
    % 2: kinematics translations were being multiplied by 1000 (m => mm),
    % which resulted in meaningless error. JCS is still in supposedly m,
    % but the values line up with expectations in mm.
    error{j}=kinematics{j}-JCS{j}; 


%% Write to CSV
    traj_folder = {trajectories.folder}';
    writetable(kinematics{j}, fullfile(traj_folder{j}, file_name{j} + "_kinematics.csv"))
    writetable(JCS{j}, fullfile(traj_folder{j}, file_name{j} + "_jcs.csv"))
    writetable(error{j}, fullfile(traj_folder{j}, file_name{j} + "_error.csv"))
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