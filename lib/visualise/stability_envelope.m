function stability_envelope(data, config, truncate_min, truncate_max)
    colourmap = lines(8);    
    paired_conditions = @(x, str1, str2) contains([x.loading_condition], str1) | contains([x.loading_condition], str2);
    ant_pos = @(x) paired_conditions(x, 'ant', 'pos');
    ext_int = @(x) paired_conditions(x, 'ext', 'int');

    states = fieldnames(data);
    is_native = states == "Native";

    native = data.(states{is_native});
    is_native_neutral = contains([native.loading_condition], "Neutral");
    native_neutral = native(is_native_neutral);
  
    states(contains(states, 'name')) = [];
    plots = [];

    figure(2); hold on;
    for st = 1:numel(states)
        datum = data.(states{st});
        datum = datum(is_flexion_arc(datum, 180));

        ap_datum = {datum(ant_pos(datum)).kinematics};
        ap = subtract_native(ap_datum, native_neutral.kinematics);
        plots(st,1) = gen_plots(ap, colourmap(st, :));
        grid on;
    end
    sgtitle("Anterior/Posterior stability envelope");
    legend_text = replace(states, '_w_', '+');
    legend_text = replace(legend_text, '_wo_', '-');
    legend(plots(:,1), replace(legend_text, '_', ' '));

    plots = [];
    figure(3); hold on;
    for st = 1:numel(states)
        datum = data.(states{st});
        is_full_flexion = is_flexion_arc(datum, 180);
        datum = datum(is_full_flexion);

        is_ext_int = ext_int(datum);
        kinematics_ie = {datum(is_ext_int).kinematics};
        plots(st,2) = gen_plots(kinematics_ie, colourmap(st, :));
        grid on;
    end
    sgtitle("Internal/External stability envelope");
    legend_text = replace(states, '_w_', '+');
    legend_text = replace(legend_text, '_wo_', '-');
    legend(plots(:,2), replace(legend_text, '_', ' '));

end
function o = subtract_native(datum, native)
    for n = 1:numel(datum)
        o{n} = datum{n} - native;
    end
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
            [x_arrowed, y_arrowed] = arrowed_line(data{ap}.flexion, data{ap}.(orientations{o}), 10, 100, 100);

            p = plot(x_arrowed, y_arrowed, 'color', colour);
            grid on;
            xlabel("Flexion angle");
            ylabel(orientations{o});
        end
    end
end
