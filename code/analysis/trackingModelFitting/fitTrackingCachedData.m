function fitTrackingCachedData(subjID)
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
%
% The bootstrap fitting is slow, and doesn't affect the figures.  So you
% can set that to false if you're just fussing with figures.
doBootstrapFits = false;
fitOneMechanism = false;
doDiagnosticBootPlots = false;
saveFigures = true;
verbose = false;

% Search with two different fmincon algorithms and take the best
% % 'active-set' 'sqp' 'interior-point'
theFminconAlgorithm0 = 'sqp'; 
theFminconAlgorithm1 = 'active-set';

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
%
% The fit error scalar is chosen by hand and seems to make
% the fits work a little better.
defaultParamsInfo = [];
fitErrorScalar    = 100000;

% One mechanism
%
% Not doing this in the end.  Should add grid search/algorithm logic from
% below if we ever put it back.
if (fitOneMechanism)
    [rotMOneMechParams,~,lagsFromFitOneMech] = ctmOBJmechOne.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
        'initialParams',[], 'fitErrorScalar',fitErrorScalar);
    lagsOneMechMat = reshape(lagsFromFitOneMech.values,size(lagsMat));
end

% Two mechanism fit.
%
% We do a grid search of starting parameters, as the fit can get stuck,
% We also search with two different fmincon algorithms and take the better
% of the two fits, for each choice of initial parameters.
fprintf('Fitting actual data from multiple starting points\n');
initialAngles = -95:10:95;
initialRatios = linspace(0.01,0.09,3);
initialParam3s = [0.5 1];
initialParam4s = [0.4];
initialParam5s = [0.15];
initialParamsMatrix =  [];
for ii1 = 1:length(initialAngles)
    for ii2 = 1:length(initialRatios);
        for ii3 = 1:length(initialParam3s);
            for ii4 = 1:length(initialParam4s);
                for ii5 = 1:length(initialParam5s)
                    initialParamsMatrix = [initialParamsMatrix [initialAngles(ii1) initialRatios(ii2) initialParam3s(ii3) initialParam4s(ii4) initialParam5s(ii5)]'];
                end
            end
        end
    end
end
% initialParamsMatrix = [ [75 .03 1 0.3 0.15]' [90 0.02 0.5 0.4 0.15]'  [90 0.08 0.5 0.4 0.15]'  [45 0.02 0.5 0.4 0.15]'  [45 0.08 0.5 0.4 0.15]'  ...
%     [0 0.02 0.5 0.4 0.15]'  [0 0.08 0.5 0.4 0.15]'  ...
%     [-45 0.02 0.5 0.4 0.15]'  [-45 0.08 0.5 0.4 0.15]'  [-90 0.02 0.5 0.4 0.15]'  [-905 0.08 0.5 0.4 0.15]'];
fVal = Inf;
for ss = 1:size(initialParamsMatrix,2)
    if (verbose)
        fprintf('\tStarting point %d of %d ...');
    end
    initialParamsStruct = ctmOBJmechTwo.vecToParams(initialParamsMatrix(:,ss));
    [rotMTwoMechParams0,fVal0,lagsFromFitTwoMech0] = ctmOBJmechTwo.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
        'initialParams',initialParamsStruct, 'fitErrorScalar',fitErrorScalar,'fminconAlgorithm',theFminconAlgorithm0);
    [rotMTwoMechParams1,fVal1,lagsFromFitTwoMech1] = ctmOBJmechTwo.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
        'initialParams',initialParamsStruct, 'fitErrorScalar',fitErrorScalar,'fminconAlgorithm',theFminconAlgorithm1);
    if (fVal0 < fVal1)
        rotMTwoMechParamsTemp = rotMTwoMechParams0;
        fValTemp = fVal0;
        lagsFromFitTwoMechTemp = lagsFromFitTwoMech0;
    else
        rotMTwoMechParamsTemp = rotMTwoMechParams1;
        fValTemp = fVal1;
        lagsFromFitTwoMechTemp = lagsFromFitTwoMech1;
    end

    if (fValTemp < fVal)
        if (verbose)
            fprintf('best so far.\n');
        end
        fVal = fValTemp;
        rotMTwoMechParams = rotMTwoMechParamsTemp;
        lagsFromFitTwoMech =  lagsFromFitTwoMechTemp;
    else
        if (verbose)
            fprintf('not as good as one already done.\n');
        end
    end
end

% Save out fit lags for plotting
lagsTwoMechMat = reshape(lagsFromFitTwoMech.values,size(lagsMat));

% Bootstrapping
if (doDiagnosticBootPlots)
    bootDiagFigure = figure;
end
if (doBootstrapFits)

    % Set up basic bootstrap packet
    theBootPacket = thePacket;

    % Now do the fit for each bootstrap iteration
    nBootstraps = size(bootData.rParamsBtstrpStruct(1).rParamsBtstrp,3);
    bootParamsStruct = bootData.rParamsBtstrpStruct;
    for bb = 1:nBootstraps
        lagsBtstrp = [];

        % There is one bootstrap parameter structure for each of the three
        % datasets.
        for ss = 1:length(bootParamsStruct)
            % Each row is for one parameter.
            rParamsBtstrp = bootParamsStruct(ss).rParamsBtstrp;
            lagsBtstrpTemp = flipud(squeeze(rParamsBtstrp(2,:,bb,:)));
            lagsBtstrp = [lagsBtstrp lagsBtstrpTemp];
        end

        % Look at the measured lags and bootstrapped lags, just to make 
        % sure we've decoded things rightif (doDiagnosticBootPlots)
        if (doDiagnosticBootPlots)
            figure(bootDiagFigure); clf; hold on;
            plot(lagsMat(:),lagsBtstrp(:),'r+');
            axis('square'); xlim([0.1 1]); ylim([0.1 1]);
        end

        % Stick the bootstrapped lags data into the
        % bootstrapped packet. Unpacking this in the same way
        % as the real data above get unpacked. The flipud is needed
        % so that things make sense, and I think it was applied somewhere 
        % when pcData were created. 
        theBootPacket.response.values = lagsBtstrp(:)';

        % Do the bootstrapped data fit.
        %
        % Fit with two different fmincon algorithms and take the best
        if (verbose)
            fprintf('Fitting boostrap %d from multiple starting points\n',bb);
        else
            if (bb == 1)
                fprintf('Fitting bootstrapped data\n');
            end
        end
        fValBoot(bb) = Inf;
        for ss = 1:size(initialParamsMatrix,2)
            if (verbose)
                fprintf('\tStarting point %d of %d ...');
            end
            initialParamsStruct = ctmOBJmechTwo.vecToParams(initialParamsMatrix(:,ss));

            [rotMTwoMechParamsBoot0{bb},fValBoot0(bb),lagsFromFitTwoMechBoot0{bb}] = ctmOBJmechTwo.fitResponse(theBootPacket,'defaultParamsInfo',defaultParamsInfo,...
                'initialParams',initialParamsStruct, 'fitErrorScalar',fitErrorScalar,'fminconAlgorithm',theFminconAlgorithm0);
            [rotMTwoMechParamsBoot1{bb},fValBoot1(bb),lagsFromFitTwoMechBoot1{bb}] = ctmOBJmechTwo.fitResponse(theBootPacket,'defaultParamsInfo',defaultParamsInfo,...
                'initialParams',initialParamsStruct, 'fitErrorScalar',fitErrorScalar,'fminconAlgorithm',theFminconAlgorithm1);
            if (fValBoot0(bb) < fValBoot1(bb))
                rotMTwoMechParamsBootTemp{bb} = rotMTwoMechParamsBoot0{bb};
                fValBootTemp(bb) = fValBoot0(bb);
                lagsFromFitTwoMechBootTemp{bb} = lagsFromFitTwoMechBoot0{bb};
            else
                rotMTwoMechParamsBootTemp{bb} = rotMTwoMechParamsBoot1{bb};
                fValBootTemp(bb) = fValBoot1(bb);
                lagsFromFitTwoMechBootTemp{bb} = lagsFromFitTwoMechBoot1{bb};
            end

            if (fValBootTemp(bb) < fValBoot(bb))
                if (verbose)
                    fprintf('best so far.\n');
                end
                rotMTwoMechParamsBoot{bb} = rotMTwoMechParamsBootTemp{bb};
                fValBoot(bb) = fValBootTemp(bb);
                lagsFromFitTwoMechBoot{bb} = lagsFromFitTwoMechBootTemp{bb};
            else
                if (verbose)
                    fprintf('not as good as one already done.\n');
                end
            end
        end
    end
end

%% Pull out bootstrapped parameters from structure
if (doBootstrapFits)
    for bb = 1:nBootstraps
        anglesBoot(bb) = rotMTwoMechParamsBoot{bb}.angle;
        minAxisRatiosBoot(bb) = rotMTwoMechParamsBoot{bb}.minAxisRatio;
        scalesBoot(bb) = rotMTwoMechParamsBoot{bb}.scale;
        minLagsBoot(bb) = rotMTwoMechParamsBoot{bb}.minLag;
        amplitudesBoot(bb) = rotMTwoMechParamsBoot{bb}.amplitude;
    end

    % Fix boot angles sign so that they are all consistent when averaged.
    anglesBoot(anglesBoot < 0) = anglesBoot(anglesBoot < 0) + 180;
end

%% Print the params
if (fitOneMechanism)
    fprintf('\ntfeCTM One Mechanism Parameters:\n');
    ctmOBJmechOne.paramPrint(rotMOneMechParams);
end

fprintf('\ntfeCTM Two Mechanism Parameters:\n');
ctmOBJmechTwo.paramPrint(rotMTwoMechParams);

% Print boostrap info if we did it
if (doBootstrapFits)
    % Report on bootstrapped values.  Taking the standard deviation of the
    % bootstrapped quantity gives us an estimate of the standard error of
    % that quantity.
    fprintf('Bootstrapped ellipse angle: %0.1f +/- %0.3f\n',mean(anglesBoot),std(anglesBoot));
    fprintf('Bootstrapped min axis ratio: %0.2f +/- %0.3f\n',mean(minAxisRatiosBoot),std(minAxisRatiosBoot));
end

%% Plots ellipse and summary fit plot 
[tcHndlCont,tcHndlNonlin] = plotIsoContAndNonLin(rotMTwoMechParams,'thePacket',thePacket,'plotInfo',plotInfo, ...
    'desiredEqContrast',1,'ellipseXLim',1.25,'ellipseYLim',1.25,'saveFigure',saveFigures);

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
    directionGroups = {[0,90],[75,-75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.6,88.6,87.6],[22.5,-1.4,-22.5]};
    yLimVals = [0.2 0.9];
elseif strcmp(subjID,'BMC')
    directionGroups = {[0,90],[75,-75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.1,88.1,87.1],[22.5,-0.9,-22.5]};
    yLimVals = [0.2 0.6];
elseif strcmp(subjID,'KAS')
    directionGroups = {[0,90],[75,-75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.1,88.1,87.1],[22.5,-1.9,-22.5]};
    yLimVals = [0.2 0.8];
end

% Do the plot
plotColors = thePacket.metaData.dirPlotColors;
plotDirectionPairs(100*matrixContrasts,lagsMat,lagsTwoMechMat,uniqueColorDirs(:), directionGroups, plotInfo,'plotColors',plotColors','errorBarsCI',CIs,'yLimVals',yLimVals, ...
    'figSaveInfo',saveFigures);

%% Find lag difference for L and S cone directions at equal contrast
%
% Need to compute and plot/analyze model predictions for a larger
% range of contrasts than we measured.
%
% Set up to compute.  We use the fit parameter values and compute
% for L and S cone isolating modulations of the same set of contrasts,
% over a range of contrasts.
lowContrast = 0.05;
highContrast = 0.9;
nContrasts = 100;
LConePacket = thePacket;
SConePacket = thePacket;
targetConeContrasts = linspace(lowContrast,highContrast,nContrasts);
otherConeContrasts = zeros(size(targetConeContrasts));
LConePacket.stimulus.values = [targetConeContrasts ; otherConeContrasts];
LConePacket.stimulus.timebase = 1:length(targetConeContrasts);
SConePacket.stimulus.values = [otherConeContrasts ; targetConeContrasts];
SConePacket.stimulus.timebase = 1:length(targetConeContrasts);
LConeLags = ctmOBJmechTwo.computeResponse(rotMTwoMechParams,LConePacket.stimulus);
SConeLags = ctmOBJmechTwo.computeResponse(rotMTwoMechParams,SConePacket.stimulus);

% Plot the model computed L and S cone lags on the same plot.  You can
% add black lines to show the fits at the measured contrasts, as a check that we've
% done everything right here.
figure; clf; hold on;
LDirIndex = 1;
SDirIndex = 2;
plot(100*targetConeContrasts,LConeLags.values,'r','LineWidth',5);
plot(100*targetConeContrasts,SConeLags.values,'b','LineWidth',5);
if (100*true)
    plot(100*matrixContrasts(:,LDirIndex),lagsTwoMechMat(:,LDirIndex),'k','LineWidth',3);
    plot(100*matrixContrasts(:,SDirIndex),lagsTwoMechMat(:,SDirIndex),'k','LineWidth',3);
end
xlabel('Contrast');
ylabel('Lag (seconds')

% Make plot of S lag versus L lag, over the contrast range
figure; clf; hold on;
plot(LConeLags.values,SConeLags.values,'k','LineWidth',5)
axis('square');
xlabel('L Cone Lag');
ylabel('S Cone Lag');
xlim([0.3 1]);
ylim([0.3 1]);

% Even better, plot S cone delay relative to L cones, as
% a function of contrast
tcHndl = figure; clf; hold on;
plot(100*targetConeContrasts,SConeLags.values-LConeLags.values,'k','LineWidth',5);
axis('square');
xlabel('Contrast (%)');
ylabel('S Cone Lag - L Cone Lag');
xlim([0 100]);
ylim([0 0.6]);

if (saveFigures)
    figureSizeInches = plotInfo.figureSizeInches;
    tcHndl.Units  = 'inches';
    tcHndl.PaperUnits  = 'inches';
    tcHndl.PaperSize = figureSizeInches;
    tcHndl.OuterPosition = [0 0 figureSizeInches(1) figureSizeInches(2)];
    tcHndl.InnerPosition = [.5 .5 figureSizeInches(1)-.5 figureSizeInches(2)-.5];
    figNameTc =  fullfile(plotInfo.figSavePath,[plotInfo.subjCode, '_SlessLConeLag.pdf']);
    print(tcHndl, figNameTc, '-dpdf', '-r300');
    exportgraphics(tcHndl,figNameTc);
end

end