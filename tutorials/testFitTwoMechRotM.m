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

%% Make the fit two mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJ = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

% Make the fit two mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmRotMOBJ= tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% set params to see if they can be recovered
params.angle        = 80;
params.minAxisRatio = .1;
params.scale        = 2;
params.amplitude    = .4;
params.minLag       = .35;

% compute the lag for our stim and the params above
lagsFromFRotM = ctmRotMOBJ.computeResponse(params,thePacket.stimulus,thePacket.kernel);

%% finish the packet
% the lags from the model
thePacket.response.values   = lagsFromFRotM.values;
thePacket.response.timebase = lagsFromFRotM.timebase;
% The Meta Data 
thePacket.metaData.stimDirections = atand(cS(:)./cL(:));
thePacket.metaData.stimContrasts  = vecnorm([cS(:),cL(:)]')';

%% fit the packet (try to recover the params)
fitErrorScalar = 1000;
defaultParamsInfo = [];
[fitParamsTwoMech,fVal,objFitResponses] = ctmOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

% convert the paramters from the RotM method to the 2mech 
R = deg2rotm(params.angle);
E = [1,0;0,params.minAxisRatio];
theWeights = R*E*params.scale;

params2.weightL_1 =theWeights(1,1);
params2.weightS_1 =theWeights(1,2);
params2.weightL_2 =theWeights(2,1);
params2.weightS_2 =theWeights(2,2);
params2.minLag    =params.minLag;
params2.amplitude =params.amplitude ;


weightL_2 = fitParamsTwoMech.weightS_1 .* fitParamsTwoMech.weight_M2;
weightS_2 = -1.*fitParamsTwoMech.weightL_1 .* fitParamsTwoMech.weight_M2;
fitParamsTwoMechFull = fitParamsTwoMech;
fitParamsTwoMechFull.weightL_2 = weightL_2;
fitParamsTwoMechFull.weightS_2 = weightS_2;
fitParamsTwoMechFull = rmfield(fitParamsTwoMechFull,'weight_M2');
        
%% print the params
fprintf('\ntfeCTM Original Parameters:\n');
ctmOBJ.paramPrint(params2)
fprintf('\ntfeCTM Recovered Parameters:\n');
ctmOBJ.paramPrint(fitParamsTwoMechFull)

%% plot the lags/fits
figure;hold on
plot(lagsFromFRotM.values,'k')
plot(objFitResponses.values,'r')

