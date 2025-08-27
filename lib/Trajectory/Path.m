classdef Path
    properties
        Paths
        Names
        States
    end
    methods
        function obj = Path(neutral_paths, names, states)
            obj.Paths = neutral_paths;
            obj.Names = names;
            obj.States = states;
        end
        function vplot = plot(obj)
        end
    end
end
