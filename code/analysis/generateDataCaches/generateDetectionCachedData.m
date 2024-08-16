function [] = generateDetectionCachedData(subjID)
%
% This function is the top level call to read in and do
% some massaging and initial fitting of th detection
% experiment.
%
% You need to have your Matlab preference file set up
% to point to teh folder containing the raw data - see
% config/ColorTrackingLocalHookTemplate.m for how you
% set that up.  Then execute the three lines below to
% produce the cached data files used for further fitting.
% The cached data is put into a filename
% with pcCache as part of it, where pc is supposed to make
% you think of percent correct.
%
% This didn't previously produce bootstrapped data, but I added
% the 'nBoots',100 key/value pair to the call to LSDthresholdAnalysis
% and fixed the hard coded directory there to respect the project
% preference.  Also had to pass subjNum into that routine to get the
% filename right.

%{
    % Check that the setting of CORRECTED in getContrastLSD is as you want
    it.
    generateDetectionCachedData('MAB');
    generateDetectionCachedData('BMC');
    generateDetectionCachedData('KAS');
%}

% Get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
    subjNum = 1;
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
    subjNum = 2;
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
    subjNum = 3;
end

% Burge lab functions used to read and sort the data, etc.
S = loadPSYdataLMSall('JND', subjID, 'LSD', 'CGB',{[1:48]}, 'blobfish', 'local');

% Get angles and contrast and convert to L and S cone contrast
theAngles = unique(S.targetContrastAngle)';
[targetContrast,targetAngles] = getContrastLSD(subjID,'combined');
targetContrast = flipud(targetContrast);
anglesMat = repmat(theAngles,[size(targetContrast,1),1]);
cS = targetContrast.*sind(anglesMat);
cL = targetContrast.*cosd(anglesMat);

% Burge lab functions used to do more stuff.  It looks like
% our main purpose here is to get the percent correct data
% out for each stimulus level.
[tFit,mFit,sFit,bFit,PCdta] = LSDthresholdAnalysis(S,1,'bPLOTpsfs',1,'fitType','weibull','showPlot',false,'nBoot',100,'subjNum',subjNum);
pcData = flipud(PCdta);
infoParams.computeDate = date;

%% Save out what we need for more fitting
projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');
paramsCacheFileName     = fullfile(paramsCacheFolder,'detection',[subjCode '_pcCache.mat']);
save(paramsCacheFileName,'infoParams','pcData','targetContrast','cL','cS','theAngles')

end