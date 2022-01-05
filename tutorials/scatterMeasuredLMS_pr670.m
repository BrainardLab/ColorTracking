% scatterMeasuredLMS_pr670

%% Get the measurements
savePath = '/Users/michael/labDropbox/CNST_materials/ColorTrackingTask/monitorValiadtions/';
saveName = fullfile(savePath,'pr670_CC_measurements.mat');

load(saveName);

%get the mean and SEM
meanMeasuredCC = mean(measuredCC,3);
semMeasuredCC  = std(measuredCC,0,3)./sqrt(size(measuredCC,3));

meanMeasuredL = meanMeasuredCC(1,:);
meanMeasuredM = meanMeasuredCC(2,:);
meanMeasuredS = meanMeasuredCC(3,:);

semMeasuredL = semMeasuredCC(1,:);
semMeasuredM = semMeasuredCC(2,:);
semMeasuredS = semMeasuredCC(3,:);

%% Get the nominals
contrastLMSPos = LMSstimulusContrast('experiment','Experiment1-Pos');
maxExp1Pos = contrastLMSPos(3:6:end,:)';
contrastLMSNeg = LMSstimulusContrast('experiment','Experiment1-Neg');
maxExp1Neg = contrastLMSNeg(3:6:end,:)';

target_coneContrast = [maxExp1Pos,maxExp1Neg];

nominalL = target_coneContrast(1,:);
nominalM = target_coneContrast(2,:);
nominalS = target_coneContrast(3,:);

%% scatter
fgHndl = figure;
sz = 54;

% L cone scatter
subplot(1,3,1);
hold on 
cF = [1,.3,.3];
cE = [.5,0,0];
scatter(nominalL,meanMeasuredL,sz,'MarkerEdgeColor',cE,...
              'MarkerFaceColor',cF,...
              'LineWidth',1.5);
e = errorbar(nominalL,meanMeasuredL,semMeasuredL,...
                'o','LineWidth',2,'Color',cF);

axis square
refline(1,0)
lMax = max(abs([nominalL,meanMeasuredL]));lMax + lMax*.2
theLimL = round(lMax + lMax*.2,2);
ylim([-1*theLimL,theLimL]);
xlim([-1*theLimL,theLimL]);
autoTicks =  -1*theLimL:(theLimL +1*theLimL)/4:theLimL;

set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'FontSize'    , 16        , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , autoTicks, ...
    'XTick'       , autoTicks,...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');

set(gcf, 'Color', 'white' );
% Add labels
hTitle  = title ('L Cone Measurements');
hXLabel = xlabel('Nominal L Cone Contrast');
hYLabel = ylabel('Measured L Cone Contrast');

set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 18);
set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');

% M cone scatter
subplot(1,3,2)
hold on
cF = [.3,1,.3];
cE = [0,.5,0];
scatter(nominalM,meanMeasuredM,sz,'MarkerEdgeColor',cE,...
              'MarkerFaceColor',cF,...
              'LineWidth',1.5);
e = errorbar(nominalM,meanMeasuredM,semMeasuredM,...
                'o','LineWidth',2,'Color',cF);
axis square
refline(1,0)
mMax = max(abs([nominalM,meanMeasuredM]));
theLimM = round(mMax + mMax*.2,2);
ylim([-1*theLimM,theLimM]);
xlim([-1*theLimM,theLimM]);

autoTicks =  -1*theLimM:(theLimM +1*theLimM)/4:theLimM;
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'FontSize'    , 16        , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , autoTicks, ...
    'XTick'       ,autoTicks,...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');

set(gcf, 'Color', 'white' );

% Add labels
hTitle  = title ('M Cone Measurements');
hXLabel = xlabel('Nominal M Cone Contrast');
hYLabel = ylabel('Measured M Cone Contrast');

set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 18);
set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');

% S cone scatter
subplot(1,3,3)
hold on
cF = [.3,.3,1];
cE = [0,0,0.5];
scatter(nominalS,meanMeasuredS,sz,'MarkerEdgeColor',cE,...
              'MarkerFaceColor',cF,...
              'LineWidth',1.5);
e = errorbar(nominalS,meanMeasuredS,semMeasuredS,...
                'o','LineWidth',2,'Color',cF);
axis square
refline(1,0)
sMax = max(abs([nominalS,meanMeasuredS]));
theLimS = round(sMax + sMax*.2,2);
ylim([-1*theLimS,theLimS]);
xlim([-1*theLimS,theLimS]);
autoTicks =  -1*theLimS:(theLimS +1*theLimS)/4:theLimS;

set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'FontSize'    , 16        , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , autoTicks, ...
    'XTick'       ,autoTicks,...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');

set(gcf, 'Color', 'white' );

% Add labels
hTitle  = title ('S Cone Measurements');
hXLabel = xlabel('Nominal S Cone Contrast');
hYLabel = ylabel('Measured S Cone Contrast');


set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 18);
set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');

%% Save it 

figureSizeInches = [20 10];
set(fgHndl, 'PaperUnits', 'inches');
set(fgHndl, 'PaperSize',figureSizeInches);

% set(tcHndl, 'PaperUnits', 'inches');
% set(tcHndl, 'PaperSize',figureSizeInches);
fgHndl.Units  = 'inches';
fgHndl.PaperUnits  = 'inches';
fgHndl.PaperSize = figureSizeInches;
fgHndl.OuterPosition = [0 0 figureSizeInches(1) figureSizeInches(2)];
fgHndl.InnerPosition = [.5 .5 figureSizeInches(1)-.5 figureSizeInches(2)-.5];
figName =  fullfile(savePath,'coneContrastValidations_pr670.pdf');
% % Save it
print(fgHndl, figName, '-dpdf', '-r300');
