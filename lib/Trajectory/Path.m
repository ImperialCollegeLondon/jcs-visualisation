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
    end

    methods

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

        function plots = plot(obj)
            signals = obj.Signals;
            states = obj.States;
            colours = lines(numel(states));
            specimens = obj.Specimens;
            for sp = 1:numel(specimens)
                specimen = specimens(sp);
                for sg = 1:numel(signals)
                    signal = signals(sg);
                    figure;
                    for s = 1:numel(states)

                        state = states(s);
                        colour = colours(s, :);

                        orientations = obj.Data.(specimen).(state).(signal).Properties.VariableNames;
                        orientations = setdiff(orientations, 'flexion');
                        for o = 1:numel(orientations)
                            nexttile(o); hold on;
                            x = obj.Data.(specimen).(state).(signal).flexion;
                            y = obj.Data.(specimen).(state).(signal).(orientations{o});
                            plots(sp, s) = plot(x, y, 'Color', colour);

                            grid on;
                            axis square;
                            xlabel("Flexion angle");
                            ylabel(replace(orientations{o}, '_', ' '));
                        end
                    end
                    sgtitle([specimen replace(signal, '_', ' ')]);
                    legend(plots(sp, :), state_regex_inv(states));

                end
            end
        end
    end


end


function plot_neutral_path(all_runs, jcss)
is_neutral = contains([all_runs.loading_condition], 'neutral', 'IgnoreCase', true);
neutral_path = all_runs(is_neutral);
specimen_names = unique([neutral_path.specimen]);
specimen_states = unique([neutral_path.state]);
colours = lines(numel(specimen_states));

for sn = 1:numel(specimen_names)
    % figure(sn)
    legend_text = "";
    
    current_specimen = neutral_path([neutral_path.specimen] == specimen_names(sn));

    for ss = 1:numel(specimen_states)
        current_state = current_specimen([current_specimen.state] == specimen_states(ss));
        opt_jcs = {current_state.(jcss)};
        
        colour = colours(ss, :);
        legend_text(end+1) = specimen_states(ss); 
        for oj = 1:numel(opt_jcs)

            datum = opt_jcs{oj};
            flex = datum.Properties.VariableNames{strcmpi(datum.Properties.VariableNames, 'Flexion')};


            fieldnames = setdiff(datum.Properties.VariableNames, flex);
            for f = 1:numel(fieldnames)
                hold on;
                nexttile(f)
                fname = fieldnames{f};
                [x_arrowed, y_arrowed] = arrowed_line(datum.(flex), datum.(fname), 10, 100, 100);
                h = plot(x_arrowed, y_arrowed, 'Color', colour);
                xlabel("Flexion")
                ylabel(replace(fname, '_', ' '))
                grid on;

                if oj == 1 && f == 1
                    legend_handles(sn, ss) = h;
                end
            end
        end
    end
    sgtitle([specimen_names(sn) replace(jcss, '_', ' ')]);
    
    is_line = arrayfun(@(x) isa(x, 'matlab.graphics.chart.primitive.Line'), legend_handles(sn, :));
    current_legends = legend_handles(sn, :);
    legend_lines = current_legends(is_line);

    legend_text = legend_text(~(legend_text == ""));
    legend_text = state_regex_inv(legend_text);

    
    legend_text = legend_text(is_line);
    legend(legend_lines, legend_text)
end
end