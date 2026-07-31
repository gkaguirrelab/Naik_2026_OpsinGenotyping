function cleanupTempDir(tempDir)
    if exist(tempDir, 'dir')
        try
            rmdir(tempDir, 's');
        catch
        end
    end
end
