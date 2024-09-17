clear


%% Preallocate necessary variables

 flex_ind = [];
 ext_ind = [];


%% Load in relevant config files and experiment run files

right=true; %if knee is right knee TRUE, otherwise FALSE
implant_type='triathlon';  

intact_dig_folderPath = ['C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\Matlab\CS calculations\SH44\016_Persona_Flexion 0-90\Configuration\Project.sVprj.zip']; %folderpath JCS_digitised (original CS)
[config_file, config_path] = uigetfile(fullfile(intact_dig_folderPath, '*.*'), 'Select a file'); %opens window, select State.cfg file
% PF_pos_offset=Config_matrix(append(config_path,config_file),'Position Offset');
% PF_pos_offset=[Position_offset(1:3)*1000;Position_offset(4:6)*180/pi];
T_W1_W2=Config_matrix(append(config_path,config_file),'T_World1_World2'); % Transformation matrix between World 1 (Certus camera) and World 2 (Robot)
T_S1_RB1=Config_matrix(append(config_path,config_file),'T_Sensor1_RB1'); %Transformation from Certus to Rigid Body 1 (Femur)
T_S2_RB2=Config_matrix(append(config_path,config_file),'T_Sensor2_RB2'); %Transformation from Sensor 2 (Load Cell/Robot end effector) to Rigid Body 2 (Tibia)
femoral_points=Config_matrix(append(config_path,config_file),'Collected Points Rigid Body 1');
lateral_epi=femoral_points(1:3);
medial_epi=femoral_points(4:6);
femur_width=norm(medial_epi-lateral_epi);
% Position_offset=Config_matrix(append(config_path,config_file),'Position Offset'); %Neutral position offset, defined as the zero point to calculate kinematics
% Position_offset=[Position_offset(1:3)*1000;Position_offset(4:6)*180/pi];
%the above matrices are based on the ORIGINAL, DIGITISED coordinate system

%Load in the experiment run (Intact,Attune,...)

passive_flexion=('C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\Matlab\CS calculations\SH44\016_Persona_Flexion 0-90\Data');

% PF_setup=('C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\Matlab\CS calculations\SH43\004_Native_Flexion 0-90\Data');
% %[PF_setupfile,PF_setupfolder]=uigetfile(fullfile(PF_setup, '*.*'), 'Select a file');
% Position_offset=Config_matrix(append(PF_setupfolder,PF_setupfile),'Position Offset'); %Neutral position offset, defined as the zero point to calculate kinematics
% Position_offset=[Position_offset(1:3)*1000;Position_offset(4:6)*180/pi];

experiment_run=('C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\Matlab\CS calculations\SH44\015_Triathlon_optimised_dynamic_lax_1BW\Data\');

%% Sort files to be in the same order every time (written into correct excel sheet)

% Get a list of all files in the folder
experiment_files = dir(fullfile(experiment_run,'*processed.tdms'));

% List of strings in the desired order
desiredOrder = {'ext', 'int', 'valg', 'var', 'ant', 'post', 'Neutral'};

% Extract the part of the file name that you want to use for sorting
fileNames = {experiment_files.name};
stringPart = cellfun(@(x) extractBetween(x, '1BW', 'flex'), fileNames, 'UniformOutput', false);
stringPart = cellfun(@char, stringPart, 'UniformOutput', false);

% Initialize a cell array to store the reordered elements

% Loop through each element in desiredOrder
for i = 1:length(desiredOrder)
    % Find the index of the matching element in stringPart
    index = find(contains(stringPart, desiredOrder{i}), 1);
    
  % Assign the matching fields from experiment_files to sortedFiles
    sortedFiles(i).name = experiment_files(index).name;
    sortedFiles(i).folder = experiment_files(index).folder;
    sortedFiles(i).date = experiment_files(index).date;
    sortedFiles(i).bytes = experiment_files(index).bytes;
    sortedFiles(i).isdir = experiment_files(index).isdir;
    sortedFiles(i).datenum = experiment_files(index).datenum;

end

% Display the reorderedArray

% Sort the files based on the assigned indices


% Now you can loop through the sorted files and load them
% for i = 1:numel(sortedFiles)
%     currentFile = sortedFiles(i);
%     fullPath = fullfile(folderPath, currentFile.name);
% 
% end

PF_file = dir(fullfile(passive_flexion,'*processed.tdms'));
files=[PF_file,sortedFiles];
%files=sortedFiles;

all_kinematics=cell(1, numel(files));

%% Run through each of the loading conditions

for i = 1:numel(all_kinematics)
    flex_ind=[];
    ext_ind=[];
    file_path = fullfile(files(i).folder, files(i).name);
    disp(['Processing file: ', files(i).name]);
    
    % Load data from the file
    input_data = tdmsread(file_path); % Uses tdsmread function, which returns a cell array of data, each cell represents an excel sheet
    
    %Extract the robot positions and kinematics in the optimised coordinate
    %system

    [JCS_flex,JCS_ext,flex_robotPos,ext_robotPos]=tdms_extraction(input_data);
    robotPos=[flex_robotPos;ext_robotPos];
    JCS_dig=[JCS_flex;JCS_ext];
    T_W2_S2=coordinate2matrix(robotPos); %calculate the transformation matrix from robot to end effector from robot positions
    
%     for k=1
% 
%      T_RB1_RB2{k,1}=T_S1_RB1\T_W1_W2*T_W2_S2{k,1}*T_S2_RB2; %calculate transform from TIBIA (RB2) to FEMUR (RB1) 
%      [angles_dig(k,:),XYZ_dig(k,:)]=rotationsAndTranslations_v2(T_RB1_RB2{k,1},right);
% 
%     end

    for k=1:size(T_W2_S2,1)

        T_RB1_RB2{k,1}=T_S1_RB1\T_W1_W2*T_W2_S2{k,1}*T_S2_RB2; %calculate transform from TIBIA (RB2) to FEMUR (RB1) 
        T_RB2_RB1{k,1}=T_RB1_RB2{k,1}^-1;
        [med_epi{k},lat_epi{k}]=femur_projection(T_RB2_RB1{k,1},femur_width);
        [angles_dig(k,:),XYZ_dig(k,:)]=rotationsAndTranslations_v2(T_RB1_RB2{k,1},right); %turn transforms into rotations and translations: angles=[flex,Valg,IE], XYZ=[ML,AP,SI];
%       final_angles(k,:)=angles_dig(k,:)-Position_offset(4:6)';
        final_XYZ(k,:)=XYZ_dig(k,:)*1000; %convert translation from m to mm
        %-Position_offset(1:3)';
    end

    %Reorder, combine and gives headers

    new_order=[4,2,1,3,6,5]; %change order of columns for robot position based kinematics
    columnNames = {'Flexion', 'Posterior', 'Medial', 'Superior', 'Internal', 'Valgus'};
    kinematics_final=horzcat(final_XYZ,angles_dig);
%     kinematics_final=[flex_kinematics;ext_kinematics];
    kinematics_final=kinematics_final(:,new_order);
    kinematics_final=kinematics_final(1:length(JCS_dig),:);

    error=kinematics_final-JCS_dig;

    kinematics_final= array2table(kinematics_final, 'VariableNames', columnNames); 
    JCS_final=array2table(JCS_dig,'VariableNames', columnNames); 
    error=array2table(error,'VariableNames', columnNames); 
    %save into cell array
    all_kinematics{i} = kinematics_final;
    all_JCS{i}=JCS_final;
    all_error{i}=error;
end

%% Write kinematics to excel

results_file='C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\Matlab\CS calculations\SH44\SH44.xlsx';
Write2Excel_robot(all_kinematics, results_file,'neutral')
Write2Excel_robot(all_kinematics, results_file,implant_type)

% results_file='C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\Matlab\CS calculations\SH38\SH38_optimised.xlsx';
% Write2Excel_robot(all_JCS, results_file,'neutral')
% Write2Excel_robot(all_JCS, results_file,implant_type)
% % 
% % This is set up to work specifically with template provided
% for i=1:numel(all_kinematics)
%     if i==1
%         Write2Excel_robot(all_kinematics, results_file,'neutral')
%         
%     end
%     if i>1
%         Write2Excel_robot(all_kinematics, results_file,implant_type)
%     end
% end

 %% Function to find angles
% function indices = find_indices(signal, values)
%     indices = arrayfun(@(val) max(find(abs(signal - val) == min(abs(signal - val)))), values);
% end

%% Visualise coordinate systems and calculate differences






