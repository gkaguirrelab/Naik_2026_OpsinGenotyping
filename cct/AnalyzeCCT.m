% Analyze the CCT-T and CCT-E data for subjects in the Naik et al. paper.

% Initialize
clear; close all;

% Set project name
theProject = 'Naik_2026_OpsinGenotyping';

% Data locations
CCTTdir = getpref(theProject,'ccttDir');
CCTEdir = getpref(theProject,'ccteDir');
inputDir = getpref(theProject,'inputDir');

% Output locations.  Assumes program being run from diretory containing it.
baseDir = pwd;
outputDir = getpref(theProject,'outputDir');
if (~exist(outputDir,'dir'))
    mkdir(outputDir);
end
outputFile = 'PhenotypeSummary.xlsx';

% Subjects
subjectTableName = 'UPenn_ID_conversion_log.xlsx';
subjectTable = readtable(fullfile(inputDir,subjectTableName),ReadVariableNames=false);

% Loop over subjects
outputData = struct;
for ss = 1:size(subjectTable,1)
    outputData(ss).pennSubject = subjectTable.Var1{ss};
    outputData(ss).nihSubject = subjectTable.Var2{ss};
    fprintf('Analyzing CCT for subject %s/%s\n',outputData(ss).pennSubject,outputData(ss).nihSubject);

    % CCTT
    dataDir = fullfile(CCTTdir,['Subject_' outputData(ss).pennSubject]);
    theDatafiles = dir(fullfile(dataDir,[outputData(ss).pennSubject '_*.txt']));
    if (length(theDatafiles)) == 0
        fprintf('\tNo CCT-T data files for subject %s\n',outputData(ss).pennSubject);
        outputData(ss).protanCCTTScore = -1;
        outputData(ss).deutanCCTTScore = -1;
        outputData(ss).tritanCCTTScore = -1;
        outputData(ss).nCCTTScores = 0;
        utputData(ss).CCTTRGdefectStr = 'NO_CCTT_AVAIL';
    else
        for ff = 1:length(theDatafiles)
            fprintf('\tReading CCT-T data file %s\n',theDatafiles(ff).name);
            fid = fopen(fullfile(dataDir,theDatafiles(ff).name),'rt');
            raw = fread(fid, '*char')';
            fclose(fid);

            pat = '\t([-\d.eE]+)\t([-\d.eE]+)\t\w+\s*=\s*([-\d.eE]+)';
            tok = regexp(raw, pat, 'tokens');

            if numel(tok) ~= 3
                error('Expected 3 data rows, found %d in %s', numel(tok), fname);
            end

            % We think the following about these data:
            %   Multipling lengths from file by 1000 gives the trivector score.
            %   Azimuth (angles) 0.07 = protan, 5.98 = deutan, 4.83 = tritan.
            %   Normal color vision assessed with Cambridge Color Test (< 10 protan, < 10 deutan, and < 15 tritan).
            data    = cellfun(@(c) str2double(c), vertcat(tok{:}));
            lengths = data(:,1)*1000;
            stds = data(:,2);
            angles  = data(:,3);
            rawProtanCCTTScores(ff) = lengths(abs(angles-0.07) < 1e-3);
            rawDeutanCCTTScores(ff) = lengths(abs(angles-5.98) < 1e-3);
            rawTritanCCTTScores(ff) = lengths(abs(angles-4.83) < 1e-3);
        end
        outputData(ss).protanCCTTScore = mean(rawProtanCCTTScores);
        outputData(ss).deutanCCTTScore = mean(rawDeutanCCTTScores);
        outputData(ss).tritanCCTTScore = mean(rawTritanCCTTScores);
        outputData(ss).nCCTTScores = length(theDatafiles);
        fprintf('\tCCT-T (%d files), Protan: %0.1f, Deutan: %0.1f, Tritan: %0.1f\n',outputData(ss).nCCTTScores,outputData(ss).protanCCTTScore,outputData(ss).deutanCCTTScore,outputData(ss).tritanCCTTScore );
        if (outputData(ss).protanCCTTScore > 10 & outputData(ss).deutanCCTTScore > 10)
            fprintf('\tCCT-T indicates a PROTAN_DEUTAN defect\n');
            outputData(ss).CCTTRGdefectStr = 'PROTAN_DEUTAN';
        elseif (outputData(ss).protanCCTTScore > 10)
            fprintf('\tCCT-T indicates a PROTAN defect\n');
            outputData(ss).CCTTRGdefectStr = 'PROTAN';
        elseif (outputData(ss).deutanCCTTScore > 10)
            fprintf('\tCCT-T indicates a DEUTAN defect\n');
            outputData(ss).CCTTRGdefectStr = 'DEUTAN';
        else
            fprintf('\tCCT-T indicates RG_NORMAL\n');
            outputData(ss).CCTTRGdefectStr = 'RG_NORMAL';
        end
    end

    % CCTE
    dataDir = fullfile(CCTEdir,['Subject_' outputData(ss).pennSubject]);
    theDatafiles = dir(fullfile(dataDir,[outputData(ss).pennSubject '_*.txt']));
    if (length(theDatafiles)) == 0
        fprintf('\tNo CCT-E data files for subject %s\n',outputData(ss).pennSubject);
    else
        for ff = 1:length(theDatafiles)
            fprintf('\tReading CCT-E data file %s\n',theDatafiles(ff).name);
            [h,u_prime,v_prime,fitArea,fitMajorAxisLength,fitMajorAxisAngleDegs,fitMajorMinorAxisRatio] = ...
                CCTplot(fullfile(dataDir,theDatafiles(ff).name));
            title(['CCT-E ' outputData(ss).pennSubject]);

            fprintf('\tMajor/minor axis ratio of fit ellipse: %0.1f\n',fitMajorMinorAxisRatio);
            fprintf('\tMajor axis diameter: %0.1f * 10^-5\n',fitMajorAxisLength*10^5);
            fprintf('\tArea: %0.1f * 10^-6\n',fitArea*10^6)
        end
    end
end

% Make and write output summary table
T = struct2table(outputData);
writetable(T,fullfile(outputDir,outputFile));