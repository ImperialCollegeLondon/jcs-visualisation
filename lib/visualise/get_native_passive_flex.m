function native_passive_flex = get_native_passive_flex(specimen, native_name, passive_flex_name)
    sp_states = fieldnames(specimen);
    is_native = sp_states == native_name;
    native = specimen.(sp_states{is_native});
    is_passive_flex = [native.loading_condition] == passive_flex_name;
    native_passive_flex = native(is_passive_flex);
end