classdef EnvelopeAverage
    properties
        Data
        States
        Directions
        Signals
    end
    methods % Static
        function obj = EnvelopeAverage(envelopes)
            specimens = envelopes.specimens;
            directions = envelopes.directions;
            states = envelopes.states;
            signals = envelopes.signals;

            for d = 1:numel(directions)
                direction = directions(d);
                for st = 1:numel(states)
                    state = states(st);

                    % signals = fieldnames(envelopes.Data.(specimens(1)).(state).(direction));
                    for sg = 1:numel(signals)
                        signal = signals{sg};
                        all_tables = cell(1, numel(specimens));
                        for sp = 1:numel(specimens)
                            specimen = specimens(sp);

                            all_tables{sp} = envelopes.Data.(specimen).(state).(direction).(signal);
                        end
                        headers = all_tables{1}.Properties.VariableNames;
                        tables = cellfun(@table2array, all_tables, "UniformOutput", false);
                        stacked = cat(3, tables{:});
                        avg = mean(stacked, 3);
                        stdev = std(stacked, 0, 3);

                        obj.Data.(state).(signal).(direction).mean = array2table(avg, "VariableNames", headers);
                        obj.Data.(state).(signal).(direction).std = array2table(stdev, "VariableNames", headers);
                    end
                end
            end
            obj.States = states;
            obj.Directions = directions;
            obj.Signals = string(signals);
        end
    end

    methods
        function spmi = spm(obj)
            states = obj.States;
            directions = obj.Directions;
            signals = obj.Signals;

            for sg = 1:numel(signals)
                signal = signals(sg);
                for d = 1:numel(directions)
                    direction = directions(d);
                    x = obj.Data.(states(1)).(signal).(direction).mean;
                    val = nan(height(x), numel(states), width(x));

                    for st = 1:numel(states)
                        state = states(st);
                        datum = obj.Data.(state).(signal).(direction).mean;
                        val(:, st, :) = table2array(datum);
                    end

                    headers = datum.Properties.VariableNames;
                    for h = 1:numel(headers)
                        header = headers{h};
                        spm = spm1d.stats.anova1rm(val(:, :, h)', 1:numel(states));
                        spmi.(signal).(direction).(header) = spm.inference(0.05);
                    end
                end
            end
        end

        function obj = print_to_file(obj, path)
            % % Prepare the folders
            fp_results = fullfile(path, "results", "average", "stability_envelope");
            states = obj.States;
            signals = obj.Signals;
            directions = obj.Directions;
            for st = 1:numel(states)
                state = states(st);
                for sg = 1:numel(signals)
                    signal = signals(sg);

                    filepath = fullfile(fp_results, signal, state);
                    mkdir(filepath);
                    for d = 1:numel(directions)
                        direction = directions(d);

                        datum = obj.Data.(state).(signal).(direction);
                        headers = datum.mean.Properties.VariableNames;

                        t_mean = datum.mean;
                        t_std = datum.std;
                        
                        t_mean.Properties.VariableNames = headers + "_mean";
                        t_std.Properties.VariableNames = headers + "_std";
                        
                        
                        writetable([t_mean t_std], strcat(fullfile(filepath, direction), '.csv'));
                    end
                end
            end
        end

        function [flex, ext] = split_flex_ext(obj)
            directions = obj.Directions;
            states = obj.States;
            signals = obj.Signals;

            flex = obj;
            ext = obj;

            for d = 1:numel(directions)
                direction = directions(d);
                for st = 1:numel(states)
                    state = states(st);

                    for sg = 1:numel(signals)
                        signal = signals(sg);
                        datum = obj.Data.(state).(signal).(direction);
                        headers = fieldnames(datum);

                        for h = 1:numel(headers)
                            header = headers{h};
                            n = round(height(datum.(header))/2);
                            flex.Data.(state).(signal).(direction).(header) = datum.(header)(1:n, :);
                            ext.Data.(state).(signal).(direction).(header) = datum.(header)(n:end, :);
                        end
                    end
                end
            end
        end

        function o = plot(obj, orientations)
            if nargin > 1
                orient = orientations;
            else
                orient = [];
            end
            if isempty(obj.Data)
                o = plot(0);
                return
            end

            states = obj.States;
            directions = obj.Directions;
            colours = lines(numel(states));
            signals = obj.Signals;

            for sg = 1:numel(signals)
                f(sg) = figure;
                signal = signals{sg};
                for s = 1:numel(states)
                    state = states(s);
                    colour = colours(s, :);

                    plots(s, sg) = gen_plots(obj.Data.(state).(signal), directions, colour, s, orient);

                end
                sgtitle(replace(signals(sg), '_', ' '));
                legend(plots(:,sg), state_regex_inv(states));
            end
        end
    end

end




function p = gen_plots(data, directions, colour, s, orientations)
    arguments
        data
        directions
        colour
        s
        orientations = [];
    end
    means = [];
    for d = 1:numel(directions)
        ap = directions(d);
        datum = data.(ap);
        if isempty(orientations)
            orientations = datum.mean.Properties.VariableNames;
        end
        is_flexion = contains(orientations, 'flexion');
        orientations(is_flexion) = [];
        for o = 1:numel(orientations)
            orientation = orientations{o};
            means(o, d) = mean(datum.mean.(orientation));
        end
    end

    is_first_higher = means(:, 1) > means(:, 2);

    % linestyles = ["--", ":"];
    for d = 1:numel(directions)
        ap = directions(d);
        datum = data.(ap);
        if d > 1 %Differentiate anterior from posterior
            colour = 0.9 * colour;
        end

        if isempty(datum.mean)
            p = plot(0);
            return
        end



        if isempty(orientations)
            orientations = datum.mean.Properties.VariableNames;
        end
        is_flexion = contains(orientations, 'flexion');
        orientations(is_flexion) = [];

        step = 10;



        for o = 1:numel(orientations)

            nexttile(o); hold on;
            x = datum.mean.flexion;
            y = datum.mean.(orientations{o});
            % p = plot(x, y, linestyles(d), 'color', colour);
            p = plot(x, y, 'color', colour);


            y_std = datum.std.(orientations{o});
            idx = 1:step+1*s:numel(x);
            is_bar_up = xor(is_first_higher(o), d > 1);
            if is_bar_up
                errorbar(x(idx), y(idx), 0, y_std(idx), 'LineStyle', 'none', 'Color', colour*0.7);
            else
                errorbar(x(idx), y(idx), y_std(idx), 0, 'LineStyle', 'none', 'Color', colour*0.7);
            end
            % fill(x,y, colour, 'FaceAlpha', 0.1);

            grid on;
            axis square;
            xlabel("Flexion angle");
            ylabel(replace(orientations{o}, '_', ' '));
        end


    end
end
