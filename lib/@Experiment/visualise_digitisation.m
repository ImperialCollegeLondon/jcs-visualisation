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

            tibia_digitisation = landmarks(data.JCS.Collected_Points_Rigid_Body_2);
            tibia = pre_multiply(tibia_digitisation, inv(data.JCS.T_World1_World2));
            femur_digitisation = landmarks(data.JCS.Collected_Points_Rigid_Body_1);
            femur = pre_multiply(femur_digitisation, inv(data.JCS.T_World1_World2));
            [plots, colour] = visualise_landmark(to_mm(tibia), to_mm(femur), is_right_knee, state, "-", colour);

            % is_optimised = any(data.JCS.T_RB2_OPT_RB2_Orig ~= eye(4), "all");
            % if is_optimised
            %     tTopt = data.JCS.T_RB2_OPT_RB2_Orig;
            %     tTopt(1:3, 4) = tTopt(1:3, 4); 
            %     t_opt = post_multiply(tibia, tTopt);
            %
            %     fTopt = data.JCS.T_RB1_OPT_RB1_Orig;
            %     fTopt(1:3, 4) = fTopt(1:3, 4); 
            %     f_opt = post_multiply(femur, fTopt);
            %     visualise_landmark(to_mm(t_opt), to_mm(f_opt), is_right_knee, state,  ":", colour);
            % end
            legend;
            grid on;
            hold off;

            % disp(trajectory_set)
            % disp(rotationsAndTranslations(data.JCS.T_RB2_OPT_RB2_Orig, is_right_knee));
        end
    end
end


function res = pre_multiply(rigid_body, transform)
    res.lateral = transform * rigid_body.lateral;
    res.medial = transform * rigid_body.medial;
    res.distal = transform * rigid_body.distal;
end
function res = post_multiply(rigid_body, transform)
    res.lateral = rigid_body.lateral' * transform;
    res.medial  = rigid_body.medial' * transform;
    res.distal  = rigid_body.distal' * transform;
end

function res = to_mm(rb)
    res.lateral = rb.lateral * 1000;
    res.medial  = rb.medial * 1000;
    res.distal  = rb.distal * 1000;
end
