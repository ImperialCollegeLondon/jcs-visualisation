function [c,m,h,gnames] = split_into_stats_struct(data)
    fields = fieldnames(data);
    for f = 1:numel(fields)
        field_data = data.(fields{f});
        is_data(f) = istable(field_data);
        is_property(f) = ~istable(field_data) && ~isnumeric(field_data);
    end

    field_properties = fields(is_property);
    field_data = fields(is_data);
    for fd = 1:numel(field_data)
        
        for n = 1:size(data, 2)
            data_all_rows = data(:, n);
            current_angle = table;
            for k = 1:numel(data_all_rows)
                new_row = table;
                datum = data_all_rows(k, :);
                field_datum = field_data{fd};
                for f = 1:numel(field_properties)
                    new_row.(field_properties{f}) = categorical(datum.(field_properties{f}));
                end
                new_row = [new_row, datum.(field_datum)];
                current_angle(k,:) = new_row;
            end

            for fp = 1:numel(field_properties)
                groups{fp} = [data_all_rows.(field_properties{fp})]';
            end

            groups = cellfun(@(x) replace(x, '_w_', '+'), groups, 'UniformOutput', false);
            groups = cellfun(@(x) replace(x, '_wo_', '-'), groups, 'UniformOutput', false);
            properties = current_angle.Properties.VariableNames;
            for p = 1:numel(properties)
                c_field = properties{p};
                dat = current_angle.(properties{p});
                if isnumeric(dat)
                    [pval, tbl, sts, terms] = anovan(dat, groups, 'varnames', field_properties, 'display', 'off');
                    [c(n).(field_data{fd}).(c_field), m(n).(field_data{fd}).(c_field), h(n).(field_data{fd}).(c_field), gnames] = multcompare(sts, 'Display','off');
                    title(replace(c_field, '_', ' '))
                end
            end
           
        end
    end
end