function stability_envelope(data, config, truncate_min, truncate_max)
    paired_conditions = @(x, str1, str2) contains([x.loading_condition], str1) | contains([x.loading_condition], str2);
    ant_pos = @(x) paired_conditions(x, 'ant', 'pos');
    ext_int = @(x) paired_conditions(x, 'ext', 'int');

    colourmap = lines;
    states = fieldnames(data);
    states(contains(states, 'name')) = [];
    plots = [];

    figure(1); hold on;
    for st = 1:numel(states)
        datum = data.(states{st});

        is_ant_pos = ant_pos(datum);
        kinematics_ap = {datum(is_ant_pos).kinematics};
        plots(st) = gen_plots(kinematics_ap, colourmap(st, :));
    end
    legend(plots, replace(states, '_', ' '));

    plots = [];
    figure(2); hold on;
    for st = 1:numel(states)
        datum = data.(states{st});

        is_ext_int = ext_int(datum);
        kinematics_ie = {datum(is_ext_int).kinematics};
        plots(st) = gen_plots(kinematics_ie, colourmap(st, :));
    end
    legend(plots, states);

end

function p = gen_plots(data, colour)
    if isempty(data)
        p = plot(0);
        return
    end
    orientations = data{1}.Properties.VariableNames;
    orientations(contains(orientations, 'flexion')) = [];

    % tiledlayout(round(numel(orientations)/2), 2);
    for ap = 1:numel(data)
        for o = 1:numel(orientations)
            nexttile(o); hold on;
            p = plot(data{ap}.flexion, data{ap}.(orientations{o}), 'color', colour);
            xlabel("Flexion angle");
            ylabel(orientations{o});
        end
    end
end
