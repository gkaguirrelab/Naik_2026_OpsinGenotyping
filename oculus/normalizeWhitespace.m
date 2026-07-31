function s = normalizeWhitespace(s)
    s = regexprep(s, '\r\n|\r|\n', ' ');
    s = regexprep(s, '\s+', ' ');
    s = strtrim(s);
end
