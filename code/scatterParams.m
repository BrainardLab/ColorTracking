function [tcHndl] = scatterParams(xAxisVals,yAxisVals,plotColors,plotNames,varargin)
%% Make a chromatic gabor of specified chormatic direction and orientation
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
p.addRequired('xAxisVals',@ismatrix);
p.addRequired('yAxisVals',@ismatrix);
p.addRequired('plotColors',@ismatrix);
p.addRequired('plotNames',@isstruct);
p.addParameter('sz',12,@isscalar);
p.addParameter('contrastAlpha',ones(size(yAxisVals)),@ismatrix);
p.addParameter('yLimVals',[0.2 0.6],@isvector);
p.addParameter('xTickVals',[]);
p.addParameter('semiLog',true,@islogical);
p.parse(xAxisVals,yAxisVals,plotColors, plotNames, varargin{:});

%% init the plot
tcHndl = figure;
hold on;

% get the number of lines to plot
numLines = size(yAxisVals,1);

numPoints = size(yAxisVals,2);
% Loop over the lines
for ii = 1:numLines
    for jj = 1:numPoints
    
    scatter(xAxisVals(jj,ii),yAxisVals(jj,ii),p.Results.sz, ...
        'MarkerEdgeColor',.3*plotColors(:,ii),...
        'MarkerFaceColor',plotColors(:,ii),...
        'MarkerFaceAlpha', p.Results.contrastAlpha(jj,ii),...
        'LineWidth',2);
    end
end


axis square;

if p.Results.semiLog
    set(gca,'Xscale','log');
end

ylim(p.Results.yLimVals)

autoTicksY = p.Results.yLimVals(1):(p.Results.yLimVals(2)-p.Results.yLimVals(1))/4:p.Results.yLimVals(2);

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

if ~isempty(p.Results.xTickVals)
    set(gca,'XTick',p.Results.xTickVals);
end

%% Add labels
if isfield(plotNames,'title')
    hTitle  = title (plotNames.title);
end
if isfield(plotNames,'xlabel')
    hXLabel = xlabel(plotNames.xlabel);
end
if isfield(plotNames,'ylabel')
    hYLabel = ylabel(plotNames.ylabel);
end

%% Add Legend
if isfield(plotNames,'legend')
legend('0°','90°','-75°','75°','-45°','45°');
end
%% Format fonts
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 18);
set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');



