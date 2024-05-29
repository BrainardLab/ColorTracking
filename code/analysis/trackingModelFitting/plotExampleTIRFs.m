%% Plot the tITFs for a single color direction
%
% Run this to generate the sample tIRF estimation plots
% from raw data.  You have to save by hand.

% Set up the subj and exp
subjID = 'KAS';
expName = 'LS1';
numRuns = 20;
fitMethod = 'LGS';
uniqueColorDir = 90;

% Load the bulk raw data for that experiment
theRuns = 1:numRuns;
Sall = loadPSYdataLMSall('TRK', subjID, expName, 'CGB', {theRuns}, 'jburge-hubel', 'local');

% Select the direction
% 0 DEG IN SL PLANE
ind = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-uniqueColorDir)<0.001;

S = structElementSelect(Sall,ind,size(Sall.tgtXmm,2));

% Fit the log gaussian and plot
[r, rSmooth, rParams]= LMSxcorrAnalysis(S,fitMethod,'bPLOTfitsAndRaw',true);

%%

absMaxContrastLMSunq = unique(abs(S.MaxContrastLMS),'rows');
indCheck = [];

figure;
set(gcf,'Position',[447 247 1182 646]);
for i = 1:length(absMaxContrastLMSunq)
   subplot(2,3,i);
   ind = abs(abs(S.MaxContrastLMS(:,3))-absMaxContrastLMSunq(i,3))<0.001;
   indCheck = [indCheck; find(ind)];
   tgtXmmLtmp = S.tgtXmmL(:,ind);
   rspXmmLtmp = S.rspXmmL(:,ind);
   signedErrRsp = rspXmmLtmp-tgtXmmLtmp;
   signedErrDeg = atand(signedErrRsp./925);
   hist(signedErrDeg(:),21);
   axis square;
   formatFigure('Error (deg)','Count',['S contrast = ' num2str(absMaxContrastLMSunq(i,3),2)]);
end
