function ColorTrackingLocalHook
%  ColorTrackingLocalHook
%
% Configure things for working on the ColorTracking project.
%
% For use with the ToolboxToolbox, but you can also just run
% this to set your preferences for the ColorTracking project,
% after editing to match your machine's configuration.
%
% If you 'git clone' ColorTracking into your ToolboxToolbox "projectRoot"
% folder, then run in MATLAB
%   tbUseProject('ColorTracking')
% ToolboxToolbox will set up ColorTracking and its dependencies on
% your machine.
% 
% As part of the setup process, ToolboxToolbox will copy this file to your
% ToolboxToolbox localToolboxHooks directory (minus the "Template" suffix).
% The defalt location for this would be
%   ~/localToolboxHooks/ColorTrackingLocalHook.m
%
% Each time you run tbUseProject('ColorTracking'), ToolboxToolbox will
% execute your local copy of this file to do setup for ColorTracking.
%
% You should edit your local copy with values that are correct for your
% local machine, for example the output directory location.

%% Say hello.
fprintf('ColorTracking local hook.\n');
projectName = 'ColorTracking';

%% Delete any old prefs
if (ispref(projectName))
    rmpref(projectName);
end

%% Specify base paths for materials and data.
%
% The switch statement below allows definition of
% user/machine specific directory locations. You may
% not have all the routines that are called to make
% this work, but in the end all you need to do is
% make sure the locations are set correctly for your
% machine.
[~, userID] = system('whoami');
userID = strtrim(userID);
cmpInfo = psyComputerInfo;

% Define the base dir for everything in the project. In the
% brainard lab, this starts at the lab dropbox tree, and the
% code below finds that on any Mac OS machine.  You can
% hardcode baseDir to be something else on your machine, if you
% want.  And, you don't really even need it as long as you get
% the locations set below to be apprpriate for your machine.
switch userID  
    otherwise
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

% Set 'dropboxPath' preference to the top level directory where files will be
% stored.  In our lab, it is inside of dropbox so we always begin
% by pointing to that.  But there is nothing magic about having
% it available under dropbox.
setpref(projectName,'dropboxPath',baseDir);

% Calibration files for the experimental apparatus.
CalFolder = fullfile(getpref(projectName,'dropboxPath'),'CNST_materials','ColorTracking','calData');

% Summarized data and analysis output (mostly figures) go under the
% analysis directory.  Specify it.
CNST_analysis = fullfile(getpref(projectName,'dropboxPath'),'CNST_analysis','ColorTrackingTask');

% Cached summarized data end up here, despite the fact that the name might
% make you think it is only cached parameters.
paramsCacheFolder     = fullfile(CNST_analysis,'dataCache','paramsCache');

% Cached boostraps of the data go here.
bootParamsCacheFolder = fullfile(CNST_analysis,'dataCache','bootParamsCache');

% Raw data live here.  These raw data are available from the authors.
rawDataDir = fullfile(baseDir,'CNSC_data','ColorTrackingTask','PaperData');

% Figures come out here.
figureSavePath = fullfile(CNST_analysis, 'outputFigures');

% Set the actual preferences according to locations defined above.
setpref(projectName,'paramsCacheFolder',paramsCacheFolder);
setpref(projectName,'bootParamsCacheFolder',bootParamsCacheFolder);
setpref(projectName,'figureSavePath',figureSavePath);
setpref(projectName,'CalDataFolder',CalFolder);
setpref(projectName,'CalFolder',CalFolder);
setpref(projectName,'rawDataDir',rawDataDir);

% This line makes the Brainard lab calibration routines save their output
% to the right place for this project.
setpref('BrainardLabToolbox','CalDataFolder',CalFolder);

% If we're running experiments, it must be a Linux box and you
% need PTB on your path.
if ismac
    % We're happy to analyze on a Mac.
elseif isunix
    fprintf('To run the experiments, make sure PTB is on your path\n');
elseif ispc
    % Code to run on Windows platform
    warning('No supported for PC')
else
    disp('What kind of computer are you using?')
end
