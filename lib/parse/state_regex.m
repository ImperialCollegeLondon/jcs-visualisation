function O = state_regex(I)
    O = replace(I, '+', '_w_');
    O = replace(O, '-', '_wo_');
end
