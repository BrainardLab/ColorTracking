% fitDemoTwoMechanisms.m
close all;
clear all;

%% Load the data
subjID = 'KAS';
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
load(fullfile(paramsCacheFolder,'detection',[subjCode '_pcCache.mat']));


paramsOrig.angle        = 60;
paramsOrig.minAxisRatio = 0.1;
paramsOrig.lambda       = .5;
paramsOrig.exponent     = 5;
paramsOrig.scale        = 1;

% The stimulus
thePacket.stimulus.values   = [cL(:),cS(:)]';
timebase = 1:length(thePacket.stimulus.values);
thePacket.stimulus.timebase = timebase;

% The Kernel
thePacket.kernel.values = [];
thePacket.kernel.timebase = [];

% The Meta Data
thePacket.metaData.stimDirections = atand(cS(:)./cL(:));
thePacket.metaData.stimContrasts  = vecnorm([cS(:),cL(:)]')';

%% Make the fit LSD object
theDimension= size(thePacket.stimulus.values, 1);
lsdOBJ= tfeLSD('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

simulatedPC = lsdOBJ.computeResponse(paramsOrig,thePacket.stimulus,thePacket.kernel);

%% Make the packet
thePacket.response.values   = simulatedPC.values;
thePacket.response.timebase = timebase;

%% Fit the Data
defaultParamsInfo = lsdOBJ.defaultParams;
fitErrorScalar = 10000;
[lsdRecoverParams,fVal,lsdRecoverResponses] = lsdOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

figure; hold on;
plot(simulatedPC.values,'k','LineWidth',2)
plot(lsdRecoverResponses.values,'r')



