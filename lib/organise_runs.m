function specimens = organise_runs(all_runs)
states = unique([all_runs.state]);
specimen_names = unique([all_runs.specimen]);
for st = 1:numel(states)
    for sp = 1:numel(specimen_names)
        knee_state = states(st);
        specimen_name = specimen_names(sp);
        
        mask_state = strcmp([all_runs.state], states(st)) & strcmp([all_runs.specimen], specimen_name);
        specimens(sp).name = specimen_name;
        datum = rmfield(all_runs(mask_state), ["specimen", "state"]);
        if ~isempty(datum)
            specimens(sp).(knee_state) = datum;
        end
    end
end

end