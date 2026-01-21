function [orig, opt] = calculate_relative_motion(W1_T_W2, W2_T_S2, S1_T_W1, S1_T_RB1opt, S2_T_RB2opt, RB2opt_T_RB2orig, RB1opt_T_RB1orig)
    RB1opt_T_W2 = S1_T_RB1opt \ S1_T_W1 * W1_T_W2;
    RB1opt_T_S2 = pagemtimes(RB1opt_T_W2, W2_T_S2);
    RB1opt_T_RB2opt = pagemtimes(RB1opt_T_S2, S2_T_RB2opt);
    RB1orig_T_RB2opt = pagemldivide(RB1opt_T_RB1orig, RB1opt_T_RB2opt);
    RB1_T_RB2 = pagemtimes(RB1orig_T_RB2opt, RB2opt_T_RB2orig);

    orig = RB1_T_RB2;
    opt = RB1opt_T_RB2opt;
end
