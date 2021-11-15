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

% Let's compute the error with the final parameters and the stimuli.
[oldWayFitError,oldWayLagEstFromErrorFunction] = objectiveFunc(p_hat,thePacket.response.values,thePacket.stimulus.values(1,:),thePacket.stimulus.values(2,:));
checkLags = max(abs(lagsFromFit(:)-oldWayLagEstFromErrorFunction(:)));
if (checkLags ~= 0)
    error('Did not compute the same lags in the two places they are computed');
end

defaultParamsInfo = [];
initialParams     = oldWayParams;
fitErrorScalar    = 1000;

% Before we fit with tfe, let's make sure we get same model response and
% same error value when we use the parameters we obtained the old way.
tfeParamsCheck = ctmOBJ.vecToParams(ctmOBJ.paramsToVec(oldWayParams));
tfeFValCheck = ctmOBJ.fitError(ctmOBJ.paramsToVec(oldWayParams),thePacket,'fitErrorScalar',fitErrorScalar);

%% Compute the fit based on the timebase of the stimulus
clear startParams
startParams.weightL = 50;
startParams.weightS = 2;
% startParams.weightL_2 = 0;
% startParams.weightS_2  = 0;
startParams.minLag = 0.3;
startParams.amplitude = 0.2;
modelResponseStruct = ctmOBJ.computeResponse(oldWayParams,thePacket.stimulus,thePacket.kernel);
checkLags1 = max(abs(lagsFromFit(:)-modelResponseStruct.values(:)));
if (checkLags1 ~= 0)
    error('Did not compute the same lags in the two places they are computed');
end

[fitParams,fVal,objFitResponses] = ctmOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',startParams, 'fitErrorScalar',fitErrorScalar);


%% Print the params
fprintf('\ntfeCTM parameters:\n');
ctmOBJ.paramPrint(fitParams)

fprintf('\nThe old way parameters:\n');
ctmOBJ.paramPrint(oldWayParams)