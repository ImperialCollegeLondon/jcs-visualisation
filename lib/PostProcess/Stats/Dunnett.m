classdef Dunnett < PostHoc
    properties
        States
        Control
        PCritical
        Data
    end
    properties % From PostHoc
        Significance
    end
    methods
        function obj = Dunnett(spm, control, p_critical)
            signals = spm.signals;
            directions = spm.directions;
            specimens = spm.specimens;
            states = spm.states;

            for sg = 1:numel(signals)
                signal = signals(sg);
                for d = 1:numel(directions)
                    direction = directions(d);
                    x = spm.data.(specimens(1)).(states(1)).(direction).(signal);
                    val = nan(height(x), numel(specimens), width(x));
                    data = struct();
                    for st = 1:numel(states)
                        state = states(st);
                        for sp = 1:numel(specimens)
                            specimen = specimens(sp);
                            datum = spm.data.(specimen).(state).(direction).(signal);
                            val(:, sp, :) = table2array(datum);
                        end
                        data.(state) = val;
                    end

                    headers = x.Properties.VariableNames;
                    for st = 1:numel(states)
                        state = states(st);
                        is_control = state == control;
                        if is_control, continue, end

                        is_significant = table();
                        for h = 1:numel(headers)
                            header = headers{h};
                            current = data.(state)(:,:, h)';
                            control_spcm = data.(control)(:,:,h)';

                            spm_t = spm1d.stats.ttest2(current, control_spcm);
                            inference = spm_t.inference(p_critical, 'two_tailed', true);
                            obj.Data.(signal).(state).(direction).(header) = inference;
                            is_significant.(header) = (inference.z > inference.zstar)';
                        end
                        obj.Significance.(signal).(state).(direction) = is_significant;
                    end
                end
            end

            obj.States = states;
            obj.Control = control;
            obj.PCritical = p_critical;
        end

        function o = is_significant(obj)
            o = obj.Significance;
        end
    end




end
