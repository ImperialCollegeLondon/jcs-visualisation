classdef PathAverage
    properties
        Specimens
        States
        Directions
        Signals
        Data
    end
    methods % Static
        function obj = PathAverage(paths)
            states = paths.States;
            signals = paths.Signals;
            for st = 1:numel(states)
                state = states(st);
                data = [paths.Data.(state).Data];
                for sg = 1:numel(signals)
                    signal = signals(sg);
                    
                    tables = {data.(signal)};
                    tables = cellfun(@table2array, tables, "UniformOutput", false);
                    stacked = cat(3, tables{:});
                    avg = mean(stacked, 3);
                    stdev = std(stacked, 0, 3);

                    headers = data(1).(signal).Properties.VariableNames;

                    obj.Data.(state).(signal).mean = array2table(avg, "VariableNames", headers);
                    obj.Data.(state).(signal).std = array2table(stdev, "VariableNames", headers);
                end
            end
            obj.Directions = paths.Directions;
            obj.Signals = paths.Signals;
            obj.States = paths.States;
        end
    end

    methods
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

        function [flex, ext] = split_flex_ext(obj)
            directions = obj.Directions;
            states = obj.States;
            signals = obj.Signals;

            flex = obj;
            ext = obj;

            for st = 1:numel(states)
                state = states(st);
                for sg = 1:numel(signals)
                    signal = signals(sg);
                    datum = obj.Data.(state).(signal);
                    n = round(height(datum.mean)/2);

                    flex.Data.(state).(signal).mean = datum.mean(1:n, :);
                    flex.Data.(state).(signal).std = datum.std(1:n, :);
                    ext.Data.(state).(signal).mean = datum.mean(n:end, :);
                    ext.Data.(state).(signal).std = datum.std(n:end, :);
                end
            end
        end

        function plots = plot(obj, orientations)
            signals = obj.Signals;
            states = obj.States;
            colours = lines(numel(states));

            for sg = 1:numel(signals)
                signal = signals(sg);
                figure(sg); 
                for s = 1:numel(states)
                    
                    state = states(s);
                    colour = colours(s, :);

                    if ~nargin > 1
                    orientations = obj.Data.(state).(signal).mean.Properties.VariableNames;
                    orientations = setdiff(orientations, 'flexion');
                    end
                    for o = 1:numel(orientations)
                        nexttile(o); hold on;
                        x = obj.Data.(state).(signal).mean.flexion;
                        y = obj.Data.(state).(signal).mean.(orientations{o});
                        p = plot(x, y, 'Color', colour);


                        idx = 1:10+2*s:numel(x);
                        y_std = obj.Data.(state).(signal).std.(orientations{o});
                        errorbar(x(idx), y(idx), y_std(idx), 'LineStyle', 'none', 'Color', colour*0.7);


                        grid on;
                        axis square;
                        xlabel("Flexion angle");
                        ylabel(replace(orientations{o}, '_', ' '));
                    end
                    plots(s) = p;
                end
                sgtitle(replace(signal, '_', ' '));
                legend(plots, state_regex_inv(states));

            end
        end
    end
end