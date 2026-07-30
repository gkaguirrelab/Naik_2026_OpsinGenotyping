function s = normalizeWhitespace(s)
    s = regexprep(s, '\r\n|\r|\n', ' ');
    s = regexprep(s, '\s+', ' ');
    s = strtrim(s);
end

function val = getToken(txt, pattern, tokenIdx)
    tok = regexp(txt, pattern, 'tokens', 'once');
    if isempty(tok)
        val = '';
    else
        val = strtrim(tok{tokenIdx});
    end
end

function val = getNumber(txt, pattern)
    tok = regexp(txt, pattern, 'tokens', 'once');
    if isempty(tok)
        val = [];
    else
        val = str2double(tok{1});
    end
end

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

function s = xpsDecode(s)
% Decode common XML entities and XPS escaped forms.
    s = strrep(s, '&amp;', '&');
    s = strrep(s, '&quot;', '"');
    s = strrep(s, '&lt;', '<');
    s = strrep(s, '&gt;', '>');
    s = strrep(s, '&#x0D;', ' ');
    s = strrep(s, '&#x0A;', ' ');
    s = strrep(s, '&#10;', ' ');
    s = strrep(s, '&#13;', ' ');
end

function cleanupTempDir(tempDir)
    if exist(tempDir, 'dir')
        try
            rmdir(tempDir, 's');
        catch
        end
    end
end