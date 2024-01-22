function fitTrackingCashedData(subjID)
%%%%%%% Do the CTM fits for the 1 and 2 mech models %%%%%%%

% Run as here to analyze all subjects
%{
    fitTrackingCachedData('MAB');
    fitTrackingCachedData('BMC');
    fitTrackingCachedData('KAS');
%}

%% Close any open figures
close all;

%% Parameters
doBootstrapFits = true;
fitOneMechanism = false;

%% Get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end

projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');
plotInfo.figSavePath = getpref(projectName,'figureSavePath');
plotInfo.subjCode    = subjCode;

%% Load data
load(fullfile(paramsCacheFolder,'tracking',[subjCode '_paramsCache.mat']));

%% Bootstrap info
bootParamsCacheFolder = getpref(projectName,'bootParamsCacheFolder');
bootData = load(fullfile(bootParamsCacheFolder,'tracking',[subjCode '_bootParamsCache.mat']));

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
if (fitOneMechanism)
    theDimension= size(thePacket.stimulus.values, 1);
    ctmOBJmechOne = tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 1 ,'fminconAlgorithm','active-set');
end

%% Make the fit two mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJmechTwo = tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Fit
defaultParamsInfo = [];
fitErrorScalar    = 100000;

% One mechanism
if (fitOneMechanism)
    [rotMOneMechParams,~,lagsFromFitOneMech] = ctmOBJmechOne.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
        'initialParams',[], 'fitErrorScalar',fitErrorScalar);
    lagsOneMechMat = reshape(lagsFromFitOneMech.values,size(lagsMat));
end

% Two Mechanism
[rotMTwoMechParams,fVal,lagsFromFitTwoMech] = ctmOBJmechTwo.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);
lagsTwoMechMat = reshape(lagsFromFitTwoMech.values,size(lagsMat));

%% Bootstrapping
% if (doBootstrapFits)
% 
%     % Set up basic bootstrap packet
%     theBootPacket = thePacket;
% 
%     % Now do the fit for each bootstrap iteration
%     nBootstraps = size(bootData.tFitBoot,2);
%     for bb = 1:nBootstraps
%         % Stick the bootstrapped probability correct data into the
%         % bootstrapped packet. Unpacking this in the same way
%         % as the real data above get unpacked. The flipud is needed
%         % so that things make sense, and I think it was applied somewhere 
%         % when pcData were created. 
%         bootPcData = flipud(squeeze(bootData.PCdtaBoot(:,:,bb)));
%         theBootPacket.response.values = bootPcData(:)';
% 
%         % Do the bootstrapped data fit
%         [pcParamsBoot{bb},fValBoot(bb),pcFromFitParamsBoot{bb}] = lsdOBJ.fitResponse(theBootPacket,'defaultParamsInfo',defaultParamsInfo,...
%             'initialParams',[], 'fitErrorScalar',fitErrorScalar);
% 
%         anglesBoot(bb) = pcParamsBoot{bb}.angle;
%         minAxisRatiosBoot(bb) = pcParamsBoot{bb}.minAxisRatio;
%         lambdasBoot(bb) = pcParamsBoot{bb}.lambda;
%         exponentsBoot(bb) = pcParamsBoot{bb}.exponent;
%     end
% end


%% Print the params
if (fitOneMechanism)
    fprintf('\ntfeCTM One Mechanism Parameters:\n');
    ctmOBJmechOne.paramPrint(rotMOneMechParams)
end

fprintf('\ntfeCTM Two Mechanism Parameters:\n');
ctmOBJmechTwo.paramPrint(rotMTwoMechParams)

%% Plots ellipse and summary fit plot 
[tcHndlCont,tcHndlNonlin] = plotIsoContAndNonLin(rotMTwoMechParams,'thePacket',thePacket,'plotInfo',plotInfo, ...
    'desiredEqContrast',1,'ellipseXLim',0.2,'ellipseYLim',1.25);

%% Plot montage of lag vs contrast for each direction
%
% Info setup of some sort
plotInfo.title  = 'Lag Vs. Contrast'; plotInfo.xlabel  = 'Contrast (%)';
plotInfo.ylabel = 'Lag (s)'; plotInfo.figureSizeInches = [20 11];

% Confidence interval info
%
% Commented out code here does a confidence interval around the mean
% bootstrapped value.  I replaced with stderr estimated as bootstrapped
% standard deviation, around data mean.  Six of one, half a doze of the
% other, but the latter is how I'm setting up to report errors on the
% ellipse parameters from bootstrapping, so for consistency, doing it 
% this way. You have to look very carefully at the figure to see any visual
% difference between these two ways of doing it.
%
% [upperCI, lowerCI] = computeCiFromBootSruct(bootData.rParamsBtstrpStruct, 68);
% CIs.upper = abs(upperCI - bootData.meanLagBtstrpLagMat);
% CIs.lower = abs(bootData.meanLagBtstrpLagMat - lowerCI);
upperCI = lagsMat + bootData.sDevBtstrpLagMat;
lowerCI = lagsMat + bootData.sDevBtstrpLagMat;
CIs.upper = abs(upperCI - lagsMat);
CIs.lower = abs(lagsMat - lowerCI);

% Customize directions and group into pairs for montaging
if strcmp(subjID,'MAB')
    directionGroups = {[0,90],[75,-75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.6,88.6,87.6],[22.5,-1.4,-22.5]}; yLimVals = [0.2 0.9];
elseif strcmp(subjID,'BMC')
    directionGroups = {[0,90],[75,-75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.1,88.1,87.1],[22.5,-0.9,-22.5]};
    yLimVals = [0.2 0.6];
elseif strcmp(subjID,'KAS')
    directionGroups = {[0,90],[75,-75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.1,88.1,87.1],[22.5,-1.9,-22.5]};
    yLimVals = [0.2 0.8];
end

% Do the plot
plotColors = thePacket.metaData.dirPlotColors;
plotDirectionPairs(matrixContrasts,lagsMat,lagsTwoMechMat,uniqueColorDirs(:), directionGroups, plotInfo,'plotColors',plotColors','errorBarsCI',CIs,'yLimVals',yLimVals)

end