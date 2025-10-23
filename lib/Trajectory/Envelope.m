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
        function spmi = spm(obj)
            %obj.Data.JJH03.Native.ant.jcs_digitised
            states = obj.states;
            directions = obj.directions;
            specimens = obj.specimens;
            signals = obj.signals;

            for sg = 1:numel(signals)
                signal = signals(sg);
                for st = 1:numel(states)
                    state = states(st);
                    for d = 1:numel(directions)
                        direction = directions(d);
                        x = obj.Data.(specimens(1)).(state).(direction).(signal);
                        val = nan(height(x), numel(specimens), width(x));
                        for sp = 1:numel(specimens)
                            specimen = specimens(sp);
                            datum = obj.Data.(specimen).(state).(direction).(signal);
                            val(:, sp, :) = table2array(datum);
                        end
                        headers = datum.Properties.VariableNames;
                        for h = 1:numel(headers)
                            header = headers{h};
                            spm = spm1d.stats.anova1(val(:, :, h)', 1:numel(specimens));
                            spmi.(signal).(direction).(state).(header) = spm.inference(0.05);
                        end
                    end
                end
            end
        end

        function [spmi, spm_bs] = spm_2d(obj)
            %obj.Data.JJH03.Native.ant.jcs_digitised
            states = obj.states;
            directions = obj.directions;
            specimens = obj.specimens;
            signals = obj.signals;


            for sg = 1:numel(signals)
                signal = signals(sg);
                for d = 1:numel(directions)
                    direction = directions(d);
                    i = 1;
                    x = obj.Data.(specimens(1)).(states(1)).(direction).(signal);
                    val = nan(height(x), numel(specimens) * numel(states), width(x));

                    state_list = nan(numel(specimens) * numel(states), 1);
                    specimen_list = nan(numel(specimens) * numel(states), 1);
                    for st = 1:numel(states)
                        state = states(st);
                        for sp = 1:numel(specimens)
                            specimen = specimens(sp);
                            datum = obj.Data.(specimen).(state).(direction).(signal);
                            val(:, i, :) = table2array(datum);
                            state_list(i) = st-1;
                            specimen_list(i) = sp-1;
                            i = i + 1;
                        end
                    end

                    headers = datum.Properties.VariableNames;
                    for h = 1:numel(headers)
                        header = headers{h};
                        spm_bs.(signal).(direction).(header) = spm1d.stats.anova1(val(:, :, h)', state_list);
                        spm = spm1d.stats.anova1rm(val(:, :, h)', state_list, specimen_list);
                        spmi.(signal).(direction).(header) = spm.inference(0.05);
                    end
                end
            end
        end
        % function [nii, metadata] = to_nifti(obj)
        %     directions = obj.directions;
        %     states = obj.states;
        %     specimens = obj.specimens;
        %     signals = obj.signals;
        %
        %     metadata.order = '[angle, dof, direction, states]';
        %     metadata.directions = directions;
        %     metadata.states = states;
        %     for sg = 1:numel(signals)
        %         signal = signals(sg);
        %         for sp = 1:numel(specimens)
        %             specimen = specimens(sp);
        %             [i, j] = size(obj.Data.(specimen).(states(1)).(directions(1)).(signal));
        %             nii.(signal).(specimen) = nan(i, j, numel(directions), numel(states));
        %             for d = 1:numel(directions)
        %                 direction = directions(d);
        %                 for st = 1:numel(states)
        %                     state = states(st);
        %                     datum = obj.Data.(specimen).(state).(direction).(signal);
        %                     nii.(signal).(specimen)(:, :, d, st) = table2array(datum);
        %                 end
        %             end
        %         end
        %         metadata.signals.(signal) = string(datum.Properties.VariableNames);
        %     end
        % end
        function [flex, ext] = split_flex_ext(obj)
            directions = obj.directions;
            states = obj.states;
            specimens = obj.specimens;
            obj.SpecimenName = specimens;
            flex = obj;
            ext = obj;

            for d = 1:numel(directions)
                direction = directions(d);
                for st = 1:numel(states)
                    state = states(st);

                    for sp = 1:numel(specimens)
                        specimen = specimens(sp);
                        signals = fieldnames(obj.Data.(specimen).(state).(direction));
                        for sg = 1:numel(signals)
                            signal = signals{sg};
                            datum = obj.Data.(specimen).(state).(direction).(signal);
                            n = round(height(datum)/2);
                            flex.Data.(specimen).(state).(direction).(signal) = datum(1:n, :);
                            ext.Data.(specimen).(state).(direction).(signal) = datum(n:end, :);
                        end
                    end
                end
            end

        end

        function o = average(obj)
            o = EnvelopeAverage(obj);
        end

        function p = plot(obj)

            if isempty(obj.Data)
                p = plot(0);
                return
            end

            states = string(obj.states);
            specimens = string(obj.specimens);
            n_colours = length(fieldnames(obj.Data.(specimens(1))));
            colours = lines(n_colours);
            directions = string(obj.directions);

            for sp = 1:numel(specimens)
                specimen = specimens(sp);
                for s = 1:numel(states)
                    state = states(s);
                    colour = colours(s, :);

                    if any(cellfun(@(x) isempty(obj.Data.(specimen).(state).(x)), directions))
                        continue
                    end
                    signals = fieldnames(obj.Data.(specimen).(state).(directions(1)));
                    for sg = 1:numel(signals)
                        figure(sg);
                        signal = signals{sg};

                        plots(s, sg) = gen_plots(obj.Data.(specimen).(state), directions, signal, colour);



                    end
                end

                for sg = 1:numel(signals)
                    signal = signals{sg};
                    figure(sg);
                    sgtitle(replace(signal, '_', ' '));
                    legend(plots(:,sg), state_regex_inv(states));
                end
            end

        end
    end

    methods
        function obj = print_to_file(obj, path)
            % % Prepare the folders
            fp_results = fullfile(path, "results", "per_specimen", "stability_envelope");
            states = obj.states;
            signals = obj.signals;
            directions = obj.directions;
            specimens = obj.specimens;
            for sp = 1:numel(specimens)
                specimen = specimens(sp);
                for st = 1:numel(states)
                    state = states(st);
                    for sg = 1:numel(signals)
                        signal = signals(sg);

                        filepath = fullfile(fp_results, signal, state, specimen);
                        mkdir(filepath);
                        for d = 1:numel(directions)
                            direction = directions(d);

                            datum = obj.Data.(specimen).(state).(direction).(signal);

                            writetable(datum, strcat(fullfile(filepath, direction), '.csv'));
                        end
                    end
                end
            end
        end
        function o = filter_state(obj, state)
            error("Not yet implemented");
            mask = strcmpi(obj.States, state);
            o = obj(mask, :);
        end

        function o = filter_envelope(obj, envelope)
            error("Not yet implemented");
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
            signals = fieldnames(datum);

            for sg = 1:numel(signals)
                signal = signals{sg};
                is_incomplete_run = ~all(size(datum.(signal)) == size(curr_native.Data.(signal)));

                if is_incomplete_run
                    continue
                end
                o.(specimen_name).(state).(loading_condition).(signal) = datum.(signal) - curr_native.Data.(signal);
                try
                    o.(specimen_name).(state).(loading_condition).(signal).flexion = curr_native.Data.(signal).flexion;
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

function p = gen_plots(data, directions, jcs, colour)

for d = 1:numel(directions)
    ap = directions(d);
    datum = data.(ap);
    if d > 1
        colour = 0.9 * colour;
    end

    if isempty(datum)
        p = plot(0);
        continue
    end



    orientations = datum.(jcs).Properties.VariableNames;
    orientations(contains(orientations, 'flexion')) = [];
    for o = 1:numel(orientations)
        nexttile(o); hold on;
        x = datum.(jcs).flexion;
        y = datum.(jcs).(orientations{o});
        [x_arrowed, y_arrowed] = arrowed_line(x, y, 10, 100, 100);
        % fill(x,y, colour, 'FaceAlpha', 0.1);
        p = plot(x_arrowed, y_arrowed, 'color', colour);
        % p = plot(x_arrowed, y_arrowed);
        grid on;
        axis square;
        xlabel("Flexion angle");
        ylabel(replace(orientations{o}, '_', ' '));
    end


end

end
