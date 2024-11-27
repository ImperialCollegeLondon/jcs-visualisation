data_in=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\035_Persona_optimised_dynamic_lax_1BW\Data\035_Persona_optimised_dynamic_lax_1BW_8Nm_valg_flex_1of1_1_Main_processed.tdms');
 JCS_flex = [];
    JCS_ext = [];
    JCS_flex_digitised = [];
    JCS_ext_digitised = [];
    flex_ind = [];
    ext_ind = [];
    
for c = 1:numel(data_in)
        
        data = data_in{c};

        if ismember('JCS_Posterior', data.Properties.VariableNames)
            ap = -data.JCS_Posterior;
            flex = data.JCS_Flexion;
            peakFlex = find(flex == max(flex));
            disp(peakFlex)
            ir = data.('JCS_Internal Rotation');
            vv = data.('JCS_Valgus');

            flex_flex = flex(1:peakFlex);
            flex_ext = flex(peakFlex:end);

            flex_ind = find_indices(flex_flex, 0:round(max(flex)));
            ext_ind = find_indices(flex_ext, 0:round(max(flex)));
            ap_flex = ap(flex_ind)';
            ap_ext = ap(ext_ind)';
            ir_flex = ir(flex_ind)';
            ir_ext = ir(ext_ind)';
            vv_flex = vv(flex_ind)';
            vv_ext = vv(ext_ind)';

            JCS_flex = [(0:round(max(flex))); ap_flex; ir_flex; vv_flex]';
            JCS_ext= [(0:round(max(flex))); ap_ext; ir_ext; vv_ext]';
        end

      if ~isempty(flex_ind) && ismember('JCS_digitised_Posterior', data.Properties.VariableNames) &&  ismember('JCS_digitised_Posterior', data.Properties.VariableNames)
        ap_digitised = -data.JCS_digitised_Posterior;
%         flex_digitised = data.JCS_digitised_Flexion;
%         peakFlex = find(flex_digitised == max(flex_digitised));
        ir_digitised = data.('JCS_digitised_Internal Rotation');
        vv_digitised = data.('JCS_digitised_Valgus');

%         flex_flex_digitised = flex_digitised(1:peakFlex);
%         flex_ext_digitised = flex_digitised(peakFlex:end);
% 
%         flex_ind_digitised = find_indices(flex_flex_digitised, 0:round(max(flex_digitised)));
%         ext_ind_digitised = find_indices(flex_ext_digitised, 0:round(max(flex_digitised)));
        ap_flex_digitised = ap_digitised(flex_ind)';
        ap_ext_digitised = ap_digitised(ext_ind)';
        ir_flex_digitised = ir_digitised(flex_ind)';
        ir_ext_digitised = ir_digitised(ext_ind)';
        vv_flex_digitised = vv_digitised(flex_ind)';
        vv_ext_digitised = vv_digitised(ext_ind)';
     
         JCS_flex_digitised= [(0:round(max(flex))); ap_flex_digitised; ir_flex_digitised; vv_flex_digitised]';
         JCS_ext_digitised= [(0:round(max(flex))); ap_ext_digitised; ir_ext_digitised; vv_ext_digitised]';
      end
      end


function indices = find_indices(signal, values)
    indices = arrayfun(@(val) min(find(abs(signal - val) == min(abs(signal - val)))), values);
end


% data_in=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\020_Native_dynamic_lax_1BW\Data\020_Native_dynamic_lax_1BW_Neutral_flex_1of1_1_Main_processed.tdms'); 
% 
% flex_ind = [];
%     ext_ind = [];
%     ap_flex=[];
%     ap_ext=[];
%     ir_flex = [];
%     ir_ext = [];
%     vv_flex = [];
%     vv_ext = [];
%     robot_pos_x_flex = [];
%     robot_pos_x_ext = [];
%     robot_pos_y_flex = [];
%     robot_pos_y_ext = [];
%     robot_pos_z_flex = [];
%     robot_pos_z_ext = [];
%     robot_pos_pitch_flex = [];
%     robot_pos_pitch_ext = [];
%     robot_pos_roll_flex = [];
%     robot_pos_roll_ext = [];
%     robot_pos_yaw_flex = [];
%     robot_pos_yaw_ext = [];
% 
% % Loop through cells in the cell array for JCS  
%     for c = 1:numel(data_in)
%         data = data_in{c};
%         disp(['Checking for JCS in cell ', num2str(c)]);
%         
%         % Check for JCS
%         if sum(strcmp('JCS_Posterior', data_in{1, c}.Properties.VariableNames)) == 1
%             ap = -data.JCS_Posterior;
%             flex = data.JCS_Flexion;
%             peakFlex = find(flex == max(flex));
%             ir = data.("JCS_Internal Rotation");
%             vv = data.("JCS_Valgus");
% 
%             % Split into flexion and extension
%             flex_flex = flex(1:peakFlex);
%             flex_ext = flex(peakFlex:end);
% 
%             % Get indices of every degree
%             flex_ind = [flex_ind, find_indices(flex_flex, 0:round(max(flex)))];
%             ext_ind = [ext_ind, find_indices(flex_ext, 0:round(max(flex)))];
%             ap_flex = [ap_flex, ap(flex_ind)'];
%             ap_ext = [ap_ext, ap(ext_ind)'];
%             ir_flex = [ir_flex, ir(flex_ind)'];
%             ir_ext = [ir_ext, ir(ext_ind)'];
%             vv_flex = [vv_flex, vv(flex_ind)'];
%             vv_ext = [vv_ext, vv(ext_ind)'];
%             
%            
%         end
%     end
%     
%     % Initialize variables to store the entire 'Robot Position' columns
%     robot_pos_x_all = [];
%     robot_pos_y_all = [];
%     robot_pos_z_all = [];
%     robot_pos_pitch_all = [];
%     robot_pos_roll_all = [];
%     robot_pos_yaw_all = [];
% 
%     % Loop through cells in the cell array for Robot Position
%     for c = 1:numel(data_in)
%         data = data_in{c};
%         disp(['Checking for Robot Position in cell ', num2str(c)]);
%         
%         % Display the variable names in the current table
%         disp('Variable Names:');
%         disp(data.Properties.VariableNames);
%         
%         % Specify Robot Position column names
%         robot_pos_x_col = 'Robot Position_x';
%         robot_pos_y_col = 'Robot Position_y';
%         robot_pos_z_col = 'Robot Position_z';
%         robot_pos_pitch_col = 'Robot Position_pitch';
%         robot_pos_roll_col = 'Robot Position_roll';
%         robot_pos_yaw_col = 'Robot Position_yaw';
%         
%         % Check for Robot Position
%         if any(contains(data.Properties.VariableNames, robot_pos_x_col))
%             disp('Robot Position found!');
%             
%             % Update indexing to handle cell arrays
%             robot_pos_x_all = [robot_pos_x_all; data.(robot_pos_x_col)];
%             robot_pos_y_all = [robot_pos_y_all; data.(robot_pos_y_col)];
%             robot_pos_z_all = [robot_pos_z_all; data.(robot_pos_z_col)];
%             robot_pos_pitch_all = [robot_pos_pitch_all; data.(robot_pos_pitch_col)];
%             robot_pos_roll_all = [robot_pos_roll_all; data.(robot_pos_roll_col)];
%             robot_pos_yaw_all = [robot_pos_yaw_all; data.(robot_pos_yaw_col)];
%         else
%             disp('Robot Position not found in this cell.');
%         end
%     end
%  % Process robot_pos_x, robot_pos_y, etc.
%             robot_pos_x_flex = [robot_pos_x_flex,  robot_pos_x_all(flex_ind)];
%             robot_pos_x_ext = [robot_pos_x_ext,  robot_pos_x_all(ext_ind)];
%             robot_pos_y_flex = [robot_pos_y_flex,  robot_pos_y_all(flex_ind)];
%             robot_pos_y_ext = [robot_pos_y_ext, robot_pos_y_all(ext_ind)];
%             robot_pos_z_flex = [robot_pos_z_flex,  robot_pos_z_all(flex_ind)];
%             robot_pos_z_ext = [robot_pos_z_ext,  robot_pos_z_all(ext_ind)];
%             robot_pos_pitch_flex = [robot_pos_pitch_flex,  robot_pos_pitch_all(flex_ind)];
%             robot_pos_pitch_ext = [robot_pos_pitch_ext, robot_pos_pitch_all(ext_ind)];
%             robot_pos_roll_flex = [robot_pos_roll_flex, robot_pos_roll_all(flex_ind)];
%             robot_pos_roll_ext = [robot_pos_roll_ext, robot_pos_roll_all(ext_ind)];
%             robot_pos_yaw_flex = [robot_pos_yaw_flex,robot_pos_yaw_all(flex_ind)];
%             robot_pos_yaw_ext = [robot_pos_yaw_ext, robot_pos_yaw_all(ext_ind)];
%     
%  JCS_flex=[0:round(peakFlex),ap_flex,ir_flex,vv_flex];
%  JCS_ext=[0:round(peakFlex),ap_ext,ir_ext,vv_ext];
%  robot_pos_flex=[robot_pos_x_flex,robot_pos_y_flex,robot_pos_z_flex,robot_pos_roll_flex,robot_pos_pitch_flex,robot_pos_yaw_flex];
%  robot_pos_ext=[robot_pos_x_ext,robot_pos_y_ext,robot_pos_z_ext,robot_pos_roll_ext,robot_pos_pitch_ext,robot_pos_yaw_ext];
%  
% 
% 
% function indices = find_indices(signal, values)
%     indices = arrayfun(@(val) find(abs(signal - val) == min(abs(signal - val))), values);
% end
