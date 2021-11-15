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
numMechanism = 1;

ctmOBJ = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', numMechanism ,'fminconAlgorithm','active-set');


%% Fit it


% fit the old way
[p_hat,lagsFromFit] = fitWithFmincon(thePacket.response.values ,thePacket.stimulus.values);
if numMechanism == 1
    oldWayParams = p_hat([1,2,5,6]);
    oldWayParams = ctmOBJ.vecToParams(oldWayParams);
else
    oldWayParams = ctmOBJ.vecToParams(p_hat);
end

defaultParamsInfo = [];
initialParams     = oldWayParams;
fitErrorScalar    = 1000;
[fitParams,fVal,objFitResponses] = ctmOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',initialParams, 'fitErrorScalar',fitErrorScalar);


%% Print the params
fprintf('\ntfeCTM parameters:\n');
ctmOBJ.paramPrint(fitParams)

fprintf('\nThe old way parameters:\n');
ctmOBJ.paramPrint(oldWayParams)