% Specify the folder containing the files
folder_path = 'C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\019_Native_Flexion 0-90\Data'; % Update with the path to your folder
implant= 'attune'; %intact,attune,persona or triathlon, as a string

% Get a list of all files in the folder
files = dir(fullfile(folder_path,'*processed.tdms'));

% Preallocate cell arrays to store extracted data for each file

JCS_flex_cell = cell(1, numel(files));
JCS_ext_cell = cell(1, numel(files));
JCS_flex_digitised_cell = cell(1, numel(files));
JCS_ext_digitised_cell = cell(1, numel(files));

% Loop through each file

for i = 1:numel(files)
    file_path = fullfile(folder_path, files(i).name);
    disp(['Processing file: ', files(i).name]);
    
    % Load data from the file
    loaded_data = tdmsread(file_path);
   
    % Extract data using the function tdms_data_extraction_optvsdig
    [JCS_flex, JCS_ext, JCS_flex_digitised, JCS_ext_digitised] = tdms_data_extraction_optvsdig(loaded_data);
%     [JCS_flex, JCS_ext, JCS_flex_digitised, JCS_ext_digitised] = tdms_extraction(loaded_data);
    
    % Store extracted data for each file
    JCS_flex_cell{i} = JCS_flex;
    JCS_ext_cell{i} = JCS_ext;
    JCS_flex_digitised_cell{i} = JCS_flex_digitised;
    JCS_ext_digitised_cell{i} = JCS_ext_digitised;
end

%% Write the extracted data to an Excel file

%define excel file
output_filename='C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\SH25_passive_flexion.xlsx';


% Loop through each cell in the cell array
for i = 1:numel(JCS_flex_digitised_cell)

    % Call the function Write2Excel_robot for the content of each cell
    Write2Excel_robot(JCS_flex_digitised_cell, JCS_ext_digitised_cell, output_filename, implant);

end


% Create a cell array combining all extracted data
all_data = [JCS_flex_cell; JCS_ext_cell; JCS_flex_digitised_cell; JCS_ext_digitised_cell];

% for i=1:numel(JCS_flex_cell)

% Write the data to an Excel file
% xlswrite(output_path, all_data, output_sheet);
% disp(['Data written to Excel file: ', output_filename]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data_in=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\028_Attune_optimised_dynamic_lax_1BW\Data\028_Attune_optimised_dynamic_lax_1BW_8Nm_var_flex_1of1_1_Main_processed.tdms')
% 
% for c = 1:numel(data_in)
%         
%         data = data_in{c};
% 
%         if ismember('JCS_Posterior', data.Properties.VariableNames)
%             ap = -data.JCS_Posterior;
%             flex = data.JCS_Flexion;
%             peakFlex = find(flex == max(flex));
%             ir = data.('JCS_Internal Rotation');
%             vv = data.('JCS_Valgus');
% 
%             flex_flex = flex(1:peakFlex);
%             flex_ext = flex(peakFlex:end);
% 
%             flex_ind = find_indices(flex_flex, 0:round(max(flex)));
%             ext_ind = find_indices(flex_ext, 0:round(max(flex)));
% %             flex_ind = [flex_ind{:}];
% %             ext_ind=[ext_ind{:}];
%             ap_flex = ap(flex_ind)';
%             ap_ext = ap(ext_ind)';
%             ir_flex = ir(flex_ind)';
%             ir_ext = ir(ext_ind)';
%             vv_flex = vv(flex_ind)';
%             vv_ext = vv(ext_ind)';
% 
%             JCS_flex = [(0:round(max(flex))); ap_flex; ir_flex; vv_flex]';
%             JCS_ext= [(0:round(max(flex))); ap_ext; ir_ext; vv_ext]';
%         end
% 
%       if ismember('JCS_digitised_Posterior', data.Properties.VariableNames)
%         ap_digitised = -data.JCS_digitised_Posterior;
% %         flex_digitised = data.JCS_digitised_Flexion;
% %         peakFlex = find(flex_digitised == max(flex_digitised));
%         ir_digitised = data.('JCS_digitised_Internal Rotation');
%         vv_digitised = data.('JCS_digitised_Valgus');
% 
% %         flex_flex_digitised = flex_digitised(1:peakFlex);
% %         flex_ext_digitised = flex_digitised(peakFlex:end);
% % 
% %         flex_ind_digitised = find_indices(flex_flex_digitised, 0:round(max(flex_digitised)));
% %         ext_ind_digitised = find_indices(flex_ext_digitised, 0:round(max(flex_digitised)));
%         ap_flex_digitised = ap_digitised(flex_ind)';
%         ap_ext_digitised = ap_digitised(ext_ind)';
%         ir_flex_digitised = ir_digitised(flex_ind)';
%         ir_ext_digitised = ir_digitised(ext_ind)';
%         vv_flex_digitised = vv_digitised(flex_ind)';
%         vv_ext_digitised = vv_digitised(ext_ind)';
%      
%          JCS_flex_digitised= [(0:round(max(flex))); ap_flex_digitised; ir_flex_digitised; vv_flex_digitised]';
%          JCS_ext_digitised= [(0:round(max(flex))); ap_ext_digitised; ir_ext_digitised; vv_ext_digitised]';
%       end
%       end
% 
% 
% function indices = find_indices(signal, values)
%     indices = arrayfun(@(val) min(find(abs(signal - val) == min(abs(signal - val)))), values);
% end
