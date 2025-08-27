classdef Envelope
    properties
        Data
    end
    properties (Access = private)
        States
        Directions
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

            loading_direction = split_loading_condition(trajectory, envelope, specimen_states);

            obj.States = string(fieldnames(loading_direction));
            obj.Directions = string(fieldnames(loading_direction.(obj.States{1})));
            obj.Data = subtract_native(loading_direction, native_neutral.Data);


            % ap_datum = {datum(ant_pos(datum)).(jcs)};
            % if isempty(ap_datum)
            %     % Temporary fix. Should correct the Unoptimised state.
            %     continue
            % end
            % ap = subtract_native(d, native_neutral.Data);
            % plots(st,1) = gen_plots(ap, colourmap(st, :));
            % grid on;
        end
    end

    methods
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
                % tiledlayout(round(numel(orientations)/2), 2);
                for d = 1:numel(directions)
                    ap = directions(d);
                    datum = obj.Data.(state).(ap);

                    jcss = fieldnames(datum);

                    for j = 1:numel(jcss)
                        jcs = jcss{j};
                        orientations = datum.(jcs).Properties.VariableNames;
                        orientations(contains(orientations, 'flexion')) = [];
                        for o = 1:numel(orientations)
                            nexttile(o); hold on;
                            x = datum{d}.flexion;
                            y = datum{d}.(orientations{o});
                            [x_arrowed, y_arrowed] = arrowed_line(x, y, 10, 100, 100);
                            fill(x,y, colour, 'FaceAlpha', 0.1);
                            p = plot(x_arrowed, y_arrowed, 'color', colour);
                            grid on;
                            xlabel("Flexion angle");
                            ylabel(replace(orientations{o}, '_', ' '));
                        end
                    end


                end
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
                output.(specimen_states{st}).(name) = datum(is_direction).Data;
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
    states = fieldnames(data);

    for st = 1:numel(states)
        state = states{st};
        loading_conditions = fieldnames(data.(state));

        for d = 1:numel(loading_conditions)
            loading_condition = loading_conditions{d};
            datum = data.(state).(loading_condition);
            jcss = fieldnames(datum);

            for j = 1:numel(jcss)
                jcs = jcss{j};
                o.(state).(loading_condition).(jcs) = datum.(jcs) - native.(jcs);
                try
                    o.(state).(loading_condition).(jcs).flexion = native.(jcs).flexion;
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
