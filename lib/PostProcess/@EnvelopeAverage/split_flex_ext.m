function [flex, ext] = split_flex_ext(obj)
directions = obj.Directions;
states = obj.States;
signals = obj.Signals;

flex = obj;
ext = obj;

for d = 1:numel(directions)
    direction = directions(d);
    for st = 1:numel(states)
        state = states(st);

        for sg = 1:numel(signals)
            signal = signals(sg);
            datum = obj.Data.(state).(signal).(direction);
            headers = fieldnames(datum);

            for h = 1:numel(headers)
                header = headers{h};
                n = round(height(datum.(header))/2);
                flex.Data.(state).(signal).(direction).(header) = datum.(header)(1:n, :);
                ext.Data.(state).(signal).(direction).(header) = datum.(header)(n:end, :);
            end
        end
    end
end
end
