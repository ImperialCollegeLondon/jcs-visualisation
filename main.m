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
                specimens(ii) = calculate_kinematics(data, config);

                if specimens(ii).specimen ~= specimen_name && ts == 1 && t == 1
                    warning("Specimen %s changed to %s", specimens(ii).specimen, specimen_name);
                    specimens(ii).SpecimenName = string(specimen_name);
                end

                traj_text = split(trajectory_set, '_');
                state_from_name = state_regex(string(traj_text{2}));
                if specimens(ii).state ~= state_from_name
                    warning("Using knee state from file name: %s", state_from_name);
                    specimens(ii).state(state_from_name);
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
% %% Print to file
% % Prepare the folders
% fp_results = fullfile(root, "Results");
% folder_names = setdiff(string(fieldnames(all_runs)), ["specimen", "state", "loading_condition", "config"]);
% for n = 1:numel(folder_names)
%     fp_output = fullfile(fp_results, folder_names(n));
%     fp_output_specimens = fullfile(fp_output, string({specimen_list.name}));
%     cellfun(@mkdir, fp_output_specimens);
% 
%     % Print to file
%     for sp = 1:numel(all_runs)
%         filename = fullfile(fp_output, all_runs(sp).specimen, strcat(all_runs(sp).state, '_', all_runs(sp).loading_condition, '.csv'));
%         datum = all_runs(sp).(folder_names(n));
%         if ~istable(datum)
%             datum = table(datum);
%         end
%         % writetable(datum, filename);
%     end
% end
%%
states = specimens.states();


%% Neutral Path
[path_flex, path_ext] = specimens...
    .path()...
    .filter(["load", "pos", "jcs"])...
    .split_flex_ext();
path_flex.plot();

% specimens...
%     .path()...
%     .filter("jcs")...
%     .average()...
%     .split_flex_ext()...
%     .plot();

%% Stability Envelopes
[ap_flex, ap_ext] = specimens ...
    .ap() ...
    .filter("jcs") ...
    .average() ...
    .split_flex_ext();
ap_flex.plot();
[ie_flex, ie_ext] = specimens ...
    .ie()...
    .filter("jcs")...
    .average()...
    .split_flex_ext();

%% Neutral path

% jcss = ["jcs_optimised", "jcs_digitised"];
jcss = ["kinematics" "load_cell"];

for n = 1:numel(jcss)
    figure
    plot_neutral_path(specimens([specimens.is_optimised]), jcss(n))
    % plot_average_neutral_path(all_runs([all_runs.is_optimised]), jcss(n))
end

%% Statistics
% is_full_flexion = is_flexion_arc(all_runs, 180);
% data_full_flexion = all_runs(is_full_flexion);
% data_for_stats = split_to_matrix(data_full_flexion);
% [c,m,h,gnames] = split_into_stats_struct(data_for_stats);




%% Statistics
% disp("Performing statistics")
% 
% 
% for s = 1:numel(states)
%     knee_state = states{s};
%     statistics.(knee_state) = interspecimen_stats([specimens.(knee_state)], config);
% end

% %% Output stats
% disp("Printing statistics to file")
% print_mean_std_to_file(statistics, states, root);


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
