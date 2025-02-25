function result = merge_structs(s1, s2)
    result = s1;
    fields = fieldnames(s2);
    for i = 1:numel(fields)
        field = fields{i};
        if ~isfield(s1, field)
            result.(field) = s2.(field);
        elseif isstruct(s1.(field)) && isstruct(s2.(field))
            result.(field) = merge_structs(s1.(field), s2.(field));
        else
            result.(field) = s2.(field);
    end
end