function txt = fallbackReadAllXmlText(rootDir)
    files = dir(fullfile(rootDir, '**', '*.*'));
    parts = {};

    for k = 1:numel(files)
        if files(k).isdir
            continue;
        end

        [~,~,ext] = fileparts(files(k).name);
        if ~ismember(lower(ext), {'.xml','.fpage','.fdseq','.rels'})
            continue;
        end

        f = fullfile(files(k).folder, files(k).name);
        try
            raw = fileread(f);
            parts{end+1} = raw; %#ok<AGROW>
        catch
        end
    end

    txt = strjoin(parts, newline);
    txt = regexprep(txt, '<[^>]+>', ' ');
    txt = normalizeWhitespace(txt);
end