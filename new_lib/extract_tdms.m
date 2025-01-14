function output = extract_tdms(data, config)
%% Run information
output.specimen = data.Attributes__Test_Description.Specimen.data{:};
output.loading_condition = data.Attributes__Test_Description.Trajectory.data{:};
knee_state = data.Attributes__Test_Description.Experiment_Run.data{:};
knee_state = split(knee_state, '_');
knee_state = knee_state(1);
output.state = state_regex(knee_state{:});

%% Flexion
flexion = extract_data(data.State_JCS, "JCS_");
% Split flexion and extension
[peak_flexion, idx_peak_flexion] = max(flexion.Flexion);
peak_flexion = round(peak_flexion);
min_flexion = round(min(flexion.Flexion));
ext_to_flex = flexion.Flexion(1:idx_peak_flexion);
flex_to_ext = flexion.Flexion(idx_peak_flexion:end);
% Quantised flexion arc
idx_flexion = quantise(ext_to_flex, min_flexion:config.step_size:peak_flexion);
idx_extension = quantise(flex_to_ext, peak_flexion:-config.step_size:min_flexion) + (idx_flexion(end) - 1);
flexion_arc = union(idx_flexion, idx_extension)';

output.translation.actual = flexion(flexion_arc, :);

%% Rest
output.forces.actual = extract_data(data.State_JCS_Load, "JCS_Load_", flexion_arc);
output.forces.desired = extract_data(data.Kinetics_JCS_Desired, "___Desired", flexion_arc);
output.translation.desired = extract_data(data.Kinematics_JCS_Desired, "___Desired", flexion_arc);
output.robot_position = extract_data(data.Sensor_Robot_Position, "Robot_Position_", flexion_arc);
end

function output = extract_data(name, str_rep, flexion_arc)
arguments
    name 
    str_rep 
    flexion_arc = ':';
end
    headers = fieldnames(name);
    headers(ismember(headers, {'name', 'Props'})) = [];
    new_headers = replace(headers, str_rep, "");
    output = table();
    for f = 1:numel(headers)
        datum = name.(headers{f}).data(flexion_arc);
        output.(new_headers{f}) = datum(:);
    end
end

function idx = quantise(signal, values)
diffs = abs(signal - values);
[~, idx] = min(diffs, [], 1);
end