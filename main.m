%% this code calculates the knee kinematics in both the original, digitised coordinate frame and the optimised coordinate frame
clc;clear; close all;
profile on;
diary("log.txt"); % Creates a log. Important for checking which runs failed!!

%% Load in the Specimen folder
defaults;

% State cfg file is used to create the transforms.
disp("Pick the folder with all the specimens")
root = uigetdir(".", "Pick the folder with all specimens");
specimen_list = get_root_files(root, {'result'}).unwrap();
path_specimens = fullfile({specimen_list.folder}, {specimen_list.name});
%% Run data
ii = 1;
for sp = 1:numel(path_specimens) % Navigate specimens
    specimen_name = get_specimen_name(specimen_list(sp).name);
    fprintf("%d. Specimen folder: %s\n", sp, specimen_name);
    trajectory_sets = get_root_files(path_specimens{sp}, {});
    if trajectory_sets.is_none()
        warning("Folder contains no runs");
        continue
    end
    trajectory_sets = trajectory_sets.unwrap();
    % root_specimen = {trajectory_sets.folder};
    % root_specimen = root_specimen{1};
    path_trajectory_sets = string(fullfile({trajectory_sets.folder}, {trajectory_sets.name}));

    for ts = 1:numel(trajectory_sets) % Navigate trajectory sets
        path_trajectory_set = path_trajectory_sets(ts);
        [~, trajectory_set, ~] = fileparts(path_trajectory_set);
        trajectories = dir(fullfile(path_trajectory_set, "**/*processed.tdms"));
        if isempty(trajectories)
            continue
        end
        input_path = fullfile({trajectories.folder}, {trajectories.name});
        [~, file_name, ~] = fileparts({trajectories.name}'); % Name without extension

        [config, state, setup] = load_config(path_trajectory_set, config);
        % Visualise landmarks
        titles = [specimen_name replace(trajectory_set, '_', ' ')];
        visualise_digitisation(state, config, titles);

        %% load in experiment run
        for t = 1:numel(trajectories)
            trajectory = input_path{t};
            fprintf("  Run %d: %s\n", ii, regexprep(file_name{t}, '_1of1_1_M.*', ''));

            try
                data = TDMS_getStruct(input_path{t});
                all_runs(ii) = calculate_kinematics(data, config);

                traj_text = split(trajectory_set, '_');
                state_from_name = state_regex(string(traj_text{2}));
                if all_runs(ii).state ~= state_from_name
                    warning("Using knee state from file name: %s", state_from_name);
                    all_runs(ii).state = state_from_name;
                end

            catch ME
                if config.debug
                    rethrow(ME)
                end
                warning(ME.message);
            end
            ii = ii+1;
        end
    end
end

%% Remove any files that failed to run
for sp = numel(all_runs):-1:1
    if isempty(all_runs(sp).specimen)
        all_runs(sp) = [];
    end
end

%% Print to file
% Prepare the folders
fp_results = fullfile(root, "Results");
folder_names = setdiff(string(fieldnames(all_runs)), ["specimen", "state", "loading_condition", "config"]);
for n = 1:numel(folder_names)
    fp_output = fullfile(fp_results, folder_names(n));
    fp_output_specimens = fullfile(fp_output, string({specimen_list.name}));
    cellfun(@mkdir, fp_output_specimens);

    % Print to file
    for sp = 1:numel(all_runs)
        filename = fullfile(fp_output, all_runs(sp).specimen, strcat(all_runs(sp).state, '_', all_runs(sp).loading_condition, '.csv'));
        datum = all_runs(sp).(folder_names(n));
        if ~istable(datum)
            datum = table(datum);
        end
        writetable(datum, filename);
    end
end

%% Split the runs into specimens, knee states and loading conditions
specimens = organise_runs(all_runs);


%% Visualise all specimens

% gs_specimen = {all_runs.specimen}';
% gs_state = {all_runs.state}';
% gs_loading_condition = {all_runs.loading_condition}';
% gs_jcs = {all_runs.optimised_jcs}';
% 
% is_run = cellfun(@(x) height(x) == 181, gs_jcs);
% gs_specimen = gs_specimen(is_run);
% gs_state = gs_state(is_run);
% gs_loading_condition = gs_loading_condition(is_run);
% gs_jcs = gs_jcs(is_run);
% 
% for angle = 1:181
%     tab = cellfun(@(x) x(angle, :), gs_jcs, "UniformOutput",false);
%     data_per_angle = vertcat(tab{:});
%     data_per_angle.name = categorical(string(gs_specimen));
%     data_per_angle.state = categorical(string(gs_state));
%     data_per_angle.loading_condition = categorical(string(gs_loading_condition));
% 
% 
%     groups{angle} = groupsummary(data_per_angle, {'state', 'loading_condition'}, "mean");
% end
%%

states = setdiff(fieldnames(specimens), "name");
% specimen_names = [specimens.name];
%% Neutral path
neutral_path = all_runs([all_runs.loading_condition] == "Neutral_flex");
neutral_path = neutral_path([neutral_path.state] ~= "Unoptimised"); % Exclude unoptimised
specimen_names = unique([neutral_path.specimen]);
specimen_states = unique([neutral_path.state]);
colours = lines(numel(specimen_states));

for sn = 1:numel(specimen_names)
    figure(sn)
    legend_text = "";
    
    current_specimen = neutral_path([neutral_path.specimen] == specimen_names(sn));

    for ss = 1:numel(specimen_states)
        current_state = current_specimen([current_specimen.state] == specimen_states(ss));
        opt_jcs = {current_state.optimised_jcs};
        flex = 'Flexion';

        % opt_jcs = {current_state.kinematics};
        % flex = 'flexion';
        
        colour = colours(ss, :);
        legend_text(end+1) = specimen_states(ss); 
        for oj = 1:numel(opt_jcs)

            datum = opt_jcs{oj};

            fieldnames = setdiff(datum.Properties.VariableNames, flex);
            for f = 1:numel(fieldnames)
                hold on;
                nexttile(f)
                fname = fieldnames{f};
                [x_arrowed, y_arrowed] = arrowed_line(datum.(flex), datum.(fname), 10, 100, 100);
                h = plot(x_arrowed, y_arrowed, 'Color', colour);
                xlabel("Flexion")
                ylabel(replace(fname, '_', ' '))

                if oj == 1 && f == 1
                    legend_handles(sn, ss) = h;
                end
            end
        end
    end
    sgtitle([specimen_names(sn) 'Optimised']);
    
    is_line = arrayfun(@(x) isa(x, 'matlab.graphics.chart.primitive.Line'), legend_handles(sn, :));
    current_legends = legend_handles(sn, :);
    legend_lines = current_legends(is_line);

    legend_text = legend_text(~(legend_text == ""));
    legend_text = replace(legend_text, '_w_', '+');
    legend_text = replace(legend_text, '_wo_', '-');

    
    legend_text = legend_text(is_line);
    legend(legend_lines, legend_text)
end

%% Statistics
is_full_flexion = is_flexion_arc(all_runs, 180);
data_full_flexion = all_runs(is_full_flexion);
data_for_stats = split_to_matrix(data_full_flexion);
[c,m,h,gnames] = split_into_stats_struct(data_for_stats);

function [c,m,h,gnames] = split_into_stats_struct(data)
    fields = fieldnames(data);
    for f = 1:numel(fields)
        field_data = data.(fields{f});
        is_data(f) = istable(field_data);
        is_property(f) = ~istable(field_data) && ~isnumeric(field_data);
    end

    field_properties = fields(is_property);
    field_data = fields(is_data);
    for fd = 1:numel(field_data)
        
        for n = 1:size(data, 2)
            data_all_rows = data(:, n);
            current_angle = table;
            for k = 1:numel(data_all_rows)
                new_row = table;
                datum = data_all_rows(k, :);
                field_datum = field_data{fd};
                for f = 1:numel(field_properties)
                    new_row.(field_properties{f}) = categorical(datum.(field_properties{f}));
                end
                new_row = [new_row, datum.(field_datum)];
                current_angle(k,:) = new_row;
            end

            for fp = 1:numel(field_properties)
                groups{fp} = [data_all_rows.(field_properties{fp})]';
            end

            groups = cellfun(@(x) replace(x, '_w_', '+'), groups, 'UniformOutput', false);
            groups = cellfun(@(x) replace(x, '_wo_', '-'), groups, 'UniformOutput', false);
            properties = current_angle.Properties.VariableNames;
            for p = 1:numel(properties)
                c_field = properties{p};
                dat = current_angle.(properties{p});
                if isnumeric(dat)
                    [pval, tbl, sts, terms] = anovan(dat, groups, 'varnames', field_properties, 'display', 'off');
                    [c(n).(field_data{fd}).(c_field), m(n).(field_data{fd}).(c_field), h(n).(field_data{fd}).(c_field), gnames] = multcompare(sts, 'Display','off');
                    title(replace(c_field, '_', ' '))
                end
            end
           
        end
    end
end
function row_data = split_to_matrix(data)
    fields = fieldnames(data);
    for f = 1:numel(fields)
        datum = {data.(fields{f})};
        if istable(datum{1})
            h = height(datum{1});
            break
        end
    end
    if h == 0
        error("No data provided")
    end

    for i = 1:h
        for n = 1:numel(data)
            for f = 1:numel(fields)
                datum = data(n).(fields{f});
                if ~istable(datum)
                    row_data(n, i).(fields{f}) = datum;
                else
                    row_data(n, i).(fields{f}) = datum(h, :);
                end
            end
        end
    end
end

function keep = is_flexion_arc(data, threshold)
    fields = fieldnames(data);
    keep = false(size(data));
    % Remove sections that aren't a full flexion arc
    for i = 1:numel(data)
        for j = 1:numel(fields)
            T = data(i).(fields{j});
            if istable(T) && height(T) > threshold
                keep(i) = true;
                break
            end
        end
    end
end


%% Statistics
disp("Performing statistics")


for s = 1:numel(states)
    knee_state = states{s};
    statistics.(knee_state) = interspecimen_stats([specimens.(knee_state)], config);
end

% %% Output stats
% disp("Printing statistics to file")
% print_mean_std_to_file(statistics, states, root);

%% Plot
truncate_min = -5;
truncate_max = 90;

for sp = 1:numel(specimens)
    stability_envelope(specimens(sp), config, truncate_min, truncate_max)
end

% %% Statistics
% disp("Performing statistics")
% states = setdiff(fieldnames(specimens), "name");
%
% for s = 1:numel(states)
%     knee_state = states{s};
%     statistics.(knee_state) = interspecimen_stats([specimens.(knee_state)], config);
% end
%
% %% Output stats
% disp("Printing statistics to file")
% print_mean_std_to_file(statistics, states, root);

%% Plot
%% Stability envelope
%% Plot interspecimen


% plot_interspecimen(config, statistics, statistics, states, truncate_min, truncate_max);
% Only plots loading conditions that Native has experienced. If any are missing from it, they are just ignored.

