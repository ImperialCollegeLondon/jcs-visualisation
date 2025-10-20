classdef Experiment
    properties
        Config
        Root
        Trajectories
    end
    properties (Access = private)
        SpecimenName
        i
    end
    methods (Access = private)
        function obj = load_specimens(obj)
            root = obj.Root;
            obj.Config = obj.Config;

            specimen_list = get_root_files(root, {'result'}).unwrap();
            path_specimens = fullfile({specimen_list.folder}, {specimen_list.name});

            obj.i = 1;
            for sp = 1:numel(path_specimens) % Navigate specimens
                obj.SpecimenName = get_specimen_name(specimen_list(sp).name);
                fprintf("%d. Specimen folder: %s\n", sp, obj.SpecimenName);
                trajectory_sets = get_root_files(path_specimens{sp}, {});
                if trajectory_sets.is_none()
                    warning("Folder contains no runs");
                    continue
                end
                trajectory_sets = trajectory_sets.unwrap();
                path_trajectory_sets = string(fullfile({trajectory_sets.folder}, {trajectory_sets.name}));

                for ts = 1:numel(trajectory_sets) % Navigate trajectory sets
                    path_trajectory_set = path_trajectory_sets(ts);
                    obj = obj.open_files_then_process(path_trajectory_set);
                end
            end
        end
        function obj = load_specimens2(obj)
            root = obj.Root;
            obj.Config = obj.Config;

            specimen_list = get_root_files(root, {'result'}).unwrap();
            path_specimens = fullfile({specimen_list.folder}, {specimen_list.name});

            obj.i = 1;
            for sp = 1:numel(path_specimens) % Navigate specimens
                obj.SpecimenName = get_specimen_name(specimen_list(sp).name);
                fprintf("%d. Specimen folder: %s\n", sp, obj.SpecimenName);
                trajectory_sets = get_root_files(path_specimens{sp}, {});
                if trajectory_sets.is_none()
                    warning("Folder contains no runs");
                    continue
                end
                trajectory_sets = trajectory_sets.unwrap();
                path_trajectory_sets = string(fullfile({trajectory_sets.folder}, {trajectory_sets.name}));

                for ts = 1:numel(trajectory_sets) % Navigate trajectory sets
                    path_trajectory_set = path_trajectory_sets(ts);

                    [obj.Config, state, ~] = load_config(path_trajectory_set, obj.Config);
                    % Visualise landmarks
                    [~, trajectory_set, ~] = fileparts(path_trajectory_set);
                    titles = [obj.SpecimenName replace(trajectory_set, '_', ' ')];
                    visualise_digitisation(state, obj.Config, titles);

                    [path, file_name] = get_input_path(path_trajectory_set);
                    for t = 1:numel(path)
                        fprintf("  Run %d: %s\n", obj.i, regexprep(file_name{t}, '_1of1_1_M.*', ''));
                        data = obj.open(path{t});
                        obj.process(data)
                    end

                    obj = obj.open_files_then_process(path_trajectory_set);
                end
            end
        end

        function [path, file_name] = get_input_path(path_trajectory_set)
            trajectories = dir(fullfile(path_trajectory_set, "**/*processed.tdms"));
            if isempty(trajectories)
                return
            end
            path = fullfile({trajectories.folder}, {trajectories.name});
            [~, file_name, ~] = fileparts({trajectories.name}'); % Name without extension
        end

        function data = open(obj, input_path)
            %% load in experiment run
            try
                data = TDMS_getStruct(input_path);
            catch ME
                if obj.Config.debug
                    rethrow(ME)
                end
                warning(ME.message);
            end
        end
        function process(obj, data)
            try
                trajectory = calculate_kinematics(data, obj.Config);

                if trajectory.specimen ~= obj.SpecimenName && ts == 1 && t == 1
                    warning("Specimen %s changed to %s", trajectory.specimen, obj.SpecimenName);
                    trajectory.SpecimenName = string(obj.SpecimenName);
                end

                traj_text = split(trajectory_set, '_');
                state_from_name = state_regex(string(traj_text{2}));
                if trajectory.state ~= state_from_name
                    warning("Using knee state from file name: %s", state_from_name);
                    trajectory.state(state_from_name);
                end

            catch ME
                if obj.Config.debug
                    rethrow(ME)
                end
                warning(ME.message);
            end
        end

        function obj = open_files_then_process(obj, path_trajectory_set)
            [~, trajectory_set, ~] = fileparts(path_trajectory_set);
            trajectories = dir(fullfile(path_trajectory_set, "**/*processed.tdms"));
            if isempty(trajectories)
                return
            end
            input_path = fullfile({trajectories.folder}, {trajectories.name});
            [~, file_name, ~] = fileparts({trajectories.name}'); % Name without extension

            [obj.Config, state, ~] = load_config(path_trajectory_set, obj.Config);
            % Visualise landmarks
            titles = [obj.SpecimenName replace(trajectory_set, '_', ' ')];
            visualise_digitisation(state, obj.Config, titles);

            %% load in experiment run
            for t = 1:numel(trajectories)
                fprintf("  Run %d: %s\n", obj.i, regexprep(file_name{t}, '_1of1_1_M.*', ''));

                try
                    data = TDMS_getStruct(input_path{t});
                    trajectory = calculate_kinematics(data, obj.Config);

                    if trajectory.specimen ~= obj.SpecimenName && ts == 1 && t == 1
                        warning("Specimen %s changed to %s", trajectory.specimen, obj.SpecimenName);
                        trajectory.SpecimenName = string(obj.SpecimenName);
                    end

                    traj_text = split(trajectory_set, '_');
                    state_from_name = state_regex(string(traj_text{2}));
                    if trajectory.state ~= state_from_name
                        warning("Using knee state from file name: %s", state_from_name);
                        trajectory.state(state_from_name);
                    end

                catch ME
                    if obj.Config.debug
                        rethrow(ME)
                    end
                    warning(ME.message);
                end
                if isempty([obj.Trajectories])
                    obj.Trajectories = trajectory;
                else
                    obj.Trajectories(obj.i) = trajectory;
                end
                obj.i = obj.i+1;
            end
        end
    end

    methods
        function obj = Experiment(root, config)
            obj.Config = config;
            obj.Root = root;
            obj = obj.load_specimens();
            % obj = obj.load_specimens2();
        end
        function out = signals(obj)
            out = obj.Trajectories.signals;
        end

        function [nii, metadata] = to_nifti(obj, signals)
            arguments
                obj 
                signals = obj.Trajectories.signals;
            end

            trajectories = obj.Trajectories;
            names = unique(trajectories.specimen);
            states = unique(trajectories.states);
            loading_conditions = unique(trajectories.loading_condition);

            metadata.order = '[angle, dof, loading_conditions, states]';
            metadata.loading_condition = loading_conditions;
            metadata.states = states;

            for sg = 1:numel(signals)
                signal = signals{sg};
                %  data = arrayfun(@(t) t.Data.(signal), trajectories, 'UniformOutput', false);
                % 
                % 
                % [~, loc_name] = ismember(trajectories.specimen, names);
                % is_specimen = (loc_name == (1:numel(names))')';
                % [~, loc_state] = ismember(trajectories.states, states);
                % is_state = (loc_state == (1:numel(states))')';
                % [~, loc_lc] = ismember(trajectories.loading_condition, loading_conditions);
                % is_loading_condition = (loc_lc == (1:numel(loading_conditions))')';


                headers = trajectories(1).Data.(signal).Properties.VariableNames;

                h = height(trajectories(1).Data.(signal));
                nii_data = nan(h, numel(headers), numel(loading_conditions), numel(states));

                
                metadata.signals.(signal) = string(headers);

                for sn = 1:numel(names)
                    name = names(sn);
                    is_specimen_name = [trajectories.SpecimenName] == name;
                    for st = 1:numel(states)
                        state = states(st);
                        is_state = [trajectories.SpecimenState] == state;
                        for lc = 1:numel(loading_conditions)
                            loading_condition = loading_conditions(lc);
                            is_lc = [trajectories.LoadingCondition] == loading_condition;

                            mask = is_specimen_name & is_state & is_lc;

                            specimen = trajectories(mask);
                            datum = specimen.Data.(signal);
                            nii.(signal).(name)(:, :, lc, st) = table2array(datum);
                        end

                    end
                end
            end
        end
    end
end