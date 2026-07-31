function Naik_2026_OpsinGenotypingLocalHook
% Naik_2026_OpsinGenotypingLocalHook
%
% Configure things for working on the Naik_2026_OpsinGenotyping project.
%
% For use with the ToolboxToolbox.  If you copy this into your
% ToolboxToolbox localToolboxHooks directory (by defalut,
% ~/localToolboxHooks) and delete "LocalHooksTemplate" from the filename,
% this will get run when you execute tbUseProject('Naik_2026_OpsinGenotyping') to set up for
% this project.  You then edit your local copy to match your configuration.
%
% You will need to edit the project location and i/o directory locations
% to match what is true on your computer.

%% Say hello
theProject = 'Naik_2026_OpsinGenotyping';

%% Remove old preferences
if (ispref(theProject))
    rmpref(theProject);
end

%% Put project toolbox onto path
%
% Specify project name and location
projectName = theProject;
projectBaseDir = tbLocateProject(theProject);

if (exist('GetComputerInfo','file'))
    sysInfo = GetComputerInfo();
    switch (sysInfo.localHostName)
 
        otherwise
            % Some unspecified machine, try user specific customization
            switch(sysInfo.userShortName)
                % Could put user specific things in, but at the moment generic
                % is good enough.
                otherwise
                    % Some unspecified machine, try our generic approach,
                    % which works on a mac to find the dropbox for business
                    % path.
                    if ismac
                        dbJsonConfigFile = '~/.dropbox/info.json';
                        fid = fopen(dbJsonConfigFile);
                        raw = fread(fid,inf);
                        str = char(raw');
                        fclose(fid);
                        val = jsondecode(str);
                        baseDir = val.business.path;
                    end
            end
    end
end

%% Set preferences for project i/o
%
% This is where the psychophysical data are stored
ccttDir = fullfile(projectBaseDir,'data','Exp_CCTT');
ccteDir = fullfile(projectBaseDir,'data','Exp_CCTE');
%anomDir = fullfile(projectBaseDir,'data','Exp_Anomaloscope');
anomDir = fullfile(baseDir,'MTRP_data','Exp_Anomaloscope');

% This is where the input spreadsheet lives
inputDir = fullfile(projectBaseDir,'input');

% This is where the output goes
outputDir = fullfile(projectBaseDir,'output');

% Set the preferences
setpref(theProject,'ccttDir',ccttDir);
setpref(theProject,'ccteDir',ccteDir);
setpref(theProject,'anomDir',anomDir);
setpref(theProject,'inputDir',inputDir);
setpref(theProject,'outputDir',outputDir);
