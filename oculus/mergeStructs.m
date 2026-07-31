function out = mergeStructs(a, b)
% Fields in b override a when nonempty.
    out = a;
    if isempty(fieldnames(a))
        out = b;
        return;
    end
    fb = fieldnames(b);
    for i = 1:numel(fb)
        name = fb{i};
        val = b.(name);
        if ~isempty(val) && ~(ischar(val) && isempty(strtrim(val)))
            out.(name) = val;
        elseif ~isfield(out, name)
            out.(name) = val;
        end
    end
end
