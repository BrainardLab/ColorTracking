function ColorTrackingLocalHook
%  ColorTrackingLocalHook
%
% Configure things for working on the  ColorTracking project.
%
% For use with the ToolboxToolbox.
%
% If you 'git clone' ColorTracking into your ToolboxToolbox "projectRoot"
% folder, then run in MATLAB
%   tbUseProject('ColorTracking')
% ToolboxToolbox will set up ColorTracking and its dependencies on
% your machine.
%crossValCacheFolder
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
%


%% Say hello.
fprintf('ColorTracking local hook.\n');
projectName = 'ColorTracking';

%% Delete any old prefs
if (ispref(projectName))
    rmpref(projectName);
end

%% Specify base paths for materials and data
[~, userID] = system('whoami');
userID = strtrim(userID);
cmpInfo = psyComputerInfo;
switch userID
    case {'brainardlab'}
        dropboxPath = fullfile('/home',userID,'labDropbox');
        CNST_analysis = fullfile(dropboxPath,'CNST_analysis','ColorTrackingTask');
        setpref(projectName,'dropboxPath',dropboxPath);
        CalFolder = fullfile(getpref(projectName,'dropboxPath'),'CNST_materials','ColorTrackingTask','calData');
        paramsCacheFolder     = fullfile(CNST_analysis,'dataCache','paramsCache');
        bootParamsCacheFolder = fullfile(CNST_analysis,'dataCache','bootParamsCache');
        crossValCacheFolder = fullfile(CNST_analysis,'dataCache','crossVal');
        figureSavePath = fullfile(CNST_analysis, 'Results');

    case{'micalan'}
        dropboxPath = fullfile('/home',userID,'labDropbox');
        CNST_analysis = fullfile(dropboxPath,'CNST_analysis','ColorTrackingTask');
        setpref(projectName,'dropboxPath',dropboxPath);
        CalFolder = fullfile(getpref(projectName,'dropboxPath'),'CNST_materials','ColorTrackingTask','calData');
        paramsCacheFolder     = fullfile(CNST_analysis,'dataCache','paramsCache');
        bootParamsCacheFolder = fullfile(CNST_analysis,'dataCache','bootParamsCache');
        crossValCacheFolder = fullfile(CNST_analysis,'dataCache','crossVal');
        figureSavePath = fullfile(CNST_analysis, 'Results');
    case{'michael'}
        dropboxPath = fullfile('/Users',userID,'labDropbox');
        CNST_analysis = fullfile(dropboxPath,'CNST_analysis','ColorTrackingTask');
        setpref(projectName,'dropboxPath',dropboxPath);
        CalFolder = fullfile(getpref(projectName,'dropboxPath'),'CNST_materials','ColorTrackingTask','calData');
        paramsCacheFolder     = fullfile(CNST_analysis,'dataCache','paramsCache');
        bootParamsCacheFolder = fullfile(CNST_analysis,'dataCache','bootParamsCache');
        crossValCacheFolder = fullfile(CNST_analysis,'dataCache','crossVal');
        figureSavePath = fullfile(CNST_analysis, 'Results');
    case{'jburge-hubel'}
        setpref(projectName,'dropboxPath',[]);
        CalFolder = fullfile('/Users','Shared','Matlab','BurgeLabCalibrationData');
        paramsCacheFolder     = '';
        bootParamsCacheFolder = '';
    case{'dhb'}
        if strcmp(cmpInfo.localHostName,'Davids-iMac')
            setpref(projectName,'dropboxPath',['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)']);
        else
            setpref(projectName,'dropboxPath',fullfile(['/Volumes/Users1/Dropbox (Aguirre-Brainard Lab)']));
        end
        CalFolder = fullfile(getpref(projectName,'dropboxPath'),'CNST_materials','ColorTrackingTask','calData');

        CNST_analysis = fullfile(getpref(projectName,'dropboxPath'),'CNST_analysis','ColorTrackingTask');
        paramsCacheFolder     = fullfile(CNST_analysis,'dataCache','paramsCache');
        bootParamsCacheFolder = fullfile(CNST_analysis,'dataCache','bootParamsCache');
        crossValCacheFolder = fullfile(CNST_analysis,'dataCache','crossVal');
        figureSavePath = fullfile(CNST_analysis, 'Results');

    otherwise
        setpref(projectName,'dropboxPath',['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)']);
        CalFolder = fullfile(getpref(projectName,'dropboxPath'),'CNST_materials','ColorTracking','calData');
        CNST_analysis = fullfile(getpref(projectName,'dropboxPath'),crossValCacheFolder,'CNST_analysis','ColorTracking');
        paramsCacheFolder     = fullfile(CNST_analysis,'dataCache','paramsCache');
        bootParamsCacheFolder = fullfile(CNST_analysis,'dataCache','bootParamsCache');
        figureSavePath = fullfile(CNST_analysis, 'Results');

end

setpref(projectName,'paramsCacheFolder',paramsCacheFolder);
setpref(projectName,'bootParamsCacheFolder',bootParamsCacheFolder);
setpref(projectName,'crossValCacheFolder',crossValCacheFolder);
setpref(projectName,'figureSavePath',figureSavePath);
setpref(projectName,'CalDataFolder',CalFolder);
setpref(projectName,'CalFolder',CalFolder)
setpref('BrainardLabToolbox','CalDataFolder',CalFolder);

if ismac
    % Code to run on Mac plaform
    %setpref(projectName,'');
elseif isunix
    fprintf('*** ADDING Psychtoolbox-3 ***')
    %addpath(genpath('/usr/share/psychtoolbox-3/'));
elseif ispc
    % Code to run on Windows platform
    warning('No supported for PC')
else
    disp('What are you using?')
end
