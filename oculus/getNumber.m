function val = getNumber(txt, pattern)
    tok = regexp(txt, pattern, 'tokens', 'once');
    if isempty(tok)
        val = [];
    else
        val = str2double(tok{1});
    end
end
