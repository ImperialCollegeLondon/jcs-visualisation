function data_struct = serialise(path)
    file_lines = strip(string(fileread(path)));
    file_lines = splitlines(file_lines);
    file_lines = file_lines(~strcmp(file_lines, ""));
    % Initialize variables
    data_struct = struct();
    current_header = '';
    
    % Parse file
    for i = 1:numel(file_lines)
        line = file_lines(i);
        %% Define header
        if startsWith(line, '[') && endsWith(line, ']')
            current_header = matlab.lang.makeValidName(extractBetween(line, '[', ']'));
            data_struct.(current_header) = struct();
            continue
        end
        %% Tokenise 
        tokens = split(line, '=', 2);
        tokens = [tokens(1), tokens(2:end).join('')];
        key = strip(tokens(1));
        value = parse_value(tokens(2));

        keys = split(key, {'.', ' - '});

        if contains(keys{end}, "size")
            continue
        end

        %% Group similar keys.
        % Channel Names [0-n] grouped as a string array.
        % last_digit_is_num = is_last_word_num(keys);
        if ~(contains(key, '.') || contains(key, '-'))
            handle_grouped_key()
            continue
        end

        %% Groups composite names
        % "Collected Point Names - Rigid Body [1, 2]" get grouped together into
        % its components strings under the struct Collected Point Names
        if is_last_word_num(keys)
            handle_composite_key()
            continue
        end

        if isscalar(keys)
            keys = clean_key(keys);
            key = keys;
            data_struct.(current_header).(key) = value;
            continue
        end

        %% First occurence that requires nesting
        % (Data Description Parameters).Category nests
        % `Category` into the `Data Description Parameters` struct
        key_parent = keys(1).split();
        key_parent_last = str2double(key_parent(end));
        last_digit_is_num = ~isnan(key_parent_last(end));
        if last_digit_is_num
            handle_nesting()
            continue
        end

        keys_clean = clean_key(keys);
        nest = nest_struct(keys_clean, value);
        if ~isfield(data_struct.(current_header), keys_clean(1))
            data_struct.(current_header).(keys_clean(1)) = nest.(keys_clean(1));
            continue
        end
        %% Second occurence of nesting
        % i.e. found `Data Description Parameters` struct,
        % and needs to add the field `Source`.
        data_struct.(current_header).(keys_clean(1)) = merge_structs(data_struct.(current_header).(keys_clean(1)), nest.(keys_clean(1)));
    end

    
    function handle_grouped_key()
        keys_numeric_end = cellfun(@split, keys, 'UniformOutput', false);
        keys_last_word = str2double(keys_numeric_end{end});
        last_digit_is_num = ~isnan(keys_last_word(end));
    
        if last_digit_is_num
            key = string(keys_numeric_end{:});
            key = key(1:end-1).join(" ");
            key = clean_key(key);
    
            if isfield(data_struct.(current_header), key)
                data_struct.(current_header).(key)(end+1) = value;
            else
                data_struct.(current_header).(key)(1) = value;
            end
            return
        end
        %% Key is a simple string, e.g. Version
        data_struct.(current_header).(clean_key(key)) = value;
    end
    function handle_composite_key()
        key_str = [];
        for ii = 1:numel(keys)
            k = split(keys(ii), ".");
            k = k(~contains(k, "size"));
            key_str = [key_str k];
        end
        nested_key = key_str(end).split();
        nested_key = nested_key(1:end-1).join(" ");
        keys = [clean_key(key_str(1:end-1)) clean_key(nested_key)];
        nest = nest_struct(keys, value);
        if ~isfield(data_struct.(current_header), keys(1))
            % Creates the first entry
            data_struct.(current_header).(keys(1)) = nest.(keys(1));
            return
        end

        % Combine the second key into an array (e.g. Rigid Body 1)
        if isfield(data_struct.(current_header).(keys(1)), keys(2))
            data_struct.(current_header).(keys(1)).(keys(2)) = ...
                [data_struct.(current_header).(keys(1)).(keys(2)), value];
        else
            data_struct.(current_header).(keys(1)).(keys(2)) = value;
        end
    end
    function handle_nesting()
        keys(1) = key_parent(1:end-1).join(" ");
        num = str2double(key_parent(end)) + 1;
        keys_clean = clean_key(keys);
        nest = nest_struct(keys_clean, value);
        if ~isfield(data_struct.(current_header), keys_clean(1))
            data_struct.(current_header).(keys_clean(1))(num) = nest.(keys_clean(1));
            return
        end
        try
            merged = merge_structs(data_struct.(current_header).(keys_clean(1))(num), nest.(keys_clean(1)));
            data_struct.(current_header).(keys_clean(1))(num) = merged;
        catch
            data_struct.(current_header).(keys_clean(1))(num).(keys_clean(2)) = nest.(keys_clean(1)).(keys_clean(2));
        end
    end
end

function is_num = is_last_word_num(keys)
    last_word = cellfun(@split, keys, 'UniformOutput', false);
    last_word_num = str2double(last_word{end});
    is_num = ~isnan(last_word_num(end));
end

            