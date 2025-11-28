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

    methods
        function obj = Experiment(root, config)
            obj.Config = config;
            obj.Root = root;
            obj = load_specimens(config, root);
            % obj = obj.load_specimens2();
        end
        function out = signals(obj)
            out = obj.Trajectories.signals;
        end

    end
end



function obj = load_specimens(root, config)
            obj.Root = root;
            obj.Config = config;

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
            if obj.Config.visualise_digitisation
                visualise_digitisation(state, obj.Config, titles);
            end

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