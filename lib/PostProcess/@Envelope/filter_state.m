function o = filter_state(obj, state)
    error("Not yet implemented");
    mask = strcmpi(obj.States, state);
    o = obj(mask, :);
end
