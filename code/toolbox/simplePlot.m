function simplePlot(thing1,thing1color,thing2,thing2color,plotNames,legendLocation)
plot(thing1,'-', ...
    'Color',thing1color,...
    'LineWidth',2);
plot(thing2,'-', ...
    'Color',thing2color,...
    'LineWidth',1.5);
axis square;

maxVals = max(max([thing1(:),thing2(:)]));

autoTicksY = 0:ceil(maxVals+(0.15.*maxVals))./4:ceil(maxVals+(0.15.*maxVals));
ylim([0 ceil(maxVals+(0.15.*maxVals))]);
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

% Add labels
if isfield(plotNames,'title')
    hTitle  = title (plotNames.title);
end
if isfield(plotNames,'xlabel')
    hXLabel = xlabel(plotNames.xlabel);
end
if isfield(plotNames,'ylabel')
    hYLabel = ylabel(plotNames.ylabel);
end
% Add Legend
if isfield(plotNames,'legend')
    legend(plotNames.legend,'Location',legendLocation);
end
axis square
end