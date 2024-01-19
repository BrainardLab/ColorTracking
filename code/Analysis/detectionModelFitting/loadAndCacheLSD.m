function [] = loadAndCacheLSD(subjID)
%{
    loadAndCacheLSD('MAB');
%}

% get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end

S = loadPSYdataLMSall('JND', subjID, 'LSD', 'CGB',{[1:48]}, 'blobfish', 'local');

theAngles = unique(S.targetContrastAngle)';

[targetContrast,targetAngles] = getContrastLSD(subjID,'combined');
targetContrast = flipud(targetContrast);
anglesMat = repmat(theAngles,[size(targetContrast,1),1]);

% Convert angles to L and S contrast
cS = targetContrast.*sind(anglesMat);
cL = targetContrast.*cosd(anglesMat);

[tFit,mFit,sFit,bFit,PCdta] = LSDthresholdAnalysis(S,1,'bPLOTpsfs',1,'fitType','weibull','showPlot',false);

pcData = flipud(PCdta);

infoParams.computeDate = date;
%% save out the params
projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');
paramsCacheFileName     = fullfile(paramsCacheFolder,'detection',[subjCode '_pcCache.mat']);
save(paramsCacheFileName,'infoParams','pcData','targetContrast','cL','cS','theAngles')
end