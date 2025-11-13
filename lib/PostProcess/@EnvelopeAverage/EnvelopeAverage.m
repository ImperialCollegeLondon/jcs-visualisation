classdef EnvelopeAverage
    properties
        Data
        States
        Directions
        Signals
    end
    methods
        function obj = EnvelopeAverage(envelopes)
            specimens = envelopes.specimens;
            directions = envelopes.directions;
            states = envelopes.states;
            signals = envelopes.signals;

            for d = 1:numel(directions)
                direction = directions(d);
                for st = 1:numel(states)
                    state = states(st);

                    % signals = fieldnames(envelopes.Data.(specimens(1)).(state).(direction));
                    for sg = 1:numel(signals)
                        signal = signals{sg};
                        all_tables = cell(1, numel(specimens));
                        for sp = 1:numel(specimens)
                            specimen = specimens(sp);

                            all_tables{sp} = envelopes.Data.(specimen).(state).(direction).(signal);
                        end
                        headers = all_tables{1}.Properties.VariableNames;
                        tables = cellfun(@table2array, all_tables, "UniformOutput", false);
                        stacked = cat(3, tables{:});
                        avg = mean(stacked, 3);
                        stdev = std(stacked, 0, 3);

                        obj.Data.(state).(signal).(direction).mean = array2table(avg, "VariableNames", headers);
                        obj.Data.(state).(signal).(direction).std = array2table(stdev, "VariableNames", headers);
                    end
                end
            end
            obj.States = states;
            obj.Directions = directions;
            obj.Signals = string(signals);
        end
    end
end





