%% makeChromaticGaborImage

%% Clear
clear; close all; clc;

%% Load a CRT calibration file
cal = LoadCalFile('PTB3TestCal',[],getpref('BrainardLabToolbox','CalDataFolder'));

% Make calibration file compatible with current system
[calStructOBJ, inputArgIsACalStructOBJ] = ObjectToHandleCalOrCalStruct(cal);

%% Set number of bits for display
nMonitorBits = 10;
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
imgSzXYdeg = [4 4];
smpPerDeg  = 128;
fxCPD      = 1; 
angleDeg   = 0;
phaseDeg   = 0;
sigmaDeg   = 0.6;
[contrastImage, sRGBimage] = generateStimContrastProfile(imgSzXYdeg,smpPerDeg,fxCPD,angleDeg,phaseDeg,sigmaDeg);
        
%% Standard initialization of calibration structure
SetSensorColorSpace(calStructOBJ,T_cones_ss2,S_cones_ss2);
SetGammaMethod(calStructOBJ,1);


backgroundRGB = [0.50 0.50 0.50]'; %SensorToSettings(calStructOBJ,backgroundLMS);

backgroundLMS_hat = SettingsToSensor(calStructOBJ,backgroundRGB);

backgroundRGB_hat = SensorToSettings(calStructOBJ,backgroundLMS_hat);


%% Generate the stimulus
angle = 0;
LMScontrastModulation = .065*[.7071 -.7071 0]';
LMScontrastModulation = .6*[0 0 1]';
[stimPrimaries,coneExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,backgroundRGB_hat,LMScontrastModulation, angle);


% Make the background
for ii = 1: length(backgroundLMS_hat)
    background(ii,:) =  backgroundLMS_hat(ii) .* ones([1 imgInfo.rows*imgInfo.cols]);
end

contrastExcitations =  coneExcitations + background;

[contrastSettings,badIndex] = SensorToSettings(calStructOBJ,contrastExcitations);
sum(badIndex)
img  = reshape(contrastSettings',[imgInfo.rows, imgInfo.cols, 3]);
gaborSettingsImages = reshape(contrastSettings',[imgInfo.rows, imgInfo.cols, 3]);
hFig = figure(1); clf;

set(hFig, 'Position', [800 10  400 500]);
image(gaborSettingsImages); axis 'image'; axis 'ij'
set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
box off
set(hFig, 'Color', lin2rgb(SettingsToPrimary(calStructOBJ,backgroundRGB)));
hFig = figure(2); clf;

surf(gaborSettingsImages(:,:,1)); 
hFig = figure(3); clf;

surf(gaborSettingsImages(:,:,2)); 

hFig = figure(4); clf;
surf(gaborSettingsImages(:,:,3)); 

hFig = figure(5); clf;
surf(mean(gaborSettingsImages,3)); 




theBitsSettings = round(2^nMonitorBits .* contrastSettings);













% %% Print stuff to the terminal
% fprintf('<strong>*The Background*</strong>.\n')
% str = 'Desired Settings of Background:       R = %1.4f, G = %1.4f,  B = %1.4f\n';
% fprintf( str, backgroundRGB(1),backgroundRGB(2),backgroundRGB(3));
% str = 'Quantized Settings of Background:     R = %1.4f, G = %1.4f,  B = %1.4f\n';
% fprintf( str, backgroundRGB_hat(1),backgroundRGB_hat(2),backgroundRGB_hat(3));
% 
% str = 'Quantized Ecxitations of Background:  L = %1.4f, M = %1.4f,  S = %1.4f\n';
% fprintf( str, backgroundLMS_hat(1),backgroundLMS_hat(2),backgroundLMS_hat(3));
% 
% fprintf('\n<strong>*The Modulation* </strong>                     L = %1.3f, M = %1.3f,  S = %1.3f\n',LMScontrastModulation(1),LMScontrastModulation(2),LMScontrastModulation(3))
% 
% str = 'Desired Excitations of Modulation:    L = %1.4f, M = %1.4f,  S = %1.4f\n';
% fprintf( str, max(contrastExcitations(1,:)),max(contrastExcitations(2,:)),max(contrastExcitations(3,:)));
% str = 'Quantized Ecitations of Modulation:   L = %1.4f, M = %1.4f,  S = %1.4f\n';
% fprintf( str, max(contrastExcitations_hat(1,:)),max(contrastExcitations_hat(2,:)),max(contrastExcitations_hat(3,:)));
% 
% str = 'Quantized Settings of Modulation:     R = %1.4f, G = %1.4f,  B = %1.4f\n';
% fprintf( str, max(contrastSettings(1,:)),max(contrastSettings(2,:)),max(contrastSettings(3,:)));
% 
% coneContrasts_hat = contrastExcitations_hat ./ (1+backgroundLMS_hat);
% fprintf('\n<strong>*Recoverd Modulation*</strong>                 L = %1.4f, M = %1.4f,  S = %1.4f\n',max(coneContrasts_hat(1,:)),max(coneContrasts_hat(2,:)),max(coneContrasts_hat(3,:)))
% if ~sum(badIndex) == 0
%     fprintf('\n<strong>WARNING:</strong> L = %1.2f%% of pixels out of gammut\n\n',100*(sum(badIndex)/length(badIndex)))
% end
% str = 'Estimated %1.0f-Bit Settings:             R = %1.0f, G = %1.0f,  B = %1.0f\n';
% fprintf( str, nMonitorBits,theBitsSettings(1),theBitsSettings(2),theBitsSettings(3));


