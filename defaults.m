config.visualise_digitisation = true; % Plots the landmark digitisation
%% Important post-processing definitions
% These are sensible defaults.


config.is_first_run_digitisation = true;
config.split_folders_with = "90N";
config.sensors = ["LVDT", "Single"]; %Make sure these are strings, not chars. Use ", not '.
config.digitisation_state_name = {'unoptimised'}; %These are char.
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
config.debug = true;

%% Other nice stuff

warning('off', 'backtrace'); warning('off', 'MATLAB:MKDIR:DirectoryExists');
% set(0,'defaulttextinterpreter','latex');