function [SsplitDet] = cacheCrossValDetection(subjID,varargin)
% Cahce data for Tracking Cross-Validation code
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('subjID',@ischar);
p.addParameter('numRuns',48,@isnumeric);
p.parse(subjID,varargin{:});

% get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end

% get prefs
projectName = 'ColorTracking';
crossValCacheFolder = getpref(projectName,'crossValCacheFolder');

%% Loop over the experiments
% Load the bulk raw data for that experiment
theRuns = 1:p.Results.numRuns;
Sall = loadPSYdataLMSall('JND', subjID, 'LSD', 'CGB',{theRuns}, 'blobfish', 'local');

% load the stilumus L and S contrast used in the experiment
uniqueColorDirs = unique(Sall.targetContrastAngle);

for jj = 1:size(uniqueColorDirs,1)
    
    ind = abs(Sall.targetContrastAngle-uniqueColorDirs(jj))<0.001;
    
    Sdir = structElementSelect(Sall,ind,size(Sall.cmpIntrvl,1));
    
    colorAngle    = abs(Sdir.targetContrastAngle);
    colorContrast = abs(Sdir.targetContrast);
    colorAngleContrastUnq = unique([colorAngle colorContrast],'rows');
    
    for kk = 1:size(colorAngleContrastUnq,1)
        ind =   abs(colorAngle-colorAngleContrastUnq(kk,1))<0.001 ...
            & abs(colorContrast-colorAngleContrastUnq(kk,2))<0.001;
        SsplitDet(jj,kk) = structElementSelect(Sdir,ind,size(Sdir.cmpIntrvl,1));
    end
end


% set the
cacheInfoDet.cacheDate = date;

% save the split data struct
outFileName = fullfile(crossValCacheFolder,[subjCode '_crossValDet_chached.mat']);
save(outFileName,'SsplitDet','cacheInfoDet');

end