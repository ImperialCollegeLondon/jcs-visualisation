classdef CalculateKinematics < matlab.unittest.TestCase
    methods(Test)
        function calculate_relative_motion(test_case)
            % RB1 = femur
            % RB2 = tibia
            % S2 = End effector
            % W2 = Robot
            % W1 = Camera
            W1_T_W2 = [0.1525 0.2884 0.9453 -1.1052;0.9311 -0.3627 -0.0396 -0.9598; 0.3314 0.8862 -0.3239 -2.3803; 0 0 0 1];
            W2_T_S2(:,:,1) = [0.9181 -0.3963 -0.006985 0.9040;-0.3949 -0.9161 0.06906 0.1390;-0.03376 -0.06064 -0.9976 0.9707;0 0 0 1];
            W2_T_S2(:,:,2) = [0.9192 -0.3936 -0.01021 0.9048;-0.3913 -0.9162 0.08658 0.1349;-0.04343 -0.07559 -0.9962 0.9705;0 0 0 1];
            S1_T_RB1opt = [0.1371 -0.5150 -0.8461 -0.2308; 0.8354 0.5191 -0.1806 -0.1908; 0.5321 -0.6821 0.5015 -2.1860; 0 0 0 1];
            S2_T_RB2opt = [0.5967 0.8004 -0.05841 0.01282;-0.7971 0.5995 0.07228 0.003949;0.09286 0.003433 0.9957 0.2363;0 0 0 1];
            RB2opt_T_RB2orig = [0.9874 -0.1581 0.003975 -0.01480;0.1580 0.9874 0.007943 -0.009811;-0.005180 -0.007215 1.000 -0.04564;0 0 0 1];
            RB1opt_T_RB1orig = [0.9985 -0.05517 0.001460 -0.004154;0.05517 0.9985 0.00004032 -0.005380;-0.001460 0.00004032 1.000 0.001768;0 0 0 1];
            S1_T_W1 = eye(4);

            [RB1_T_RB2, ~] = calculate_relative_motion(W1_T_W2, W2_T_S2, S1_T_W1, S1_T_RB1opt, S2_T_RB2opt, RB2opt_T_RB2orig, RB1opt_T_RB1orig);

            % Method 2
            S2_T_RB2orig = S2_T_RB2opt * RB2opt_T_RB2orig;
            S1_T_RB1orig = S1_T_RB1opt * RB1opt_T_RB1orig;
            RB1orig_T_W2 = S1_T_RB1orig \ S1_T_W1 * W1_T_W2;
            RB1orig_T_S2 = RB1orig_T_W2 * W2_T_S2(:,:,1);
            RB1orig_T_RB2orig = RB1orig_T_S2 * S2_T_RB2orig;

            test_case.assertEqual(RB1_T_RB2(:, :, 1), RB1orig_T_RB2orig, 'AbsTol', 1e-8);
        end

        function digitisation_left(test_case)
            % JCS_digitised.T_Sensor1_RB1 = [0.1097 -0.5219 -0.8459 -0.2301;0.8631 0.4722 -0.1793 -0.1974;0.493 -0.7104 0.5022 -2.1837;0 0 0 1];
            % femur_digitised = [-0.2377 -0.2368 -2.2043 -0.2224 -0.1579 -2.1631;-0.2953 -0.2022 -2.1329 -0.2969 -0.1988 -2.1578;-0.2991 -0.2285 -2.1525 -0.2913 -0.2157 -2.1356];
            % femur = landmarks(femur_digitised);
            %
            % is_right_knee = false;
            % gTf = defineBodyFixedFrameFemur(femur, is_right_knee);
            % gTf = mat_to_left_handed(gTf);
            % test_case.assertEqual(JCS_digitised.T_Sensor1_RB1, gTf, 'AbsTol', 1e-6)
            % %% Introspection
            % femur = landmarks(state.JCS.Collected_Points_Rigid_Body_1);
            % transforms.from_digitiser.gTf0 = defineBodyFixedFrameFemur(femur, is_right_knee);
            % tibia = landmarks(state.JCS.Collected_Points_Rigid_Body_2);
            % transforms.from_digitiser.gTt0 = defineBodyFixedFrameTibia(tibia, is_right_knee);
            %
            % gTf0 = transforms.from_digitiser.gTf0;
            %
            % visualise_matrix(transforms.from_digitiser.gTf0);
            % xlabel("x"); ylabel("y"); zlabel("z");
            % axis equal; grid on; view(30,30);
            % hold on;
            % visualise_matrix(state.JCS_digitised.T_Sensor1_RB1);
            % if is_right_knee
            %     legend(["Correct", "Simvitro"]);
            %     title("Both should overlap")
            % else
            %     gTf0_left_handed = mat_to_left_handed(gTf0);
            %     assert(all(state.JCS_digitised.T_Sensor1_RB1 - gTf0_left_handed < 1e-6, "all"))
            %     visualise_matrix(gTf0_left_handed);     legend(["Correct","Simvitro","Correct => Left-hand"]);
            % end
            % hold off; axis equal;
        end
        function digitisation_right(test_case)
            JCS_digitised.T_Sensor1_RB1 = [0.1097 -0.5219 -0.8459 -0.2301;0.8631 0.4722 -0.1793 -0.1974;0.493 -0.7104 0.5022 -2.1837;0 0 0 1];
            femur_digitised = [-0.2377 -0.2368 -2.2043 -0.2224 -0.1579 -2.1631;-0.2953 -0.2022 -2.1329 -0.2969 -0.1988 -2.1578;-0.2991 -0.2285 -2.1525 -0.2913 -0.2157 -2.1356];
            femur = landmarks(femur_digitised);

            % Right handed
            is_right_knee = true;
            gTf = defineBodyFixedFrameFemur(femur, is_right_knee);
            test_case.assertEqual(JCS_digitised.T_Sensor1_RB1, gTf, 'AbsTol', 1e-3)

            figure;
            visualise_matrix(JCS_digitised.T_Sensor1_RB1);
            hold on;
            visualise_matrix(gTf);
            legend(["Simvitro", "From digitiser"]);
            title("Digitisations. Expect complete overlap");
        end

        function reconstruction_left(test_case)
            % if ~is_right_knee
            %     gTr_right_handed = mat_to_left_handed(gTr_right_handed);
            %     gTf0 = mat_to_left_handed(gTf0);
            %     gTt0 = mat_to_left_handed(gTt0);
            %     rTee = mat_to_left_handed(rTee);
            %     gTr = mat_to_left_handed(gTr);
            % end
        end

        function reconstruction_right(test_case)
            % Reconstructed from digitiser
            gTr = [0.1525 0.2884 0.9453 -1.1052;0.9311 -0.3627 -0.0396 -0.9598; 0.3314 0.8862 -0.3239 -2.3803; 0 0 0 1]; % W1_T_W2
            gTf0 = [0.1097 -0.5219 -0.8459 -0.2301;0.8631 0.4722 -0.1793 -0.1974;0.493 -0.7104 0.5022 -2.1837;0 0 0 1];
            gTt0 = [-0.0769 0.2982 -0.9514 -0.1859;-0.902 -0.4274 -0.0611 -0.2074;-0.4248 0.8535 0.3018 -2.2017;0 0 0 1];

            rTee = [0.9181 -0.3963 -0.006985 0.9040;-0.3949 -0.9161 0.06906 0.1390;-0.03376 -0.06064 -0.9976 0.9707;0 0 0 1]; % W2_T_S2
            rTee_neutral = [0.772 -0.6355 -0.0137 0.9073;-0.6346 -0.7718 0.0413 0.1464;-0.0368 -0.0232 -0.9991 0.9706;0 0 0 1];

            % As per Simvitro
            S2_T_RB2opt = [0.5967 0.8004 -0.0584 0.0128;-0.7971 0.5995 0.0723 0.0039;0.0929 0.0034 0.9957 0.2363;0 0 0 1];
            RB2opt_T_RB2orig = [0.9874 -0.1581 0.004 -0.0148;0.158 0.9874 0.0079 -0.0098;-0.0052 -0.0072 1 -0.0456;0 0 0 1];

            eeTt = pagemldivide(pagemtimes(gTr, rTee), gTt0);
            eeTt0 = (gTr * rTee_neutral) \ gTt0;

            figure;
            visualise_matrix(eeTt);
            hold on;
            visualise_matrix(S2_T_RB2opt * RB2opt_T_RB2orig);

            visualise_matrix(eeTt0);
            legend(["Tibia in end-effector", "Recreation", "Recreation from neutral position"]);
            view(30, 45); grid on; axis equal; hold off;
        end
    end

    methods(TestMethodSetup)
        function set_path(~)
            addpath(genpath('lib'))
        end
    end
    % methods(TestMethodTeardown)
    %     function close_figures(~)
    %         close all;
    %     end
    % end
end
