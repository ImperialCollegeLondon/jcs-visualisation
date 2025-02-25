function parsed_value = parse_value(value)
    value = strtrim(strrep(value, '"', ''));
    parsed_value = value;
    if contains(value, "size")
        sizes = extractBetween(value, "size(s)", ">");
        sizes = str2double(split(sizes));
        if any(sizes == 0)
            parsed_value = [];
            return
        end
        text = split(regexprep(value, '<.*> ', ''));
        parsed_value = str2double(text);
        parsed_value = reshape(parsed_value, sizes(1), []);
        parsed_value = parsed_value';
        return;
    end
    if contains(value, ".000") && ~contains(value, "size")
        parsed_value = str2double(value);
        return
    end
    
    if strcmpi(value, "true")
        parsed_value = true;
    elseif strcmpi(value, "false")
        parsed_value = false;
    end
end