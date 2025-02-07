%% this code calculates the knee kinematics in both the original, digitised coordinate frame and the optimised coordinate frame
clc;clear; close all;
diary("log.txt"); % Creates a log. Important for checking which runs failed!!

%% Load in the Specimen folder
defaults;

% State cfg file is used to create the transforms.
disp("Pick the folder with all the specimens")
root = uigetdir(".", "Pick the folder with all specimens");
specimen_list = get_root_files(root, {'result'}).unwrap();
fp_specimens = fullfile({specimen_list.folder}, {specimen_list.name});
%% Run data
ii = 0;
for i = 1:numel(fp_specimens)
    specimen_folder_name = get_specimen_name(specimen_list(i).name);
    fprintf("%d. Specimen folder: %s\n", i, specimen_folder_name);
    fp_runs = get_root_files(fp_specimens{i}, {});
    if fp_runs.is_none()
        warning("Folder contains no runs");
        continue
    end
    specimen_runs = fp_runs.unwrap();
    root_specimen = {specimen_runs.folder};
    root_specimen = root_specimen{1};
    runs = fullfile(root_specimen, {specimen_runs.name});

    [config, state, setup] = load_config(runs{i}, config);

    if config.visualise_digitisation && any(config.optimisation_rb2_current ~= state.JCS.T_RB2_OPT_RB2_Orig, "all")
        config.optimisation_rb2_current = state.JCS.T_RB2_OPT_RB2_Orig;
        config.optimisation_rb1_current = state.JCS.T_RB1_OPT_RB1_Orig;

        figure; hold on; grid;
        t = landmarks(state.JCS.Collected_Points_Rigid_Body_2);
        f = landmarks(state.JCS.Collected_Points_Rigid_Body_1);
        visualise_landmark(t, f, config);

        if all(state.JCS.T_RB2_OPT_RB2_Orig ~= eye(4), "all")
            t_opt = to_opt(t, state.JCS.T_RB2_OPT_RB2_Orig);
            f_opt = to_opt(f, state.JCS.T_RB1_OPT_RB1_Orig);
            visualise_landmark(t_opt, f_opt, config);
        end
        hold off;
    end

    %% Generate list of all trajectories
    trajectories = dir(fullfile(root_specimen, "**/*processed.tdms"));

    
    %% Load the digitised coordinate system files    
    input_path = fullfile({trajectories.folder}, {trajectories.name});
    [~, file_name, ~] = fileparts({trajectories.name}'); % Name without extension

    %% load in experiment run
    
    for j = 1:length(input_path)
        ii = ii + 1;
        fprintf("  Run %d: %s\n", j, regexprep(file_name{j}, '_1of1_1_M.*', ''));
        try
            data = TDMS_getStruct(input_path{j});
            all_runs(ii) = calculate_kinematics(data, config);
        catch ME
            warning(ME.message)
            if config.debug
                rethrow ME
            end
        end
    end
end

%% Remove any files that failed to run
for i = numel(all_runs):-1:1
    if isempty(all_runs(i).specimen)
        all_runs(i) = [];
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
    for i = 1:numel(all_runs)
        filename = fullfile(fp_output, all_runs(i).specimen, strcat(all_runs(i).state, '_', all_runs(i).loading_condition, '.csv'));
        writetable(all_runs(i).(folder_names(n)), filename);
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

    function r = landmarks(points)
        p = reshape(points', 3, []);
        p(4,:) = 1; %% To homogeneous
        r.lateral = p(:,1);
        r.medial = p(:,2);
        r.distal = mean(p(:, 4:6), 2);
    end
            function r = to_opt(p, t)
            r.lateral = t * p.lateral;
            r.medial = t * p.medial;
            r.distal = t * p.distal;
        end