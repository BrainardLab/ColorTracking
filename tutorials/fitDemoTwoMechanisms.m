% fitDemoTwoMechanisms.m
close all;
clear all;

%% Load the data  
subjID = 'BMC';
projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');

% get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end

% load the data mat files
load(fullfile(paramsCacheFolder,[subjCode '_paramsCache.mat']));

%% Make the packet
lagVec = lagsMat(:)';
timebase = 1:length(lagVec);

% The stimulus
thePacket.stimulus.values   = [cL(:),cS(:)]';
thePacket.stimulus.timebase = timebase;

% The Kernel 
thePacket.kernel.values = [];
thePacket.kernel.timebase = [];

%% Make the fit one mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJmechOne = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', 1 ,'fminconAlgorithm','active-set');

%% Make the fit two mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJmechTwo = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

% set params to see if they can be recovered
params.angle = 80;
params.minAxisRatio = .1;
params.scale = 2;
params.amplitude = .4;
params.minLag    = .35;

% compute the lag for our stim and the params above
lagsFromFitTwoMech = ctmOBJmechTwo.computeResponse(params,thePacket.stimulus,thePacket.kernel);

%% finish the packet
% the lags from the model
thePacket.response.values   = lagsFromFitTwoMech.values;
thePacket.response.timebase = lagsFromFitTwoMech.timebase;
% The Meta Data 
thePacket.metaData.stimDirections = atand(cS(:)./cL(:));
thePacket.metaData.stimContrasts  = vecnorm([cS(:),cL(:)]')';

%% fit the packet (try to recover the params)
fitErrorScalar = 1000;
defaultParamsInfo = [];
[fitParamsTwoMechSim,fVal,objFitResponses] = ctmOBJmechTwo.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

%% print the params
fprintf('\ntfeCTM Original Parameters:\n');
ctmOBJmechTwo.paramPrint(params)
fprintf('\ntfeCTM Recovered Parameters:\n');
ctmOBJmechTwo.paramPrint(fitParamsTwoMechSim)

%% Try fitting the real data
thePacket.response.values   = lagVec;
thePacket.response.timebase = timebase;

% fit it for the one mech
[fitParamsOneMech,~,~] = ctmOBJmechOne.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

% fit it for the two mech
[fitParamsTwoMechReal,fVal,objFitResponses] = ctmOBJmechTwo.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

% print it
fprintf('\ntfeCTM Actual Parameters:\n');
ctmOBJmechTwo.paramPrint(fitParamsTwoMechReal)

% convert to standard 6 param format
weightL_2 = fitParamsTwoMechSim.weightS_1 .* fitParamsTwoMechSim.weight_M2;
weightS_2 = -1.*fitParamsTwoMechSim.weightL_1 .* fitParamsTwoMechSim.weight_M2;
fitParamsTwoMechFull = fitParamsTwoMechReal;
fitParamsTwoMechFull.weightL_2 = weightL_2;
fitParamsTwoMechFull.weightS_2 = weightS_2;
fitParamsTwoMechFull = rmfield(fitParamsTwoMechFull,'weight_M2');

% print the 6 params format
fprintf('\ntfeCTM Actual Parameters:\n');
ctmOBJmechTwo.paramPrint(fitParamsTwoMechFull)

% calculate the null direction 
nullDirectionOneMech = atand(fitParamsOneMech.weightL ./ fitParamsOneMech.weightS);
nullDirectionTwoMech1 = atand(fitParamsTwoMechSim.weightL_1 ./ fitParamsTwoMechSim.weightS_1);
nullDirectionTwoMech2 = atand(fitParamsTwoMechFull.weightL_2 ./ fitParamsTwoMechFull.weightS_2);

% print the null directions
fprintf('One Mechanism: The null direction is -- %1.2f\n',nullDirectionOneMech)
fprintf('Two Mechanism: The null directions are: %1.2f & %1.2f\n ',nullDirectionTwoMech1,nullDirectionTwoMech2)

%% Get the isolag contours
targetLag = 0.40;
measuredDirections = uniqueColorDirs(:)';
contourColors = [84,39,143]./255;

% Get the one mechanism model 
[targetL_one, targetS_one,~] = generateIsolagContour(fitParamsOneMech, targetLag, 1);

% Get the two mechanism model
[targetL_two, targetS_two,~] = generateIsolagContour(fitParamsTwoMechFull, targetLag, 2);

%% plot the isolag contour
figHndl = figure;
hold on;
% get current axes
axh = gca;

% plot x and y axes
line([-20 20], [0 0], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);
line([0 0], [-6 6], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);

% plot the 2 mech isolag
plot(targetL_two,targetS_two.negMech1,'Color',[1,.1,0],'LineWidth',1.5)
plot(targetL_two,targetS_two.posMech1,'Color',[1,.1,0],'LineWidth',1.5)
plot(targetL_two,targetS_two.negMech2,'Color',[0.60,.2,0],'LineWidth',1.5)
plot(targetL_two,targetS_two.posMech2,'Color',[0.60,.2,0],'LineWidth',1.5)

plot(targetL_one,targetS_one.neg,'Color',[.3,.3,.3],'LineStyle','--','LineWidth',1)
plot(targetL_one,targetS_one.pos,'Color',[.3,.3,.3],'LineStyle','--','LineWidth',1)


% set axes and figure labels
hXLabel = xlabel('L Contrast');
hYLabel = ylabel('S Contrast');
hTitle  = title('Isoresponse Contour');
set(gca,'FontSize',12);
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 12);
set( hTitle, 'FontSize', 14,'FontWeight' , 'bold');

% formatting
axis square

manTicks =  [-2:1:2];

set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'FontSize'    , 16        , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'off'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , manTicks, ...
    'XTick'       , manTicks,...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');

set(gcf, 'Color', 'white' );

xlim([-2 2]); ylim([-2 2]); axis('square');