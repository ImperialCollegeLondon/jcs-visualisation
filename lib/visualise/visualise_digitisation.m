function visualise_digitisation(data, config, titles)
    % figure; 

    name_trajectory = split(titles(2), ' ');
    state = name_trajectory(2);


    hold on; axis square;
    sgtitle(titles);
    t_certus = landmarks(data.JCS.Collected_Points_Rigid_Body_2);
    t = transform_landmark(t_certus, inv(data.JCS.T_World1_World2));
    f_certus = landmarks(data.JCS.Collected_Points_Rigid_Body_1);
    f = transform_landmark(f_certus, inv(data.JCS.T_World1_World2));
    [plots, colour] = visualise_landmark(t, f, config, state);

    if any(data.JCS.T_RB2_OPT_RB2_Orig ~= eye(4), "all")
        t_opt = transform_landmark(t, data.JCS.T_RB2_OPT_RB2_Orig);
        f_opt = transform_landmark(f, data.JCS.T_RB1_OPT_RB1_Orig);
        visualise_landmark(t_opt, f_opt, config, state,  ":", colour);
    end
    legend;
    grid on;
    hold off;
    
    % disp(trajectory_set)
    disp(rotationsAndTranslations(data.JCS.T_RB2_OPT_RB2_Orig, config.is_right_knee))
end
