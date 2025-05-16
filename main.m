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
    fp_digitisation = get_digitisation(fp_runs.unwrap(), config);

    %% Load the digitised coordinate system files
    

    config = load_config(fp_digitisation, config);
    
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

        %Current state from name
        file_name_split = split(file_name{j}, '_');
        state_from_file_name = file_name_split{2};
        config.state_from_file_name = state_from_file_name;
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
        % opt_jcs = {current_state.optimised_jcs};
        % flex = 'Flexion';

        opt_jcs = {current_state.kinematics};
        flex = 'flexion';
        
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
    legend_text = legend_text(~(legend_text == ""));
    sgtitle(specimen_names(sn));
    legend_text = replace(legend_text, '_w_', '+');
    legend_text = replace(legend_text, '_wo_', '-');
    legend(legend_handles(sn, :), legend_text)
end


%% Statistics
disp("Performing statistics")


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


plot_interspecimen(config, statistics, statistics, states, truncate_min, truncate_max);
% Only plots loading conditions that Native has experienced. If any are missing from it, they are just ignored.