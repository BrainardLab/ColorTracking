%%%%%%% Do the CTM for the 1 and 2 mech models %%%%%%%
%
%% Load the data  
subjID = 'MAB';
projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');
bootParamsCacheFolder = getpref(projectName,'bootParamsCacheFolder');
plotInfo.figSavePath = getpref(projectName,'figureSavePath');

% get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end

load(fullfile(paramsCacheFolder,[subjCode '_paramsCache.mat']));
load(fullfile(bootParamsCacheFolder,[subjCode '_bootParamsCache.mat']));
% Get the CIs
[upperCI, lowerCI] = computeCiFromBootSruct(rParamsBtstrpStruct, 68);

%% Make the packet
lagVec = lagsMat(:)';
timebase = 1:length(lagVec);

% Initialize the packet
thePacket.response.values   = lagVec;
thePacket.response.timebase = timebase;

% The stimulus
thePacket.stimulus.values   = [cL(:),cS(:)]';
thePacket.stimulus.timebase = timebase;

% The Kernel 
thePacket.kernel.values = [];
thePacket.kernel.timebase = [];

% The Meta Data 
thePacket.metaData.stimDirections = atand(cS(:)./cL(:));
thePacket.metaData.stimContrasts  = vecnorm([cS(:),cL(:)]')';

matrixContrasts = reshape(thePacket.metaData.stimContrasts,size(lagsMat));

%% Make the fit one mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJmechOne = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', 1 ,'fminconAlgorithm','active-set');

%% Make the fit two mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJmechTwo = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Fit it
defaultParamsInfo = [];
fitErrorScalar    = 1000;

% One mechanism
[fitParamsOneMech,~,~] = ctmOBJmechOne.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);
lagsFromFitOneMech = ctmOBJmechOne.computeResponse(fitParamsOneMech,thePacket.stimulus,thePacket.kernel);
lagsFromFitMat = reshape(lagsFromFitOneMech.values,size(lagsMat));

% Two Mechanism
[fitParamsTwoMech,fVal,objFitResponses] = ctmOBJmechTwo.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);
lagsFromFitTwoMech = ctmOBJmechTwo.computeResponse(fitParamsTwoMech,thePacket.stimulus,thePacket.kernel);
lagsFromFitMat = reshape(lagsFromFitTwoMech.values,size(lagsMat));

%% Print the params
fprintf('\ntfeCTM One Mechanism Parameters:\n');
ctmOBJmechOne.paramPrint(fitParamsOneMech)
fprintf('\ntfeCTM Two Mechanism Parameters:\n');
ctmOBJmechTwo.paramPrint(fitParamsTwoMech)

%% Get the null direction
nullDirectionOneMech = atand(fitParamsOneMech.weightL ./ fitParamsOneMech.weightS);
nullDirectionTwoMech1 = atand(fitParamsTwoMech.weightL_1 ./ fitParamsTwoMech.weightS_1);
nullDirectionTwoMech2 = atand(fitParamsTwoMech.weightL_2 ./ fitParamsTwoMech.weightS_2);

fprintf('One Mechanism: The null direction is -- %1.2f\n',nullDirectionOneMech)
fprintf('Two Mechanism: The null directions are: %1.2f & %1.2f\n ',nullDirectionTwoMech1,nullDirectionTwoMech2)

%% Get the isolag contours
targetLag = 0.40;
measuredDirections = uniqueColorDirs(:)';
contourColors = [84,39,143]./255;

% plot contour
[targetL, targetS,~] = generateIsolagContour(fitParamsTwoMech, targetLag, 2);

% Work out the contour shape
mech1Pos =min([vecnorm([targetL;targetS.posMech1]);vecnorm([targetL;targetS.posMech2])]);
%% plot the isolag contour
figHndl = figure;
hold on;
% get current axes
axh = gca;

plot(targetL,targetS.negMech1,'r')
plot(targetL,targetS.posMech1,'r')
plot(targetL,targetS.negMech2,'b')
plot(targetL,targetS.posMech2,'b')

% plot x and y axes
line([-20 20], [0 0], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);
line([0 0], [-6 6], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);

% set axes and figure labels
hXLabel = xlabel('L Contrast');
hYLabel = ylabel('S Contrast');
hTitle  = title('Isoresponse Contour');
set(gca,'FontSize',12);
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 12);
set( hTitle, 'FontSize', 14,'FontWeight' , 'bold');
xlim([-2 2]); ylim([-2 2]); axis('square');


legend([p1{:}],num2str(targetLags(:)))
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

