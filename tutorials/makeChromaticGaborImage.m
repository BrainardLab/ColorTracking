%% makeChromaticGaborImage

%% Clear
clear; close all; clc;

%% Load a CRT calibration file
cal = LoadCalFile('ViewSonicG220fb',[],getpref('BrainardLabToolbox','CalDataFolder'));

% Make calibration file compatible with current system
[calStructOBJ, inputArgIsACalStructOBJ] = ObjectToHandleCalOrCalStruct(cal);

%% Set number of bits for display
nMonitorBits = 8;
nInputLevels = 2.^nMonitorBits;
CalibrateFitGamma(calStructOBJ, nInputLevels);

%% Get relevant info from cal file 
% Get wavelength sampling of functions in cal file.
S = calStructOBJ.get('S');
wavelengthAxis = SToWls(S);

ambient = calStructOBJ.get('P_ambient');
P_device      = calStructOBJ.get('P_device');
gammaInput = calStructOBJ.get('gammaInput');
gammaTable = calStructOBJ.get('gammaTable');

%% Load Stockman and Sharpe 2 deg Cone Fund.
load T_cones_ss2

%% Generate Contrast image of Gabor
% Define the Gabor Parameters
imgSzXYdeg = [8 8];
smpPerDeg  = 128;
fxCPD      = 1; 
angleDeg   = 0;
phaseDeg   = 0;
sigmaDeg   = 0.6;
[scaledContrastImage, ~] = generateStimContrastProfile(imgSzXYdeg,smpPerDeg,fxCPD,angleDeg,phaseDeg,sigmaDeg);
        
%% Standard initialization of calibration structure
SetSensorColorSpace(calStructOBJ,T_cones_ss2,S_cones_ss2);
SetGammaMethod(calStructOBJ,2);

%% Set the background
backgroundRGB = [0.50 0.50 0.50]'; %SensorToSettings(calStructOBJ,backgroundLMS);

backgroundLMS_hat = SettingsToSensor(calStructOBJ,backgroundRGB);

backgroundRGB_hat = SensorToSettings(calStructOBJ,backgroundLMS_hat);


%% Create a chromatic modulation 
LMScontrastModulation = .10*[.7071 -.7071 0]';

[stimSettings,stimExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,scaledContrastImage,backgroundLMS_hat,LMScontrastModulation);

%% Display the Gabor
hFig = figure(1); clf;
set(hFig, 'Position', [800 10  400 500]);
image(stimSettings); axis 'image'; axis 'ij'
set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
box off
set(hFig, 'Color', backgroundRGB);
