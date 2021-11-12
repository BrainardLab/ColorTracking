% test the tfeCTM
%% Load the data
load('dataCache_subj3.mat')

%% Make the packet
lagVec = lags(:)';
timebase = 1:length(lagVec);

% Initialize the packet
thePacket.response.values   = lagVec;
thePacket.response.timebase = timebase;

% The stimulus
thePacket.stimulus.values   = [cL,cS]';
thePacket.stimulus.timebase = timebase;


thePacket.kernel.values = [];
thePacket.kernel.timebase = [];

thePacket.metaData.stimDirections = atand(cS./cL);
thePacket.metaData.stimContrasts  = vecnorm([cS,cL]')';

%% Make the fit object
theDimension= size(thePacket.stimulus.values, 1);
numMechanism = 2;

ctmOBJ = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', numMechanism ,'fminconAlgorithm','active-set');




%% Fit it
defaultParamsInfo = [];
initialParams     = [];
fitErrorScalar    = 1000;

[fitParams,fVal,objFitResponses] = ctmOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',initialParams, 'fitErrorScalar',fitErrorScalar);

% fit the old way 
[p_hat,lagsFromFit] = fitWithFmincon(thePacket.response.values ,thePacket.stimulus.values);
oldWayParams = ctmOBJ.vecToParams(p_hat);


%% Print the params
fprintf('\ntfeCTM parameters:\n');
ctmOBJ.paramPrint(fitParams)

fprintf('\nThe old way parameters:\n');
ctmOBJ.paramPrint(oldWayParams)