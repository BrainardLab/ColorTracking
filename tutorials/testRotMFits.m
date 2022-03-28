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


%% Make the fit two mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJ= tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

% Make the rot mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmRotMOBJ= tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Fit the Data
fitErrorScalar = 100000;
defaultParamsInfo = [];
[classicParams,fVal,classicResponses] = ctmOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

fitErrorScalar = 100000;
[rotMParams,fVal,rotmResponses] = ctmRotMOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);
rotMParams
classicParams
classicParamsCheck = ParamsRotMToClassic(rotMParams)


figure; hold on
plot(lagVec,'LineWidth',3,'Color','k')
plot(rotmResponses.values,'LineWidth',2,'Color','r')
plot(classicResponses.values,'LineWidth',1,'Color','g')
