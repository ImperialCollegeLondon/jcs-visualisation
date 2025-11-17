function [flex, ext] = split_flex_ext(obj)
    directions = obj.Directions;
    states = obj.States;
    signals = obj.Signals;
    specimens = obj.Specimens;
    flex = obj;
    ext = obj;

    flex.Data = [];
    ext.Data = [];

    for sp = 1:numel(specimens)
        specimen = specimens(sp);
        for st = 1:numel(states)
            state = states(st);
            is_specimen = [obj.Data.(state).SpecimenName] == specimen;

            for sg = 1:numel(signals)
                signal = signals(sg);
                data = [obj.Data.(state).Data];
                try
                    datum = data(is_specimen).(signal);
                catch
                    keyboard
                end
                n = round(height(datum)/2);

                flex.Data.(specimen).(state).(signal) = datum(1:n, :);
                ext.Data.(specimen).(state).(signal) = datum(n:end, :);
            end
        end
    end
end
