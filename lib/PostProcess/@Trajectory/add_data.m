function obj = add_data(obj, label, data)
    headers = data.Properties.VariableNames;
    if ~any(contains(headers, 'flexion'))
        error("Data table must contain field 'flexion'.")
    end
    obj.Data.(label) = data;
end
