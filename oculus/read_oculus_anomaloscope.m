function result = read_oculus_anomaloscope(pdfFile, xpsFile)
% READ_OCULUS_ANOMALOSCOPE
% Extract measurement values from Oculus anomaloscope PDF and XPS files.
%
% Usage:
%   result = read_oculus_anomaloscope('MELA_3003_1.pdf', 'MELA_3003_1.xps');
%
% If your file was renamed to .xml but is really XPS, pass that filename anyway.
%
% Expected output (maybe)
% result.combined = 
% 
%   struct with fields:
% 
%               patient: 'MELA_3003, MELA_3003'
%           dateOfBirth: '1/1/1995'
%                   age: 24
%               program: 'Deuteranopia'
%            resultType: 'Red/Green color vision'
%                   eye: 'Right'
%              examDate: '6/28/2019 10:45 AM'
%     matchingRangeType: 'Absolute'
%              duration: '01:09'
%                AQ_low: 29.7000
%               AQ_high: 0.1400
%       mixingLight_low: 2.9000
%      mixingLight_high: 65.6000
%    referenceLight_low: 14.6000
%   referenceLight_high: 14.6000
%            assessment: 'Not possible'
%      mixingLight_span: 62.7000
%    referenceLight_span: 0

    result = struct();
    result.pdf = struct();
    result.xps = struct();
    result.combined = struct();

    %% ---- Read PDF text ----
    if exist(pdfFile, 'file')
        try
            pdfText = extractFileText(pdfFile);
            result.pdf.rawText = pdfText;
            result.pdf.fields = parseOculusText(pdfText);
        catch ME
            warning('Could not read PDF: %s', ME.message);
            result.pdf.rawText = '';
            result.pdf.fields = struct();
        end
    else
        warning('PDF file not found: %s', pdfFile);
        result.pdf.rawText = '';
        result.pdf.fields = struct();
    end

    %% ---- Read XPS text ----
    if exist(xpsFile, 'file')
        try
            xpsText = extractTextFromXpsLikeFile(xpsFile);
            result.xps.rawText = xpsText;
            result.xps.fields = parseOculusText(xpsText);
        catch ME
            warning('Could not read XPS-like file: %s', ME.message);
            result.xps.rawText = '';
            result.xps.fields = struct();
        end
    else
        warning('XPS file not found: %s', xpsFile);
        result.xps.rawText = '';
        result.xps.fields = struct();
    end

    %% ---- Combine: prefer PDF, fill missing from XPS ----
    result.combined = mergeStructs(result.xps.fields, result.pdf.fields);

    disp('Extracted fields:');
    disp(result.combined);
end