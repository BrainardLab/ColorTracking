% Make methods figue for the cross corr. 

%% Get the Xcorr and Tracking info for a single color direction and contrast

% Set up the subj and exp
subjID = 'BMC';
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

%% Fit the log gaussian and plot
[r, rSmooth, rParams,~,~,tSecFit]= LMSxcorrAnalysis(S,fitMethod,'bPLOTfitsAndRaw',false);

%%
tcHndl = figure; hold on 
runNum = 44;
tStep = max(tSecFit(:,1))./length(r(:,5));
t = tStep:tStep:max(tSecFit(:,1));
zerosSize = length(t) - size(rSmooth,1);

fullRSmooth = [zeros(1,zerosSize),rSmooth(:,5)']

%% SUBPLOT 1: trgPos and srpPos
subplot(2,4,[1,2]); hold on;
plot(S.tSec,S.tgtXmm(:,runNum),'LineWidth',1,'Color',[170,170,170]./255)
plot(S.tSec,S.rspXmm(:,runNum),'LineWidth',1,'Color',[0,0,0])

% set axes and figure labels
hXLabel = xlabel('Time (seconds)');
hYLabel = ylabel('Position From Center (mm)');
hTitle  = title('Target and Tracking Postition');
set(gca,'FontSize',7);
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 8);
set( hTitle, 'FontSize', 10,'FontWeight' , 'normal');

% format the figure
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'off'      , ...
    'YMinorTick'  , 'off'      , ...
    'YGrid'       , 'off'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'XTick'       , 0:1:max(S.tSec)   , ...
    'LineWidth'   , 1         , ...
    'ActivePositionProperty', 'OuterPosition');

%% SUBPLOT 2: velocity of trgPos and srpPos
subplot(2,4,[5,6]); hold on 
plot(S.tSec(1:end-1),diff(S.tgtXmm(:,runNum)),'LineWidth',1,'Color',[170,170,170]./255)
plot(S.tSec(1:end-1),diff(S.rspXmm(:,runNum)),'LineWidth',1,'Color',[0,0,0])

% set axes and figure labels
hXLabel = xlabel('Time (seconds)');
hYLabel = ylabel('Velocity (mm/second)');
hTitle  = title('Target and Tracking Velocities');
set(gca,'FontSize',7);
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 8);
set( hTitle, 'FontSize', 10,'FontWeight' , 'normal');

% format the figure
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'off'      , ...
    'YMinorTick'  , 'off'      , ...
    'YGrid'       , 'off'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , -4:1:4    , ...
    'XTick'       ,  0:1:max(S.tSec)   , ...
    'LineWidth'   , 1      , ...
    'ActivePositionProperty', 'OuterPosition');
ylim([-4 4])
%% SUBPLOT 3: trgPos and srpPos
subplot(2,4,[3,4,7,8]); hold on
plot(t,r(:,5),'LineWidth',1,'Color',[77,77,77]./255)
plot(t,fullRSmooth,'LineWidth',2,'Color',[194,171,253]./255)

% set axes and figure labels
hXLabel = xlabel('Time (seconds)');
hYLabel = ylabel('Correlation');
hTitle  = title('Cross-Correlation Function');
set(gca,'FontSize',7);
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 8);
set( hTitle, 'FontSize', 10,'FontWeight' , 'normal');

% format the figure
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'off'      , ...
    'YMinorTick'  , 'off'      , ...
    'YGrid'       , 'off'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'XTick'       ,  0:.25:max(t)    , ...
    'LineWidth'   , 1         , ...
    'ActivePositionProperty', 'OuterPosition');
axis square


% Save it!
figureSizeInches = [6.5 2.75];
% set(tcHndl, 'PaperUnits', 'inches');
% set(tcHndl, 'PaperSize',figureSizeInches);
tcHndl.Units  = 'inches';
tcHndl.PaperUnits  = 'inches';
tcHndl.PaperSize = figureSizeInches;
%tcHndl.OuterPosition = [0 0 figureSizeInches(1) figureSizeInches(2)];
%tcHndl.InnerPosition = [.5 .5 figureSizeInches(1)-.5 figureSizeInches(2)-.5];

projectName = 'ColorTracking';
plotInfo.figSavePath = getpref(projectName,'figureSavePath');
figNameTc =  fullfile(plotInfo.figSavePath,'xCorrMethod.pdf');
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');

