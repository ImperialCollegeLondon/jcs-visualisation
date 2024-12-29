%% this code calculates the knee kinematics in both the original, digitised coordinate frame and the optimised coordinate frame
clc;clear; close all;
warning('off', 'backtrace');
warning('off', 'MATLAB:MKDIR:DirectoryExists');
set(0,'defaulttextinterpreter','latex');
%% Load important defaults. Make sure you take a look at them! They are things you definitely want to change.
defaults;
%% Load in the Specimen folder

% State cfg file is used to create the transforms.
disp("Pick the folder with all the specimens")
root = uigetdir(".", "Pick the folder with all specimens");
specimen_list = get_root_files(root, {'result'});
fp_specimens = fullfile({specimen_list.folder}, {specimen_list.name});
ii = 0;

%% Run data

for i = 1:numel(fp_specimens)
    specimen_folder_name = get_specimen_name(specimen_list(i).name);
    fprintf("%d. Specimen folder: %s\n", i, specimen_folder_name);
    fp_runs = get_root_files(fp_specimens{i}, {});
    if isempty(fp_runs)
        warning("No files");
        continue
    end

    digitisation_file_mask = contains({fp_runs.name}, config.digitisation_state_name, "IgnoreCase",true); 
    if sum(digitisation_file_mask) > 1 % There's more than 1 digitisation file
        digitisation_file_mask(1:find(digitisation_file_mask, 1, "last")-1) = false; % Pick the last one
        warning("Found more than one digitisation folder. Using '%s'", fp_runs(digitisation_file_mask).name);
    end

    %% Load the digitised coordinate system files
    fp_digitisation = fullfile(fp_runs(digitisation_file_mask).folder, fp_runs(digitisation_file_mask).name);

    new_config = load_configurations(fp_digitisation);
    config = merge_config(config, new_config);
    
    %% Generate list of all trajectories
    [root_specimen, ~, ~] = fileparts(fp_digitisation);
    % trajectories = dir(fullfile(root, "**/*.tdms"));
    trajectories = dir(fullfile(root_specimen, "**/*processed.tdms"));
    
    input_path = fullfile({trajectories.folder}', {trajectories.name}');
    [~, file_name, ~] = fileparts({trajectories.name}'); % Name without extension
    
    % Find which ones are worth running
    % Expects "_flex" in the name to be a real run, as well as one of the conditions mentioned below:
    % desiredOrder = {'ext', 'int', 'valg', 'var', 'ant', 'post', 'Neutral'};
    % run_conditions = extract_condition({trajectories.name}');
    % is_run = contains(run_conditions, desiredOrder);
    
    %% load in experiment run
    
    for j = 1:length(input_path)
        ii = ii + 1;
        % if ~is_run(j) || contains(file_name{j}, "IE_optimise") % These are usually runs pre optimisation. Comment out this block if all data should be processed.
        %     disp(strcat("Skipping: ", file_name{j}));
        %     continue
        % end
        fprintf("Run: %d: %s\n", j, regexprep(file_name{j}, '_1of1_1_M.*', ''));

        all_runs(ii) = calculate_kinematics(input_path{j}, config);
    end
end

%% Split the runs into specimens, knee states and loading conditions
specimens = organise_runs(all_runs);

kinematics_results = fullfile(root, "Results", "Kinematics");
mkdir(kinematics_results);
jcs_results = fullfile(root, "Results", "JCS");
mkdir(jcs_results);
states = fieldnames(specimens);
states(strcmp(states, "name")) = [];
for s = 1:numel(states)
    knee_state = states{s};
    datum = interspecimen_stats([specimens.(knee_state)] , config);
    stats.(knee_state) = datum;
    print_mean_std_to_file(datum, knee_state, kinematics_results, jcs_results);
end

%% Plot interspecimen
truncate_min = -5;
truncate_max = 90;

plot_interspecimen(config, stats, config.intact_name, states, truncate_min, truncate_max);
% Only plots loading conditions that Native has experienced. If any are missing from it, they are just ignored.

% function term = extract_condition(names)
% % Determine the running conditions. e.g, external, internal, anterior, etc.
% % If it cannot find the term "flex" in the name, it copies a large chunk of text to give some clues of what it is.
% term = cell(size(names));
% for i = 1:numel(names)
%     name = names{i};
%     segments = strsplit(name, '_');
% 
%     cmp = strcmp(segments, 'flex');
%     if any(cmp)
%         id = find(cmp);
%         term{i} = segments{id-1};
%     else
%         id = find(contains(segments, '1of1'));
%         term{i} = strcat(segments{2:id - 1});
%     end
% end
% end

function config = merge_config(config, new_config)
    fields = fieldnames(new_config);
    for i = 1:numel(fields)
        field = fields{i};
        if ~isfield(config, field)
            config.(field) = new_config.(field);
        end
    end
end