%% parameter conversion check

% fitDemoTwoMechanisms.m
close all;
clear all;

%% Load the data  
subjCode = 'Subject1';
projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');

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

%% Make the fit one mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmRotMOBJ = tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Make the fit two mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJmechTwo = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Set Up RotM params to generate lags
params.angle = 80;
params.minAxisRatio = .1;
params.scale = 2;
params.amplitude = .4;
params.minLag    = .35;

% Convert the RotM params to the 2 mech orth. params (if this works, this
% should produce tha same lags from both models given the smae input)
R = deg2rotm(params.angle);
E = [1,0;0,params.minAxisRatio];
theWeights = R*E*params.scale;

params2.weightL_1 =theWeights(1,1);
params2.weightS_1 =theWeights(1,2);
weightL_2 =theWeights(2,1);
weightS_2 =theWeights(2,2);
if abs(weightL_2./ params2.weightS_1) == abs(params2.weightL_1./ weightS_2)
    params2.weight_M2 = abs(weightL_2./ params2.weightS_1);
else 
    error('Check the weights!!!')
end
params2.minLag    =params.minLag;
params2.amplitude =params.amplitude ;


%% compute the lag for our stim and the params above
% the RotM mode
lagsFromRotM = ctmRotMOBJ.computeResponse(params,thePacket.stimulus,thePacket.kernel);

% 2 mech with orth. constraint
lagsFromTwoMech = ctmOBJmechTwo.computeResponse(params2,thePacket.stimulus,thePacket.kernel);

%% plot it
figure; hold on 
plot(lagsFromRotM.values,'LineWidth',2,'Color','k');
plot(lagsFromTwoMech.values,'LineWidth',1.5,'Color','r','LineStyle','--');
