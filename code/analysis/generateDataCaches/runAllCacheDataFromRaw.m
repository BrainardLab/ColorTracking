% Produce all the cached data from the raw data files  

% Detection
generateDetectionCachedData('MAB');
generateDetectionCachedData('BMC');
generateDetectionCachedData('KAS');

% Tracking
generateTrackingCachedData('MAB',{'LS1','LS2','LS3'},'fitMethod','LGS','numRuns',20,'isBootstrap',true,'nBootIters',100);
generateTrackingCachedData('BMC',{'LS1','LS2','LS3'},'fitMethod','LGS','numRuns',20,'isBootstrap',true,'nBootIters',100);
generateTrackingCachedData('KAS',{'LS1','LS2','LS3'},'fitMethod','LGS','numRuns',20,'isBootstrap',true,'nBootIters',100);
