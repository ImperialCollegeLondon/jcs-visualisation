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
            line_handles = obj.LineHandles(st).(signal);
            DOFs = fields(line_handles);
            for d = 1:numel(DOFs)
                for o = 1:numel(orientations)
                    orientation = orientations(o);
                    nexttile(d);
                    dof = DOFs{d};
                    line = line_handles.(dof).(orientation);

                    x = line.XData;

                    if state == posthoc.Control
                        is_significant = true(numel(x), 1);
                    else
                        is_significant = posthoc.Significance.(signal).(state).(orientation).(dof);
                    end
                    if ~any(is_significant)
                        continue;
                    end

                    y = line.YData;
                    line_width = line.LineWidth * 4;
                    colour = line.Color;
                    plot(x(is_significant), y(is_significant), 'LineWidth', line_width, 'Color', colour, 'HandleVisibility', 'off');

                end
            end
        end
        
    end
end
