function plots = plot(obj, orientations)
    signals = obj.Signals;
    states = obj.States;
    colours = lines(numel(states));

    for sg = 1:numel(signals)
        signal = signals(sg);
        figure(sg); 
        for s = 1:numel(states)

            state = states(s);
            colour = colours(s, :);

            if ~nargin > 1
                orientations = obj.Data.(state).(signal).mean.Properties.VariableNames;
                orientations = setdiff(orientations, 'flexion');
            end
            for o = 1:numel(orientations)
                nexttile(o); hold on;
                x = obj.Data.(state).(signal).mean.flexion;
                y = obj.Data.(state).(signal).mean.(orientations{o});
                p = plot(x, y, 'Color', colour);


                idx = 1:10+2*s:numel(x);
                y_std = obj.Data.(state).(signal).std.(orientations{o});
                errorbar(x(idx), y(idx), y_std(idx), 'LineStyle', 'none', 'Color', colour*0.7);


                grid on;
                axis square;
                xlabel("Flexion angle");
                ylabel(replace(orientations{o}, '_', ' '));
            end
            plots(s) = p;
        end
        sgtitle(replace(signal, '_', ' '));
        legend(plots, state_regex_inv(states));

    end
end
