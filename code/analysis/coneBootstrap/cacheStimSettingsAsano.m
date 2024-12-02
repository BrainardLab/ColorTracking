clear; close all;

%% Get the stimuli settings for angles in the LS plane
% Load a CRT calibration file
cal = LoadCalFile('ViewSonicG220fb',[],getpref('ColorTracking','CalFolder'));
[calStructOBJ,inputArgIsACalStructOBJ] = ObjectToHandleCalOrCalStruct(cal);
nMonitorBits = 12;
nInputLevels = 2.^nMonitorBits;
CalibrateFitGamma(calStructOBJ, nInputLevels);
SetGammaMethod(calStructOBJ,2);

% Make calibration file compatible with current system

% Load Stockman and Sharpe 2 deg cone fundamentals
load T_cones_ss2
SetSensorColorSpace(calStructOBJ,T_cones_ss2,S_cones_ss2);

%% Set the background
backgroundPrimaries = [0.50 0.5 0.50]'; %SensorToSettings(calStructOBJ,backgroundLMS);
backgroundLMS = SettingsToSensor(calStructOBJ,PrimaryToSettings(calStructOBJ,backgroundPrimaries));

% Loop over angles and get settings for each
theAngles = 80:0.05:100;
startContrast = 0.7;
stimSettings = zeros(3,length(theAngles));
theContrasts = zeros(1,length(theAngles));
for ii = 1:length(theAngles)
    [stimSettings(:,ii),theContrasts(ii)] = calcStimSettings4AsanoBoot(calStructOBJ,S_cones_ss2,T_cones_ss2,theAngles(ii),nMonitorBits,startContrast);

    excitationLMS(:,ii) = SettingsToSensor(calStructOBJ,stimSettings(:,ii));
    contrastsLMS(:,ii) = ExcitationsToContrast(excitationLMS(:,ii),backgroundLMS);
end

% Execute this to save
%{
    projectDir = tbLocateProject('ColorTracking');
    cacheFileDir = fullfile(projectDir,'code','analysis','coneBootstrap');
    save(fullfile(cacheFileDir,'cacheStimSettingAsanoBoot.mat'));
%}