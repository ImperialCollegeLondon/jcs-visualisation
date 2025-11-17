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
