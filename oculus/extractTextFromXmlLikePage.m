function txt = extractTextFromXmlLikePage(filename)
% Extract text from XPS page XML by looking for UnicodeString fields.

    raw = fileread(filename);

    % Common XPS text storage
    unicodeMatches = regexp(raw, 'UnicodeString="([^"]*)"', 'tokens');
    if isempty(unicodeMatches)
        txt = '';
        return;
    end

    pieces = cellfun(@(c) xpsDecode(c{1}), unicodeMatches, 'UniformOutput', false);
    txt = strjoin(pieces, ' ');
    txt = normalizeWhitespace(txt);
end