clear;

% Define the file path
file_path = 'C:\Users\sholthof\Desktop\Imperial\PHD\Data\SH2627\SH27\005_Optimised_dynamic_lax_1BW\Configuration\Project.sVprj\State.cfg';  % Replace with the path to your notepad file

% Define the target string to search for
target_string = 'Initial T Sen1_RB1';  % Replace with the string you want to find

% Open the file for reading
fileID = fopen(file_path, 'r');

if fileID == -1
    error('Failed to open the file.');
end

% Initialize variables
line_number = 0;
found_line = '';
string_found = false;

% Read the file line by line and search for the target string
while ~feof(fileID)
    line = fgetl(fileID);
    line_number = line_number + 1;
    
    if contains(line, target_string)
        fprintf('Found "%s" on line %d: %s\n', target_string, line_number, line);
        found_line = line;  % Store the line as a string
        string_found = true;
        break;  % Stop reading the file when the target string is found
    end
end

% Close the file
fclose(fileID);

% Check if the line was found or not
if string_found
    fprintf('The line containing "%s" is: %s\n', target_string, found_line);
  % Split the found line into numeric values and convert into a 4x4 matrix
values = regexp(found_line, '[" ]', 'split');

% Remove empty strings and convert to numeric values
values = str2double(values(~cellfun('isempty', values)));
% Find the indices of NaN values
nan_indices = isnan(values);

% Remove NaN values from the 'values' array
values = values(~nan_indices);
if numel(values) == 16
    matrix = reshape(values, 4, 4);
else
    fprintf('The line does not contain 16 numeric values.\n');
end
else
    fprintf('Line not found: "%s" was not found in the file.\n', target_string);
end




% T_S1_RB1=[0.0319815659 -0.1649891925 -0.9857767221 -0.3347935842; 0.9771849720 0.2123553444 -0.0038390349 0.0225435195; 0.2099683546 -0.9631634202 0.1680164159 -2.0913445964; 0.0000000000 0.0000000000 0.0000000000 1.0000000000];
% orig=[0;0;0;1];
% x_unit=[1;0;0;1];
% y_unit=[0;1;0;1];
% z_unit=[0;0;1;1];
% 
% 
% 
% fem_orig=T_S1_RB1*orig;
% fem_x=T_S1_RB1*x_unit;
% fem_y=T_S1_RB1*y_unit;
% fem_z=T_S1_RB1*z_unit;
% fem_CS=[fem_orig,fem_x,fem_y,fem_z];
% dig_points_import=[-0.3398542023 -0.0194226500 -2.0997302897 -0.3297329661 0.0645096891 -2.0829589030 -0.4890523326 0.0496465641 -2.0650150553 -0.4859613658 0.0227687265 -2.0361985636 -0.4941495860 0.0279849375 -2.0965596517 -0.4947795898 -0.0126592651 -2.0611191650];
% dig_points=reshape(dig_points_import,3,6)';
% 
% dig_points_x=dig_points(:,1);
% dig_points_y=dig_points(:,2);
% dig_points_z=dig_points(:,3);
% 
% 
% scatter3(dig_points_x,dig_points_y,dig_points_z,'filled')
% hold on
% scatter3(fem_CS(1,:),fem_CS(2,:),fem_CS(3,:))
% xlabel('X');
% ylabel('Y');
% zlabel('Z');
% title('digitised points');
% 
% 
