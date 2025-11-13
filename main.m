%% this code calculates the knee kinematics in both the original, digitised coordinate frame and the optimised coordinate frame
clc;clear; close all;
profile on;
diary("log.txt"); % Creates a log. Important for checking which runs failed!!
addpath(genpath('spm'));
addpath(genpath('./lib'))
%% Load in the Specimen folder
defaults;

% State cfg file is used to create the transforms.
folder_exist = 7;
if exist('data', 'dir') == folder_exist
    disp("Found data folder in current directory");
    root = fullfile('.', 'data');
else
    disp("Pick experiment folder.")
    root = uigetdir(".", "Pick the folder with all specimens");
end
if root == 0, disp("Exiting script."), return, end
experiment = Experiment(root, config);
trajectories = experiment.Trajectories;

%% SPSS
spss = trajectories.ap().split_flex_ext().filter_signal("jcs").spss(); % Optional arg value between angles. Default 10.
spss.print_to_file(root);
%%
spm = trajectories.ap().split_flex_ext().filter_signal("jcs").spm();
%%
dunn = spm.dunnet('UKA_w_ACL');
dunn.Data.jcs_digitised.Native.ant.flexion.plot()
hold on;
dunn.Data.jcs_digitised.Native.pos.flexion.plot()
%%
spm.jcs_digitised.ant.posterior.plot();
spm.jcs_digitised.ant.posterior.plot_p_values();
spm.jcs_digitised.ant.posterior.plot_threshold_label();

spm.jcs_digitised.pos.posterior.plot();
hold on;
plot(spm_bs.jcs_digitised.ant.posterior.z, 'r');
plot(spm_bs.jcs_digitised.pos.posterior.z, 'r');
%%
% trajectories.plot_tibia();

%%
[ap_flex, ap_ext] = trajectories ...
    .ap() ...
    .filter_signal("jcs") ...
    .exclude_specimen("3")...
    .split_flex_ext();
ap_flex.print_to_file(root);
%% Neutral Path

trajectories...
    .path()...
    .filter_signal("jcs")...
    .average()...
    .split_flex_ext()...
    .print_to_file(root)...
    .plot("posterior");

%% Stability Envelopes
[ap_flex, ap_ext] = trajectories ...
    .ap() ...
    .filter_signal("jcs") ...
    .average() ...
    .split_flex_ext();
ap_flex.print_to_file(root);
ap_flex.plot("posterior");

trajectories ...
    .ie()...
    .filter_signal("jcs")...
    .average()...
    .split_flex_ext()...
    .plot("internal_rotation");