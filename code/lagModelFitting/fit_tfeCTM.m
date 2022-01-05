% test the tfeCTM
subjID = 'BMC';
%% Load the data
projectName = 'CorticalColorMapping';
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


thePacket.kernel.values = [];
thePacket.kernel.timebase = [];

thePacket.metaData.stimDirections = atand(cS(:)./cL(:));
thePacket.metaData.stimContrasts  = vecnorm([cS(:),cL(:)]')';

matrixContrasts = reshape(thePacket.metaData.stimContrasts,size(lagsMat));
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
%startParams.weightL_2 = 0;
%startParams.weightS_2  = 0;
startParams.minLag = 0.3;
startParams.amplitude = 0.2;
modelResponseStruct = ctmOBJ.computeResponse(oldWayParams,thePacket.stimulus,thePacket.kernel);
checkLags1 = max(abs(lagsFromFit(:)-modelResponseStruct.values(:)));
if (checkLags1 ~= 0)
    error('Did not compute the same lags in the two places they are computed');
end

[fitParams,fVal,objFitResponses] = ctmOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',startParams, 'fitErrorScalar',fitErrorScalar);
lagsFromFit = ctmOBJ.computeResponse(fitParams,thePacket.stimulus,thePacket.kernel);
lagsFromFitMat = reshape(lagsFromFit.values,size(lagsMat));

%% Print the params
fprintf('\ntfeCTM parameters:\n');
ctmOBJ.paramPrint(fitParams)

fprintf('\nThe old way parameters:\n');
ctmOBJ.paramPrint(oldWayParams)

targetLags = 0.35;
numSamples = 300;
measuredDirections = uniqueColorDirs(:)';
[C_1, sampleBaseTheta_1, targetL_1, targetS_1,expDirPoints] = generateIsorepsoneContour(fitParams, targetLags, numSamples,...
    'dataDirections',measuredDirections);

% plot the isolag contour
figHndl = figure;
hold on;

% get current axes
axh = gca;

% plot axes
line([-20 20], [0 0], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);
line([0 0], [-6 6], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);


% plot ellipse
p1 = line(targetL_1.pos,targetS_1.pos,'color', [0 63 92]./256, 'LineWidth', 2);
p2 = line(targetL_1.neg,targetS_1.neg,'color', [0 63 92]./256, 'LineWidth', 2);

%scatter the experimental directions intesect with contour
sz = 30;
scatter(expDirPoints(1,:),expDirPoints(2,:),sz,'MarkerEdgeColor',[0.3 .3 .3],...
    'MarkerFaceColor',[0.75,0.5,0.5],...
    'LineWidth',1.5)

%% Get the null direction
nullDirection = atand(fitParams.weightL ./ fitParams.weightS);

fprintf('The null direction is: %1.2f\n',nullDirection)
nullPoint = 1.5*[cosd(nullDirection) sind(nullDirection)];
spt = plot(nullPoint(1),nullPoint(2),'bo','MarkerFaceColor','b','MarkerSize',8);

% set axes and figure labels
hXLabel = xlabel('L Contrast');
hYLabel = ylabel('S Contrast');
hTitle  = title('Isoresponse Contour');
set(gca,'FontSize',12);
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 12);
set( hTitle, 'FontSize', 14,'FontWeight' , 'bold');
xlim([-4 4]); ylim([-4 4]); axis('square');


legend([p1,spt],{sprintf('%g',targetLags(1)),'null'})

plotInfo.title  = 'Lag Vs. Contrast';
plotInfo.xlabel  = 'Contrast (%)';
plotInfo.ylabel = 'Lag (s)';
plotInfo.figureSizeInches = [20 11];
plotInfo.subjCode    = subjCode;

if strcmp(subjID,'MAB')
    directionGroups = {[0,90],[75, -75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.6,88.6, 87.6],[22.5,-1.4,-22.5]};
    yLimVals = [0.2 0.9];
elseif strcmp(subjID,'BMC')
    directionGroups = {[0,90],[75, -75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.1,88.1,87.1],[22.5,-0.9,-22.5]};
    yLimVals = [0.2 0.6];
elseif strcmp(subjID,'KAS')
    directionGroups = {[0,90],[75, -75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.1,88.1,87.1],[22.5,-1.9,-22.5]};
    yLimVals = [0.2 0.8];
end

CIs.upper = abs(upperCI - meanLagBtstrpLagMat);
CIs.lower = abs(meanLagBtstrpLagMat - lowerCI);

plotColors = [230 172 178; ...
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

plotDirectionPairs(matrixContrasts,lagsMat,lagsFromFitMat,uniqueColorDirs(:), directionGroups, plotInfo,'plotColors',plotColors','errorBarsCI',CIs,'yLimVals',yLimVals)

