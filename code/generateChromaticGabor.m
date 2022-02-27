function [stimSettings,stimExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,contrastImage, backgroundExcitations,stimLMScontrast, varargin)
%% Make a chromatic gabor of specified chormatic direction and orientation
%
% Synopsis
%   [] = smoothTimeSeriesFromMask(subjectId, varargin)
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
p.addRequired('calStructOBJ',@isobject);
p.addRequired('contrastImage',@ismatrix);
p.addRequired('backgroundPrimaries',@isvector);
p.addRequired('LMScontrastModulation',@isvector);
p.addParameter('rampOnOff',[1],@isvector);
p.addParameter('addNoise',[0 0],@isvector);

p.parse(calStructOBJ,contrastImage,backgroundExcitations,stimLMScontrast, varargin{:});


% Load displaySPDs and cone fundamentals sampled at the same spectral axis
% Extract the wavelength sampling
S = calStructOBJ.get('S');
wavelengthAxis = SToWls(S);

% Extract the spectral power distributions of the display's RGB primaries
displaySPDs = (calStructOBJ.get('P_device'))';

% Load the Smith-Pokorny 2 deg cone fundamentals
load('T_cones_ss2.mat');

% Spline the Stockman Sharpe 2 deg cone fundamentals to match the wavelengthAxis
coneFundamentals = SplineCmf(S_cones_ss2, T_cones_ss2, WlsToS(wavelengthAxis));

% Check outputs for correctness
assert(ndims(coneFundamentals) == 2, 'Cone fundamentals is not a 2D matrix');
assert(ndims(displaySPDs) == 2, 'displaySPDs is not a 2D matrix');
assert(size(coneFundamentals,1) == 3,'Cone fundamentals is not a [3 x N] matrix');
assert(size(displaySPDs,1) == 3,'Display SPDs is not a [3 x N] matrix');
assert(size(displaySPDs,2) == size(coneFundamentals,2),'Cone fundamental and display SPD  spectral entries do not match');

%% Set the color space conversions
SetSensorColorSpace(calStructOBJ,T_cones_ss2,S_cones_ss2);

% Create a 1-D contrast image
imgInfo.rows = size(contrastImage,1);
imgInfo.cols = size(contrastImage,2);
stimContrastProfile1D = reshape(contrastImage, [1 imgInfo.rows*imgInfo.cols]);

stimConeContrast = zeros(3, numel(stimContrastProfile1D));

% scale the contrast images by the LMS modulaiton amount
for pixel = 1:numel(stimContrastProfile1D)
    cL = stimContrastProfile1D(pixel) * stimLMScontrast(1);
    cM = stimContrastProfile1D(pixel) * stimLMScontrast(2);
    cS = stimContrastProfile1D(pixel) * stimLMScontrast(3);
    stimConeContrast(:, pixel) = [cL  cM cS]';
end

% Check Dimensions
assert(size(stimConeContrast,1) == 3, 'cone contrasts must be a [3 x N] matrix');
assert((size(backgroundExcitations,1) == 3)  && (size(backgroundExcitations,2) == 1), 'background  cone excitations must be a [3 x 1] matrix');


for ii = 1:length(p.Results.rampOnOff)
    % Create the stimulus excitations
    stimExcitations(:,:,ii) = repmat(backgroundExcitations, [1, size(stimConeContrast,2)]) .* (1 + (p.Results.rampOnOff(ii).*stimConeContrast));

    % Check Dimensions
    assert(size(stimExcitations(:,:,ii),1) == 3, 'Cone excitations must have 3 rows');

    % Convert excitation to settings
    [stimSettings2D, badIndex] = SensorToSettings(calStructOBJ,stimExcitations(:,:,ii));

    % check and warn for out of gamut pixles
    if sum(badIndex) > 0
        fprintf('\n <strong> WARNGING: </strong> %2.3f%% of pixels out of gamut.\n', 100*(sum(badIndex)./size(stimSettings2D,2)));
    end

    % reshape to an mxnx3 image
    stimSettings(:,:,:,ii) = reshape(stimSettings2D',[imgInfo.rows, imgInfo.cols, 3]);
end

end






