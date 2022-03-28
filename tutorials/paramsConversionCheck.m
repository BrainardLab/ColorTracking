%% parameter conversion check

% Initialize
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

% The kernel 
thePacket.kernel.values = [];
thePacket.kernel.timebase = [];

%% Make the RotM version object
theDimension= size(thePacket.stimulus.values, 1);
ctmRotMOBJ = tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Make the "classic" two mechanism version object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJmechTwo = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Set Up RotM params to generate lags
rotMParams.angle = 80;
rotMParams.minAxisRatio = .1;
rotMParams.scale = 2;
rotMParams.amplitude = .4;
rotMParams.minLag    = .35;

%% Convert the RotM params to the 2 mech orth. params (if this works, this
% should produce tha same lags from both models given the smae input)
classicParams = ParamsRotMToClassic(rotMParams);

% See if we can go back again
rotMParamsCheck = ParamsClassicToRotM(classicParams)

%% Compute the lag for our stim and the params above
% the RotM mode
lagsFromRotM = ctmRotMOBJ.computeResponse(rotMParamsCheck,thePacket.stimulus,thePacket.kernel);

% 2 mech with orth. constraint
lagsFromTwoMech = ctmOBJmechTwo.computeResponse(classicParams,thePacket.stimulus,thePacket.kernel);

%% plot it
figure; hold on 
plot(lagsFromRotM.values,'LineWidth',2,'Color','k');
plot(lagsFromTwoMech.values,'LineWidth',1.5,'Color','r','LineStyle','--');

