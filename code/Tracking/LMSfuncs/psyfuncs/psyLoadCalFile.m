function [cal, cals, fullFilename] = psyLoadCalFile(filespec, whichCal, dir)

% function [cal, cals, fullFilename] = psyLoadCalFile([filespec], [whichCal], [dir])
%
%   example call: fdir = ['/Users/Shared/Matlab/BurgeLabCalibrationData/'];
%                 psyLoadCalFile('ProPixx_Calib.mat', [whichCal], [dir])
%
% adapted from LoadCalFile in /Applications/Psychtoolbox/PsychCal/LoadCalFile.m
%
% Loads calibration data from saved file in the CalData folder.
% Will search one level deep in the CalData folder if the 
% file does not exist at the top level, but skips subdirs
% called 'xOld', 'Plots', and those that begin with '.'.
%
% If no argument is given, loads from file default.mat.  If
% an integer N is passed, loads from file screenN.mat.  If
% a string S is given, loads from S.mat.  You can pass the
% trailing .mat as well and it will still work.
%
% If whichCal is specified, the whichCal'th calibration
% in the file is returned.  If whichCal > nCals, an
% empty calibration is returned.  whichCal defaults
% to the most recent calibration.
%
% If the specified file cannot be found, returns empty matrix.
%
% The returned variable cal is a structure containing calibration 
% information.
%
% The returned cell array cals contains all of the calibrations
% stored in the file
%
% The returned string fullFilename is the full path to the calibration
% file.
%
% See also SaveCalFile, CalDataFolder.

% Get whichCal
if nargin < 2 || isempty(whichCal)
	whichCal = Inf;
end

% Set filespec
if (nargin < 1 || isempty(filespec))
	filename = ['default.mat'];
elseif (ischar(filespec))
    if (length(filespec) < 4 || ~strcmp(filespec(end-3:end),'.mat'))
        filename = [filespec '.mat'];
    else
        filename = filespec;
    end
else
	filename = [sprintf('screen%d.mat', filespec)];
end

% Set the directory
if nargin < 3 || isempty(dir)
	useDir = CalDataFolder(0,filename);
else
	useDir = CalDataFolder(0,filename,dir);
end
fullFilename = [useDir filename];

% If file doesn't exist in defaykt location, look in the secondary location
if (~exist(fullFilename, 'file') && (nargin < 3 || isempty(dir)))
	useDir = CalDataFolder(1,filename);
	fullFilename = [useDir filename];
end

% Now read the sucker if it is there.
if exist(fullFilename, 'file')
	eval(['load ' QuoteString(fullFilename)]);
    try
        cals{1} = cal;
    end
	if isempty(cals) % #ok<NODEF>
		cal = [];
	else
		% Get the number of calibrations.
		nCals = length(cals);
		
		% User the most recent calibration (the last one in the cals cell
		% array) by default.  If the user specified a particular cal file,
		% try to retrieve it or return an empty matrix if the cal index is
		% out of range.
		if whichCal == Inf
			cal = cals{nCals};
		elseif whichCal > nCals || whichCal < 1
			cal = [];
		else
			cal = cals{whichCal};
		end
	end
else
	cal = [];
	cals = {};
end
