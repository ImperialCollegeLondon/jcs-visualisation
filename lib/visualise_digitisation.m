function visualise_digitisation(state, config, titles)
    if config.visualise_digitisation
        figure; 
        hold on; grid;
        sgtitle(titles);
        t_certus = landmarks(state.JCS.Collected_Points_Rigid_Body_2);
        t = transform_landmark(t_certus, inv(state.JCS.T_World1_World2));
        f_certus = landmarks(state.JCS.Collected_Points_Rigid_Body_1);
        f = transform_landmark(f_certus, inv(state.JCS.T_World1_World2));
        plots = visualise_landmark(t, f, config, 'b', 'r');
        if any(state.JCS.T_RB2_OPT_RB2_Orig ~= eye(4), "all")
            t_opt = transform_landmark(t, state.JCS.T_RB2_OPT_RB2_Orig);
            f_opt = transform_landmark(f, state.JCS.T_RB1_OPT_RB1_Orig);
            plots_t = visualise_landmark(t_opt, f_opt, config, 'k', 'k');
            plots = [plots plots_t];

            legend(plots, {'Digitised Tibia', 'Digitised Femur', 'Optimised Tibia', 'Optimised Femur'});
        else
            legend(plots, {'Tibia', 'Femur'});
        end
        hold off;
        
        disp(trajectory_set)
        disp(rotationsAndTranslations(state.JCS.T_RB2_OPT_RB2_Orig, config.is_right_knee))
    end
end
