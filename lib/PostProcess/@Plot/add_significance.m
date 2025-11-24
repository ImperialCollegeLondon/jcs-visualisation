function add_significance(obj, posthoc)
    arguments
        obj
        posthoc PostHoc
    end

    states = obj.States;
    orientations = obj.Orientations;

    for sg = 1:numel(obj.Signals)
        signal = obj.Signals(sg);

        figure_handle = obj.FigureHandles(sg);
        figure(figure_handle.Number); % Switch figure

        for st = 1:numel(states)
            state = states(st);
            if state == posthoc.Control
                continue
            end
            line_handles = obj.LineHandles(st).(signal);
            DOFs = fields(line_handles);
            for o = 1:numel(orientations)
                orientation = orientations(o);
                for d = 1:numel(DOFs)
                    nexttile(d);
                    dof = DOFs{d};
                    line = line_handles.(dof);
                    is_significant = posthoc.Significance.(signal).(state).(orientation).(dof);
                    if ~any(is_significant)
                        continue;
                    end

                    x = line.XData;
                    y = line.YData;
                    colour = line.Color;
                    plot(x(is_significant), y(is_significant), 'LineWidth', 2, 'Color', colour, 'HandleVisibility', 'off');

                end
            end
        end
        
    end
end
