%% makeChromaticGaborImage

%% Clear
clear; clc;

%% Load a CRT calibration file
cal = LoadCalFile('ViewSonicG220fb',[],getpref('CorticalColorMapping','CalFolder'));

% Make calibration file compatible with current system
[calStructOBJ, inputArgIsACalStructOBJ] = ObjectToHandleCalOrCalStruct(cal);

%% Set number of bits for display
nMonitorBits = 8;
nInputLevels = 2.^nMonitorBits;
CalibrateFitGamma(calStructOBJ, nInputLevels);


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
contrastImage = generateStimContrastProfile(imgSzXYdeg,smpPerDeg,fxCPD,angleDeg,phaseDeg,sigmaDeg);
        
%% Standard initialization of calibration structure
SetSensorColorSpace(calStructOBJ,T_cones_ss2,S_cones_ss2);
SetGammaMethod(calStructOBJ,2);

%% Set the background
backgroundPrimaries = [0.50 0.5 0.50]'; %SensorToSettings(calStructOBJ,backgroundLMS);

backgroundLMS_hat = SettingsToSensor(calStructOBJ,PrimaryToSettings(calStructOBJ,backgroundPrimaries));

backgroundPrimaries_hat = SensorToPrimary(calStructOBJ,backgroundLMS_hat);


%% Create a chromatic modulation 
 LMScontrastModulation1 = generateStimContrasts(0,-45,0.03)'
 LMScontrastModulation2 = generateStimContrasts(0,45,0.03)'
 LMScontrastModulation3 = generateStimContrasts(0,-75,0.06)'
 LMScontrastModulation4 = generateStimContrasts(0,75,0.06)'

[stimSettings1,stimExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,contrastImage,backgroundLMS_hat,LMScontrastModulation1);
[stimSettings2,stimExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,contrastImage,backgroundLMS_hat,LMScontrastModulation2);
[stimSettings3,stimExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,contrastImage,backgroundLMS_hat,LMScontrastModulation3);
[stimSettings4,stimExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,contrastImage,backgroundLMS_hat,LMScontrastModulation4);

%% Display the Gabor
hFig = figure; clf;
set(hFig, 'Position', [800 10  400 500]);
imshow(stimSettings1); axis 'image'; axis 'ij'
set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
box off
set(hFig, 'Color', PrimaryToSettings(calStructOBJ, backgroundPrimaries));

%% Display the Gabor
hFig = figure; clf;
set(hFig, 'Position', [800 10  400 500]);
imshow(stimSettings2); axis 'image'; axis 'ij'
set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
box off
set(hFig, 'Color', PrimaryToSettings(calStructOBJ, backgroundPrimaries));

%% Display the Gabor
hFig = figure; clf;
set(hFig, 'Position', [800 10  400 500]);
imshow(stimSettings3); axis 'image'; axis 'ij'
set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
box off
set(hFig, 'Color', PrimaryToSettings(calStructOBJ, backgroundPrimaries));

%% Display the Gabor
hFig = figure; clf;
set(hFig, 'Position', [800 10  400 500]);
imshow(stimSettings4); axis 'image'; axis 'ij'
set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
box off
set(hFig, 'Color', PrimaryToSettings(calStructOBJ, backgroundPrimaries));
