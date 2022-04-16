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
ctmOBJIndiv= tfeCTMIndiv(lagsMat,'verbosity','none','fminconAlgorithm','active-set');

%% Fit the Data
defaultParamsInfo = ctmOBJIndiv.defaultParams;
fitErrorScalar = 10000;
% [rotMOneMechParams,fVal,rotmOneMechResponses] = ctmOBJOneMech.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
%     'initialParams',[], 'fitErrorScalar',fitErrorScalar);
[rotMTwoMechParams,fVal,rotmTwoMechResponses] = ctmOBJIndiv.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

figure; hold on;
plot(lagVec,'k')

plot(rotmTwoMechResponses.values,'r')



