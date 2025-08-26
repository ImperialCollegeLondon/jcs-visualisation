function stability_envelope(data, native_neutral, config, truncate_min, truncate_max, jcs)
    colourmap = lines(8);    
    ant_pos = @(x) contains([x.loading_condition], ["ant", "pos"]);
    ext_int = @(x) contains([x.loading_condition], ["ext", "int"]);

    states = fieldnames(data);
    % is_native = states == "Native";
    % 
    % native = data.(states{is_native});
    % is_native_neutral = contains([native.loading_condition], "Neutral");
    % native_neutral = native(is_native_neutral);
  
    states(contains(states, 'name')) = [];
    plots = [];

    figure; hold on;
    for st = 1:numel(states)
        datum = data.(states{st});
        if istable(datum)
            keyboard
        end
        datum = datum(is_flexion_arc(datum, 180));

        ap_datum = {datum(ant_pos(datum)).(jcs)};
        if isempty(ap_datum)
            % Temporary fix. Should correct the Unoptimised state.
            continue
        end
        ap = subtract_native(ap_datum, native_neutral.(jcs));
        plots(st,1) = gen_plots(ap, colourmap(st, :));
        grid on;
    end
    sgtitle(["Anterior/Posterior stability envelope"]);
    % legend(plots(:,1), state_regex_inv(states));

    plots = [];
    figure; hold on;
    for st = 1:numel(states)
        datum = data.(states{st});
        is_full_flexion = is_flexion_arc(datum, 180);
        datum = datum(is_full_flexion);

        is_ext_int = ext_int(datum);
        kinematics_ie = {datum(is_ext_int).(jcs)};
        plots(st,2) = gen_plots(kinematics_ie, colourmap(st, :));
        grid on;
    end
    sgtitle(["Internal/External stability envelope"]);
    legend(plots(:,2), state_regex_inv(states));

end
function o = subtract_native(datum, native)
    for n = 1:numel(datum)
        o{n} = datum{n} - native;
        o{n}.flexion = native.flexion;
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
            x = data{ap}.flexion;
            y = data{ap}.(orientations{o});
            [x_arrowed, y_arrowed] = arrowed_line(x, y, 10, 100, 100);
            fill(x,y, colour, 'FaceAlpha', 0.1);
            p = plot(x_arrowed, y_arrowed, 'color', colour);
            grid on;
            xlabel("Flexion angle");
            ylabel(replace(orientations{o}, '_', ' '));
        end
    end
end
