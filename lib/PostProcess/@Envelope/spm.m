function spm = spm(obj)
    states = obj.states;
    directions = obj.directions;
    specimens = obj.specimens;
    signals = obj.signals;
    data = obj.Data;
    spm = SPM(states, directions, specimens, signals, data);
end
