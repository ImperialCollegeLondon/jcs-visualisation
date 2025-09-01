classdef Envelope
    properties
        Data
    end
    properties (Access = private)
        States
        Directions
        SpecimenName
    end

    methods % Constructor
        function obj = Envelope(trajectory, envelope, native_neutral, specimen_states)
            % envelope is a matrix where each row constitutes the extrema of the envelope, e.g. ['ant', 'post'; 'int', 'ext'];
            arguments
                trajectory Trajectory
                envelope
                native_neutral
                % specimen_names
                specimen_states
            end

            obj.SpecimenName = string([trajectory.SpecimenName]); % Should only support one at a time?
            names = unique(obj.SpecimenName);
            states = '';
            directions = '';
            for n = 1:numel(names)
                curr_specimen = obj.SpecimenName == names(n);
                loading_direction.(names(n)) = split_loading_condition(trajectory(curr_specimen), envelope, specimen_states);
                states = [states; fieldnames(loading_direction.(names(n)))];
                directions = [directions; fieldnames(loading_direction.(names(n)).(states{1}))];
            end

            obj.States = unique(states);
            obj.Directions = unique(directions);
            obj.Data = subtract_native(loading_direction, native_neutral);
        end
    end

    methods


        function average(obj)
            inner_loop(obj.Data, @(x) x)
        end
        function p = plot(obj, colour)
            arguments
                obj
                colour = lines(10)
            end

            if isempty(obj.Data)
                p = plot(0);
                return
            end

            states = obj.states;
            
            for s = 1:numel(states)
                state = states(s);

                directions = obj.directions;
                plots(s) = gen_plots(obj.Data.(state), directions);

            end
        end
    end

    methods
        function o = filter_state(obj, state)
        mask = strcmpi(obj.States, state);
        o = obj(mask, :);
        end

        function o = filter_envelope(obj, envelope)
        mask = contains(obj.Directions, envelope, "IgnoreCase", true);
        if ~any(mask)
            o = [];
            return
        end

        o = obj;
        o.Envelopes = obj.Directions(mask);

        for s = 1:numel(o.States)
            state = o.States(s);
            env = fieldnames(o.Data.(state));
            to_remove = setdiff(env, obj.Directions(mask));
            o.Data.(state) = rmfield(obj.Data.(state), to_remove);
        end
        end

        function o = directions(obj)
        o = obj.Directions;
        end
        function o = states(obj)
        o = obj.States;
        end
    end
end

%% Private functions
function output = split_loading_condition(trajectory, envelope, specimen_states)
    arguments
        trajectory Trajectory
        envelope
        specimen_states
    end

    threshold_valid_run = 1;

    is_direction = cell(size(envelope));
    for row = 1:size(envelope, 1)
        line_curr = envelope(row, :);
        for column = 1:numel(line_curr)
            name = envelope(row, column);

            is_direction = contains([trajectory.LoadingCondition], name, "IgnoreCase", true);
            for st = 1:numel(specimen_states)
                state = specimen_states{st};
                is_state = [trajectory.SpecimenState] == state;
                datum = [trajectory(is_state & is_direction)];
                if isempty(datum)
                    output.(specimen_states{st}).(name) = [];
                    continue
                end
                % is_valid = valid_flexion([datum.Data], threshold_valid_run);
                % if ~any(is_valid)
                %     continue
                % end
                % datum = datum(is_valid);

                % output.(specimen_states{st}).(name) = datum(direction(is_valid)).Data;
                output.(specimen_states{st}).(name) = datum.Data;
            end
        end
    end

    if ~any(is_direction)
        output = [];
        return
    end

end

function keep = valid_flexion(data, threshold)
    fields = fieldnames(data);
    keep = false(size(data));
    % Remove sections that aren't a full flexion arc
    for i = 1:numel(data)
        for j = 1:numel(fields)
            T = data(i).(fields{j});
            if istable(T) && height(T) > threshold
                keep(i) = true;
                break
            end
        end
    end
end

function o = subtract_native(data, native)
o = data;

    specimen_names = [native.SpecimenName];
    for ss = 1:numel(specimen_names)
        specimen_name = specimen_names(ss);
        curr_specimen = data.(specimen_name);
        curr_native = native([native.SpecimenName] == specimen_name);

        states = fieldnames(curr_specimen);

        for st = 1:numel(states)
            state = states{st};
            loading_conditions = fieldnames(curr_specimen.(state));

            for d = 1:numel(loading_conditions)
                loading_condition = loading_conditions{d};
                datum = curr_specimen.(state).(loading_condition);
                if isempty(datum)
                    continue
                end
                jcss = fieldnames(datum);

                for j = 1:numel(jcss)
                    jcs = jcss{j};
                    o.(specimen_name).(state).(loading_condition).(jcs) = datum.(jcs) - curr_native.Data.(jcs);
                    try
                        o.(specimen_name).(state).(loading_condition).(jcs).flexion = curr_native.Data.(jcs).flexion;
                    catch ME
                        if contains(ME.message, "flexion")
                            warning("No field called 'flexion'. Expect angles to be all 0!")
                        else
                            rethrow ME
                        end
                    end
                end
            end
        end
    end
end

function p = gen_plots(data, directions)
    for d = 1:numel(directions)
        ap = directions(d);
        datum = data.(ap);
    
        if isempty(datum)
            p = plot(0);
            continue
        end
        jcss = fieldnames(datum);
    
        for j = 1:numel(jcss)
            jcs = jcss{j};
            orientations = datum.(jcs).Properties.VariableNames;
            orientations(contains(orientations, 'flexion')) = [];
            for o = 1:numel(orientations)
                nexttile(o); hold on;
                x = datum.(jcs).flexion;
                y = datum.(jcs).(orientations{o});
                [x_arrowed, y_arrowed] = arrowed_line(x, y, 10, 100, 100);
                % fill(x,y, colour, 'FaceAlpha', 0.1);
                % p = plot(x_arrowed, y_arrowed, 'color', colour);
                p = plot(x_arrowed, y_arrowed);
                grid on;
                axis square;
                xlabel("Flexion angle");
                ylabel(replace(orientations{o}, '_', ' '));
            end
        end
    
    
    end
end

function o = inner_loop(data, fn)
    states = fieldnames(data); % Should equal obj.States. Unsure when calling on multiple
    for s = 1:numel(states)
        state = states{s};
        loading_conditions = fieldnames(data.(state));
        for lc = 1:numel(loading_conditions)
            loading_condition = loading_conditions{lc};
            datum = data.(state).(loading_condition);
            if isempty(datum)
                continue
            end
            o.(state).(loading_condition) = fn(datum);
        end
    end
end