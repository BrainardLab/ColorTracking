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

% [C, sampleBaseTheta] = generateIsorepsoneContour(fitParams, 0.3, 350);
% [isoS_1,isoL_1] = pol2cart(deg2rad(sampleBaseTheta),C);
[C, sampleBaseTheta] = generateIsorepsoneContour(fitParams, 0.35, 350);
[isoL_2,isoS_2] = pol2cart(deg2rad(sampleBaseTheta),C);
[C, sampleBaseTheta] = generateIsorepsoneContour(fitParams, 0.4, 350);
[isoL_3,isoS_3] = pol2cart(deg2rad(sampleBaseTheta),C);
[C, sampleBaseTheta] = generateIsorepsoneContour(fitParams, 0.45, 350);
[isoL_4,isoS_4] = pol2cart(deg2rad(sampleBaseTheta),C);
[C, sampleBaseTheta] = generateIsorepsoneContour(fitParams, 0.5, 350);
[isoL_5,isoS_5] = pol2cart(deg2rad(sampleBaseTheta),C);
[C, sampleBaseTheta] = generateIsorepsoneContour(fitParams, 0.55, 350);
[isoL_6,isoS_6] = pol2cart(deg2rad(sampleBaseTheta),C);


% plot the isolag contour
figHndl = figure;
hold on;
xlim([-1 1])
ylim([-6 6])

% get current axes
axh = gca;

% plot axes
line([-20 20], [0 0], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);
line([0 0], [-6 6], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);

% plot ellipse
% line(isoS_1,isoL_1,'color', [.2 .7 .85]- 0.2*[0 .7 .85], 'LineWidth', 2);
line(isoL_2,isoS_2,'color', [.2 .7 .85]- 0.1*[0 .7 .85], 'LineWidth', 2);
line(isoL_3,isoS_3,'color', [.2 .7 .85]- 0.0*[0 .7 .85], 'LineWidth', 2);
line(isoL_4,isoS_4,'color', [.2 .7 .85]- 0.1*[0 .7 .85], 'LineWidth', 2);
line(isoL_5,isoS_5,'color', [.2 .7 .85]- 0.2*[0 .7 .85], 'LineWidth', 2);
line(isoL_6,isoS_6,'color', [.2 .7 .85]- 0.3*[0 .7 .85], 'LineWidth', 2);


% set axes and figure labels
hXLabel = xlabel('L Contrast');
hYLabel = ylabel('S Contrast');
hTitle  = title('Isoresponse Contour');
set(gca,'FontSize',12);
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 12);
set( hTitle, 'FontSize', 14,'FontWeight' , 'bold');

