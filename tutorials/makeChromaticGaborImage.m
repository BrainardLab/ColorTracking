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

 LMScontrastModulation1 = -1*generateStimContrasts(0,78.75, 0.13)'
 LMScontrastModulation2 = -1*generateStimContrasts(0,82.50, 0.14)'
 LMScontrastModulation3 = -1*generateStimContrasts(0,86.25, 0.18)'
 LMScontrastModulation4 = -1*generateStimContrasts(0,-78.75,0.13)'
 LMScontrastModulation5 = -1*generateStimContrasts(0,-82.50,0.14)'
 LMScontrastModulation6 = -1*generateStimContrasts(0,-86.25,0.18)'

% LMScontrastModulation1 = -1*generateStimContrasts(0,78.75, 0.83)'
% LMScontrastModulation2 = -1*generateStimContrasts(0,82.50, 0.85)'
% LMScontrastModulation3 = -1*generateStimContrasts(0,86.25, 0.85)'
% LMScontrastModulation4 = -1*generateStimContrasts(0,-78.75,0.84)'
% LMScontrastModulation5 = -1*generateStimContrasts(0,-82.50,0.84)'
% LMScontrastModulation6 = -1*generateStimContrasts(0,-86.25,0.84)'
sprintf('78.75')

[stimSettings1,stimExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,contrastImage,backgroundLMS_hat,LMScontrastModulation1);
sprintf('82.50')
[stimSettings2,stimExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,contrastImage,backgroundLMS_hat,LMScontrastModulation2);
sprintf('86.25')
[stimSettings3,stimExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,contrastImage,backgroundLMS_hat,LMScontrastModulation3);
sprintf('-78.75')
[stimSettings4,stimExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,contrastImage,backgroundLMS_hat,LMScontrastModulation4);
sprintf('-82.50')
[stimSettings5,stimExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,contrastImage,backgroundLMS_hat,LMScontrastModulation5);
sprintf('-86.25')
[stimSettings6,stimExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,contrastImage,backgroundLMS_hat,LMScontrastModulation6);
%% Display the Gabor
hFig = figure; clf;
set(hFig, 'Position', [800 10  400 500]);
catIm1 = cat(2,stimSettings1,stimSettings2,stimSettings3);
catIm2 = cat(2,stimSettings4,stimSettings5,stimSettings6);
catIm = cat(1,catIm1,catIm2);
image(catIm)
axis 'image'; axis 'ij'
set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
box off
set(hFig, 'Color', PrimaryToSettings(calStructOBJ, backgroundPrimaries));
% 
% %% Display the Gabor
% hFig = figure; clf;
% set(hFig, 'Position', [800 10  400 500]);
% imshow(stimSettings2); axis 'image'; axis 'ij'
% set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
% box off
% set(hFig, 'Color', PrimaryToSettings(calStructOBJ, backgroundPrimaries));
% 
% %% Display the Gabor
% hFig = figure; clf;
% set(hFig, 'Position', [800 10  400 500]);
% imshow(stimSettings3); axis 'image'; axis 'ij'
% set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
% box off
% set(hFig, 'Color', PrimaryToSettings(calStructOBJ, backgroundPrimaries));
% 
% %% Display the Gabor
% hFig = figure; clf;
% set(hFig, 'Position', [800 10  400 500]);
% imshow(stimSettings4); axis 'image'; axis 'ij'
% set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
% box off
% set(hFig, 'Color', PrimaryToSettings(calStructOBJ, backgroundPrimaries));
% 
% montage({stimSettings1,stimSettings2,stimSettings3,stimSettings4});
% montage(catIm);
