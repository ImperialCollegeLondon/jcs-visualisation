%% this code calculates the knee kinematics in both the original, digitised coordinate frame and the optimised coordinate frame
clc;clear; close all;
diary("log.txt"); % Creates a log. Important for checking which runs failed!!

%% Load in the Specimen folder
defaults;

% State cfg file is used to create the transforms.
disp("Pick the folder with all the specimens")
root = uigetdir(".", "Pick the folder with all specimens");
specimen_list = get_root_files(root, {'result'});
fp_specimens = fullfile({specimen_list.folder}, {specimen_list.name});
%% Run data
ii = 0;
for i = 1:numel(fp_specimens)
    specimen_folder_name = get_specimen_name(specimen_list(i).name);
    fprintf("%d. Specimen folder: %s\n", i, specimen_folder_name);
    fp_runs = get_root_files(fp_specimens{i}, {});
    if isempty(fp_runs)
        warning("No files");
        continue
    end
    fp_digitisation = get_digitisation(fp_runs, config);

    %% Load the digitised coordinate system files
    

    new_config = load_config(fp_digitisation);
    config = merge_config(config, new_config);
    
    %% Generate list of all trajectories
    [root_specimen, ~, ~] = fileparts(fp_digitisation);
    % trajectories = dir(fullfile(root, "**/*.tdms"));
    trajectories = dir(fullfile(root_specimen, "**/*processed.tdms"));
    
    input_path = fullfile({trajectories.folder}', {trajectories.name}');
    [~, file_name, ~] = fileparts({trajectories.name}'); % Name without extension
    
    %% load in experiment run
    
    for j = 1:length(input_path)
        ii = ii + 1;
        fprintf("  Run %d: %s\n", j, regexprep(file_name{j}, '_1of1_1_M.*', ''));
        try
            data = TDMS_getStruct(input_path{j});
            all_runs(ii) = calculate_kinematics(data, config);
        catch ME
            warning("Failed to run this file. Change defaults/config.debug=true if you want to figure out why")
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

%% Plot
disp("Printing statistics to file")
print_mean_std_to_file(statistics, states, root);

%% Plot interspecimen
truncate_min = -5;
truncate_max = 90;

% plot_interspecimen(config, statistics, statistics, states, truncate_min, truncate_max);
% Only plots loading conditions that Native has experienced. If any are missing from it, they are just ignored.


function config = merge_config(config, new_config)
    fields = fieldnames(new_config);
    for i = 1:numel(fields)
        field = fields{i};
        if ~isfield(config, field)
            config.(field) = new_config.(field);
        end
    end
end