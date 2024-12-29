function output = tdms_extraction(data_in, step_size)
    % tdms_extraction looks for the relevant cells in the cell array, in this
    % case JCS and robot position. For the JCS kinematics it also finds and
    % only outputs data at each degrees of flexion. If more datapoints are
    % wanted, change flex_ind and ext_ind (line 51 and 52). Robot positions are
    % output at each datapoints, as kinematics have to be calculated before
    % extracting flexion based points

    flexion_arc = [];
    
    for c = 1:numel(data_in)
        data = data_in{c};
        headers = data.Properties.VariableNames;
    
        %% JCS
        if any(contains(headers, "experiment run", "IgnoreCase", true))
            states = join(data.("Experiment Run"), '');
            states = split(states, '_');
            knee_state = state_regex(states(1));
            loading_condition = join(data.("Trajectory"), ''); % The join handles the multiple empty lines that show up because of transitions

            output.loading_condition = loading_condition_regex(loading_condition);
            output.state = matlab.lang.makeValidName(knee_state); % Knee states are used as field names, so must be made valid.
            output.specimen = join(data.("Specimen"), '');
        end
        % Check for JCS translations (= position in optimised coordinate
        % system)
        if any(strcmp('JCS_Posterior', headers))
            % if sum(strcmp('JCS_Posterior', headers)) == 1
            data.Properties.VariableNames = lower(regexprep(regexprep(headers, '^JCS_', ''), '\s\w*', '')); %First regex to remove starting with "JCS_". Second regex for Internal Rotation => Internal
    
            [peak_flexion, idx_peak_flexion] = max(data.flexion);
            peak_flexion = round(peak_flexion);
            min_flexion = round(min(data.flexion));
    
            ext_to_flex = data.flexion(1:idx_peak_flexion);
            flex_to_ext = data.flexion(idx_peak_flexion:end);
    
            idx_flexion = quantise(ext_to_flex, min_flexion:step_size:peak_flexion);
            idx_extension = quantise(flex_to_ext, peak_flexion:-step_size:min_flexion) + (idx_flexion(end) - 1); % Shift the extension indices to start at peak of flexion
    
            flexion_arc = union(idx_flexion, idx_extension);
            output.translations.actual = data(flexion_arc, :);
        end
        % Check for Desired translations and forces
        if any(contains(headers, "Desired"))
            data.Properties.VariableNames = lower(regexprep(regexprep(headers, '- Desired', ''), '\s\w*', '')); %First regex to remove starting with "- Desired". Second regex for Internal Rotation => Internal
            if any(contains(headers, "Drawer"))
                field_name = "forces";
            else
                field_name = "translations";
            end
            output.(field_name).desired = data(flexion_arc, :);
        end
        % Check for JCS (actual) loads
        if contains(headers, "JCS Load")
            data.Properties.VariableNames = lower(regexprep(regexprep(headers, '^JCS Load_', ''), '\s\w*', '')); %First regex to remove starting with "JCS Load_". Second regex for Internal Rotation => Internal
            output.forces.actual = data(flexion_arc, :);
        end
    
        %% Robot position
        if any(contains(headers, "robot position", "IgnoreCase", true))
            data.Properties.VariableNames = lower(regexprep(regexprep(headers, '^Robot Position_', ''), '\s\w*', ''));
            output.robot_position = data(flexion_arc, :);
        end
    
    end
end

function idx = quantise(signal, values)
diffs = abs(signal - values);
[~, idx] = min(diffs, [], 1);
end
