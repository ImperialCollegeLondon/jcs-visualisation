function envelope = stability_envelope(obj, envelopes, native, neutral)
    arguments
        obj
        envelopes
        native = "Native"
        neutral = "Neutral"
    end

    % names = unique([obj.SpecimenName]);
    states = unique([obj.SpecimenState]);

    is_native = contains([obj.SpecimenState], native, "IgnoreCase", true);
    native = obj(is_native);
    is_passive_flex = contains([native.LoadingCondition], neutral, "IgnoreCase", true);
    native_passive_flex = native(is_passive_flex);

    if isempty(native_passive_flex)
        error("Native Neutral flexion was not detected")
    end

    envelope = Envelope(obj, envelopes, native_passive_flex, states);
end
