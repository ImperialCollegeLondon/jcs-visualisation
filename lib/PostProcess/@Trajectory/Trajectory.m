classdef Trajectory < handle
    properties
        SpecimenName
        SpecimenState
        LoadingCondition
        IsOptimised
        IsRightKnee
        Transform
        Data struct = struct()
    end

    methods 
        function obj = Trajectory(name, state, loading_condition, is_optimised, is_right_knee)
            obj.SpecimenState = string(state);
            % warning("Removing the letter a from all tests. if you see this, you probably want to remove this.")
            obj.SpecimenName = replace(string(name), 'a', '');
            obj.LoadingCondition = string(loading_condition);
            obj.IsOptimised = is_optimised;
            obj.IsRightKnee = is_right_knee;
        end

        function out = states(obj)
            out = [obj.SpecimenState];
        end
    end

    % Convenience functions
    methods
        function out = signals(obj)
            out = string(fields(obj(1).Data));
        end
        function out = specimen(obj, arg)
            if nargin > 1
                obj.SpecimenName = arg;
                out = obj;
            else
                out = [obj.SpecimenName];
            end
        end
        function out = state(obj, arg)
            if nargin > 1
                obj.SpecimenState = arg;
                out = obj;
            else
                out = [obj.SpecimenState];
            end
        end
        function out = loading_condition(obj, arg)
            if nargin > 1
                obj.LoadingCondition = arg;
                out = obj;
            else
                out = [obj.LoadingCondition];
            end
        end
        function out = is_optimised(obj, arg)
            if nargin > 1
                obj.IsOptimised = arg;
                out = obj;
            else
                out = [obj.IsOptimised];
            end
        end

        function envelope = create_ap_envelope(obj, name_native, name_neutral_flexion)
            if nargin > 1
                envelope = obj.stability_envelope(["ant", "pos"], name_native, name_neutral_flexion);
            else
                envelope = obj.stability_envelope(["ant", "pos"]);
            end
        end

        function envelope = create_vv_envelope(obj, name_native, name_neutral_flexion)
            if nargin > 1
                envelope = obj.stability_envelope(["var", "val"], name_native, name_neutral_flexion);
            else
                envelope = obj.stability_envelope(["var", "val"]);
            end
        end

        function envelope = create_ie_envelope(obj, name_native, name_neutral_flexion)
            if nargin > 1
                envelope = obj.stability_envelope(["int", "ext"], name_native, name_neutral_flexion);
            else
                envelope = obj.stability_envelope(["int", "ext"]);
            end
        end

        % Needs to be made considerably more ergonomic
        function o = flip_ie(obj, specimen, state, loading_condition, signal_in)

            is_specimen = contains([obj.SpecimenName], specimen, "IgnoreCase", true);
            is_state = contains([obj.SpecimenState], state, "IgnoreCase", true);
            is_lc = contains([obj.LoadingCondition], loading_condition, "IgnoreCase", true);
            mask = is_specimen & is_state & is_lc;

            data = [obj.Data];
            signals = fieldnames(data);
            is_field = contains(signals, signal_in, "IgnoreCase", true);
            signals_valid = signals(is_field);
            for f = 1:numel(signals_valid)
                signal = signals_valid{f};
                datum = data(mask).(signal);
                datum.internal_rotation = -datum.internal_rotation;
                obj(mask).Data.(signal) = datum;
            end
            
            o = obj;
            
        end
    end
end

