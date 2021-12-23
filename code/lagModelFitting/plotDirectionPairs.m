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
p.addRequired('plotInfo',[],@isstruct);
p.addParameter('plotColors',[],@ismatrix);
p.addParameter('errorBarsSTD',[],@isnumeric);
p.addParameter('errorBarsCI',[],@isstruct);
p.addParameter('semiLog',true,@islogical);
p.addParameter('sz',9,@isnumeric);
p.addParameter('figSaveInfo',true,@islogical);
p.addParameter('legendLocation','northeastoutside',@ischar);
p.parse(matrixContrasts,lags,lagsFromFitMat, uniqueColorDirs,directionGroups, plotInfo, varargin{:});



%% unpack the parser
legendLocation  = p.Results.legendLocation;

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
    plotColors  = colorMapJet(colorMapIndx,:);
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



yLimVals = [0.2 0.8];

for jj = 1:length(uniqueColorDirs)
    plotNames.legend{jj} = sprintf('%s°',num2str(uniqueColorDirs(jj)));
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


p.addParameter('errorBarsCI',[],@isstruct);
p.addParameter('sz',12,@isscalar);
p.addParameter('yLimVals',[0.2 0.6],@isvector);


tcHndl2 = figure;hold on
for ii = 1:(numLines)
    subplot(numPlotRows,numPlotCols,ii)
    hold on
    
    [tcHndl] = plotParams(xAxisVals,yAxisVals,plotColors,plotNames,'errorBarsCI',errorBarsCI,'sz',sz, 'yLimVals', yLimVals)
    
end

% Save it!
figureSizeInches = figSaveInfo.figureSizeInches;
set(tcHndl2, 'PaperUnits', 'inches');
set(tcHndl2, 'PaperSize',figureSizeInches);
set(tcHndl2, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
figNameTc =  fullfile(figSaveInfo.figSavePath,[figSaveInfo.subjCode, '_model_fit_allData.pdf']);
% Save it
print(tcHndl2, figNameTc, '-dpdf', '-r300');
