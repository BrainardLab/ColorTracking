%%%%%%% Do the CTM for the 1 and 2 mech models %%%%%%%
%
close all 
clear all

%% Load the data  
projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');
subjCode = 'Subject1';
load(fullfile(paramsCacheFolder,[subjCode '_paramsCache.mat']));


%% Make the packet
% Initialize the packet
lagVec = lagsMat(:)';
timebase = 1:length(lagVec);
% The stimulus
thePacket.stimulus.values   = [cL(:),cS(:)]';
thePacket.stimulus.timebase = timebase;

% The Kernel 
thePacket.kernel.values = [];
thePacket.kernel.timebase = [];

% The Meta Data 
thePacket.metaData.stimDirections = atand(cS(:)./cL(:));
thePacket.metaData.stimContrasts  = vecnorm([cS(:),cL(:)]')';


%% Make the fit one mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJRotM = tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');


% set the params
paramsSimulateRotM.angle        = 37;
paramsSimulateRotM.minAxisRatio = .05;
paramsSimulateRotM.scale        = 22;
paramsSimulateRotM.amplitude    = .44;
paramsSimulateRotM.minLag       = .29;

lagsFromFitRotM = ctmOBJRotM.computeResponse(paramsSimulateRotM,thePacket.stimulus,thePacket.kernel)


% add the resposne
thePacket.response.values   = lagsFromFitRotM.values;
thePacket.response.timebase = timebase;


%% Fit it
defaultParamsInfo = [];
fitErrorScalar    = 10000;

% Two mechanism RotM Model
[fitParamsRotM,~,~] = ctmOBJRotM.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);
lagsFromFitRotM = ctmOBJRotM.computeResponse(fitParamsRotM,thePacket.stimulus,thePacket.kernel);

% %% Print the params

fprintf('\ntfeCTM Set Parameters:\n');
ctmOBJRotM.paramPrint(paramsSimulateRotM)
fprintf('\ntfeCTM Recovered Parameters:\n');
ctmOBJRotM.paramPrint(fitParamsRotM)


%% Plot It
figure; hold on
plot(lagVec,'LineWidth',3,'Color','k')
plot(lagsFromFitRotM.values,'LineWidth',2,'Color','r')
legend('Lags','RotM')
