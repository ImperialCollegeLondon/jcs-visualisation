function keep = is_flexion_arc(data, threshold)
    fields = fieldnames(data);
    keep = false(size(data));
    % Remove sections that aren't a full flexion arc
    for i = 1:numel(data)
        for j = 1:numel(fields)
            T = data(i).(fields{j});
            if istable(T) && height(T) > threshold
                keep(i) = true;
                break
            end
        end
    end
end
