function CorticalColorMappingLocalHook
%  LFContrastAnalsysisLocalHook
%
% Configure things for working on the  LFContrastAnalysis project.
%
% For use with the ToolboxToolbox.
%
% If you 'git clone' ILFContrastAnalsysis into your ToolboxToolbox "projectRoot"
% folder, then run in MATLAB
%   tbUseProject('LFContrastAnalysis')
% ToolboxToolbox will set up IBIOColorDetect and its dependencies on
% your machine.
%
% As part of the setup process, ToolboxToolbox will copy this file to your
% ToolboxToolbox localToolboxHooks directory (minus the "Template" suffix).
% The defalt location for this would be
%   ~/localToolboxHooks/LFContrastAnalsysisLocalHook.m
%
% Each time you run tbUseProject('LFContrastAnalysis'), ToolboxToolbox will
% execute your local copy of this file to do setup for LFContrastAnalsysis.
%
% You should edit your local copy with values that are correct for your
% local machine, for example the output directory location.
%


%% Say hello.
fprintf('CorticalColorMapping local hook.\n');
projectName = 'CorticalColorMapping';

%% Delete any old prefs
if (ispref(projectName))
    rmpref(projectName);
end

%% Specify base paths for materials and data
[~, userID] = system('whoami');
userID = strtrim(userID);
switch userID
    case {'brainardlab'}
        CalFolder = fullfile('/home',userID, 'labDropbox','CNST_materials','ColorTracking','calData');
    case{'michael'}
        CalFolder = fullfile('Users',userID, 'labDropbox','CNST_materials','ColorTracking','calData');
    otherwise
end

setpref(projectName,'CalFolder',CalFolder) 

if ismac
    % Code to run on Mac plaform
    setpref(projectName,'');
elseif isunix
    fprintf('*** ADDING Psychtoolbox-3 ***')
    %addpath(genpath('/usr/share/psychtoolbox-3/'));
elseif ispc
    % Code to run on Windows platform
    warning('No supported for PC')
else
    disp('What are you using?')
end
