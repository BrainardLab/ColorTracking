% scatterMeasuredLMS_pr670

%% Get the measurements
savePath = '/Users/michael/labDropbox/CNST_materials/ColorTrackingTask/monitorValiadtions/';
saveName = fullfile(savePath,'pr670_CC_measurements_1.mat');

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
totalContrast = vecnorm(target_coneContrast);
[theta, rho] = cart2pol(nominalL,nominalS);
contrastSign = sign(rad2deg(theta));
contrastSign(contrastSign == 0 )  = 1;
totalContrast = totalContrast.*contrastSign;
%% scatter
fgHndl = figure;
sz = 54;

% L cone scatter
subplot(3,3,1);
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

ylim([-.1,.1]);
xlim([-.1,.1]);
manTicks =  [-.10:.05:.10];

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
    'YTick'       , manTicks, ...
    'XTick'       , manTicks,...
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
subplot(3,3,2)
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
ylim([-0.02,0.02]);
xlim([-0.02,0.02]);

manTicks =  [-0.02,0,0.02];
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
    'YTick'       , manTicks, ...
    'XTick'       ,manTicks,...
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
subplot(3,3,3)
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
manTicks =  -1*theLimS:(theLimS +1*theLimS)/4:theLimS;

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
    'YTick'       , manTicks, ...
    'XTick'       ,manTicks,...
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

%% L cone splatter Vs total contrast
subplot(3,3,4)
hold on
cF = [1,.3,.3];
cE = [.5,0,0];

deltaL = meanMeasuredL - nominalL;
scatter(totalContrast,deltaL,sz,'MarkerEdgeColor',cE,...
              'MarkerFaceColor',cF,...
              'LineWidth',1.5);
axis square
lMax = max(deltaL);
theMaxLimL = round(lMax + lMax*.2,2);
lMin = min(deltaL);
theMinLimL = round(lMin + lMin*.2,2);
ylim([theMinLimL,theMaxLimL]);
xlim([round(min(totalContrast),1),round(max(totalContrast),1)]);

manTicksX =  -5:.1:.5;
manTicksY =  -0.02:.005:0;

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
    'YTick'       , manTicksY, ...
    'XTick'       ,manTicksX,...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');

set(gcf, 'Color', 'white' );

% Add labels
hTitle  = title ('L Cone Measurements');
hXLabel = xlabel('Total Cone Contrast');
hYLabel = ylabel('Measured - Nominal L');

set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 18);
set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');

%% M cone splatter Vs total contrast
subplot(3,3,5)
hold on
cF = [.3,1,.3];
cE = [0,.5,0];

deltaM = meanMeasuredM - nominalM;
scatter(totalContrast,deltaM,sz,'MarkerEdgeColor',cE,...
              'MarkerFaceColor',cF,...
              'LineWidth',1.5);
axis square
mMax = max(deltaM);
theMaxLimM = round(mMax + mMax*.2,3);
mMin = min(deltaM);
theMinLimM = round(mMin + mMin*.2,2);
ylim([theMinLimM,theMaxLimM]);
xlim([round(min(totalContrast),1),round(max(totalContrast),1)]);

manTicksX =  -5:.1:.5;
manTicksY =  -0.01:.002:.004;
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
    'YTick'       , manTicksY, ...
    'XTick'       ,manTicksX,...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');

set(gcf, 'Color', 'white' );

% Add labels
hTitle  = title ('M Cone Measurements');
hXLabel = xlabel('Total Cone Contrast');
hYLabel = ylabel('Measured - Nominal M');

set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 18);
set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');

%% S cone splatter Vs total contrast
subplot(3,3,6)
hold on
cF = [.3,.3,1];
cE = [0,0,0.5];

deltaS = meanMeasuredS - nominalS;
scatter(totalContrast,deltaS,sz,'MarkerEdgeColor',cE,...
              'MarkerFaceColor',cF,...
              'LineWidth',1.5);
axis square
sMax = max(deltaS);
theMaxLimS = round(sMax + sMax*.2,2);
sMin = min(deltaS);
theMinLimS = round(sMin + sMin*.2,2);
ylim([theMinLimS,theMaxLimS]);
xlim([round(min(totalContrast),1),round(max(totalContrast),1)]);

manTicksX =  -5:.1:.5;
manTicksY =  -0.02:.005:.02;

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
    'YTick'       , manTicksY, ...
    'XTick'       ,manTicksX,...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');

set(gcf, 'Color', 'white' );

% Add labels
hTitle  = title ('S Cone Measurements');
hXLabel = xlabel('Total Cone Contrast');
hYLabel = ylabel('Measured - Nominal S');

set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 18);
set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');

%% L cone splatter Vs total contrast
subplot(3,3,7)
hold on
cF = [1,.3,.3];
cE = [.5,0,0];

precentL = 100* (deltaL./totalContrast);
scatter(totalContrast,precentL,sz,'MarkerEdgeColor',cE,...
              'MarkerFaceColor',cF,...
              'LineWidth',1.5);
axis square
lMax = max(precentL);
theMaxLimL = round(lMax + lMax*.2,2);
lMin = min(precentL);
theMinLimL = round(lMin + lMin*.2,2);
ylim([theMinLimL,theMaxLimL]);
xlim([round(min(totalContrast),1),round(max(totalContrast),1)]);

manTicksX =  -5:.1:.5;
manTicksY =  -15:5:10;

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
    'YTick'       , manTicksY, ...
    'XTick'       ,manTicksX,...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');

set(gcf, 'Color', 'white' );

% Add labels
hTitle  = title ('L Cone Measurements');
hXLabel = xlabel('Total Cone Contrast');
hYLabel = ylabel('Percent L Splatter');

set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 18);
set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');

%% M cone splatter Vs total contrast
subplot(3,3,8)
hold on
cF = [.3,1,.3];
cE = [0,.5,0];

percentM = 100* (deltaM./totalContrast);
scatter(totalContrast,percentM,sz,'MarkerEdgeColor',cE,...
              'MarkerFaceColor',cF,...
              'LineWidth',1.5);
axis square
mMax = max(percentM);
theMaxLimM = round(mMax + mMax*.2,3);
mMin = min(percentM);
theMinLimM = round(mMin + mMin*.2,2);
ylim([theMinLimM,theMaxLimM]);
xlim([round(min(totalContrast),1),round(max(totalContrast),1)]);

manTicksX =  -5:.1:.5;
manTicksY =  -10:5:10;
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
    'YTick'       , manTicksY, ...
    'XTick'       ,manTicksX,...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');

set(gcf, 'Color', 'white' );

% Add labels
hTitle  = title ('M Cone Measurements');
hXLabel = xlabel('Total Cone Contrast');
hYLabel = ylabel('Percent S Splatter');

set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 18);
set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');

%% S cone splatter Vs total contrast
subplot(3,3,9)
hold on
cF = [.3,.3,1];
cE = [0,0,0.5];

percentS = 100* (deltaS./totalContrast);
scatter(totalContrast,percentS,sz,'MarkerEdgeColor',cE,...
              'MarkerFaceColor',cF,...
              'LineWidth',1.5);
axis square
sMax = max(percentS);
theMaxLimS = round(sMax + sMax*.25,0);
sMin = min(percentS);
theMinLimS = round(sMin + sMin*.25,0);
ylim([theMinLimS,theMaxLimS]);
xlim([round(min(totalContrast),1),round(max(totalContrast),1)]);

manTicksX =  -5:.1:.5;
manTicksY =  -10:5:20;

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
    'YTick'       , manTicksY, ...
    'XTick'       ,manTicksX,...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');

set(gcf, 'Color', 'white' );

% Add labels
hTitle  = title ('S Cone Measurements');
hXLabel = xlabel('Total Cone Contrast');
hYLabel = ylabel('Percent L Splatter');

set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 18);
set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');

%% Save it 

figureSizeInches = [18 18];
set(fgHndl, 'PaperUnits', 'inches');
set(fgHndl, 'PaperSize',figureSizeInches);

% set(tcHndl, 'PaperUnits', 'inches');
% set(tcHndl, 'PaperSize',figureSizeInches);
fgHndl.Units  = 'inches';
fgHndl.PaperUnits  = 'inches';
fgHndl.PaperSize = figureSizeInches;
fgHndl.OuterPosition = [0 0 figureSizeInches(1) figureSizeInches(2)];
fgHndl.InnerPosition = [.5 .5 figureSizeInches(1)-.5 figureSizeInches(2)-.5];
figName =  fullfile(savePath,'coneContrastValidations_pr670_1.pdf');
% % Save it
print(fgHndl, figName, '-dpdf', '-r300');
