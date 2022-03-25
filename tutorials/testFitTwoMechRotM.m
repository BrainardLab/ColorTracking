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
params.angle        = 75;
params.minAxisRatio = .02;
params.scale        = .2;
params.amplitude    = .4;
params.minLag       = .35;

% compute the lag for our stim and the params above
lagsFromRotM = ctmRotMOBJ.computeResponse(params,thePacket.stimulus,thePacket.kernel);

%% finish the packet
% the lags from the model
thePacket.response.values   = lagsFromRotM.values;
thePacket.response.timebase = lagsFromRotM.timebase;
% The Meta Data 
thePacket.metaData.stimDirections = atand(cS(:)./cL(:));
thePacket.metaData.stimContrasts  = vecnorm([cS(:),cL(:)]')';

%% fit the packet (try to recover the params)
fitErrorScalar = 10000;
defaultParamsInfo = [];
[rotmParams,fVal,rotmResponses] = ctmRotMOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);
fitErrorScalar = 10000;
[classicParams,fVal,classicResponses] = ctmOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

rotMParams = ParamsClassicToRotM(classicParams)

figure; hold on 
plot(lagsFromRotM.values,'LineWidth',3,'Color','k')
plot(rotmResponses.values,'LineWidth',2,'Color','r')
plot(classicResponses.values,'LineWidth',1,'Color','g')
