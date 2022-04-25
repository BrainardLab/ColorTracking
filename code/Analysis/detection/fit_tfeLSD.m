%%%%%%% Do the CTM for the 1 and 2 mech models %%%%%%%
%
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


%% Make the packet
pcVec = pcData(:)';
timebase = 1:length(pcVec);

% Initialize the packet
thePacket.response.values   = pcVec;
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
thePacket.metaData.dirPlotColors  = [230 172 178; ...
    194  171  253; ...
    36   210  201; ...
    32   140  163; ...
    253  182    44; ...
    252  153  233;...
    127  201  127;...
    190  174  212;...
    253  192  134;...
    255  255  153;...
    56   108  176;...
    240    2  127;...
    ]./255;
matrixContrasts = reshape(thePacket.metaData.stimContrasts,size(pcData));

%% Make the fit two mechanism object
theDimension= size(thePacket.stimulus.values, 1);
lsdOBJ = tfeLSD('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Fit it
defaultParamsInfo = [];
% get subject specific error scalar
if strcmp(subjID,'MAB')
    fitErrorScalar    = 100;
elseif strcmp(subjID,'BMC')
    fitErrorScalar    = 10;
elseif strcmp(subjID,'KAS')
   fitErrorScalar    = 10;
end

% get the pc from start params
pcFromStartParams = lsdOBJ.computeResponse(lsdOBJ.defaultParams,thePacket.stimulus,thePacket.kernel);
% fit it 
[pcParams,fVal,pcFromFitParams] = lsdOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

figure;hold on;
plot(pcVec,'k','LineWidth',2);
plot(pcFromStartParams.values,'g','LineWidth',2,'LineStyle','-')
plot(pcFromFitParams.values,'r','LineWidth',2,'LineStyle','--')


plotIsoContLSD(pcParams,'thePacket',thePacket,'plotInfo',plotInfo)



uniqColorDirs = unique(thePacket.metaData.stimDirections)';

plotInfo.xlabel  = 'Contrast (%)';
plotInfo.ylabel = 'Percent Correct'; plotInfo.figureSizeInches = [6 5];

plotColors = thePacket.metaData.dirPlotColors;
plotPsychometric(pcParams,pcData,matrixContrasts,uniqColorDirs,plotInfo,'plotColors',plotColors)

