function obj = print_to_file(obj, path)
    % % Prepare the folders
    fp_results = fullfile(path, "results", "average", "neutral_path");
    states = obj.States;
    signals = obj.Signals;
    for st = 1:numel(states)
        state = states(st);
        for sg = 1:numel(signals)
            signal = signals(sg);

            filepath = fullfile(fp_results, signal);
            mkdir(filepath);

            datum = obj.Data.(state).(signal);
            headers = datum.mean.Properties.VariableNames;

            t_mean = datum.mean;
            t_std = datum.std;

            t_mean.Properties.VariableNames = headers + "_mean";
            t_std.Properties.VariableNames = headers + "_std";


            writetable([t_mean t_std], strcat(fullfile(filepath, state), '.csv'));
        end
    end
end

