function [] = plotPsychometric(pcParams,pcData,matrixContrasts,uniqueColorDirs,plotInfo,varargin)
%% Take in lags and model fits and plot them is a series of subplots.
%
% Synopsis
%   plotPsychometric(pcParams,pcData,MaxContrastLMS,rgbMatrixForPlotting,varargin)
%
% Description
%  This function smooths function data with the burred mask seperatly in
%  the left and right hemispere and combines the hemis.
%
% Inputs
%  backgroundPrimaries:       Speficy primary values for background (vector).
%  LMScontrastModulation:     Speficy LMS contrast vector (vector).
%
% Key/val pairs
%  -none
%
% Output
%  -none

% MAB 06/20/21 -- started

% Input Parser
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('pcParams',@isstruct);
p.addRequired('pcData',@ismatrix);
p.addRequired('matrixContrasts',@ismatrix);
p.addRequired('uniqColorDirs',@isnumeric);
p.addRequired('plotInfo',@isstruct);
p.addParameter('plotColors',[],@ismatrix);
p.addParameter('errorBarsSTD',[],@isnumeric);
p.addParameter('errorBarsCI',[],@isstruct);
p.addParameter('semiLog',false,@islogical);
p.addParameter('sz',4,@isnumeric);
p.addParameter('figSaveInfo',true,@islogical);
p.addParameter('nSmplPnts',50,@isnumeric);
p.addParameter('legendLocation','northeast',@ischar);
p.parse(pcParams,pcData,matrixContrasts, uniqueColorDirs, plotInfo, varargin{:});


%% unpack the parser
legendLocation  = p.Results.legendLocation;
sz = p.Results.sz;
yLimVals = [min(pcData(:)) 1];
nSmplPnts = p.Results.nSmplPnts;
%% get a color map if none is provided
if isempty(p.Results.plotColors)
    colorMapJet = jet;
    if mod(length(uniqueColorDirs(:)),2) == 1
        colorPlotLength = length(uniqueColorDirs(:))+1;
    else
        colorPlotLength = length(uniqueColorDirs(:));
    end
    colorMapIndx = round(linspace(1,size(colorMapJet,1),colorPlotLength));
    tmpShuff = [colorMapIndx(1:(colorPlotLength/2));colorMapIndx(colorPlotLength/2+1:colorPlotLength)];
    colorMapIndx = tmpShuff(:);
    plotColors  = colorMapJet(colorMapIndx,:)';
else
    plotColors = p.Results.plotColors;
end

if ~isempty(p.Results.errorBarsCI)
    theErrorMat = p.Results.errorBarsCI;
elseif ~isempty(p.Results.errorBarsSTD)
    theErrorMat = p.Results.errorBarsSTD;
else
    theErrorMat = [];
end

% get the number of subplots/ rows and cols
nColorDirPlots = size(pcData,2);
numPlotRows    = floor(sqrt(nColorDirPlots));
numPlotCols    = ceil(nColorDirPlots./numPlotRows);

tcHndl = figure;hold on

% create the cumulative Weibull function
theDimension= 2;
lsdOBJ = tfeLSD('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');
thePacket.kernel.values = [];
thePacket.kernel.timebase = [];

% Break up direction into indivual subplots
% the based on the directionGroups cell
for ii = 1:nColorDirPlots
    xAxisVals = matrixContrasts(:,ii);
    yAxisVals = pcData(:,ii);
    currPlotColor = plotColors(ii,:);

    subplot( numPlotRows,numPlotCols,ii)

    hold on;
    if ~isempty(p.Results.errorBarsSTD)
        e = errorbar(xAxisVals(:,jj),yAxisVals(:,jj),theErrorMat(:,jj),'o')
    elseif ~isempty(p.Results.errorBarsCI);
        e = errorbar(xAxisVals(:,jj),yAxisVals(:,jj),theErrorMat.lower(:,jj),theErrorMat.upper(:,jj),...
            'o','LineWidth',2,'Color',currPlotColors(:,jj));
    end

    % Make the packet for current direction
    cSmpleBase = 0:max(xAxisVals)./nSmplPnts:max(xAxisVals);
    cS = cSmpleBase.*sind(uniqueColorDirs(ii));
    cL = cSmpleBase.*cosd(uniqueColorDirs(ii));
    thePacket.stimulus.values = [cL;cS];
    thePacket.stimulus.timebase = 1:length(cS);
    pcFromParamsFit = lsdOBJ.computeResponse(pcParams,thePacket.stimulus,thePacket.kernel);


    plot(cSmpleBase,pcFromParamsFit.values,'-', ...
        'MarkerEdgeColor',.3*currPlotColor,...
        'MarkerFaceColor',currPlotColor,...
        'Color',currPlotColor,...
        'LineWidth',1.5,...
        'MarkerSize',sz);

    h{ii} =  plot(xAxisVals,yAxisVals,'o', ...
        'MarkerEdgeColor',.3*currPlotColor,...
        'MarkerFaceColor',currPlotColor,...
        'Color',currPlotColor,...
        'LineWidth',1,...
        'MarkerSize',sz);

    axis square;

    if p.Results.semiLog
        set(gca,'Xscale','log');
    end

    ylim(yLimVals)
    xlim([0,max(xAxisVals.*1.15)])

    nTicks = 3;
    autoTicksX = round(0:max(xAxisVals)./nTicks:max(xAxisVals),4);
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
    
    xticks(autoTicksX)

    for jj = 1:length(autoTicksX)
        tickNames{jj} = sprintf('%1.1f',100*autoTicksX(jj)); 
    end
    xticklabels(tickNames)

    set(gcf, 'Color', 'white' );


    %% Format fonts


    %% Add labels

    hTitle  = title (sprintf('%2.2f^o',uniqueColorDirs(ii)));


    hXLabel = xlabel(plotInfo.xlabel);


    hYLabel = ylabel(plotInfo.ylabel);


    %% Add Legend
    set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
    set([hXLabel, hYLabel,],'FontSize', 6);
    set( hTitle, 'FontSize', 6,'FontWeight' , 'normal');


end


% Save it!
figureSizeInches = plotInfo.figureSizeInches;
% set(tcHndl, 'PaperUnits', 'inches');
% set(tcHndl, 'PaperSize',figureSizeInches);
tcHndl.Units  = 'inches';
tcHndl.PaperUnits  = 'inches';
tcHndl.PaperSize = figureSizeInches;
% tcHndl.OuterPosition = [0 0 figureSizeInches(1) figureSizeInches(2)];
% tcHndl.InnerPosition = [0 0 figureSizeInches(1) figureSizeInches(2)];

figNameTc =  fullfile(plotInfo.figSavePath,[plotInfo.subjCode, '_LSD_psychometric.pdf']);
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');

end