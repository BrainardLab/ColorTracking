%%%%%%% Do the CTM for the 1 and 2 mech models %%%%%%%
%
close all 
clear all

%% Load the data  
subjID = 'BMC';
projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');
bootParamsCacheFolder = getpref(projectName,'bootParamsCacheFolder');
plotInfo.figSavePath = getpref(projectName,'figureSavePath');

% get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end

load(fullfile(paramsCacheFolder,[subjCode '_paramsCache.mat']));
load(fullfile(bootParamsCacheFolder,[subjCode '_bootParamsCache.mat']));
% Get the CIs
[upperCI, lowerCI] = computeCiFromBootSruct(rParamsBtstrpStruct, 68);

%% Make the packet
lagVec = lagsMat(:)';
timebase = 1:length(lagVec);

% Initialize the packet
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

matrixContrasts = reshape(thePacket.metaData.stimContrasts,size(lagsMat));

%% Make the fit one mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJRotM = tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Make the fit two mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJClassic = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Fit it
defaultParamsInfo = [];
fitErrorScalar    = 1000;

% Two mechanism RotM Model
[fitParamsRotM,fVal1,~] = ctmOBJRotM.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);
lagsFromFitRotM = ctmOBJRotM.computeResponse(fitParamsRotM,thePacket.stimulus,thePacket.kernel);

% Two Mechanism
[fitParamsTwoMech,fVal2,objFitResponses] = ctmOBJClassic.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);
lagsFromFitClassic = ctmOBJClassic.computeResponse(fitParamsTwoMech,thePacket.stimulus,thePacket.kernel);


fVal1
fVal2

% %% Print the params
fprintf('\ntfeCTM RotM Mechanism Parameters:\n');
ctmOBJRotM.paramPrint(fitParamsRotM)
fprintf('\ntfeCTM Two Mechanism Parameters:\n');
ctmOBJClassic.paramPrint(fitParamsTwoMech)

%% Plot It
figure; hold on
plot(lagVec,'LineWidth',3,'Color','k')
plot(lagsFromFitRotM.values,'LineWidth',2,'Color','r')
plot(lagsFromFitClassic.values,'LineWidth',2,'Color','g')
legend('Lags','RotM','Classic')
