clear
%% this code calculates the knee kinematics in both the original, digitised coordinate frame and the optimised coordinate frame


%% START CODE


% [config_file,config_path] = uigetfile('C:\Users\sholthof\Desktop\Imperial\PHD\Data\SH2627\SH27\005_Optimised_dynamic_lax_1BW\Configuration\Project');

%% Load in Setup cfg file
% Intact_folderPath = ['C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\Matlab\CS calculations\SH38\008_Native_Flexion 0-90\Configuration\Project.sVprj'];

Attune_folderPath='../data-processing/data/JJH15/075_UKA+ACL_flex-ext_1BW_5IE_90AP/Configuration/Project.sVprj';
% Persona_folderPath='C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\035_Persona_optimised_dynamic_lax_1BW\Configuration\Project.sVprj';
% Triathlon_folderPath='C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\039_Triathlon_optimised_dynamic_lax_1BW\Configuration\Project.sVprj';
% Define the filter to show all files using the wildcard '*.*'
[config_file, config_path] = uigetfile(fullfile(Attune_folderPath, '*.*'), 'Select a file');

%% Extract relevant static matrices from cfg file
T_W1_W2=Config_matrix(fullfile(config_path,config_file),'T_World1_World2'); % Transformation matrix between World 1 (Certus camera) and World 2 (Robot)
T_S1_RB1=Config_matrix(fullfile(config_path,config_file),'T_Sensor1_RB1'); %Transformation from Certus to Rigid Body 1 (Femur)
T_S2_RB2=Config_matrix(fullfile(config_path,config_file),'T_Sensor2_RB2'); %Transformation from Sensor 2 (Load Cell/Robot end effector) to Rigid Body 2 (Tibia)
T_S1_RB1_Orig=Config_matrix(fullfile(config_path,config_file),'Initial T Sen1_RB1');
T_S2_RB2_Orig=Config_matrix(fullfile(config_path,config_file),'Initial T Sen2_RB2');
Position_offset=Config_matrix(fullfile(config_path,config_file),'Position Offset'); %Neutral position offset, defined as the zero point to calculate kinematics
Position_offset_orig=Config_matrix(fullfile(config_path, config_path),'Position Offset');
Position_offset=[Position_offset(1:3)*1000;Position_offset(4:6)*180/pi];
Position_offset_orig=[Position_offset_orig(1:3)*1000;Position_offset_orig(4:6)*180/pi];

%% load in experiment run
input_file=tdmsread("/home/jj/Documents/Education/doctorate/uka-aclr/data-processing/data/JJH15/075_UKA+ACL_flex-ext_1BW_5IE_90AP/Data/test.tdms");
%% Extract JCS kinematics and robot positions
[JCS_flex,JCS_ext,RP_flex,RP_ext]=tdms_extraction(input_file);
[JCS_flex_test,JCS_ext_test,JCS_flex_dig,JCS_ext_dig]=tdms_data_extraction_optvsdig(input_file);

%% Convert robot position into transformation matrix
T_W2_S2_flex=coordinate2matrix(RP_flex);
T_W2_S2_ext=coordinate2matrix(RP_ext);
T_W2_S2=[T_W2_S2_flex;T_W2_S2_ext];

% test=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Data\SH2627\SH27\005_Optimised_dynamic_lax_1BW\Data\005_Optimised_dynamic_lax_1BW_Neutral_flex_1of1_1_Main_processed.tdms');
%% calculate TIBIA FROM ABOVE+JCS

right=true;

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
for k=1:size(xyz,1)
    JCS_final(k,:)=JCS_no_offset(k,:)-Position_offset_orig';
%     JCS_dig_final(k,:)=JCS_dig(k,:)-Position_offset_orig';
end

JCS_final=JCS_final(:,new_order);
JCS_no_offset=JCS_no_offset(:,new_order);
JCS_dig_final=JCS_dig(:,dig_order);

%check difference between SimVitro output and calculated output

% error= JCS_final-[JCS_flex;JCS_ext];
error= JCS_final-JCS_dig_final;
offset_error=JCS_no_offset-[JCS_flex;JCS_ext];

% Define column names
columnNames = {'Flexion', 'Posterior', 'Medial', 'Superior', 'Internal', 'Valgus'};



% Create a table with the combined matrix and assign column names
JCS_final = array2table(JCS_final, 'VariableNames', columnNames);
JCS_dig_final= array2table(JCS_dig_final, 'VariableNames', columnNames);
JCS_flex = array2table(JCS_flex, 'VariableNames', columnNames);
JCS_ext=array2table(JCS_ext, 'VariableNames', columnNames);
error=array2table(error, 'VariableNames', columnNames);



 %% Code graveyard
