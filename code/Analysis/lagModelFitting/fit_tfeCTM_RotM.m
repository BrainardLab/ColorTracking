%%%%%%% Do the CTM for the 1 and 2 mech models %%%%%%%
%
%% Load the data  
subjID = 'KAS';
projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');
bootParamsCacheFolder = getpref(projectName,'bootParamsCacheFolder');


% get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end

plotInfo.figSavePath = getpref(projectName,'figureSavePath');
plotInfo.subjCode    = subjCode;

load(fullfile(paramsCacheFolder,'tracking',[subjCode '_paramsCache.mat']));
load(fullfile(bootParamsCacheFolder,'tracking',[subjCode '_bootParamsCache.mat']));
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
    179  226  205;...
    253  205  172;...
    203  213  232;...
    237  248  177;...
    127  205  187;...
    44   127  184;...
    ]./255;
matrixContrasts = reshape(thePacket.metaData.stimContrasts,size(lagsMat));

%% Make the fit one mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJmechOne = tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 1 ,'fminconAlgorithm','active-set');

%% Make the fit two mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJmechTwo = tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Fit it
defaultParamsInfo = [];
fitErrorScalar    = 100000;

% One mechanism
[rotMOneMechParams,~,lagsFromFitOneMech] = ctmOBJmechOne.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);
lagsOneMechMat = reshape(lagsFromFitOneMech.values,size(lagsMat));

% Two Mechanism
[rotMTwoMechParams,fVal,lagsFromFitTwoMech] = ctmOBJmechTwo.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);
lagsTwoMechMat = reshape(lagsFromFitTwoMech.values,size(lagsMat));

%% Print the params
fprintf('\ntfeCTM One Mechanism Parameters:\n');
ctmOBJmechOne.paramPrint(rotMOneMechParams)
fprintf('\ntfeCTM Two Mechanism Parameters:\n');
ctmOBJmechTwo.paramPrint(rotMTwoMechParams)

%% Do the isolag contours -- one mechanism 
targetLags = [0.3,0.35,0.4,0.45,0.5];
measuredDirections = uniqueColorDirs(:)';
contourColors = [242,240,247;...
203,201,226;...
158,154,200;...
117,107,177;...
84,39,143]./255;

%[figHndl] = plotIsoContAndNonLin(rotMOneMechParams,'thePacket',thePacket)


[figHndl] = plotIsoContAndNonLin(rotMTwoMechParams,'thePacket',thePacket,'plotInfo',plotInfo)


plotInfo.title  = 'Lag Vs. Contrast'; plotInfo.xlabel  = 'Contrast (%)';
plotInfo.ylabel = 'Lag (s)'; plotInfo.figureSizeInches = [20 11];


if strcmp(subjID,'MAB')
    directionGroups = {[0,90],[75,-75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.6,88.6,87.6],[22.5,-1.4,-22.5]}; yLimVals = [0.2 0.9];
elseif strcmp(subjID,'BMC')
    directionGroups = {[0,90],[75,-75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.1,88.1,87.1],[22.5,-0.9,-22.5]};
    yLimVals = [0.2 0.6];
elseif strcmp(subjID,'KAS')
    directionGroups = {[0,90],[75,-75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.1,88.1,87.1],[22.5,-1.9,-22.5]};
    yLimVals = [0.2 0.8];
end

CIs.upper = abs(upperCI - meanLagBtstrpLagMat);
CIs.lower = abs(meanLagBtstrpLagMat - lowerCI);

plotColors = thePacket.metaData.dirPlotColors;
plotDirectionPairs(matrixContrasts,lagsMat,lagsTwoMechMat,uniqueColorDirs(:), directionGroups, plotInfo,'plotColors',plotColors','errorBarsCI',CIs,'yLimVals',yLimVals)

