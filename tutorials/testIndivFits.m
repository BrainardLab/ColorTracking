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

%% Make the matrix inputs to the fitting object
directions = reshape(thePacket.metaData.stimDirections,size(lagsMat));
contrasts = reshape(thePacket.metaData.stimContrasts,size(lagsMat));

%% Make the fit individual directions object
ctmOBJIndiv= tfeCTMIndiv(directions,contrasts,'verbosity','none','fminconAlgorithm','active-set');

%% Make the fit one mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJmechOne = tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 1 ,'fminconAlgorithm','active-set');

%% Make the fit two mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJmechTwo = tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Fit the Data
% indiv model
indivParamsInfo = ctmOBJIndiv.defaultParams;
fitErrorScalar = 10000;
[indivParams,fVal,indivResponses] = ctmOBJIndiv.fitResponse(thePacket,'defaultParamsInfo',indivParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

% One mechanism
defaultParamsInfo = [];
fitErrorScalar    = 100000;
[rotMOneMechParams,~,lagsFromFitOneMech] = ctmOBJmechOne.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

% Two Mechanism
[rotMTwoMechParams,fVal,lagsFromFitTwoMech] = ctmOBJmechTwo.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

figure; hold on;
plot(lagVec,'k','LineWidth',3)
plot(indivResponses.values,'r','LineWidth',1.5)
plot(lagsFromFitOneMech.values,'g','LineWidth',1.5)
plot(lagsFromFitTwoMech.values,'b','LineWidth',1.5)
legend('Lags','Indiv Model','One Mech','Two Mech')

hXLabel = xlabel('Simulus #');
hYLabel = ylabel('Lag (s)');
hTitle  = title('Model Lag Fits');
set(gca,'FontSize',12);
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 12);
set( hTitle, 'FontSize', 14,'FontWeight' , 'bold');
% format plot
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , .3:.2:.7    , ...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition',...
    'xscale','linear');
ylim([.3 .7]);
set(gcf, 'Color', 'white' );
axis square