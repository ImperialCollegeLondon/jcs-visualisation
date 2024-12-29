%% Important post-processing definitions
% These are sensible defaults.


config.digitisation_state_name = {'unoptimised', 'native'};
config.shift_flex = @(x) x - min(x); % Offset so min flex (extension) is 0
% config.shift_flex = @(x) x + 120 - max(x); % Offset so max flexion is 120.

config.step_size = 1; % quantisation step size for output data. i.e., flexion is grouped in intervals of 1 or 0.5 or n.
config.smallest_range = true; %Whether to interpolate down to the smallest or up to the largest range.

%%%%%% Function signature for all of these must be (T) => T %%%%%%
% Smoothing functions are very computationally expensive. Suggest no intraspecimen smoothing intraspecimen.
% Interspecimen
config.interpolation_algorithm = @(x, v, xq) interp1(x, v, xq, "pchip"); % Should be changed to to generalised cross-validated cubic spline-interpolation.
config.interspecimen_smooth_mean = @(x) x; % Smooth after calculating the interspecimen mean
config.interspecimen_smooth_diff = @(x) smoothdata(x, "gaussian", 10); % Smooth after comparing the current knee state to the intact.


config.intact_name = "Native"; % Name for the native state. Used for interspecimen comparisons