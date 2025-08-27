classdef Trajectory < handle
    properties
        SpecimenName
        SpecimenState
        LoadingCondition
        Data struct = struct()
    end
    properties (Access = private)
        IsOptimised
    end

    methods % Constructor
        function obj = Trajectory(name, state, loading_condition)
            obj.SpecimenState = string(state);
            obj.SpecimenName = string(name);
            obj.LoadingCondition = string(loading_condition);
        end
    end

    methods
        function obj = add_data(obj, label, data)
            obj.Data.(label) = data;
        end
        function path = path(obj, label)
            contains_label = contains([obj.LoadingCondition], label, 'IgnoreCase', true);
            if ~any(contains_label)
                path = Option.None;
                return;
            end

            paths = obj(contains_label);
            names = unique([paths.SpecimenName]);
            states = unique([paths.SpecimenState]);

            path = Option(Path(paths, names, states));
        end


        function envelope = stability_envelope(obj, envelopes, native, neutral)
            arguments
                obj
                envelopes
                native = "Native"
                neutral = "Neutral"
            end

            % names = unique([obj.SpecimenName]);
            states = unique([obj.SpecimenState]);

            is_native = contains([obj.SpecimenState], native, "IgnoreCase", true);
            native = obj(is_native);
            is_passive_flex = contains([native.LoadingCondition], neutral, "IgnoreCase", true);
            native_passive_flex = native(is_passive_flex);

            if isempty(native_passive_flex)
                error("Native Neutral flexion was not detected")
            end

            envelope = Envelope(obj, envelopes, native_passive_flex, states);
        end
    end

    % Convenience functions
    methods
        function envelope = ap(obj, name_native, name_neutral_flexion)
            if nargin > 1
                envelope = obj.stability_envelope(["ant", "pos"], name_native, name_neutral_flexion);
            else
                envelope = obj.stability_envelope(["ant", "pos"]);
            end
        end

        function envelope = vv(obj, name_native, name_neutral_flexion)
            if nargin > 1
                envelope = obj.stability_envelope(["var", "val"], name_native, name_neutral_flexion);
            else
                envelope = obj.stability_envelope(["var", "val"]);
            end
        end

        function envelope = ie(obj, name_native, name_neutral_flexion)
            if nargin > 1
                envelope = obj.stability_envelope(["int", "ext"], name_native, name_neutral_flexion);
            else
                envelope = obj.stability_envelope(["int", "ext"]);
            end
        end
    end
end

