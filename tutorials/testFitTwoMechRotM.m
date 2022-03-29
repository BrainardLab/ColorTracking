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

% Make the fit two mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJ= tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

% Make the rot mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmRotMOBJ= tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% set params to see if they can be recovered
paramsSimulateRotM.angle        = 80;
paramsSimulateRotM.minAxisRatio = .2;
paramsSimulateRotM.scale        = .2;
paramsSimulateRotM.amplitude    = .7;
paramsSimulateRotM.minLag       = .25;
% params.weightL_1 = 2;
% params.weightS_1 = 1;
% params.weight_M2 = 0.72;
% params.minLag    = 0.350;
% params.amplitude = 0.450;

paramsSimulateClassic = ParamsRotMToClassic(paramsSimulateRotM);


% compute the lag for our stim and the params above
lagsFromRotM = ctmRotMOBJ.computeResponse(paramsSimulateRotM,thePacket.stimulus,thePacket.kernel);
lagsFromClassic = ctmOBJ.computeResponse(paramsSimulateClassic,thePacket.stimulus,thePacket.kernel);

%% finish the packet
% the lags from the model
thePacket.response.values   = lagsFromRotM.values;
thePacket.response.timebase = lagsFromRotM.timebase;
% The Meta Data
thePacket.metaData.stimDirections = atand(cS(:)./cL(:));
thePacket.metaData.stimContrasts  = vecnorm([cS(:),cL(:)]')';

%% fit the packet (try to recover the params)
fitErrorScalar = 100000;
defaultParamsInfo = [];
[classicParams,fVal,classicResponses] = ctmOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

fitErrorScalar = 100000;
[rotMParams,fVal,rotmResponses] = ctmRotMOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

% classicParamsCheck = ParamsRotMToClassic(rotMParams)
rotMParamsCheck = ParamsClassicToRotM(classicParams)

figure; hold on
plot(lagsFromRotM.values,'LineWidth',3,'Color','k')
plot(lagsFromClassic.values,'LineWidth',3,'Color','b')


plot(rotmResponses.values,'LineWidth',2,'Color','r')
plot(classicResponses.values,'LineWidth',1,'Color','g')
