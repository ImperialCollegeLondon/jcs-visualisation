classdef PathAverage
    properties
        Specimens
        States
        Directions
        Signals
        Data
    end
    methods 
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
end
