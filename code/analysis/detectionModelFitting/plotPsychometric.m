function [] = plotPsychometric(pcParams,pcData,matrixContrasts,uniqueColorDirs,plotInfo,varargin)
%% Plot the psychometric functions in a montage
%
% Synopsis
%   plotPsychometric(pcParams,pcData,MaxContrastLMS,rgbMatrixForPlotting,varargin)
%
% Description
%   Plot the psychometric functions in a montage
%
% Inputs:
%    Wouldn't it be nice if someone had described the input
%    arguments?  See fitDetectionCachedData for how this is called.
%
% Key/val pairs
%  -none
%
% Output
%  -none

% MAB 06/20/21 -- started

%% Input Parser
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

%% Unpack the parser
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

tcHndl = figure; hold on
set(gcf,'Position',[100 100 plotInfo.figureSizeInches(1)*75 plotInfo.figureSizeInches(2)*75]);

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

    % Make the packet for current direction
    cSmpleBase = 0:max(xAxisVals)./nSmplPnts:max(xAxisVals);
    cS = cSmpleBase.*sind(uniqueColorDirs(ii));
    cL = cSmpleBase.*cosd(uniqueColorDirs(ii));
    thePacket.stimulus.values = [cL;cS];
    thePacket.stimulus.timebase = 1:length(cS);
    pcFromParamsFit = lsdOBJ.computeResponse(pcParams,thePacket.stimulus,thePacket.kernel);

    % This was broken and I fixed up the STD part.  I guessed at but did
    % not test the right call for the CI part.
    if ~isempty(p.Results.errorBarsSTD)
        e = errorbar(xAxisVals,yAxisVals,theErrorMat(:,ii),'o','Color',currPlotColor);
    elseif ~isempty(p.Results.errorBarsCI)
        e = errorbar(xAxisVals,yAxisVals,theErrorMat.lower(:,ii),theErrorMat.upper(:,ii),...
            'o','LineWidth',2,'Color',currPlotColor);
    end

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

    % Tidy plot
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
tcHndl.Units  = 'inches';
tcHndl.PaperUnits  = 'inches';
tcHndl.PaperSize = figureSizeInches;
figNameTc =  fullfile(plotInfo.figSavePath,[plotInfo.subjCode, '_LSD_psychometric.pdf']);
print(tcHndl, figNameTc, '-dpdf', '-r300');

end