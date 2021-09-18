%% Calculate contrast steps

%% Clear
clear; close all; clc;

%% Load a test calibration file
cal = LoadCalFile('ViewSonicG220fb',[],getpref('BrainardLabToolbox','CalDataFolder'));

[calStructOBJ, inputArgIsACalStructOBJ] = ObjectToHandleCalOrCalStruct(cal);

%% Set number of bits for display
nMonitorBits = 8;
nInputLevels = 2.^nMonitorBits;
CalibrateFitGamma(calStructOBJ, nInputLevels);

%     % Update internal data reprentation
%     obj.processedData.gammaInput  = calStructOBJ.get('gammaInput');
%     obj.processedData.gammaTable  = calStructOBJ.get('gammaTable');
%     obj.processedData.gammaFormat = calStructOBJ.get('gammaFormat');

% Get wavelength sampling of functions in cal file.
S = calStructOBJ.get('S');
wavelengthAxis = SToWls(S);

ambient = calStructOBJ.get('P_ambient');
P_device      = calStructOBJ.get('P_device');
gammaInput = calStructOBJ.get('gammaInput');
gammaTable = calStructOBJ.get('gammaTable');

% Load Stockman and Sharpe 2 deg Cone Fund.
load T_cones_ss2
% Spline the Stockman and Sharpe 2 deg cone fundamentals to match the wavelengthAxis
%T_cones_ss2 = SplineCmf(S_cones_ss2, T_cones_ss2, wavelengthAxis);

%% Standard initialization of calibration structure
SetSensorColorSpace(calStructOBJ,T_cones_ss2,S_cones_ss2);
SetGammaMethod(calStructOBJ,2);

%% Choose a target XYZ that is within monitor gamut.
%
% We'll do this using Psychtoolbox calibration code.


%backgroundLMS = [0.0193 0.0138 0.0050]';
backgroundRGB = [0.30 0.30 0.3]'; %SensorToSettings(calStructOBJ,backgroundLMS);
fprintf('<strong>*The Background*</strong>.\n')
str = 'Desired Settings of Background:       R = %1.4f, G = %1.4f,  B = %1.4f\n';
fprintf( str, backgroundRGB(1),backgroundRGB(2),backgroundRGB(3));

backgroundLMS_hat = SettingsToSensor(calStructOBJ,backgroundRGB);
backgroundRGB_hat = SensorToSettings(calStructOBJ,backgroundLMS_hat);

str = 'Quantized Settings of Background:     R = %1.4f, G = %1.4f,  B = %1.4f\n';
fprintf( str, backgroundRGB_hat(1),backgroundRGB_hat(2),backgroundRGB_hat(3));

str = 'Quantized Ecxitations of Background:  L = %1.4f, M = %1.4f,  S = %1.4f\n';
fprintf( str, backgroundLMS_hat(1),backgroundLMS_hat(2),backgroundLMS_hat(3));

%% Generate the stimulus
angle = 0;
LMScontrastModulation = .08*[.7071 -.7071 0]';
[stimPrimaries,coneExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,backgroundRGB_hat,LMScontrastModulation, angle);

% Make the background
for ii = 1: length(backgroundLMS_hat)
    background(ii,:) =  backgroundLMS_hat(ii) .* ones([1 imgInfo.rows*imgInfo.cols]);
end


contrastExcitations =  coneExcitations + background;


fprintf('\n<strong>*The Modulation* </strong>                     L = %1.3f, M = %1.3f,  S = %1.3f\n',LMScontrastModulation(1),LMScontrastModulation(2),LMScontrastModulation(3))

str = 'Desired Excitations of Modulation:    L = %1.4f, M = %1.4f,  S = %1.4f\n';
fprintf( str, max(contrastExcitations(1,:)),max(contrastExcitations(2,:)),max(contrastExcitations(3,:)));


[contrastSettings,badIndex] = SensorToSettings(calStructOBJ,contrastExcitations);
if ~sum(badIndex) == 0
    fprintf('\n<strong>WARNING:</strong> L = %1.2f%% of pixels out of gammut\n\n',100*(sum(badIndex)/length(badIndex)))
end
contrastExcitations_hat = SettingsToSensor(calStructOBJ,contrastSettings);

str = 'Quantized Ecitations of Modulation:   L = %1.4f, M = %1.4f,  S = %1.4f\n';
fprintf( str, max(contrastExcitations_hat(1,:)),max(contrastExcitations_hat(2,:)),max(contrastExcitations_hat(3,:)));

str = 'Quantized Settings of Modulation:     R = %1.4f, G = %1.4f,  B = %1.4f\n';
fprintf( str, max(contrastSettings(1,:)),max(contrastSettings(2,:)),max(contrastSettings(3,:)));

coneContrasts_hat = contrastExcitations_hat ./ (1+backgroundLMS_hat);
fprintf('\n<strong>*Recoverd Modulation*</strong>                 L = %1.4f, M = %1.4f,  S = %1.4f\n',max(coneContrasts_hat(1,:)),max(coneContrasts_hat(2,:)),max(coneContrasts_hat(3,:)))


theBitsSettings = round(2^nMonitorBits .* contrastSettings);
str = 'Estimated %1.0f-Bit Settings:             R = %1.0f, G = %1.0f,  B = %1.0f\n';
fprintf( str, nMonitorBits,theBitsSettings(1),theBitsSettings(2),theBitsSettings(3));
