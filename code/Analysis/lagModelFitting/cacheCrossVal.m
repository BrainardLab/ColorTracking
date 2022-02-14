function [Ssplit] = cacheCrossVal(subjID,expNameCell,varargin)
% Cahce data for Cross-Validation code
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('subjID',@ischar);
p.addRequired('expNameCell',@iscell);
p.addParameter('numRuns',20,@isnumeric);
p.parse(subjID,expNameCell,varargin{:});

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
for ii = 1:length(expNameCell)
    
    % get the experimnent code name
    expName = expNameCell{ii};
    
    % Load the bulk raw data for that experiment
    theRuns = 1:p.Results.numRuns;
    Sall = loadPSYdataLMSall('TRK', subjID, expName, 'CGB', {theRuns}, 'jburge-hubel', 'local');
    
    % get the specific experiemtn code
    if strcmp(expName,'LS1')
        expCode = 'Experiment1-Pos';
    elseif strcmp(expName,'LS2')
        expCode = 'Experiment2-Pos';
    elseif strcmp(expName,'LS3')
        expCode = ['Experiment3-' subjID '-Pos'];
    end
    
    % load the stilumus L and S contrast used in the experiment
    MaxContrastLMS(:,:,ii) = LMSstimulusContrast('experiment',expCode);
    cL(:,ii) = MaxContrastLMS(:,1,ii);
    cS(:,ii) = MaxContrastLMS(:,3,ii);
    colorDirs = round(atand(cS(:,ii)./cL(:,ii)),2);
    uniqueColorDirs(:,ii) = unique(colorDirs,'stable');
    
    for jj = 1:size(uniqueColorDirs,1)
        
        ind = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-uniqueColorDirs(jj,ii))<0.001;
        
        Sdir = structElementSelect(Sall,ind,size(Sall.tgtXmm,2));
        
        colorAngle    = round(atand(Sdir.MaxContrastLMS(:,3)./Sdir.MaxContrastLMS(:,1)));
        colorContrast = round(sqrt(Sdir.MaxContrastLMS(:,3).^2+Sdir.MaxContrastLMS(:,1).^2),3);
        colorAngleContrastUnq = unique([colorAngle colorContrast],'rows');
        
        for kk = 1:size(colorAngleContrastUnq,1)
            ind =   abs(colorAngle-colorAngleContrastUnq(kk,1))<0.001 ...
                & abs(colorContrast-colorAngleContrastUnq(kk,2))<0.001;
            Ssplit(jj,kk,ii) = structElementSelect(Sdir,ind,size(Sdir.MaxContrastLMS,1));
        end
    end
end

% set the 
cacheInfo.cacheDate = date;

% save the split data struct 
outFileName = fullfile(crossValCacheFolder,[subjCode '_crossVal_chached.mat']);
save(outFileName,'Ssplit','cacheInfo')

end
