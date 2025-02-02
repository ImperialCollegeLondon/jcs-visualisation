classdef Option
    properties
        is_some
        value
    end
    methods(Static)
        function none = None()
            none = Option();
        end
        function some = Some(val)
            some = Option(val);
        end
    end
    methods
        function r = and_then(obj, func)
            obj = obj(~obj.is_none);
            if obj.is_none
                r = Option.None;
                return
            end
            val = {obj.value};
            r = cellfun(func, val, "UniformOutput", false);
            r = r(cellfun(@(x) x.is_some, r));
            if isscalar(r)
                r = r{:};
            end
            if isempty(r)
                r = Option.None();
            end
        end
        function r = expect(obj, msg)
            if obj.is_none
                error(msg)
            end
            r = {obj.value};
            if isscalar(r)
                r = r{:};
            end
        end
        function r = unwrap(obj)
            r = obj.expect("Called unwrap() on None");
        end
        % function r = unwrap_or(obj, default)
        %     % None
        %     none = obj.is_none;
        %     r = obj;
        %     if any(none)
        %         disp("x");
        %     end
        %     r(none) = default;
        %     r = r.unwrap();
        %     % if obj.is_none
        %     %     r = default;
        %     %     return
        %     % end
        %     % % Some
        %     % r = obj.value;
        % end
        function r = is_none(obj)
            some = [obj.is_some];
            val = {obj.value};
            r = ~some & cellfun(@isempty, val);

            % r = ~obj.is_some && isempty(obj.value);
        end
        function r = map(obj, func)
            obj = obj(~obj.is_none);
            if isempty(obj)
                r = Option.None();
                return;
            end
            val = {obj.value};
            r = Option(cellfun(func, val, "UniformOutput", false));
            if isscalar(r.value)
                r.value = r.value{:};
            end
            obj = r;
        end
        function r = filter_map(obj, func)
            if obj.is_none
                r = Option.None;
                return
            end
            obj = obj(~obj.is_none);
            val = {obj.value};
            r = cellfun(@(x) func(x), val, "UniformOutput", false);
            if isscalar(r)
                r = r{:};
            end
            r = r.value;
        end
        function obj = Option(val)
            if nargin == 0 || isempty(val)
                obj.is_some = false;
                obj.value = [];
            else
                obj.is_some = true;
                obj.value = val;
            end
        end
    end
end