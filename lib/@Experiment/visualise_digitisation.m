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
        zlabel("Superior-inferior (mm)");
        ylabel("Anterior-posterior (mm)")
        xlabel("Medial-lateral (mm)")

        colours = lines(numel(states));
        for st = 1:numel(states)
            colour = colours(st, :);
            state = states(st);

            data = trajectory_sets(st).JCS;

            hold on; axis square;

            t_certus = landmarks(data.JCS.Collected_Points_Rigid_Body_2);
            t = pre_multiply(t_certus, inv(data.JCS.T_World1_World2));
            f_certus = landmarks(data.JCS.Collected_Points_Rigid_Body_1);
            f = pre_multiply(f_certus, inv(data.JCS.T_World1_World2));
            [plots, colour] = visualise_landmark(to_mm(t), to_mm(f), is_right_knee, state, "-", colour);

            if any(data.JCS.T_RB2_OPT_RB2_Orig ~= eye(4), "all")
                tTopt = data.JCS.T_RB2_OPT_RB2_Orig;
                tTopt(1:3, 4) = tTopt(1:3, 4); 
                t_opt = post_multiply(t, tTopt);

                fTopt = data.JCS.T_RB1_OPT_RB1_Orig;
                fTopt(1:3, 4) = fTopt(1:3, 4); 
                f_opt = post_multiply(f, fTopt);
                visualise_landmark(to_mm(t_opt), to_mm(f_opt), is_right_knee, state,  ":", colour);
            end
            legend;
            grid on;
            hold off;

            % disp(trajectory_set)
            % disp(rotationsAndTranslations(data.JCS.T_RB2_OPT_RB2_Orig, is_right_knee));
        end
    end
end


function res = pre_multiply(rb, t)
    res.lateral = t * rb.lateral;
    res.medial = t * rb.medial;
    res.distal = t * rb.distal;
end
function res = post_multiply(rb, t)
    res.lateral = rb.lateral' * t;
    res.medial  = rb.medial' * t;
    res.distal  = rb.distal' * t;
end

function res = to_mm(rb)
    res.lateral = rb.lateral * 1000;
    res.medial  = rb.medial * 1000;
    res.distal  = rb.distal * 1000;
end
