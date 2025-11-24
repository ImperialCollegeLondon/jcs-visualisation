classdef Plot
    properties
        LineHandles
        States
        Signals
        Orientations
        FigureHandles
    end

    methods
        function obj = Plot(envelope,orientations)
            arguments
                envelope EnvelopeAverage
                orientations = [];
            end
            obj.States = envelope.States;
            obj.Signals = envelope.Signals;
            obj.Orientations = envelope.Directions;
            [obj.LineHandles, obj.FigureHandles] = create_plot(envelope, orientations);
        end
    end
end

function [line_handles, figure_handles] = create_plot(obj, orientations)
    if isempty(obj.Data)
        line_handles = plot(0);
        return
    end

    states = obj.States;
    directions = obj.Directions; %anterior-posterior
    colours = lines(numel(states));
    signals = obj.Signals;
    %orientations = degree of freedom

    for sg = 1:numel(signals)
        figure_handles(sg) = figure;
        signal = signals{sg};
        for s = 1:numel(states)
            state = states(s);
            colour = colours(s, :);

            plots(s).(signal) = gen_plots(obj.Data.(state).(signal), directions, colour, s, orientations);

        end
        sgtitle(replace(signals(sg), '_', ' '));
        plot_handles = [plots.(signal)];
        orient = fields(plot_handles);
        legend([plot_handles.(orient{1})], state_regex_inv(states));
    end
    line_handles = plots;
    
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
        try
        datum = data.(ap);
        catch ME
            keyboard
        end
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
            for o = 1:numel(orientations)
                p.(orientations{o}) = plot(0);
            end
            return
        end



        if isempty(orientations)
            orientations = datum.mean.Properties.VariableNames;
        end
        is_flexion = contains(orientations, 'flexion');
        orientations(is_flexion) = [];

        step = 10;



        for o = 1:numel(orientations)
            orientation = orientations{o};

            nexttile(o); hold on;
            x = datum.mean.flexion;
            y = datum.mean.(orientation);
            % p = plot(x, y, linestyles(d), 'color', colour);
            p.(orientation) = plot(x, y, 'color', colour);

            y_std = datum.std.(orientation);
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
            ylabel(replace(orientation, '_', ' '));
        end


    end
end