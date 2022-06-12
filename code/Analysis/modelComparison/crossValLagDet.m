function [] = crossValLagDet(subjID,varargin)

% Cross-Validation model comaprison code.
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('subjID',@ischar);
p.addParameter('fitMethod','LGS',@ischar);
p.addParameter('nCrossValIter',15,@isnumeric);
p.addParameter('makeAndSavePlot',false,@islogical);
p.addParameter('fitErrorScalar',1000,@isnumeric);
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

% Load the cross val data cache
dataCacheName = fullfile(crossValCacheFolder,[subjCode '_crossVal_chached.mat']);
load(dataCacheName);

% Load the 

