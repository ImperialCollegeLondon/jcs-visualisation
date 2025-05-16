function structure = nest_struct(keys, value)
    if isscalar(keys)
        structure.(keys{1}) = value;
    else
        structure.(keys{1}) = nest_struct(keys(2:end), value);
    end
end