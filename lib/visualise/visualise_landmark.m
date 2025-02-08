function visualise_landmark(t, f, config, colour_t, colour_f)
    plot_t = scatter3(t.medial(1), t.medial(2), t.medial(3));
    hold on;
    text(t.medial(1), t.medial(2), t.medial(3), "  Medial");

    scatter3(t.lateral(1), t.lateral(2), t.lateral(3));
    text(t.lateral(1), t.lateral(2), t.lateral(3), "  Lateral");
    scatter3(t.distal(1), t.distal(2), t.distal(3));
    text(t.distal(1), t.distal(2), t.distal(3), "  Distal");
    

    %% Medial lateral axis
    o = (t.medial + t.lateral)/2;
    scatter3(o(1), o(2), o(3), colour_t, 'filled');

    if config.is_right_knee
        med_lat = t.lateral - t.medial;
        quiver3(t.medial(1), t.medial(2), t.medial(3), med_lat(1), med_lat(2), med_lat(3), 0, colour_t);
    else
        med_lat = t.medial - t.lateral;
        quiver3(t.lateral(1), t.lateral(2), t.lateral(3), med_lat(1), med_lat(2), med_lat(3), 0, colour_t);
    end

    %% Proximal-distal axis
    prox_dist = t.distal - o;
    quiver3(o(1), o(2), o(3), prox_dist(1), prox_dist(2), prox_dist(3), 0, colour_t);


    %% Femur

    plot_f = scatter3(f.medial(1), f.medial(2), f.medial(3));
    hold on;
    text(f.medial(1), f.medial(2), f.medial(3), "  Medial");

    scatter3(f.lateral(1), f.lateral(2), f.lateral(3));
    text(f.lateral(1), f.lateral(2), f.lateral(3), "  Lateral");
    scatter3(f.distal(1), f.distal(2), f.distal(3));
    text(f.distal(1), f.distal(2), f.distal(3), "  Proximal");

    %% Medial lateral axis
    o = (f.medial + f.lateral)/2;
    scatter3(o(1), o(2), o(3), colour_f, 'filled');

    if config.is_right_knee
        med_lat = f.lateral - f.medial;
        quiver3(f.medial(1), f.medial(2), f.medial(3), med_lat(1), med_lat(2), med_lat(3), 0, colour_f);
    else
        med_lat = f.medial - f.lateral;
        quiver3(f.lateral(1), f.lateral(2), f.lateral(3), med_lat(1), med_lat(2), med_lat(3), 0, colour_f);
    end

    %% Proximal-distal axis
    prox_dist = f.distal - o;
    quiver3(o(1), o(2), o(3), prox_dist(1), prox_dist(2), prox_dist(3), 0, colour_f);
    legend([plot_t, plot_f], {'Tibia', 'Femur'});
end
