function [stimPrimariesMod,coneExcitationsMod,imgInfo] = generateChromaticGabor(calStructOBJ,backgroundPrimaries,LMScontrastModulation, angle, varargin)
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
%  angle:                     Specify angle of gabor in degrees (scalar).
%
% Key/val pairs
%  kernelSize:                Gaussian smoothing size mm (scalar).
%
% Output
%  -none

% MAB 06/20/21 -- started

% Input Parser
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('calStructOBJ',@isobject);
p.addRequired('backgroundPrimaries',@isvector);
p.addRequired('LMScontrastModulation',@isvector);
p.parse(calStructOBJ,backgroundPrimaries,LMScontrastModulation, varargin{:});


% Load displaySPDs and cone fundamentals sampled at the same spectral axis
% Extract the wavelength sampling
S = calStructOBJ.get('S');
wavelengthAxis = SToWls(S);

% Extract the spectral power distributions of the display's RGB primaries
displaySPDs = (calStructOBJ.get('P_device'))';

% Load the Smith-Pokorny 2 deg cone fundamentals
load('T_cones_ss2.mat');

% Spline the Smith-Pokorny 2 deg cone fundamentals to match the wavelengthAxis
coneFundamentals = SplineCmf(S_cones_ss2, T_cones_ss2, WlsToS(wavelengthAxis));

% Check outputs for correctness
assert(ndims(coneFundamentals) == 2, 'Cone fundamentals is not a 2D matrix');
assert(ndims(displaySPDs) == 2, 'displaySPDs is not a 2D matrix');
assert(size(coneFundamentals,1) == 3,'Cone fundamentals is not a [3 x N] matrix');
assert(size(displaySPDs,1) == 3,'Display SPDs is not a [3 x N] matrix');
assert(size(displaySPDs,2) == size(coneFundamentals,2),'Cone fundamental and display SPD  spectral entries do not match');

%% Set the color space conversions
SetSensorColorSpace(calStructOBJ,T_cones_ss2,S_cones_ss2);

%% Get the background excitations
backgroundConeExcitations = PrimaryToSensor(calStructOBJ, backgroundPrimaries);

[contrastImage, sRGBimage] = generateStimContrastProfile(p.Results.imgSzXYdeg,p.Results.smpPerDeg,p.Results.fx,p.Results.angle,p.Results.phase,p.Results.sigma);

% Generate stimulus settings
imgInfo.rows = size(contrastImage,1);
imgInfo.cols = size(contrastImage,2);
stimContrastProfile1D = reshape(contrastImage, [1 imgInfo.rows*imgInfo.cols]);

coneContrasts = zeros(3, numel(stimContrastProfile1D));
for pixel = 1:numel(stimContrastProfile1D)
    cL = stimContrastProfile1D(pixel) * LMScontrastModulation(1);
    cM = stimContrastProfile1D(pixel) * LMScontrastModulation(2);
    cS = stimContrastProfile1D(pixel) * LMScontrastModulation(3);
    coneContrasts(:, pixel) = [cL  cM cS];
end

assert(size(coneContrasts,1) == 3, 'cone contrasts must be a [3 x N] matrix');
assert((size(backgroundConeExcitations,1) == 3)  && (size(backgroundConeExcitations,2) == 1), 'background  cone excitations must be a [3 x 1] matrix');

coneExcitationsMod = repmat(backgroundConeExcitations, [1, size(coneContrasts,2)]) .* (coneContrasts);

assert(size(coneExcitationsMod,1) == 3, 'Cone excitations must have 3 rows');

stimPrimariesMod = SensorToPrimary(calStructOBJ,coneExcitationsMod);

end






