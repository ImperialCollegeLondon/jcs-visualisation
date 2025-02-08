%% this code calculates the knee kinematics in both the original, digitised coordinate frame and the optimised coordinate frame
clc;clear; close all;
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
        input_path = fullfile({trajectories.folder}, {trajectories.name});
        [~, file_name, ~] = fileparts({trajectories.name}'); % Name without extension

        [config, state, setup] = load_config(path_trajectory_set, config);

        % Visualise landmarks
        if config.visualise_digitisation
            figure; 
            hold on; grid;
            sgtitle([specimen_name replace(trajectory_set, '_', ' ')]);
            t = landmarks(state.JCS.Collected_Points_Rigid_Body_2);
            f = landmarks(state.JCS.Collected_Points_Rigid_Body_1);
            visualise_landmark(t, f, config, 'b', 'r');

            if any(state.JCS.T_RB2_OPT_RB2_Orig ~= eye(4), "all")
                t_opt = transform_landmark(t, state.JCS.T_RB2_OPT_RB2_Orig);
                f_opt = transform_landmark(f, state.JCS.T_RB1_OPT_RB1_Orig);
                visualise_landmark(t_opt, f_opt, config, 'k', 'k');
            end
            hold off;

            disp(trajectory_set)
            disp(rotationsAndTranslations(state.JCS.T_RB2_OPT_RB2_Orig, config.is_right_knee))
        end

        %% load in experiment run
        for t = 1:numel(trajectories)
            trajectory = input_path{t};
            fprintf("  Run %d: %s\n", ii, regexprep(file_name{t}, '_1of1_1_M.*', ''));

            try
                data = TDMS_getStruct(input_path{t});
                all_runs(ii) = calculate_kinematics(data, config);
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
folder_names = setdiff(string(fieldnames(all_runs)), ["specimen", "state", "loading_condition"]);
for n = 1:numel(folder_names)
    fp_output = fullfile(fp_results, folder_names(n));
    fp_output_specimens = fullfile(fp_output, string({specimen_list.name}));
    cellfun(@mkdir, fp_output_specimens);

    % Print to file
    for sp = 1:numel(all_runs)
        filename = fullfile(fp_output, all_runs(sp).specimen, strcat(all_runs(sp).state, '_', all_runs(sp).loading_condition, '.csv'));
        writetable(all_runs(sp).(folder_names(n)), filename);
    end
end

%% Split the runs into specimens, knee states and loading conditions
specimens = organise_runs(all_runs);

%% Statistics
disp("Performing statistics")
states = setdiff(fieldnames(specimens), "name");

for s = 1:numel(states)
    knee_state = states{s};
    statistics.(knee_state) = interspecimen_stats([specimens.(knee_state)], config);
end

%% Output stats
disp("Printing statistics to file")
print_mean_std_to_file(statistics, states, root);

%% Plot
truncate_min = -5;
truncate_max = 90;
%% Stability envelope
stability_envelope(config, statistics, truncate_min, truncate_max)
%% Plot interspecimen


% plot_interspecimen(config, statistics, statistics, states, truncate_min, truncate_max);
% Only plots loading conditions that Native has experienced. If any are missing from it, they are just ignored.

