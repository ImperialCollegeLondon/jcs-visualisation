% find_indices.m
function indices = find_indices(signal, values)
    indices = arrayfun(@(val) max(find(abs(signal - val) == min(abs(signal - val)))), values);
end
