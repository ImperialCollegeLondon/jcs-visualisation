function path = path(obj)
    names = unique([obj.SpecimenName]);
    states = unique([obj.SpecimenState]);
    directions = unique([obj.LoadingCondition]);

    path = Path(obj, names, states, directions);
end
