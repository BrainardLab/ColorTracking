% testBADSFit.m
% Demo to test the BADS fit agianst the fmincon fit
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
load(fullfile(paramsCacheFolder,'tracking',[subjCode '_paramsCache.mat']));

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
thePacket.metaData.dirPlotColors = [230 172 178; ...
    194  171  253; ...
    36   210  201; ...
    32   140  163; ...
    253  182    44; ...
    252  153  233;...
    127  201  127;...
    190  174  212;...
    253  192  134;...
    255  255  153;...
    56   108  176;...
    240    2  127;...
    179  226  205;...
    253  205  172;...
    203  213  232;...
    237  248  177;...
    127  205  187;...
    44   127  184;...
    ]./255;

%% Make the BADS object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJBads= tfeCTMBads('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Make the fmincon object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJfmincon= tfeCTMBads('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Fit the Data
defaultParamsInfo = ctmOBJBads.defaultParams;
fitErrorScalar = 1;

[rotMFminParams,fVal,rotmFminResponses] = ctmOBJfmincon.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar,'searchMethod','fmincon');

[rotMBadsParams,fVal,rotmBadsResponses] = ctmOBJBads.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar,'searchMethod','bads');

[rotMBadsfMinParams,fVal,rotmBadsfMinResponses] = ctmOBJBads.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',rotMFminParams, 'fitErrorScalar',fitErrorScalar,'searchMethod','bads');


%% Plot it
figure; hold on;
% The Lags
plot(lagVec,'k')
% The BADS fit
plot(rotmBadsResponses.values,'r')
% The BADS fit with initaial params set to fmincom solution 
plot(rotmBadsfMinResponses.values,'g')
% The fmincon fit
plot(rotmFminResponses.values,'b--')
legend('Lags','BADS','BADS from fmin', 'fmincon')


% The isocontour and non-linearity
[figHndl] = plotIsoContAndNonLin(rotMBadsfMinParams,'thePacket',thePacket)
