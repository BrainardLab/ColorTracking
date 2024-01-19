function [tcHndl] = plotIsoContLSD(paramsLSD, varargin)
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
p.addParameter('plotColor',[0.4 0.4 0.4],@isvector);
p.addParameter('xSampleBase',[],@isvector);
p.addParameter('lSampleBase',[-.5:0.01:.5],@isvector);
p.addParameter('dispParams',false,@islogical);
p.addParameter('thePacket',[],@isstruct);
p.addParameter('plotInfo',[],@isstruct);
p.parse(paramsLSD,varargin{:});

% Pull stuff out of the results struct
nPoints      = p.Results.nPoints;
plotColor    = p.Results.plotColor;
xSampleBase  = p.Results.xSampleBase;
lSampleBase  = p.Results.lSampleBase;
targetPC     = p.Results.targetPC;
plotInfo     = p.Results.plotInfo;
%% Ellipse Figure
% Calculate the Minv matrix to tranform a unit circle to the ellipse and do it
%                    PC  = 1-(1-0.5).*exp(-(m./lambda)).^exponent;
%         ((PC-1)./-0.5) = exp(-(m./lambda)).^exponent)
%         log(((PC-1)./-0.5)) = -(m./lambda).^exponent
% paramsLSD.lambda.* ((-log(((targetPC-1)./-0.5)))^(1/paramsLSD.exponent)) = m
desiredEqContrast = paramsLSD.lambda.*(-log((targetPC-1)./-(1-0.5))).^(1/paramsLSD.exponent);
circlePoints = desiredEqContrast*UnitCircleGenerate(nPoints);
[M,Minv,Q] = EllipsoidMatricesGenerate([1 1./paramsLSD.minAxisRatio paramsLSD.angle]','dimension',2);
ellipsePoints = Minv*circlePoints;


% Plot it
tcHndl = figure;
h1 = subplot(1,2,1); hold on

% get current axes
axh = gca;

% plot axes
line([-1 1], [0 0], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);
line([0 0], [-1 1], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);

% plot ellipse
line(ellipsePoints(1,:),ellipsePoints(2,:),'color', plotColor, 'LineWidth', 1.5);

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
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'off'      , ...
    'YMinorTick'  , 'off'      , ...
    'YGrid'       , 'off'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , -.1:.05:.1    , ...
    'XTick'       , -.1:.05:.1    , ...
    'LineWidth'   , 1         , ...
    'ActivePositionProperty', 'OuterPosition');
axis square
xlim([-.1 .1])
ylim([-.1 .1])


%% Non-linearity figure

% Get the NL params
lambda   = paramsLSD.lambda;
exponent = paramsLSD.exponent;

% Define NL function
pcNL = @(m) 1-(1-0.5).*exp(-(m./lambda).^exponent);

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
        % turn colors into color map
         nColors = size(cVals,1);
%         nRepeats  = 255./nColors;
      
        % set the color map to custom 8 color
        colormap(cVals);
    
        % set color map range
        caxis([-86.25,90]);
    
        % set color bar location and labels [-76.25,-72.50,-68.75,-65.00,-45.00,10.00,35.00,65.00,68.75,72.50,76.25,80.00']
        c = colorbar('Location','eastoutside' ,'Ticks',-76.25:abs(-76.25-100)./nColors:100-abs(-76.25-100)./nColors,...
                 'TickLabels',{'-86.25^o','-82.50^o','-78.75^o','-75.00^o','-45.00^o','0.00^o',...
                 '45.00^o','75.00^o','78.75^o','82.50^o','86.25^o','90.00^o'});
        c.Label.String = 'Chromatic Direction (angles in L/S plane)';
        c.FontSize = 8;

    % resize figure to original size
    set(h2, 'Position', originalSize);

end

%% Plot The Non-Linearity
xMax = round(maxEqContrast*1.25,2);
if isempty(xSampleBase)
    xSampleBase = 0:0.001:xMax;
end
% Evaluate the NR at the xSampleBase Points
nlVals = pcNL(xSampleBase);

L1 = plot(xSampleBase,nlVals,'Color', plotColor, 'LineWidth', 1.5);

% set the axes and figure labels
hTitle  = title ('Response Nonlinearlity');
hXLabel = xlabel('Equivalent Contrast'  );
hYLabel = ylabel('Response');
set(gca,'FontSize',8);
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 12);
set( hTitle, 'FontSize', 10,'FontWeight' , 'normal');

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
    'XTick'       , [0, 0.05, 0.1, 0.2, 0.5], ...
    'XTickLabel'  , {'0%','5%','10%','20%','50%'}, ...
    'LineWidth'   , 1         , ...
    'ActivePositionProperty', 'OuterPosition',...
    'xscale','linear');
ylim([.4 1]);
xlim([0 xMax]);
set(gcf, 'Color', 'white' );
axis square



% Save it!
figureSizeInches = [6.5 3];
% set(tcHndl, 'PaperUnits', 'inches');
% set(tcHndl, 'PaperSize',figureSizeInches);
tcHndl.Units  = 'inches';
tcHndl.PaperUnits  = 'inches';
tcHndl.PaperSize = figureSizeInches;
tcHndl.OuterPosition = [0 0 figureSizeInches(1) figureSizeInches(2)];
tcHndl.InnerPosition = [.5 .5 figureSizeInches(1)-.5 figureSizeInches(2)-.5];

figNameTc =  fullfile(plotInfo.figSavePath,[plotInfo.subjCode, '_Isocont_Nonlin_LSD.pdf']);
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');

end