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
            obj.Root = root;
            obj.Config = config;
            obj.Trajectories = load_specimens(config, root);
            % obj = obj.load_specimens2();
        end
        function out = signals(obj)
            out = obj.Trajectories.signals;
        end

    end
end


function trajectories = load_specimens(config, root)
            obj.Root = root;

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
                is_parent_config = contains({trajectory_sets.name}, 'configuration', IgnoreCase=true);
                trajectory_sets = trajectory_sets([trajectory_sets.isdir] & ~is_parent_config);
                path_trajectory_sets = string(fullfile({trajectory_sets.folder}, {trajectory_sets.name}));

                for ts = 1:numel(trajectory_sets) % Navigate trajectory sets
                    path_trajectory_set = path_trajectory_sets(ts);

                    [is_right_knee, state, setup, transforms] = load_config(path_trajectory_set);

                    % Visualise landmarks
                    if config.visualise_digitisation
                        [~, trajectory_set, ~] = fileparts(path_trajectory_set);
                        titles = [obj.SpecimenName replace(trajectory_set, '_', ' ')];
                        visualise_digitisation(state, is_right_knee, titles);
                    end
                    %

                    obj = open_files_then_process(obj, path_trajectory_set, transforms, config, is_right_knee);
                end
            end
            trajectories = obj.Trajectories;
end

function obj = open_files_then_process(obj, path_trajectory_set, transforms, config, is_right_knee)
            [~, trajectory_set, ~] = fileparts(path_trajectory_set);
            trajectories = dir(fullfile(path_trajectory_set, "**/*processed.tdms"));
            if isempty(trajectories)
                return
            end

            input_path = fullfile({trajectories.folder}, {trajectories.name});
            [~, file_name, ~] = fileparts({trajectories.name}'); % Name without extension


            %% load in experiment run
            for t = 1:numel(trajectories)
                fprintf("  Run %d: %s\n", obj.i, regexprep(file_name{t}, '_1of1_1_M.*', ''));

                try
                    data = TDMS_getStruct(input_path{t});
                    trajectory = calculate_kinematics(data, transforms, config, is_right_knee);

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
                    if config.debug
                        rethrow(ME)
                    end
                    warning(ME.message);
                end

                obj.Trajectories(obj.i) = trajectory;
                obj.i = obj.i+1;
            end
        end