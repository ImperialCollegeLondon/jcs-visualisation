function [plots, colour] = visualise_landmark(t, f, is_right_knee, label, linestyle, colour)
    arguments
        t
        f
        is_right_knee
        label
        linestyle = "-"
        colour = []
    end

    args = {'Color', colour, 'DisplayName', label};
    if linestyle == ":"
        args = [args, {'HandleVisibility', 'off'}];        
    end
    plots(1) = scatter3(t.medial(1), t.medial(2), t.medial(3), 'MarkerFaceColor', colour, 'DisplayName', label, args{:});

    hold on;
    text(t.medial(1), t.medial(2), t.medial(3), "  Medial");
    if isempty(colour)
        colour = plots(1).CData;
    end

    scatter3(t.lateral(1), t.lateral(2), t.lateral(3), [], 'MarkerFaceColor', colour, 'HandleVisibility', 'off');
    text(t.lateral(1), t.lateral(2), t.lateral(3), "  Lateral");
    scatter3(t.distal(1), t.distal(2), t.distal(3), [], 'MarkerFaceColor', colour, 'HandleVisibility', 'off');
    text(t.distal(1), t.distal(2), t.distal(3), "  Distal");
    

%% Tibia
    %% Medial lateral axis
    o = (t.medial + t.lateral)/2;
    scatter3(o(1), o(2), o(3), 'MarkerFaceColor', colour, 'HandleVisibility', 'off');

    if is_right_knee
        med_lat = t.lateral - t.medial;
        quiver3(t.medial(1), t.medial(2), t.medial(3), med_lat(1), med_lat(2), med_lat(3), 0, linestyle, "Color", colour, 'HandleVisibility', 'off');
    else
        med_lat = t.medial - t.lateral;
        quiver3(t.lateral(1), t.lateral(2), t.lateral(3), med_lat(1), med_lat(2), med_lat(3), 0, linestyle, "Color", colour, 'HandleVisibility', 'off');
    end

    %% Proximal-distal axis
    prox_dist = t.distal - o;
    quiver3(o(1), o(2), o(3), prox_dist(1), prox_dist(2), prox_dist(3), 0, linestyle, "Color", colour, 'HandleVisibility', 'off');


%% Femur

    plots(2) = scatter3(f.medial(1), f.medial(2), f.medial(3), [], 'MarkerFaceColor', colour, 'HandleVisibility', 'off');
    hold on;
    text(f.medial(1), f.medial(2), f.medial(3), "  Medial");

    scatter3(f.lateral(1), f.lateral(2), f.lateral(3), [], 'MarkerFaceColor', colour, 'HandleVisibility', 'off');
    text(f.lateral(1), f.lateral(2), f.lateral(3), "  Lateral");
    scatter3(f.distal(1), f.distal(2), f.distal(3), [], 'MarkerFaceColor', colour, 'HandleVisibility', 'off');
    text(f.distal(1), f.distal(2), f.distal(3), "  Proximal");

    %% Medial lateral axis
    o = (f.medial + f.lateral)/2;
    scatter3(o(1), o(2), o(3), 'MarkerFaceColor', colour, 'HandleVisibility', 'off');

    if is_right_knee
        med_lat = f.lateral - f.medial;
        quiver3(f.medial(1), f.medial(2), f.medial(3), med_lat(1), med_lat(2), med_lat(3), 0, linestyle, "Color", colour, 'HandleVisibility', 'off');
    else
        med_lat = f.medial - f.lateral;
        quiver3(f.lateral(1), f.lateral(2), f.lateral(3), med_lat(1), med_lat(2), med_lat(3), 0, linestyle, "Color", colour, 'HandleVisibility', 'off');
    end

    %% Proximal-distal axis
    prox_dist = f.distal - o;
    quiver3(o(1), o(2), o(3), prox_dist(1), prox_dist(2), prox_dist(3), 0, linestyle, "Color", colour, 'HandleVisibility', 'off');
end
