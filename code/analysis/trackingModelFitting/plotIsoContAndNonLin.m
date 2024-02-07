function [tcHndlCont,tcHndlNonlin] = plotIsoContAndNonLin(paramsCTM, varargin)
% Plot the normalized ellipse and non-linearity from the QCM param
%
% Syntax:
%   [figHndl] = plotEllipseAndNonLin(qcmParams, varargin)
%
% Description:
%
%
% Inputs:
%    qcmParams         - Parameters from the QCM model fit.
%                           Angle, Minor Axis Ratio, NR Exp, NR AMP, NR
%                           Semi, NR Offset
%
% Outputs:
%    figHndl           - Figure Handle
%
% Optional key/value pairs:
%    nQCMPoints        - Resolution of the ellipse
%    ellipseColor      - Set the color of the ellipse and non-linearity line

% MAB 03/18/20

%% Input Parser
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('paramsCTM',@isstruct);
p.addParameter('targetLag',.400,@isnumeric);
p.addParameter('nPoints',100,@isnumeric);
p.addParameter('elPlotColor',[0.4 0.4 0.4],@isvector);
p.addParameter('xSampleBase',[],@isvector);
p.addParameter('lSampleBase',[-.5:0.01:.5],@isvector);
p.addParameter('dispParams',false,@islogical);
p.addParameter('thePacket',[],@isstruct);
p.addParameter('plotInfo',[],@isstruct);
p.addParameter('desiredEqContrast',[],@isvector);
p.addParameter('ellipseXLim',1.25,@isnumeric);
p.addParameter('ellipseYLim',1.25,@isnumeric);
p.addParameter('saveFigure',true,@islogical);
p.parse(paramsCTM,varargin{:});

% Pull stuff out of the results struct
nPoints      = p.Results.nPoints;
elPlotColor  = p.Results.elPlotColor;
xSampleBase  = p.Results.xSampleBase;
lSampleBase  = p.Results.lSampleBase;
targetLag    = p.Results.targetLag;
plotInfo     = p.Results.plotInfo;
desiredEqContrast = p.Results.desiredEqContrast;

%% Ellipse Figure
%
% Calculate the Minv matrix to tranform a unit circle to the ellipse and do it
if paramsCTM.minAxisRatio < 10^-5 % one mech case
    if (isempty(desiredEqContrast))
        desiredEqContrast = -1* log((targetLag-paramsCTM.minLag)./paramsCTM.amplitude)./paramsCTM.scale;
    end
    S1 = (desiredEqContrast-lSampleBase*cosd(paramsCTM.angle))./sin(paramsCTM.angle);
    S2 = (desiredEqContrast-lSampleBase*cosd(paramsCTM.angle))./sin(paramsCTM.angle);
    [~,~,Q] = EllipsoidMatricesGenerate([1 paramsCTM.minAxisRatio paramsCTM.angle]','dimension',2);
else
    if (isempty(desiredEqContrast))
        desiredEqContrast = -1* log((targetLag-paramsCTM.minLag)./paramsCTM.amplitude)./paramsCTM.scale;
    end
    circlePoints = desiredEqContrast*UnitCircleGenerate(nPoints);
    [M,Minv,Q] = EllipsoidMatricesGenerate([1 1./paramsCTM.minAxisRatio paramsCTM.angle]','dimension',2);
    ellipsePoints = Minv*circlePoints;
end

% Plot it
tcHndlCont = figure; hold on
xlim([-p.Results.ellipseXLim p.Results.ellipseXLim])
ylim([-p.Results.ellipseYLim p.Results.ellipseYLim]);

% get current axes
axh = gca;

% plot axes
line([-1.25 1.25], [0 0], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);
line([0 0], [-1.25 1.25], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);

% plot ellipse
if paramsCTM.minAxisRatio < 10^-5 % one mech case
    plot(lSampleBase,S1)
    plot(lSampleBase,S2)
else
    line(ellipsePoints(1,:),ellipsePoints(2,:),'color', elPlotColor, 'LineWidth', 1.5);
end

% set axes and figure labels
hXLabel = xlabel('L Contrast');
hYLabel = ylabel('S Contrast');
hTitle  = title('Isoresponse Contour');
set(gca,'FontSize',8);
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 12);
set( hTitle, 'FontSize', 10,'FontWeight' , 'normal');

% Add paramters to the plot
if p.Results.dispParams

    % Text containing math set in LaTeX
    if isempty(qcmCI)
        modelTxtTheta = ['${\theta} = ' num2str(round(paramsCTM.angle,2)) '^{\circ}$'];
        modelTxtMAR   = ['$m_ratio = ' num2str(round(paramsCTM.minAxisRatio,2)) '$'];
    else
        modelTxtTheta = ['{$\theta$ = ' num2str(round(paramsCTM.Qvec(2),2)) '$^\circ$' ...
            ' CI [' num2str(round(qcmCI.angle(2),2)) ', ' num2str(round(qcmCI.angle(1),2)) ']}'];
        modelTxtMAR   = ['{m = ' num2str(round(paramsCTM.Qvec(1),2))...
            ' CI [' num2str(round(qcmCI.mar(2),2)) ', ' num2str(round(qcmCI.mar(1),2)) ']}'];
    end

    % Add the above text to the plot
    theTextHandle = text(gca, -.9,.9 , modelTxtTheta, 'Interpreter', 'latex');
    set(theTextHandle,'FontSize', 12, 'Color', [0.3 0.3 0.3], 'BackgroundColor', [1 1 1]);
    theTextHandle = text(gca, -.9,.76 , modelTxtMAR, 'Interpreter', 'latex');
    set(theTextHandle,'FontSize', 12, 'Color', [0.3 0.3 0.3], 'BackgroundColor', [1 1 1]);
end

% format the figure
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'off'      , ...
    'YMinorTick'  , 'off'      , ...
    'YGrid'       , 'off'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , -1:.5:1    , ...
    'LineWidth'   , 1         , ...
    'ActivePositionProperty', 'OuterPosition');
axis square

%% Non-linearity figure

% Get the NR params
amp  = paramsCTM.amplitude;
scale  = paramsCTM.scale;
offset = paramsCTM.minLag;

% Define NR function
lagNL = @(c) amp .* exp(-1*c*scale) + offset;

% Plot it
tcHndlNonlin = figure; hold on
nonLinFigureSizeInches = [5 3.5];
set(tcHndlNonlin,'Position',[10 10 round(nonLinFigureSizeInches(1)*200) round(nonLinFigureSizeInches(2)*200)]);
if ~isempty(p.Results.thePacket)

    thePacket = p.Results.thePacket;
    % get the eqiv. contrast struct
    theStimVals = thePacket.stimulus.values;

    % Convert to Eqiv. Contrast
    eqContrast  = diag(sqrt(theStimVals'*Q*theStimVals));
    maxEqContrast = max(eqContrast);
    theResponse = thePacket.response.values;

    % reshape by direction
    theDirs = unique(round(thePacket.metaData.stimDirections,4));

    nContrast = length(eqContrast)./length(theDirs);

    eqContrastMat = reshape(eqContrast,[nContrast,length(theDirs)]);
    theResponseMat = reshape(theResponse,[nContrast,length(theDirs)]);
    % get the plot color RGB values
    cVals = thePacket.metaData.dirPlotColors;

    % plot each point with its associated color
    for ii = 1:size(eqContrastMat,2)

        % set the marker size
        markerSize = 4;
        markerAreaPtsSquared = markerSize^2;

        % plot it
        sctrHndl = scatter(eqContrastMat(:,ii),theResponseMat(:,ii),markerAreaPtsSquared, ...
            'LineWidth', 1.0, 'MarkerFaceColor', cVals(ii,:), ...
            'MarkerEdgeColor', cVals(ii,:));

        % set the alpha value
        set(sctrHndl, 'MarkerFaceAlpha', 0.8);
    end

    % get the current plot size
    originalSize = get(gca, 'Position');

    % set the color map to custom 18 color
    colormap(cVals);

    % set color map range
    caxis([min(theDirs),max(theDirs)]);
    nColors = length(theDirs);
    theSteps = (abs(min(theDirs)-max(theDirs)))./nColors;
    theTicks = (min(theDirs):theSteps:(max(theDirs))-theSteps)+5;
    for jj = 1:length(theDirs)
        theTickLabels{jj} = sprintf('%2.2f^o',theDirs(jj));
    end

    % set color bar location and labels
    c = colorbar('Location','eastoutside' ,'Ticks',theTicks,...
        'TickLabels',theTickLabels);
    c.Label.String = 'Chromatic Direction (angles in L/S plane)';
    c.FontSize = 6;

    % resize figure to original size
    set(tcHndlNonlin, 'Position', originalSize);
end

%% Plot The Non-Linearity
%xMax = round(maxEqContrast*1.25,2);
xMax = 10;
if isempty(xSampleBase)
    xSampleBase = 0:.05:xMax;
end

% Evaluate the NR at the xSampleBase Points
nlVals = lagNL(xSampleBase);
L1 = plot(xSampleBase,nlVals,'Color', elPlotColor, 'LineWidth', 1.5);%'LineStyle','--'

% Set the axes and figure labels
hTitle  = title ('Response Nonlinearlity');
hXLabel = xlabel('Equivalent Contrast'  );
hYLabel = ylabel('Response');
set(gca,'FontSize',8)
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 12);
set( hTitle, 'FontSize', 10,'FontWeight' , 'normal');

% Add parameters to the plot
if p.Results.dispParams

    % Text containing math set in LaTeX
    if isempty(qcmCI)
        modelTxtAmp  = ['$Amp = ' num2str(round(qcmParams.crfAmp,2)) '$'];
        modelTxtExp  = ['$Exp = ' num2str(round(qcmParams.crfExponent,2)) '$'];
        modelTxtSemi = ['$Semi = ' num2str(round(qcmParams.crfSemi,2)) '$'];
    else
        modelTxtAmp  = ['{Amp = ' num2str(round(qcmParams.crfAmp,2))...
            ' CI [' num2str(round(qcmCI.amp(2),2)) ', ' num2str(round(qcmCI.amp(1),2)) ']}'];
        modelTxtExp  = ['{Exp = ' num2str(round(qcmParams.crfExponent,2))...
            ' CI [' num2str(round(qcmCI.exp(2),2)) ', ' num2str(round(qcmCI.exp(1),2)) ']}'];
        modelTxtSemi = ['{Semi = ' num2str(round(qcmParams.crfSemi,2))...
            ' CI [' num2str(round(qcmCI.semi(2),2)) ', ' num2str(round(qcmCI.semi(1),2)) ']}'];
    end

    % Add the above text to the plot
    theTextHandle = text(gca, 1/500,1.3 , modelTxtAmp, 'Interpreter', 'latex');
    set(theTextHandle,'FontSize', 12, 'Color', [0.3 0.3 0.3], 'BackgroundColor', [1 1 1]);
    theTextHandle = text(gca, 1/500,1.15, modelTxtExp, 'Interpreter', 'latex');
    set(theTextHandle,'FontSize', 12, 'Color', [0.3 0.3 0.3], 'BackgroundColor', [1 1 1]);
    theTextHandle = text(gca, 1/500,1 , modelTxtSemi, 'Interpreter', 'latex');
    set(theTextHandle,'FontSize', 12, 'Color', [0.3 0.3 0.3], 'BackgroundColor', [1 1 1]);
end

% Get the x axis spacing and labels
nTicks = 4;
%autoTicksX = round(0:xMax./nTicks:xMax);
autoTicksX = [0 5 10];
for jj = 1:length(autoTicksX)
    tickNames{jj} = sprintf('%1.0f%',100*autoTicksX(jj));
end

% Format plot
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , -.5:.25:1.5    , ...
    'XTick'       , autoTicksX, ...
    'XTickLabel'  , tickNames, ...
    'LineWidth'   , 1         , ...
    'ActivePositionProperty', 'OuterPosition',...
    'xscale','linear');
ylim([.25 .75]);
xlim([0 xMax]);
set(gcf, 'Color', 'white' );
axis square

% Save figures
if (p.Results.saveFigure)

    figureSizeInches = [3.5 3.5];
    tcHndlCont.Units  = 'inches';
    tcHndlCont.PaperUnits  = 'inches';
    tcHndlCont.PaperSize = figureSizeInches;
    tcHndlCont.OuterPosition = [0 0 figureSizeInches(1) figureSizeInches(2)];
    tcHndlCont.InnerPosition = [.1 .1 figureSizeInches(1)-.1 figureSizeInches(2)-.1];
    if ~isempty(plotInfo)
        figNameTc =  fullfile(plotInfo.figSavePath,[plotInfo.subjCode, '_Isocont_CTM.pdf']);
        print(tcHndlCont, figNameTc, '-dpdf', '-r300');
    end

    tcHndlNonlin.Units  = 'inches';
    tcHndlNonlin.PaperUnits  = 'inches';
    tcHndlNonlin.PaperSize = nonLinFigureSizeInches;
    tcHndlNonlin.OuterPosition = [0 0 nonLinFigureSizeInches(1) nonLinFigureSizeInches(2)];
    tcHndlNonlin.InnerPosition = [.1 .1 nonLinFigureSizeInches(1)-.1 nonLinFigureSizeInches(2)-.1];
    if ~isempty(plotInfo)
        figNameTc =  fullfile(plotInfo.figSavePath,[plotInfo.subjCode, '_Nonlin_CTM.pdf']);
        print(tcHndlNonlin, figNameTc, '-dpdf', '-r300');
    end
end
end