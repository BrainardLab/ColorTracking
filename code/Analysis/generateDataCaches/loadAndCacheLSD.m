function [] = loadAndCacheLSD(subjID)
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

%{
    loadAndCacheLSD('MAB');
    loadAndCacheLSD('BMC');
    loadAndCacheLSD('KAS');
%}

% Get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
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
[tFit,mFit,sFit,bFit,PCdta] = LSDthresholdAnalysis(S,1,'bPLOTpsfs',1,'fitType','weibull','showPlot',false);
pcData = flipud(PCdta);
infoParams.computeDate = date;

%% Save out what we need for more fitting
projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');
paramsCacheFileName     = fullfile(paramsCacheFolder,'detection',[subjCode '_pcCache.mat']);
save(paramsCacheFileName,'infoParams','pcData','targetContrast','cL','cS','theAngles')

end