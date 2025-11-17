function obj = print_to_file(obj, path)
    % % Prepare the folders
    fp_results = fullfile(path, "results", "per_specimen", "stability_envelope");
    states = obj.states;
    signals = obj.signals;
    directions = obj.directions;
    specimens = obj.specimens;
    for sp = 1:numel(specimens)
        specimen = specimens(sp);
        for st = 1:numel(states)
            state = states(st);
            for sg = 1:numel(signals)
                signal = signals(sg);

                filepath = fullfile(fp_results, signal, state, specimen);
                mkdir(filepath);
                for d = 1:numel(directions)
                    direction = directions(d);

                    datum = obj.Data.(specimen).(state).(direction).(signal);

                    writetable(datum, strcat(fullfile(filepath, direction), '.csv'));
                end
            end
        end
    end
end
