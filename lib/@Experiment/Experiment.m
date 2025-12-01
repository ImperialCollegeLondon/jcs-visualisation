classdef Experiment
    properties
        Config
        Root
        Trajectories
        RawTrajectorySets
    end

    methods
        function obj = Experiment(root, config)
            obj.Root = root;
            obj.Config = config;
            [obj.Trajectories, obj.RawTrajectorySets] = load_specimens(config, root);
            % obj = obj.load_specimens2();
        end
        function out = signals(obj)
            out = obj.Trajectories.signals;
        end
    end
end


function [trajectories, trajectory_sets] = load_specimens(config, root)
            obj.Root = root;
            obj.Config = config;

            specimen_list = get_root_files(root, {'result'}).unwrap();
            path_specimens = fullfile({specimen_list.folder}, {specimen_list.name});

            obj.i = 1;
            for sp = 1:numel(path_specimens) % Navigate specimens
                obj.SpecimenName = get_specimen_name(specimen_list(sp).name);
                fprintf("%d. Specimen folder: %s\n", sp, obj.SpecimenName);
                folders_trajectory_sets = get_root_files(path_specimens{sp}, {});
                if folders_trajectory_sets.is_none()
                    warning("Folder contains no runs");
                    continue
                end
                folders_trajectory_sets = folders_trajectory_sets.unwrap();
                is_parent_config = contains({folders_trajectory_sets.name}, 'configuration', IgnoreCase=true);
                folders_trajectory_sets = folders_trajectory_sets([folders_trajectory_sets.isdir] & ~is_parent_config);
                paths_trajectory_sets = string(fullfile({folders_trajectory_sets.folder}, {folders_trajectory_sets.name}));

                for ts = 1:numel(folders_trajectory_sets) % Navigate trajectory sets
                    path_trajectory_set = paths_trajectory_sets(ts);

                    [is_right_knee, JCS, setup, transforms] = load_config(path_trajectory_set);

                    trajectory_sets(ts).specimen = string(obj.SpecimenName);
                    
                    [~, trajectory_set, ~] = fileparts(path_trajectory_set);
                    words = split(trajectory_set, '_');

                    trajectory_sets(ts).state = words(2);
                    trajectory_sets(ts).JCS = JCS;
                    trajectory_sets(ts).setup = setup;
                    trajectory_sets(ts).is_right_knee = is_right_knee;


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
