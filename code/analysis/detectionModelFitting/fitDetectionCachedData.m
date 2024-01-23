function fitDetectionCachedData(subjID)
%%%%%%% Do the detection model for the 1 and 2 mech models %%%%%%%

% Run as here to analyze all subjects
%{
    e
%}

%% Close
close all;

%% Parameters
doBootstrapFits = true;
doDiagnosticBootPlots = true;
verbose = false;

% Get subject code from subjID
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
    subjNum = 1;
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
    subjNum = 2;
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
    subjNum = 3;
end

% Set up names and places
projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');
bootParamsCacheFolder = fullfile(getpref(projectName,'bootParamsCacheFolder'),'detection');
plotInfo.figSavePath = getpref(projectName,'figureSavePath');
plotInfo.subjCode    = subjCode;

%% Load cached summary data
%
% DHB: 1/18/24.  Despite the name that suggests these are cached
% parameters, I think these are actually the experimental data
% in summary form, and that the model is fit below.
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

%% Fit it with subject specific error scalar
defaultParamsInfo = [];

% Get subject specific error scalar
if strcmp(subjID,'MAB')
    fitErrorScalar    = 100;
elseif strcmp(subjID,'BMC')
    fitErrorScalar    = 10;
elseif strcmp(subjID,'KAS')
    fitErrorScalar    = 10;
end

% Fit
[pcParams,fVal,pcFromFitParams] = lsdOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

%% Bootstrapping
if (doBootstrapFits)
    % Load the cached bootstrapped data
    bootFile = fullfile(bootParamsCacheFolder,['detectionBootsS' num2str(subjNum) 'cache.mat']);
    bootData = load(bootFile);

    % Get mean and std of bootstrapped pcs, so we can put error
    % bars on the psychometric function data points
    bootstrapMeanPc = flipud(mean(bootData.PCdtaBoot(:,:,:),3));
    bootstrapStdPc = flipud(std(bootData.PCdtaBoot(:,:,:),[],3));
    if (doDiagnosticBootPlots)
        figure; clf; hold on;
        plot(pcData(:)',bootstrapMeanPc(:)','r+');
        axis('square');
        xlim([0.3 1]); ylim([0.3 1]);
    end

    % Set up basic bootstrap packet
    theBootPacket = thePacket;

    % Now do the fit for each bootstrap iteration
    nBootstraps = size(bootData.tFitBoot,2);
    for bb = 1:nBootstraps
        % Stick the bootstrapped probability correct data into the
        % bootstrapped packet. Unpacking this in the same way
        % as the real data above get unpacked. The flipud is needed
        % so that things make sense, and I think it was applied somewhere 
        % when pcData were created. 
        bootPcData = flipud(squeeze(bootData.PCdtaBoot(:,:,bb)));
        theBootPacket.response.values = bootPcData(:)';

        % Do the bootstrapped data fit
        [pcParamsBoot{bb},fValBoot(bb),pcFromFitParamsBoot{bb}] = lsdOBJ.fitResponse(theBootPacket,'defaultParamsInfo',defaultParamsInfo,...
            'initialParams',[], 'fitErrorScalar',fitErrorScalar);

        anglesBoot(bb) = pcParamsBoot{bb}.angle;
        minAxisRatiosBoot(bb) = pcParamsBoot{bb}.minAxisRatio;
        lambdasBoot(bb) = pcParamsBoot{bb}.lambda;
        exponentsBoot(bb) = pcParamsBoot{bb}.exponent;
    end
end

% Fix boot angles sign so that they are all consistent when averaged.
anglesBoot(anglesBoot < 0) = anglesBoot(anglesBoot < 0) + 180;

%% Print the params
fprintf('\ntfeCTM Two Mechanism Parameters:\n');
lsdOBJ.paramPrint(pcParams)

%% Print boostrap fit info if we did it
if (doBootstrapFits)
    % Report on bootstrapped values.  Taking the standard deviation of the
    % bootstrapped quantity gives us an estimate of the standard error of
    % that quantity.
    fprintf('Bootstrapped ellipse angle: %0.1f +/- %0.3f\n',mean(anglesBoot),std(anglesBoot));
    fprintf('Bootstrapped min axis ratio: %0.2f +/- %0.3f\n',mean(minAxisRatiosBoot),std(minAxisRatiosBoot));
end

%% Make the figures
%
% Diagnostic plot.  Compare data, starting fit, and the actual fit
pcFromStartParams = lsdOBJ.computeResponse(lsdOBJ.defaultParams,thePacket.stimulus,thePacket.kernel);
figure; hold on;
plot(pcVec,'k','LineWidth',2);
plot(pcFromStartParams.values,'g','LineWidth',2,'LineStyle','-');
plot(pcFromFitParams.values,'r','LineWidth',2,'LineStyle','--');

% Isoresponse contour and summary evaluation of fit to non-linearity
plotIsoContLSD(pcParams,'thePacket',thePacket,'plotInfo',plotInfo, ...
    'desiredEqContrast',1,'ellipseXLim',0.2,'ellipseYLim',1.25);

% Montage of psychometric functions
uniqColorDirs = unique(thePacket.metaData.stimDirections)';
plotInfo.xlabel  = 'Contrast (%)';
plotInfo.ylabel = 'Percent Correct'; plotInfo.figureSizeInches = [6 5];
plotColors = thePacket.metaData.dirPlotColors;
plotPsychometric(pcParams,pcData,matrixContrasts,uniqColorDirs,plotInfo,'plotColors',plotColors, ...
    'errorBarsSTD',bootstrapStdPc);

% Establish delay between L and S contrast equated stimuli

end