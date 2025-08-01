function plot_average_neutral_path(all_runs, jcss)
is_neutral = contains([all_runs.loading_condition], 'neutral', 'IgnoreCase', true);
neutral_path = all_runs(is_neutral);
specimen_names = unique([neutral_path.specimen]);
specimen_states = unique([neutral_path.state]);
colours = lines(numel(specimen_states));


for ss = 1:numel(specimen_states)
    specimen_state = specimen_states(ss);
    is_current_state = [neutral_path.state] == specimen_state;
    current_state = neutral_path(is_current_state);

    fieldnames = fields(current_state);

    for f = 1:numel(fieldnames)
        fieldname = fieldnames{f};
        field_vals = {current_state.(fieldname)};
        if ~any(cellfun(@istable, field_vals))
            continue
        end

        cellfun()
        field_vals
    end

    for sn = 1:numel(specimen_names)
    % figure(sn)
    legend_text = "";
    
    current_specimen = neutral_path([neutral_path.specimen] == specimen_names(sn));

    
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