classdef CalculateKinematics < matlab.unittest.TestCase
    methods(Test)
        function calculate_relative_motion(test_case)
            % RB1 = femur
            % RB2 = tibia
            % S2 = End effector
            % W2 = Robot
            % W1 = Camera
            S1_T_RB1opt = [0.1371 -0.5150 -0.8461 -0.2308; 0.8354 0.5191 -0.1806 -0.1908; 0.5321 -0.6821 0.5015 -2.1860; 0 0 0 1];
            W1_T_W2 = [0.1525 0.2884 0.9453 -1.1052;0.9311 -0.3627 -0.0396 -0.9598; 0.3314 0.8862 -0.3239 -2.3803; 0 0 0 1];
            S2_T_RB2opt = [0.5967 0.8004 -0.05841 0.01282;-0.7971 0.5995 0.07228 0.003949;0.09286 0.003433 0.9957 0.2363;0 0 0 1];
            W2_T_S2(:,:,1) = [0.9181 -0.3963 -0.006985 0.9040;-0.3949 -0.9161 0.06906 0.1390;-0.03376 -0.06064 -0.9976 0.9707;0 0 0 1];
            W2_T_S2(:,:,2) = [0.9192 -0.3936 -0.01021 0.9048;-0.3913 -0.9162 0.08658 0.1349;-0.04343 -0.07559 -0.9962 0.9705;0 0 0 1];
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
    end

    methods(TestMethodSetup)
        function set_path(~)
            addpath(genpath('lib'))
        end
    end
end
