%% Calculate contrast steps

%% Clear
clear; close all;clc;

%% Load a test calibration file
cal = LoadCalFile('ViewSonicG220fb');
 
[calStructOBJ, inputArgIsACalStructOBJ] = ObjectToHandleCalOrCalStruct(cal);

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
SetGammaMethod(calStructOBJ,0);

%% Choose a target XYZ that is within monitor gamut.
% 
% We'll do this using Psychtoolbox calibration code.


%backgroundLMS = [0.0193 0.0138 0.0050]';
backgroundRGB = [0.3 0.3 0.3]'; %SensorToSettings(calStructOBJ,backgroundLMS);
fprintf('<strong>*The Background*</strong>.\n')
str = 'Desired Settings of Background:       R = %1.4f, G = %1.4f,  B = %1.4f\n';
fprintf( str, backgroundRGB(1),backgroundRGB(2),backgroundRGB(3));

backgroundLMS_hat = SettingsToSensor(calStructOBJ,backgroundRGB);
backgroundRGB_hat = SensorToSettings(calStructOBJ,backgroundLMS_hat);

str = 'Quantized Settings of Background:     R = %1.4f, G = %1.4f,  B = %1.4f\n';
fprintf( str, backgroundRGB_hat(1),backgroundRGB_hat(2),backgroundRGB_hat(3));

str = 'Quantized Ecxitations of Background:  L = %1.4f, M = %1.4f,  S = %1.4f\n';
fprintf( str, backgroundLMS_hat(1),backgroundLMS_hat(2),backgroundLMS_hat(3));

coneContrasts = [1.09 1 1]';
fprintf('\n<strong>*The Modulation* </strong>                     L = %1.3f, M = %1.3f,  S = %1.3f\n',coneContrasts(1),coneContrasts(2),coneContrasts(3))
contrastExcitations = backgroundLMS_hat.*coneContrasts;
str = 'Desired Excitations of Modulation:    L = %1.4f, M = %1.4f,  S = %1.4f\n';
fprintf( str, contrastExcitations(1),contrastExcitations(2),contrastExcitations(3));


contrastSettings = SensorToSettings(calStructOBJ,contrastExcitations);
contrastExcitations_hat = SettingsToSensor(calStructOBJ,contrastSettings);

str = 'Quantized Ecitations of Modulation:   L = %1.4f, M = %1.4f,  S = %1.4f\n';
fprintf( str, contrastExcitations_hat(1),contrastExcitations_hat(2),contrastExcitations_hat(3));

str = 'Quantized Settings of Modulation:     R = %1.4f, G = %1.4f,  B = %1.4f\n';
fprintf( str, contrastSettings(1),contrastSettings(2),contrastSettings(3));

coneContrasts_hat = contrastExcitations_hat ./ backgroundLMS_hat;
fprintf('\n<strong>*Recoverd Modulation*</strong>                 L = %1.4f, M = %1.4f,  S = %1.4f\n',coneContrasts_hat(1),coneContrasts_hat(2),coneContrasts_hat(3))



nMonitorBits = 8;
theBitsSettings = round(2^nMonitorBits .* contrastSettings);
str = 'Estimated %1.0f-Bit Settings:             R = %1.0f, G = %1.0f,  B = %1.0f\n';
fprintf( str, nMonitorBits,theBitsSettings(1),theBitsSettings(2),theBitsSettings(3));
