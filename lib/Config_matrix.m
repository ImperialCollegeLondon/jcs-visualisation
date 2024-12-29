function matrix = config_matrix(file_path, target_string)
    % Open the file for reading
    fileID = fopen(file_path, 'r');

    if fileID == -1
        error('Failed to open the file.');
    end

    % Initialize variables
    line_number = 0;
    found_line = '';
    string_found = false;

    % Read the file line by line and search for the target string at the start of the line
    while ~feof(fileID)
        line = fgetl(fileID);
        line_number = line_number + 1;

        % Check if the target string is at the start of the line
        if strncmp(line, target_string, length(target_string))
            % fprintf('Found "%s" at the start of line %d: %s\n', target_string, line_number, line);
            found_line = strrep(line, target_string, '');  % Remove the target string
            string_found = true;
            break;  % Stop reading the file when the target string is found at the start of the line
        end
    end

    % Close the file
    fclose(fileID);

    % Check if the line was found or not
    if string_found

        % Split the found line into numeric values and convert into a 4x4 matrix
        values = regexp(found_line, '[" ]', 'split');

        if strcmp(values(end-1), 'Right')
            matrix = true;
            return
        elseif strcmp(values(end-1), 'Left')
            matrix = false;
            return
        end

        % Remove empty strings and convert to numeric values
        values = str2double(values(~cellfun('isempty', values)));

        % Remove NaN values from the 'values' array
        values = values(~isnan(values));

        % Check if there are numerical values in the line
        if ~isempty(values) && numel(values) == 16
            matrix = reshape(values, 4, 4)';
            % disp('4x4 Matrix:');
            % disp(matrix);
        elseif ~isempty(values) && numel(values) == 6
            matrix=values';
            % disp('Position offsets (medial,posterior,superior,flexion,valgus,internal rotation):');
            % disp(matrix);
        elseif ~isempty(values) && numel(values) == 18
            matrix=values(1:6);
            % disp('Femoral epicondyles');
            % disp(matrix);
        else
            % fprintf('The line does not contain 16 valid numeric values.\n');
            matrix = [];  % Return an empty matrix if the conditions are not met
        end
    else
        % fprintf('Line not found: "%s" was not found at the start of any line in the file.\n', target_string);
        matrix = [];  % Return an empty matrix if the target string is not found at the start of any line
    end
end
