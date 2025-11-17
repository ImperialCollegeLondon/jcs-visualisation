function o = filter_envelope(obj, envelope)
    error("Not yet implemented");
    mask = contains(obj.Directions, envelope, "IgnoreCase", true);
    if ~any(mask)
        o = [];
        return
    end

    o = obj;
    o.Envelopes = obj.Directions(mask);

    for s = 1:numel(o.States)
        state = o.States(s);
        env = fieldnames(o.Data.(state));
        to_remove = setdiff(env, obj.Directions(mask));
        o.Data.(state) = rmfield(obj.Data.(state), to_remove);
    end
end
