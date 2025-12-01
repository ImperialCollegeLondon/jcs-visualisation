function inspect_end_effector(self)
    all_trajectory_sets = self.RawTrajectorySets;
    specimens = unique([all_trajectory_sets.specimen]);
    
    for sp = 1:numel(specimens)
        specimen = specimens(sp);
        is_specimen = [all_trajectory_sets.specimen] == specimen;
        trajectory_sets = all_trajectory_sets(is_specimen);
        states = [trajectory_sets.state];
    
        figure;
        sgtitle(specimen);
        for st = 1:numel(states)
            state = states(st);
            rTt = trajectory_sets(st).JCS.JCS_digitised.T_Sensor2_RB2;

            grid on;
    
            plots(st) = visualise_matrix(rTt);
        end
        legend(plots, states);
    end
end

function plots = visualise_matrix(matrix)
    arguments
        matrix (4,4) {mustBeNumeric}
    end

    x = matrix(1:3, 1);
    y = matrix(1:3, 2);
    z = matrix(1:3, 3);
    o = matrix(1:3, 4);

    hold on;

    plots = quiver3(o(1), o(2), o(3), y(1), y(2), y(3));
    colour = plots.Color;
    quiver3(o(1), o(2), o(3), x(1), x(2), x(3), "Color", colour, "HandleVisibility", "off");
    quiver3(o(1), o(2), o(3), z(1), z(2), z(3), "Color", colour, "HandleVisibility", "off");

    tip_x = o + x;
    tip_y = o + y;
    tip_z = o + z;
    text(tip_x(1), tip_x(2), tip_x(3), "  Superior");
    text(tip_y(1), tip_y(2), tip_y(3), "  Anterior");
    text(tip_z(1), tip_z(2), tip_z(3), "  Medial");

    hold off;
    
end
