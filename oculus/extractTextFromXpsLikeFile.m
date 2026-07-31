function txt = extractTextFromXpsLikeFile(xpsFile)
% Extract text from an XPS file (or a file renamed from .xps).
% XPS is a ZIP archive containing XML-like FixedPage markup.

    tempDir = tempname;
    mkdir(tempDir);

    cleanupObj = onCleanup(@() cleanupTempDir(tempDir));

    % MATLAB's unzip is more reliable with a .zip extension
    zipFile = fullfile(tempDir, 'archive.zip');
    copyfile(xpsFile, zipFile);
    extractDir = fullfile(tempDir, 'extracted');
    mkdir(extractDir);
    unzip(zipFile, extractDir);

    % Find FixedPage fdoc/fpage XML files
    pageFiles = [ ...
        dir(fullfile(extractDir, '**', '*.fpage')); ...
        dir(fullfile(extractDir, '**', '*.xml')) ];

    txtParts = {};

    for k = 1:numel(pageFiles)
        f = fullfile(pageFiles(k).folder, pageFiles(k).name);
        try
            pageTxt = extractTextFromXmlLikePage(f);
            if ~isempty(strtrim(pageTxt))
                txtParts{end+1} = pageTxt; %#ok<AGROW>
            end
        catch
            % skip unreadable files
        end
    end

    txt = strjoin(txtParts, newline);

    % Fallback: if no structured extraction worked, read all xml-like files as text
    if isempty(strtrim(txt))
        txt = fallbackReadAllXmlText(extractDir);
    end
end