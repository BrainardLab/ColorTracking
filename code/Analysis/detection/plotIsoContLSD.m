function [figHndl] = plotIsoContLSD(paramsLSD, varargin)
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
p.addRequired('paramsLSD',@isstruct);
p.addParameter('targetPC',.76,@isnumeric);
p.addParameter('nPoints',100,@isnumeric);
p.addParameter('plotColor',[0.3 0.45 0.81],@isvector);
p.addParameter('xSampleBase',[],@isvector);
p.addParameter('lSampleBase',[-.5:0.01:.5],@isvector);
p.addParameter('dispParams',false,@islogical);
p.addParameter('thePacket',[],@isstruct);
p.parse(paramsLSD,varargin{:});

% Pull stuff out of the results struct
nPoints      = p.Results.nPoints;
plotColor    = p.Results.plotColor;
xSampleBase  = p.Results.xSampleBase;
lSampleBase  = p.Results.lSampleBase;
targetPC     = p.Results.targetPC;

%% Ellipse Figure
% Calculate the Minv matrix to tranform a unit circle to the ellipse and do it


desiredEqContrast = -paramsLSD.lambda.*log((targetPC - 1)./(-(1-paramsLSD.scale))).^1/paramsLSD.exponent;
circlePoints = desiredEqContrast*UnitCircleGenerate(nPoints);
[M,Minv,Q] = EllipsoidMatricesGenerate([1 1./paramsLSD.minAxisRatio paramsLSD.angle]','dimension',2);
ellipsePoints = Minv*circlePoints;


% Plot it
figHndl = figure;
h1 = subplot(1,2,1); hold on
xlim([-1 1])
ylim([-1 1])

% get current axes
axh = gca;

% plot axes
line([-1 1], [0 0], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);
line([0 0], [-1 1], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);

% plot ellipse
line(ellipsePoints(1,:),ellipsePoints(2,:),'color', plotColor, 'LineWidth', 2);

% set axes and figure labels
hXLabel = xlabel('L Contrast');
hYLabel = ylabel('M Contrast');
hTitle  = title('Isoresponse Contour');
set(gca,'FontSize',12);
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 12);
set( hTitle, 'FontSize', 14,'FontWeight' , 'bold');

% Add paramters to the plot
if p.Results.dispParams

    % Text containing math set in LaTeX
    if isempty(qcmCI)
        modelTxtTheta = ['${\theta} = ' num2str(round(paramsLSD.angle,2)) '^{\circ}$'];
        modelTxtMAR   = ['$m_ratio = ' num2str(round(paramsLSD.minAxisRatio,2)) '$'];
    else
        modelTxtTheta = ['{$\theta$ = ' num2str(round(paramsLSD.Qvec(2),2)) '$^\circ$' ...
            ' CI [' num2str(round(qcmCI.angle(2),2)) ', ' num2str(round(qcmCI.angle(1),2)) ']}'];
        modelTxtMAR   = ['{m = ' num2str(round(paramsLSD.Qvec(1),2))...
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
    'TickDir'     , 'in'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'off'      , ...
    'YMinorTick'  , 'off'      , ...
    'YGrid'       , 'off'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , -1:.2:1    , ...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');
axis square


%% Non-linearity figure

% Get the NR params
lambda   = paramsLSD.lambda;
scale    = paramsLSD.scale;
exponent = paramsLSD.exponent;

% Define NR function
lagNL = @(c) 1-(1-paramsLSD.scale).*exp(-c./paramsLSD.lambda).^paramsLSD.exponent;

% Plot it
h2 = subplot(1,2,2);
hold on

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
        markerSize = 7.5;
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

    %     % set the color map to custom 8 color
    %     colormap(eqContrast.colorMap);
    %
    %     % set color map range
    %     caxis([-45,112.5]);
    %
    %     % set color bar location and labels
    %     c = colorbar('Location','eastoutside' ,'Ticks',[-35,-15,5,25,42.5,62.5,82.5,102.5],...
    %              'TickLabels',{'-45^o','-22.5^o','0^o','22.5^o','45^o','67.5^o','90^o','112.5^o'});
    %     c.Label.String = 'Chromatic Direction (angles in L/M plane)';
    %     c.Label.FontSize = 12;

    % resize figure to original size
    set(h2, 'Position', originalSize);

end

%% Plot The Non-Linearity
xMax = round(maxEqContrast*1.25,2)
if isempty(xSampleBase)
    xSampleBase = 0:0.001:xMax;
end
% Evaluate the NR at the xSampleBase Points
nlVals = lagNL(xSampleBase);

L1 = plot(xSampleBase,nlVals,'Color', plotColor, 'LineWidth', 2);

% set the axes and figure labels
hTitle  = title ('Response Nonlinearlity');
hXLabel = xlabel('Equivalent Contrast'  );
hYLabel = ylabel('Response');
set(gca,'FontSize',12)
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 12);
set( hTitle, 'FontSize', 14,'FontWeight' , 'bold');

% add parameters to the plot
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

% format plot
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , .4:.2:1    , ...
    'XTick'       , [0, 0.03, 0.05, 0.1, 0.2, 0.5], ...
    'XTickLabel'  , {'0%','3%','5%','10%','20%','50%'}, ...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition',...
    'xscale','linear');
ylim([.4 1]);
xlim([0 xMax]);
set(gcf, 'Color', 'white' );
axis square

end