clear
%% this code calculates the knee kinematics in both the original, digitised coordinate frame and the optimised coordinate frame


%% START CODE


% [config_file,config_path] = uigetfile('C:\Users\sholthof\Desktop\Imperial\PHD\Data\SH2627\SH27\005_Optimised_dynamic_lax_1BW\Configuration\Project');

%% Load in Setup cfg file
right=false;

Intact_folderPath = 'C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\SimVitro files\Cadaveric_MCL\SH06\003_Native_reset to 0\Configuration\Project.sVprj\State.cfg';
% Attune_folderPath='C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\SimVitro files\Cadaveric_MCL\SH06\002_Native_Flexion 0-90\Configuration\Project.sVprj\State.cfg';
% Persona_folderPath='C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\SimVitro files\Cadaveric_MCL\SH49_implanted\016_Persona_dynamic_lax_1BW\Configuration\Project.sVprj\State.cfg';
% Triathlon_folderPath='C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\SimVitro files\Cadaveric_MCL\SH49_implanted\020_Triathlon_dynamic_lax_1BW\Configuration\Project.sVprj\State.cfg';

%load in experiment runs
Intact_run=tdmsread('C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\SimVitro files\Cadaveric_MCL\SH06\002_Native_Flexion 0-90\Data\002_Native_Flexion 0-90_Passive Flexion_1of1_1_Main_processed.tdms');
% Attune_run=tdmsread('C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\SimVitro files\Cadaveric_MCL\SH06\002_Native_Flexion 0-90\Data\002_Native_Flexion 0-90_Passive Flexion_1of1_1_Main_processed.tdms');
% Persona_run=tdmsread('C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\SimVitro files\Cadaveric_MCL\SH49_implanted\016_Persona_dynamic_lax_1BW\Data\016_Persona_dynamic_lax_1BW_Neutral_flex_1of1_1_Main_processed.tdms');
% Triathlon_run=tdmsread('C:\Users\sholthof\OneDrive - Imperial College London\Imperial\PHD\SimVitro files\Cadaveric_MCL\SH49_implanted\020_Triathlon_dynamic_lax_1BW\Data\020_Triathlon_dynamic_lax_1BW_Neutral_flex_1of1_1_Main_processed.tdms');

%%Calculate Tibia and Femur CS in robot world (W2), both digitised and
%%optimised

Intact_matrices=CS_Extraction(Intact_folderPath,Intact_run,right);
% Attune_matrices=CS_Extraction(Attune_folderPath,Attune_run,right);
% Persona_matrices=CS_Extraction(Persona_folderPath,Persona_run,right);
% Triathlon_matrices=CS_Extraction(Triathlon_folderPath,Triathlon_run,right);

%%OUTPUTS ARE OPTIMISED TIBIA, OPTIMISED FEMUR, DIGITISED TIBIA AND
%%DIGITISED FEMUR IN THAT ORDER


%% Create video of coordinate systems

% Create a VideoWriter object
v = VideoWriter(['SH06_digvsopt.mp4'], 'MPEG-4');
v.FrameRate = 10; % Set the frame rate (adjust as needed)
open(v);


% Iterate through 101 transformation matrices
for i = 1:101
    % Plot the transformed coordinate axes for the current transformation matrix
    figure;
    hold on

%     opt_Femur_W2{i,1}=visualiseCoordinateSystem(Femur_W2{i,1},{'r', 'r', 'r'});
%     dig_Femur_W2{i,1}=visualiseCoordinateSystem(Femur_W2_dig{i,1},{'y', 'y', 'y'});
%     dig_Tibia_W2{i,1}=visualiseCoordinateSystem(Tibia_W2_dig{i,1},{'m', 'm', 'm'});
    dig_Tibia_W2_intact{i,1}=visualiseCoordinateSystem(Intact_matrices{3}{i,1},{'k', 'k:', 'k--'},1000,25);
    opt_Tibia_W2_intact{i,1}=visualiseCoordinateSystem(Intact_matrices{1}{i,1},{'b', 'b:', 'b--'},1000,25);
    % opt_Tibia_W2_attune{i,1}=visualiseCoordinateSystem(Attune_matrices{1}{i,1},{'g', 'g:', 'g--'},1000,25);
    % opt_Tibia_W2_persona{i,1}=visualiseCoordinateSystem(Persona_matrices{1}{i,1},{'m', 'm:', 'm--'},1000,25);
    % opt_Tibia_W2_triathlon{i,1}=visualiseCoordinateSystem(Triathlon_matrices{1}{i,1},{'r', 'r:', 'r--'},1000,25);
    
    dig_Femur_W2_intact{i,1}=visualiseCoordinateSystem(Intact_matrices{4}{1,1},{'k', 'k:', 'k'},1000,25);
    opt_Femur_W2_intact{i,1}=visualiseCoordinateSystem(Intact_matrices{2}{1,1},{'b', 'b:', 'b'},1000,25);
    % opt_Femur_W2_attune{i,1}=visualiseCoordinateSystem(Attune_matrices{2}{1,1},{'g', 'g:', 'g'},1000,25);
    % opt_Femur_W2_persona{i,1}=visualiseCoordinateSystem(Persona_matrices{2}{1,1},{'m', 'm:', 'm'},1000,25);
    % opt_Femur_W2_triathlon{i,1}=visualiseCoordinateSystem(Triathlon_matrices{2}{1,1},{'r', 'r:', 'r'},1000,25);

    legend ('Intact dig','','','Intact')
    % ,'','','Attune','','','Persona','','','Triathlon','','')
    title('Tibial coordinate systems')
    
    % [Tibia_diff(i,:),Tibia_APdiff(i,:),Tibia_Origdiff(i,:)]=calculateCS_change(dig_Tibia_W2_intact{i,1}, opt_Tibia_W2_intact{i,1},opt_Tibia_W2_attune{i,1},opt_Tibia_W2_persona{i,1},opt_Tibia_W2_triathlon{i,1});
    % [Femur_diff(i,:),Femur_APdiff(i,:),Femur_Origdiff(i,:)]=calculateCS_change(dig_Femur_W2_intact{i,1}, opt_Femur_W2_intact{i,1},opt_Femur_W2_attune{i,1},opt_Femur_W2_persona{i,1},opt_Femur_W2_triathlon{i,1});
    % Change the view angle for each frame (for example, rotating the view)
    view(0, 90); % Adjust angles based on the frame index 'i'

    % Capture the current figure as a frame in the video
    writeVideo(v, getframe(gcf));

    % Close the figure to prevent cluttering
    close;

end
% Close the video file
close(v);

%% check differences between coordinate systems

%Since all vectors are unit vectors, dot product equal cos(angle)





%% Code graveyard


% xyz=XYZ*1000;
% xyz_dig=XYZ_dig*1000;
% % Combine the matrices horizontally
% JCS_no_offset = horzcat(xyz,angles);
% JCS_dig=horzcat(xyz_dig,angles_dig);
% new_order=[4,2,1,3,6,5]; %change order of columns 
% 
% for k=1:size(xyz,1)
%     JCS_final(k,:)=JCS_no_offset(k,:)-Position_offset';
% end
% 
% JCS_final=JCS_final(:,new_order);
% JCS_no_offset=JCS_no_offset(:,new_order);
% JCS_dig=JCS_dig(:,new_order);
% %check difference between SimVitro output and calculated output
% 
% error= JCS_final-JCS_flex;
% offset_error=JCS_no_offset-JCS_flex;
% 
% % Define column names
% columnNames = {'Flexion', 'Posterior', 'Medial', 'Superior', 'Valgus', 'Internal'};
% 
% 
% 
% % Create a table with the combined matrix and assign column names
% JCS_final = array2table(JCS_final, 'VariableNames', columnNames);
% JCS_dig= array2table(JCS_dig, 'VariableNames', columnNames);
% JCS_flex = array2table(JCS_flex, 'VariableNames', columnNames);
% JCS_ext=array2table(JCS_ext, 'VariableNames', columnNames);


% % Display the resulting table
% disp(JCS_no_offset);


%Take position offset
%Look for position offset in state file
%Take JCS and add PO
%Convert to T_FEM_TIB using knee module page 8 matrix
%Multiply by T_SENS1_RB1

%%what we need to extract
%orig_T_SENS1_RB1
%Optimised T_SENS1_RB1
