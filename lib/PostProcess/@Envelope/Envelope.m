classdef Envelope
    properties
        Data
        States
        Directions
        SpecimenName
        Signals
    end
    % properties (Access = private)
    % end

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

            specimen_list = string([trajectory.SpecimenName]);
            obj.SpecimenName = unique(specimen_list); % Should only support one at a time?
            names = unique(obj.SpecimenName);
            states = '';
            directions = '';
            for n = 1:numel(names)
                curr_specimen = specimen_list == names(n);
                specimens.(names(n)) = split_loading_condition(trajectory(curr_specimen), envelope, specimen_states);
                states = [states; fieldnames(specimens.(names(n)))];
                directions = [directions; fieldnames(specimens.(names(n)).(states{1}))];

            end
            is_neutral = contains([trajectory.LoadingCondition], "neutral", "IgnoreCase", true);
            neutral = trajectory(is_neutral);

            obj.Signals = fieldnames(specimens.(names(1)).(states{1}).(directions{1}));
            obj.States = setdiff(unique(states), ["UKA_w_pACL", "Unoptimised"]); % Remove
            obj.Directions = unique(directions);
            % obj.Data = subtract_native(specimens, native_neutral);
            obj.Data = subtract_neutral(specimens, neutral);
        end
    end

    methods
        function o = average(obj)
            o = EnvelopeAverage(obj);
        end

        function o = exclude_specimen_exact(obj, specimen)
            o = obj;
            specimens_remaining = setdiff(o.specimens, specimen);
            o.SpecimenName = specimens_remaining;
        end
        function o = exclude_specimen(obj, specimen)
            o = obj;
            mask = contains(o.specimens, specimen);
            o.SpecimenName = o.SpecimenName(~mask);
        end
        function o = filter_signal(obj, signal)
            obj.Signals = obj.Signals(contains(obj.Signals, signal));
            o = obj;
        end
        function o = directions(obj)
            o = string(obj.Directions);
        end
        function o = states(obj)
            o = string(obj.States);
        end
        function o = specimens(obj)
            o = string(unique(obj.SpecimenName));
        end
        function o = signals(obj)
            o = string(unique(obj.Signals));
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

function o = subtract_neutral(data, neutral)
    o = data;

    specimen_names = [neutral.SpecimenName];
    for ss = 1:numel(specimen_names)
        specimen_name = specimen_names(ss);
        curr_specimen = data.(specimen_name);

        states = fieldnames(curr_specimen);

        for st = 1:numel(states)
            state = states{st};
            is_curr_neutral = ([neutral.SpecimenState] == state) & ([neutral.SpecimenName] == specimen_name);
            curr_neutral = neutral(is_curr_neutral);
            loading_conditions = fieldnames(curr_specimen.(state));

            for d = 1:numel(loading_conditions)
                loading_condition = loading_conditions{d};
                datum = curr_specimen.(state).(loading_condition);
                if isempty(datum)
                    continue
                end
                signals = fieldnames(datum);

                for sg = 1:numel(signals)
                    signal = signals{sg};
                    try
                        is_incomplete_run = ~all(size(datum.(signal)) == size(curr_neutral.Data.(signal)));
                    catch ME
                        keyboard
                    end
                    if is_incomplete_run
                        continue
                    end
                    o.(specimen_name).(state).(loading_condition).(signal) = datum.(signal) - curr_neutral.Data.(signal);
                    try
                        o.(specimen_name).(state).(loading_condition).(signal).flexion = curr_neutral.Data.(signal).flexion;
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

% function o = subtract_native(data, native)
%     o = data;
%
%     specimen_names = [native.SpecimenName];
%     for ss = 1:numel(specimen_names)
%         specimen_name = specimen_names(ss);
%         curr_specimen = data.(specimen_name);
%         curr_native = native([native.SpecimenName] == specimen_name);
%
%         states = fieldnames(curr_specimen);
%
%         for st = 1:numel(states)
%             state = states{st};
%             loading_conditions = fieldnames(curr_specimen.(state));
%
%             for d = 1:numel(loading_conditions)
%                 loading_condition = loading_conditions{d};
%                 datum = curr_specimen.(state).(loading_condition);
%                 if isempty(datum)
%                     continue
%                 end
%                 signals = fieldnames(datum);
%
%                 for sg = 1:numel(signals)
%                     signal = signals{sg};
%                     is_incomplete_run = ~all(size(datum.(signal)) == size(curr_native.Data.(signal)));
%
%                     if is_incomplete_run
%                         continue
%                     end
%                     o.(specimen_name).(state).(loading_condition).(signal) = datum.(signal) - curr_native.Data.(signal);
%                     try
%                         o.(specimen_name).(state).(loading_condition).(signal).flexion = curr_native.Data.(signal).flexion;
%                     catch ME
%                         if contains(ME.message, "flexion")
%                             warning("No field called 'flexion'. Expect angles to be all 0!")
%                         else
%                             rethrow ME
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end

% function keep = valid_flexion(data, threshold)
%     fields = fieldnames(data);
%     keep = false(size(data));
%     % Remove sections that aren't a full flexion arc
%     for i = 1:numel(data)
%         for j = 1:numel(fields)
%             T = data(i).(fields{j});
%             if istable(T) && height(T) > threshold
%                 keep(i) = true;
%                 break
%             end
%         end
%     end
% end
