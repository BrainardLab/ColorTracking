function [] = plotDirectionPairs(matrixContrasts,lags,lagsFromFitMat,uniqueColorDirs, directionGroups, plotInfo,varargin)
%% Take in lags and model fits and plot them is a series of subplots.
%
% Synopsis
%   plotParamsVsContrast(rParams,MaxContrastLMS,rgbMatrixForPlotting,varargin)
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
p.addRequired('matrixContrasts',@ismatrix);
p.addRequired('lags',@ismatrix);
p.addRequired('lagsFromFitMat',@ismatrix);
p.addRequired('uniqColorDirs',@isnumeric);
p.addRequired('directionGroups',@iscell);
p.addRequired('plotInfo',@isstruct);
p.addParameter('plotColors',[],@ismatrix);
p.addParameter('errorBarsSTD',[],@isnumeric);
p.addParameter('errorBarsCI',[],@isstruct);
p.addParameter('semiLog',true,@islogical);
p.addParameter('sz',9,@isnumeric);
p.addParameter('yLimVals',[0.2 0.8],@isnumeric);
p.addParameter('figSaveInfo',true,@islogical);
p.addParameter('legendLocation','northeast',@ischar);
p.parse(matrixContrasts,lags,lagsFromFitMat, uniqueColorDirs,directionGroups, plotInfo, varargin{:});


%% unpack the parser
legendLocation  = p.Results.legendLocation;
sz = p.Results.sz;
yLimVals = p.Results.yLimVals;

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
nColorDirPlots = length(directionGroups);
numPlotRows    = floor(sqrt(nColorDirPlots));
numPlotCols    = ceil(nColorDirPlots./numPlotRows);

tcHndl = figure;hold on

% Break up direction into indivual subplots
% the based on the directionGroups cell
for ii = 1:(nColorDirPlots)
    theDirections = directionGroups{ii};
    directionIndx = find(sum(theDirections == uniqueColorDirs,2));
    xAxisVals = matrixContrasts(:,directionIndx);
    yAxisVals = lags(:,directionIndx);
    modelFitLags = lagsFromFitMat(:,directionIndx);
    currPlotColors = plotColors(:,directionIndx);
    
    subplot( numPlotRows,numPlotCols,ii)
    
    for kk = 1:length(theDirections)
        plotInfo.legend{kk} = sprintf('%s°',num2str(theDirections(kk)));
    end
    
    
    for jj = 1:length(theDirections)
        
        hold on;
        if ~isempty(p.Results.errorBarsSTD)
            e = errorbar(xAxisVals(:,jj),yAxisVals(:,jj),theErrorMat(:,jj),'o')
        elseif ~isempty(p.Results.errorBarsCI);
            e = errorbar(xAxisVals(:,jj),yAxisVals(:,jj),theErrorMat.lower(:,jj),theErrorMat.upper(:,jj),...
                'o','LineWidth',2,'Color',currPlotColors(:,jj));
        end
        
        
        plot(xAxisVals(:,jj),modelFitLags(:,jj),'--', ...
            'MarkerEdgeColor',.3*currPlotColors(:,jj),...
            'MarkerFaceColor',currPlotColors(:,jj),...
            'Color',currPlotColors(:,jj),...
            'LineWidth',2,...
            'MarkerSize',sz);
        
       h{jj} =  plot(xAxisVals(:,jj),yAxisVals(:,jj),'o', ...
            'MarkerEdgeColor',.3*currPlotColors(:,jj),...
            'MarkerFaceColor',currPlotColors(:,jj),...
            'Color',currPlotColors(:,jj),...
            'LineWidth',2,...
            'MarkerSize',sz);
    end
    axis square;
    
    if p.Results.semiLog
        set(gca,'Xscale','log');
    end
    
    set(gca,'XTick',[0.03 0.1 0.3 1]);
    
    ylim(yLimVals)
    
    autoTicksY = yLimVals(1):(yLimVals(2)-yLimVals(1))/4:yLimVals(2);
    
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'FontSize'    , 16        , ...
        'TickLength'  , [.02 .02] , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'on'      , ...
        'YGrid'       , 'on'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'YTick'       , autoTicksY, ...
        'LineWidth'   , 2         , ...
        'ActivePositionProperty', 'OuterPosition');
    
    set(gcf, 'Color', 'white' );
    
    
    %% Format fonts
    
    
    %% Add labels
    
    hTitle  = title (plotInfo.title);
    
    
    hXLabel = xlabel(plotInfo.xlabel);
    
    
    hYLabel = ylabel(plotInfo.ylabel);
    
    
    %% Add Legend
    
    legend([h{:}],plotInfo.legend,'Location',legendLocation);
    
    set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
    set([hXLabel, hYLabel,],'FontSize', 18);
    set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');
    
    plotInfo = rmfield(plotInfo,'legend');
end

% Save it!
figureSizeInches = plotInfo.figureSizeInches;
set(tcHndl, 'PaperUnits', 'inches');
set(tcHndl, 'PaperSize',figureSizeInches);
set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
figNameTc =  fullfile(plotInfo.figSavePath,[plotInfo.subjCode, '_model_fit_allData.pdf']);
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');
