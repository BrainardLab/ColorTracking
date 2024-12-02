function [stimSettings,maxContrast] = calcStimSettings4AsanoBoot(calStructOBJ,S_cones,T_cones,theAngle,nMonitorBits,maxContrast)
% calcStimSettings4AsanoBoot
%
% Calculates the nominal settings for the the stimuli 

%% Set number of bits for display
nInputLevels = 2.^nMonitorBits;
CalibrateFitGamma(calStructOBJ, nInputLevels);

%% Standard initialization of calibration structure
SetSensorColorSpace(calStructOBJ,T_cones,S_cones);
SetGammaMethod(calStructOBJ,2);

%% Set the background
backgroundPrimaries = [0.50 0.5 0.50]'; %SensorToSettings(calStructOBJ,backgroundLMS);
backgroundLMS_hat = SettingsToSensor(calStructOBJ,PrimaryToSettings(calStructOBJ,backgroundPrimaries));
backgroundPrimaries_hat = SensorToPrimary(calStructOBJ,backgroundLMS_hat);

%% Create a chromatic modulation 
LMScontrastModulation1 = generateStimContrasts(0,theAngle,maxContrast)';
imgInfo.badIndex = 1;
while imgInfo.badIndex > 0 
    [stimSettings1,stimExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,1,backgroundLMS_hat,LMScontrastModulation1);
    if imgInfo.badIndex > 0 
        maxContrast = maxContrast - 0.005;
        LMScontrastModulation1 = generateStimContrasts(0,theAngle,maxContrast)';
    end
end

% Get final settings
stimSettings = squeeze(stimSettings1);