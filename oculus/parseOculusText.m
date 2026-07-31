function fields = parseOculusText(txt)
% Parse anomaloscope text block into structured fields.

    if isempty(txt)
        fields = struct();
        return;
    end

    txt = normalizeWhitespace(txt);

    fields = struct();

    fields.patient           = getToken(txt, 'Patient:\s*(.*?)\s*(?:Date of birth:|Age:|Program:)', 1);
    fields.dateOfBirth       = getToken(txt, 'Date of birth:\s*([0-9/.-]+)', 1);
    fields.age               = getNumber(txt, 'Age:\s*([0-9]+)');
    fields.program           = getToken(txt, 'Program:\s*(.*?)\s*(?:Result:|Eye:)', 1);
    fields.resultType        = getToken(txt, 'Result:\s*(.*?)\s*(?:Eye:|Date of exam\.:)', 1);
    fields.eye               = getToken(txt, 'Eye:\s*(.*?)\s*(?:Date of exam\.:|Matching range:)', 1);
    fields.examDate          = getToken(txt, 'Date of exam\.\s*:\s*(.*?)\s*(?:Matching range:|Duration:)', 1);
    fields.matchingRangeType = getToken(txt, 'Matching range:\s*(.*?)\s*(?:Duration:|Anomaly quotient AQ:)', 1);
    fields.duration          = getToken(txt, 'Duration:\s*([0-9:]+)', 1);

    % AQ range — the instrument reports ∞ (char 8734) when range extends to infinity
    infPat = char(8734);
    aq = regexp(txt, ['Anomaly quotient AQ:\s*([0-9.]+|' infPat ')\s*to\s*([0-9.]+|' infPat ')'], 'tokens', 'once');
    if ~isempty(aq)
        fields.AQ_low  = aqVal(aq{1});
        fields.AQ_high = aqVal(aq{2});
    else
        fields.AQ_low  = [];
        fields.AQ_high = [];
    end

    % Mixing light range
    ml = regexp(txt, 'Matching range Mixing light:\s*([0-9.]+)\s*to\s*([0-9.]+)', 'tokens', 'once');
    if ~isempty(ml)
        fields.mixingLight_low  = str2double(ml{1});
        fields.mixingLight_high = str2double(ml{2});
    else
        fields.mixingLight_low  = [];
        fields.mixingLight_high = [];
    end

    % Reference light range
    rl = regexp(txt, 'Reference light:\s*([0-9.]+)\s*to\s*([0-9.]+)', 'tokens', 'once');
    if ~isempty(rl)
        fields.referenceLight_low  = str2double(rl{1});
        fields.referenceLight_high = str2double(rl{2});
    else
        fields.referenceLight_low  = [];
        fields.referenceLight_high = [];
    end

    fields.assessment = getToken(txt, 'Assessment\s*(.*?)\s*(?:Comment|$)', 1);

    % Optional numeric summaries
    if ~isempty(fields.mixingLight_low) && ~isempty(fields.mixingLight_high)
        fields.mixingLight_span = fields.mixingLight_high - fields.mixingLight_low;
    else
        fields.mixingLight_span = [];
    end

    if ~isempty(fields.referenceLight_low) && ~isempty(fields.referenceLight_high)
        fields.referenceLight_span = fields.referenceLight_high - fields.referenceLight_low;
    else
        fields.referenceLight_span = [];
    end
end

function v = aqVal(s)
    if strcmp(s, char(8734))
        v = Inf;
    else
        v = str2double(s);
    end
end
