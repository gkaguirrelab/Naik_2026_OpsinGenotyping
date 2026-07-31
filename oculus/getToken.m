function val = getToken(txt, pattern, tokenIdx)
    tok = regexp(txt, pattern, 'tokens', 'once');
    if isempty(tok)
        val = '';
    else
        val = strtrim(tok{tokenIdx});
    end
end
