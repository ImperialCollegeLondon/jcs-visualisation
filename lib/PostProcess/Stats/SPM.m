classdef SPM
    properties
        inference
        within_subject
        between_subject
    end
    properties(Access = private)
        States
        Specimens
        Directions
        Signals
        Data
    end

    methods
        function obj = SPM(states, directions, specimens, signals, data)

            for sg = 1:numel(signals)
                signal = signals(sg);
                for d = 1:numel(directions)
                    direction = directions(d);
                    i = 1;
                    x = data.(specimens(1)).(states(1)).(direction).(signal);
                    val = nan(height(x), numel(specimens) * numel(states), width(x));

                    state_list = nan(numel(specimens) * numel(states), 1);
                    specimen_list = nan(numel(specimens) * numel(states), 1);
                    for st = 1:numel(states)
                        state = states(st);
                        for sp = 1:numel(specimens)
                            specimen = specimens(sp);
                            datum = data.(specimen).(state).(direction).(signal);
                            val(:, i, :) = table2array(datum);
                            state_list(i) = st-1;
                            specimen_list(i) = sp-1;
                            i = i + 1;
                        end
                    end

                    headers = datum.Properties.VariableNames;
                    for h = 1:numel(headers)
                        header = headers{h};
                        obj.between_subject.(signal).(direction).(header) = spm1d.stats.anova1(val(:, :, h)', state_list);
                        spm = spm1d.stats.anova1rm(val(:, :, h)', state_list, specimen_list);
                        % spm = spm1d.stats.anova1(val(:, :, h)', state_list);
                        obj.within_subject = spm;
                        obj.inference.(signal).(direction).(header) = spm.inference(0.05);
                    end
                end
            end

            obj.States = states;
            obj.Specimens = specimens;
            obj.Directions = directions;
            obj.Signals = signals;
            obj.Data = data;
        end


        function o = dunnett(obj, control)
            if nargin < 2
                error("Missing control group. options: %s", strjoin(obj.States, ', '))
            end
            if ~ismember(control, obj.States)
                error("Not a valid control. options: %s", strjoin(obj.States, ', '))
            end

            alpha = 0.05;
            n_tests = numel(obj.States) - 1;

            p_critical = spm1d.util.p_corrected_bonf(alpha, n_tests);


            o = Dunnett(obj, control, p_critical);
        end

        function o = states(obj)
            o = obj.States;
        end

        function o = specimens(obj)
            o = obj.Specimens;
        end

        function o = directions(obj)
            o = obj.Directions;
        end

        function o = signals(obj)
            o = obj.Signals;
        end

        function o = data(obj)
            o = obj.Data;
        end


    end
end
