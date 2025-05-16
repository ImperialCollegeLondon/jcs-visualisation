function O = state_regex(I)
    I = replace(I, '+', '_w_');
    O = replace(I, '-', '_wo_');
end