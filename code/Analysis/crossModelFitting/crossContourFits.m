% Cross-Contour fit
%% ######## Genreral set-up stuff ########
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

%% Load the the data for the tracking task
load(fullfile(paramsCacheFolder,'tracking',[subjCode '_paramsCache.mat']));

% make the packet
lagVec = lagsMat(:)';
timebaseCTM = 1:length(lagVec);

% Initialize the packet
thePacketCTM.response.values   = lagVec;
thePacketCTM.response.timebase = timebaseCTM;

% The stimulus
thePacketCTM.stimulus.values   = [cL(:),cS(:)]';
thePacketCTM.stimulus.timebase = timebaseCTM;

% The Kernel
thePacketCTM.kernel.values = [];
thePacketCTM.kernel.timebase = [];

% The Meta Data
thePacketCTM.metaData.stimDirections = atand(cS(:)./cL(:));
thePacketCTM.metaData.stimContrasts  = vecnorm([cS(:),cL(:)]')';

%% ######## Fit the data for the tracking task  #######
% make the CTM fit object
theDimension= size(thePacketCTM.stimulus.values, 1);
ctmOBJ = tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

% fit it
defaultParamsInfo = [];
fitErrorScalar    = 100000;

[lagParams,fValLags,lagsFromFitParams] = ctmOBJ.fitResponse(thePacketCTM,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

%% ######## Load the data for the detection task ########
clear cL cS MaxContrastLMS
load(fullfile(paramsCacheFolder,'detection',[subjCode '_pcCache.mat']));

% make the packet
pcVec = pcData(:)';
timebaseLSD = 1:length(pcVec);

% Initialize the packet
thePacketLSD.response.values   = pcVec;
thePacketLSD.response.timebase = timebaseLSD;

% The stimulus
thePacketLSD.stimulus.values   = [cL(:),cS(:)]';
thePacketLSD.stimulus.timebase = timebaseLSD;

% The Kernel
thePacketLSD.kernel.values = [];
thePacketLSD.kernel.timebase = [];

% The Meta Data
thePacketLSD.metaData.stimDirections = atand(cS(:)./cL(:));
thePacketLSD.metaData.stimContrasts  = vecnorm([cS(:),cL(:)]')';



%% Fit the data for the the detection task

% Make the LSD fit object
theDimension= size(thePacketLSD.stimulus.values, 1);
lsdOBJ = tfeLSD('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

defaultParamsInfo = [];
% get subject specific error scalar
if strcmp(subjID,'MAB')
    fitErrorScalar    = 100;
elseif strcmp(subjID,'BMC')
    fitErrorScalar    = 10;
elseif strcmp(subjID,'KAS')
    fitErrorScalar    = 10;
end

% fit it
[pcParams,fValPC,pcFromFitParams] = lsdOBJ.fitResponse(thePacketLSD,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);

%% Swap the ellipse params across fits
pcParamsSwapInit  = pcParams;
lagParamsSwapInit = lagParams;

pcParamsSwapInit.angle = lagParams.angle;
pcParamsSwapInit.minAxisRatio = lagParams.minAxisRatio;

lagParamsSwapInit.angle = pcParams.angle;
lagParamsSwapInit.minAxisRatio = pcParams.minAxisRatio;

%% Fit the model for both tasks with swapped params locked

fitErrorScalar    = 100000;

[lagParamsSwap,fValLags,~] = ctmOBJ.fitResponse(thePacketCTM,'defaultParamsInfo',[],...
    'initialParams',lagParamsSwapInit, 'fitErrorScalar',fitErrorScalar,'lockAngle',true,'lockMAR',true);

defaultParamsInfo = [];
% get subject specific error scalar
if strcmp(subjID,'MAB')
    fitErrorScalar    = 100;
elseif strcmp(subjID,'BMC')
    fitErrorScalar    = 10;
elseif strcmp(subjID,'KAS')
    fitErrorScalar    = 10;
end

% fit it
[pcParamsSwap,fValPC,~] = lsdOBJ.fitResponse(thePacketLSD,'defaultParamsInfo',[],...
    'initialParams',pcParamsSwapInit, 'fitErrorScalar',fitErrorScalar,'lockAngle',true,'lockMAR',true);


lagsSwapped = ctmOBJ.computeResponse(lagParamsSwap,thePacketCTM.stimulus,thePacketCTM.kernel);
lagsSwappedMat = reshape(lagsSwapped.values,size(lagsMat));
lagsFromFitMat = reshape(lagsFromFitParams.values,size(lagsMat));

pcSwapped   = lsdOBJ.computeResponse(pcParamsSwap,thePacketLSD.stimulus,thePacketLSD.kernel);
pcSwappedMat = reshape(pcSwapped.values,size(pcData));
pcFromFitMat = reshape(pcFromFitParams.values,size(pcData));


%% Plot the results for the tracking
% general stuff for both taks
dirsPerTask  = [-45,0,45,90];
numPlotsPerTask = length(dirsPerTask);

theDirsCTM = unique(thePacketCTM.metaData.stimDirections,'stable');
theDirsLSD = unique(thePacketCTM.metaData.stimDirections,'stable');

ctmContrastMat = reshape(vecnorm(thePacketCTM.stimulus.values),size(lagsMat));
lsdContrastMat = reshape(vecnorm(thePacketLSD.stimulus.values),size(pcData));

sz = 6;
plotColorsFull =  [230 172 178; ...
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

tcHndl = figure;
for ii = 1:numPlotsPerTask
    subplot(2,numPlotsPerTask,ii);hold on

    indx = find(dirsPerTask(ii) == theDirsCTM);

    theColors(ii,:) =  plotColorsFull(indx,:);

    indx = find(dirsPerTask(ii) == theDirsLSD);
    plot(ctmContrastMat(:,indx),lagsMat(:,indx),'o', ...
        'MarkerEdgeColor',.3*theColors(ii,:),...
        'MarkerFaceColor',theColors(ii,:),...
        'Color',theColors(ii,:),...
        'LineWidth',1,...
        'MarkerSize',sz);

    plot(ctmContrastMat(:,indx),lagsFromFitMat(:,indx),'-', ...
        'Color',theColors(ii,:),...
        'LineWidth',1.5);

    plot(ctmContrastMat(:,indx),lagsSwappedMat(:,indx),'--', ...
        'Color',.7*theColors(ii,:),...
        'LineWidth',1.5);
    

    yLimVals = [min(lagsMat(:)) max(lagsMat(:))];
    ylim(yLimVals)

    xAxisMax = max(ctmContrastMat(:,indx));
    xlim([0,xAxisMax.*1.15]);

    nTicks = 3;
    autoTicksX = round(0:max(xAxisMax)./nTicks:max(xAxisMax),4);
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'FontSize'    , 5        , ...
        'TickLength'  , [.02 .02] , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'on'      , ...
        'YGrid'       , 'on'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'YTick'       , 0:.1:1, ...
        'LineWidth'   , 1         , ...
        'ActivePositionProperty', 'OuterPosition');
    axis square
    xticks(autoTicksX)

    for jj = 1:length(autoTicksX)
        tickNames{jj} = sprintf('%1.1f',autoTicksX(jj));
    end
    xticklabels(tickNames)

    set(gcf, 'Color', 'white' );

    %% Add labels

    hTitle  = title (sprintf('%2.2f^o',dirsPerTask(ii)));


    hXLabel = xlabel('Contrast');


    hYLabel = ylabel('Lags (S)');


    %% Add Legend
    set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
    set([hXLabel, hYLabel,],'FontSize', 6);
    set( hTitle, 'FontSize', 6,'FontWeight' , 'normal');

end
%% Plot the results for the detection


for ii = 1:numPlotsPerTask
    subplot(2,numPlotsPerTask,ii+numPlotsPerTask);hold on

    indx = find(dirsPerTask(ii) == theDirsLSD);
    plot(lsdContrastMat(:,indx),pcData(:,indx),'o', ...
        'MarkerEdgeColor',.3*theColors(ii,:),...
        'MarkerFaceColor',theColors(ii,:),...
        'Color',theColors(ii,:),...
        'LineWidth',1,...
        'MarkerSize',sz);

    plot(lsdContrastMat(:,indx),pcFromFitMat(:,indx),'-', ...
        'Color',theColors(ii,:),...
        'LineWidth',1.5);

    plot(lsdContrastMat(:,indx),pcSwappedMat(:,indx),'--', ...
        'Color',0.7.*theColors(ii,:),...
        'LineWidth',1.5);
    
    yLimVals = [min(pcData(:)) 1];
    ylim(yLimVals)

    xAxisMax = max(lsdContrastMat(:,indx));
    xlim([0,xAxisMax.*1.15]);

    nTicks = 3;
    autoTicksX = round(0:max(xAxisMax)./nTicks:max(xAxisMax),4);
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'FontSize'    , 5        , ...
        'TickLength'  , [.02 .02] , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'on'      , ...
        'YGrid'       , 'on'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'YTick'       , 0:.1:1, ...
        'LineWidth'   , 1         , ...
        'ActivePositionProperty', 'OuterPosition');

    set(gcf, 'Color', 'white' );
    
    axis square
    %% Add labels

    hTitle  = title (sprintf('%2.2f^o',dirsPerTask(ii)));


    hXLabel = xlabel('Contrast');


    hYLabel = ylabel('Percent Correct');


    %% Add Legend
    set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
    set([hXLabel, hYLabel,],'FontSize', 6);
    set( hTitle, 'FontSize', 6,'FontWeight' , 'normal');

end



% Save it!
figureSizeInches = [6.5 32];
% set(tcHndl, 'PaperUnits', 'inches');
% set(tcHndl, 'PaperSize',figureSizeInches);
tcHndl.Units  = 'inches';
tcHndl.PaperUnits  = 'inches';
tcHndl.PaperSize = figureSizeInches;
% tcHndl.OuterPosition = [0 0 figureSizeInches(1) figureSizeInches(2)];
% tcHndl.InnerPosition = [0 0 figureSizeInches(1) figureSizeInches(2)];
figSavePath = getpref(projectName,'figureSavePath');
figNameTc =  fullfile(figSavePath,[subjCode, '_crossContourFits.pdf']);
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');

