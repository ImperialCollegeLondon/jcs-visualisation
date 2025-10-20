classdef Trajectory < handle
    properties
        SpecimenName
        SpecimenState
        LoadingCondition
        IsOptimised
        Transform
        Data struct = struct()
    end
    properties (Access = private)
    %     IsOptimised
    end

    methods % Constructor
        function obj = Trajectory(name, state, loading_condition, is_optimised)
            obj.SpecimenState = string(state);
            obj.SpecimenName = replace(string(name), 'a', '');
            obj.LoadingCondition = string(loading_condition);
            obj.IsOptimised = is_optimised;
        end
    end

    methods
        function plot_tibia(obj)

            
            range = 1:10:90;
            scale = 1;
            is_neutral = contains([obj.LoadingCondition], "neutral", "IgnoreCase", true);
            is_native = contains([obj.SpecimenState], ["native", "uka_w_acl"], "IgnoreCase", true);
            is_native_neutral = is_neutral & is_native;

            filtered = obj(is_native_neutral);
            specimens = unique([filtered.SpecimenName]);
            states = unique([filtered.SpecimenState]);

            colours = lines(numel(states));
            for sp = 1:numel(specimens)
                figure; hold on;
                specimen = specimens(sp);
                for st = 1:numel(states)
                    state = states(st);
                    mask = [filtered.SpecimenName] == specimen & [filtered.SpecimenState] == state;
                    transforms = filtered(mask).Transform;
                    for t = 1:numel(transforms)
                        headers = fields(transforms(t));
                        for h = 1:numel(headers)
                            header = headers{h};

                            tTf = transforms.(header);
                            origins = squeeze(tTf(1:2, 4, :));
                            fTfx = [1; 0; 0; 1]; % Epicondylar axis in femur == x axis.
                            tTfx = squeeze(pagemtimes(tTf, fTfx)); %Epicondylar axis in tibial frame of reference;

                            x0 = origins(1, range);
                            y0 = origins(2, range);
                            u = tTfx(1, range);
                            v = tTfx(2, range);

                            x1 = x0 + scale * u;
                            y1 = y0 + scale * v;

                            X = [x0; x1];
                            Y = [y0; y1];

                            plot(X, Y, 'Color', colours(st, :), 'LineWidth',1.5);
                            text(x1, y1, string(range-1));
                            xlabel('x'); ylabel('y');
                            title([specimen; 'Epicondylar axis projected on tibial plateau'])
                        end
                    end
                end
            end
        end
        function obj = add_data(obj, label, data)
            headers = data.Properties.VariableNames;
            if ~any(contains(headers, 'flexion'))
                error("Data table must contain field 'flexion'.")
            end
            obj.Data.(label) = data;
        end
        function obj = add_transforms(obj, label, transforms)
            obj.Transform.(label) = transforms;
        end

        function path = path(obj)
            names = unique([obj.SpecimenName]);
            states = unique([obj.SpecimenState]);
            directions = unique([obj.LoadingCondition]);

            path = Path(obj, names, states, directions);
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

