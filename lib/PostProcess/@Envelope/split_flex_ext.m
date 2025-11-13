function [flex, ext] = split_flex_ext(obj)
    directions = obj.directions;
    states = obj.states;
    specimens = obj.specimens;
    obj.SpecimenName = specimens;
    flex = obj;
    ext = obj;

    for d = 1:numel(directions)
        direction = directions(d);
        for st = 1:numel(states)
            state = states(st);

            for sp = 1:numel(specimens)
                specimen = specimens(sp);
                signals = fieldnames(obj.Data.(specimen).(state).(direction));
                for sg = 1:numel(signals)
                    signal = signals{sg};
                    datum = obj.Data.(specimen).(state).(direction).(signal);
                    n = round(height(datum)/2);
                    flex.Data.(specimen).(state).(direction).(signal) = datum(1:n, :);
                    ext.Data.(specimen).(state).(direction).(signal) = datum(n:end, :);
                end
            end
        end
    end

end
