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

projectName = 'ColorTracking';
plotInfo.figSavePath = getpref(projectName,'figureSavePath');
plotInfo.subjCode    = subjCode;

load(fullfile(paramsCacheFolder,'detection',[subjCode '_pcCache.mat']));


%% Make fit obj
theDirections = unique(atand(cS(:)./cL(:)))';
pcObjIndiv = tfeLSDIndiv(theDirections,6,'verbosity','none','dimension',2, 'numMechanism', 2 ,'fminconAlgorithm','active-set');


%% Make the packet
pcVec = pcData(:)';
timebase = 1:length(pcVec);

% Initialize the packet
thePacket.response.values   = pcVec;
thePacket.response.timebase = timebase;

% The stimulus
thePacket.stimulus.values   = [cL(:),cS(:)]';
thePacket.stimulus.timebase = timebase;

% The kernel
thePacket.kernel.values = [];
thePacket.kernel.timebase = [];

% The Meta Data 
thePacket.metaData.stimDirections = atand(cS(:)./cL(:));
thePacket.metaData.stimContrasts  = vecnorm([cS(:),cL(:)]')';

%% Fit it
defaultParamsInfo = [];
% get subject specific error scalar
if strcmp(subjID,'MAB')
    fitErrorScalar    = 100;
elseif strcmp(subjID,'BMC')
    fitErrorScalar    = 1000;
elseif strcmp(subjID,'KAS')
   fitErrorScalar    = 10;
end


[pcParams,fVal,pcFromFitParams] = pcObjIndiv.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);


%% Plot it 
figure; hold on;
plot(pcFromFitParams.values,'r')
plot(thePacket.response.values,'k--')
legend('Indiv. Fit','Orig. PC')