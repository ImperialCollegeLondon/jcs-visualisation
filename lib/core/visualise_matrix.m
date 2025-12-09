function plots = visualise_matrix(matrix, linestyle)
    arguments
        matrix (4,4) {mustBeNumeric}
        linestyle = "-"
    end

    x = matrix(1:3, 1);
    y = matrix(1:3, 2);
    z = matrix(1:3, 3);
    o = matrix(1:3, 4);

    hold on;

    plots = quiver3(o(1), o(2), o(3), y(1), y(2), y(3), "LineStyle", linestyle);
    colour = plots.Color;
    quiver3(o(1), o(2), o(3), x(1), x(2), x(3), "Color", colour, "HandleVisibility", "off", "LineStyle", linestyle);
    quiver3(o(1), o(2), o(3), z(1), z(2), z(3), "Color", colour, "HandleVisibility", "off", "LineStyle", linestyle);

    tip_x = o + x;
    tip_y = o + y;
    tip_z = o + z;
    text(tip_x(1), tip_x(2), tip_x(3), "  Superior");
    text(tip_y(1), tip_y(2), tip_y(3), "  Anterior");
    text(tip_z(1), tip_z(2), tip_z(3), "  Medial");

    hold off;
    
end