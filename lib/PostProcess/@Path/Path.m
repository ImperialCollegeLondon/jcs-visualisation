classdef Path
    properties
        Specimens
        States
        Directions
        Data
        Signals
    end

    methods
        function obj = Path(data, names, states, directions)
            obj.Specimens = names;
            obj.States = setdiff(unique(states), ["UKA_w_pACL", "Unoptimised"]);
            obj.Directions = directions;
            obj.Signals = string(fieldnames([data.Data]));

            is_neutral = contains([data.LoadingCondition], "neutral", "IgnoreCase", true);
            for st = 1:numel(states)
                state = states(st);
                is_state = [data.SpecimenState] == state;
                obj.Data.(state) = data(is_state & is_neutral);
            end
        end
        function o = average(obj)
            o = PathAverage(obj);
        end
        function o = filter_signal(obj, signal)
            obj.Signals = obj.Signals(contains(obj.Signals, signal));
            o = obj;
        end
        function o = exclude_specimen(obj, specimen)
            o = obj;
            mask = contains(o.Specimens, specimen, "IgnoreCase", true);
            o.Specimens = o.Specimens(~mask);
        end

        function o = exclude_specimen_exact(obj, specimen)
            o = obj;
            specimens_remaining = setdiff(o.Specimens, specimen);
            o.Specimens = specimens_remaining;
        end

    end
end

