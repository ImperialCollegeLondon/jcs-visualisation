function plots = visualise_digitisation(obj)
    all_trajectory_sets = obj.RawTrajectorySets;
    specimens = unique([all_trajectory_sets.specimen]);

    for sp = 1:numel(specimens)
        specimen = specimens(sp);
        is_specimen = [all_trajectory_sets.specimen] == specimen;
        trajectory_sets = all_trajectory_sets(is_specimen);
        states = [trajectory_sets.state];
        is_right_knee = trajectory_sets.is_right_knee;

        figure;
        sgtitle(specimen)

        colours = lines(numel(states));
        for st = 1:numel(states)
            colour = colours(st, :);
            state = states(st);

            data = trajectory_sets(st).JCS;

            hold on; axis square;

            t_certus = landmarks(data.JCS.Collected_Points_Rigid_Body_2);
            t = transform_landmark(t_certus, inv(data.JCS.T_World1_World2));
            f_certus = landmarks(data.JCS.Collected_Points_Rigid_Body_1);
            f = transform_landmark(f_certus, inv(data.JCS.T_World1_World2));
            [plots, colour] = visualise_landmark(t, f, is_right_knee, state, "-", colour);

            if any(data.JCS.T_RB2_OPT_RB2_Orig ~= eye(4), "all")
                t_opt = transform_landmark(t, data.JCS.T_RB2_OPT_RB2_Orig);
                f_opt = transform_landmark(f, data.JCS.T_RB1_OPT_RB1_Orig);
                visualise_landmark(t_opt, f_opt, is_right_knee, state,  ":", colour);
            end
            legend;
            grid on;
            hold off;

            % disp(trajectory_set)
            % disp(rotationsAndTranslations(data.JCS.T_RB2_OPT_RB2_Orig, is_right_knee));
        end
    end
end
