function [lookupTableSettings,badIndex] = makeLookUpTableForCC(calObj,targetContrast,targetContrastAngle,bgSettings, varargin)
% Generates the look up table needed for set the chromaitc modulation usin gthe bits++
%
% Syntax:
%   lookupTableSettings = makeLookUpTableForCC(calObj,targetContrast,targetContrastAngle,bgSettings)
%
% Description:
%
%
% Inputs:
%    calObj              - Calibration object. 
%    targetContrast      - Magnitude of the contrast modulation.
%    targetContrastAngle - Angle of the Contrast Modulation in the LS plane.
%    bgSettings          - Setting of the background of the modulation. 
%
% Outputs:
%    lookupTableSettings - Look up table for the Bits++.
%
% Optional key/value pairs:
%    nFrameBufferBits    - Frame buffer bits depth (probably 8-bit). 

% MAB 01/13/22

p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('calObj',@isobject);
p.addRequired('targetContrast',@isscalar);
p.addRequired('targetContrastDir',@isscalar);
p.addRequired('bgSettings',@isvector);
p.addParameter('nFrameBufferBits',8,@isscalar);
p.parse(calObj,targetContrast,targetContrastAngle,bgSettings,varargin{:});

%% Set the number of frame buffer bits
nFrameBufferBits = p.Results.nFrameBufferBits;
nFrameBufferLevels = 2^nFrameBufferBits;

%% Create the unit lookup table for the number for frame buffer bits
lookupTableDesiredMonochromeContrastsCal = [linspace(-1,-2/nFrameBufferLevels,nFrameBufferLevels/2-1) 0 linspace(2/nFrameBufferLevels,1,nFrameBufferLevels/2)];

%% Rotate and scale the lookup table to matvh the direction and contrast
targetContrastDir = generateStimContrasts(0,targetContrastAngle,1)';

lookupTableDesiredContrastCal = targetContrast*targetContrastDir*lookupTableDesiredMonochromeContrastsCal;

bgExcitations = SettingsToSensor(calObj,bgSettings);
lookupTableDesiredExcitationsCal = ContrastToExcitation(lookupTableDesiredContrastCal,bgExcitations);
[lookupTableSettings, badIndex] = SensorToSettings(calObj,lookupTableDesiredExcitationsCal);