function [] = plotDirectionPairs(matrixContrasts,lags,lagsFromFitMat,uniqColorDirs,plotColors,figSaveInfo)



tcHndl2 = figure;hold on
% Names for plotting
clear plotNames
plotNames.title  = 'Lag Vs. Contrast';
plotNames.xlabel  = 'Contrast (%)';
plotNames.ylabel = 'Lag (s)';
legendLocation = 'northeastoutside';
sz = 9;
yLimVals = [0.2 0.8];
semiLog = true;
for jj = 1:length(uniqColorDirs)
    plotNames.legend{jj} = sprintf('%s°',num2str(uniqColorDirs(jj)));
end

if isfield(plotNames,'title')
    hTitle  = title (plotNames.title);
end

numLines = size(lagsFromFitMat,2)/2;


% Loop over the lines
numPlotRows = floor(sqrt(numLines));
numPlotCols = ceil(sqrt(numLines));

% Break up direction into indivual subplots
% the order must be +/- pairs

for ii = 1:(numLines)
    subplot(numPlotRows,numPlotCols,ii)
    hold on
    
    scatter(matrixContrasts(:,2*(ii)-1),lags(:,2*(ii)-1),sz.^2, ...
        'MarkerEdgeColor',.3*plotColors(:,2*(ii)-1),...
        'MarkerFaceColor',plotColors(:,2*(ii)-1),...
        'LineWidth',2);
    
    plot(matrixContrasts(:,2*(ii)-1),lagsFromFitMat(:,2*(ii)-1),'--', ...
        'Color',plotColors(:,2*(ii)-1),...
        'LineWidth',2);
    
    scatter(matrixContrasts(:,2*(ii)),lags(:,2*(ii)),sz.^2, ...
        'MarkerEdgeColor',.3*plotColors(:,2*(ii)),...
        'MarkerFaceColor',plotColors(:,2*(ii)),...
        'LineWidth',2);
    
    plot(matrixContrasts(:,2*(ii)),lagsFromFitMat(:,2*(ii)),'--', ...
        'Color',plotColors(:,2*(ii)),...
        'LineWidth',2);
    
    title(sprintf('%s° & %s°',num2str(uniqColorDirs(2*(ii)-1)),num2str(uniqColorDirs(2*(ii)))))
    
    axis square;

    set(gca,'XTick',round((0:.2:1).^2,2));
    
    ylim(yLimVals)
    xlim([0 1])
    autoTicksY = yLimVals(1):(yLimVals(2)-yLimVals(1))/4:yLimVals(2);
    
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'FontSize'    , 14        , ...
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
     if semiLog
        set(gca,'Xscale','log');
    end
    
    % Add labels
    if isfield(plotNames,'xlabel')
        hXLabel = xlabel(plotNames.xlabel);
    end
    if isfield(plotNames,'ylabel')
        hYLabel = ylabel(plotNames.ylabel);
    end
    
end
% Add Legend
if isfield(plotNames,'legend')
    %    legend(plotNames.legend,'Location',legendLocation);
end
% Format fonts
%set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
%set([hXLabel, hYLabel,],'FontSize', 18);
%set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');

% Save it!
figureSizeInches = figSaveInfo.figureSizeInches;
set(tcHndl2, 'PaperUnits', 'inches');
set(tcHndl2, 'PaperSize',figureSizeInches);
set(tcHndl2, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
figNameTc =  fullfile(figSaveInfo.figSavePath,[figSaveInfo.subjCode, '_model_fit_allData.pdf']);
% Save it
print(tcHndl2, figNameTc, '-dpdf', '-r300');
