close all 
clear all

%% Load cal files and set the gamma method
resourcesDir =  getpref('CorticalColorMapping','CalDataFolder');
load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
calCell = 4;
cal = cals{calCell};
calObj = ObjectToHandleCalOrCalStruct(cal);
gammaMethod = 2;
SetGammaMethod(calObj,gammaMethod);

%% Set up the background
bgPrimaries = [.5,.5,.5];

%% Load the xyz functions
load T_xyzCIEPhys2.mat 
% Set the sensor space to xyz
SetSensorColorSpace(calObj,T_xyzCIEPhys2,S_xyzCIEPhys2);
% compute the xyz of the backround
bgXYZ= PrimaryToSensor(calObj,bgPrimaries');
% Get the luminance of the background
Y = bgXYZ(2);

%% Load the cone fundamentals
load T_cones_ss2.mat
load T_CIE_Y2.mat

% Set the sensor space to cone coordinates
SetSensorColorSpace(calObj,T_cones_ss2,S_cones_ss2);
% Get the background excitations 
bgExcitations = PrimaryToSensor(calObj,bgPrimaries')

% Get the mac-boyn coodiantes of the background
lsBackground = LMSToMacBoyn(bgExcitations,T_cones_ss2,T_CIE_Y2);

%% Get the mac-boyn coordinates of the adapting patch
% vector angle in mac-boyn sl plane
adaptDir  = 270;
% vector magnitude in mac-boyn sl plane
adaptDist = 0.0126;
% convert to s and l coordinates 
[lMod,sMod] = pol2cart(deg2rad(adaptDir),adaptDist);
% add to the background
lAdapt = lMod+lsBackground(1);
sAdapt = sMod+lsBackground(2);

%% Get the mac-boyn coordinates of the target patch\
% vector angle in mac-boyn sl plane
adaptDir  = 90;
% vector magnitude in mac-boyn sl plane
adaptDist = 0.0126;
% convert to s and l coordinates 
[lMod,sMod] = pol2cart(deg2rad(adaptDir),adaptDist);
% add to the background
lTarget = lMod+lsBackground(1);
sTarget = sMod+lsBackground(2);

%% go from mac-boyn to cone space
[LMSfactors] = calcMacBoynLmsFactors(T_cones_ss2,T_CIE_Y2);
[LMSadapt] = MacBoynToLMS(lAdapt,sAdapt,Y,LMSfactors);

%% go from mac-boyn to cone space
[LMStarget] = MacBoynToLMS(lTarget,sTarget,Y,LMSfactors);

%% get the background settings
bgSetting = PrimaryToSettings(calObj,bgPrimaries);

%% get the adapt field settings
adaptSettings = SensorToSettings(calObj,LMSadapt)';

%% get the target field settings
targetSettings = SensorToSettings(calObj,LMStarget)';

%% Show the stuff
PsychDefaultSetup(2);

screens = Screen('Screens');
screenNumber = max(screens);

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, bgSetting);

[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
baseRect = [0 0 150 150];
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);

% put up the adapt sqaure
Screen('FillRect', window, adaptSettings, centeredRect);
Screen('Flip', window);

pause

% put up the target sqaure
Screen('FillRect', window, targetSettings, centeredRect);
Screen('Flip', window);
pause;
sca


