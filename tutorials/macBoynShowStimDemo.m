close all 
clear all

%% Load cal files and set the gamma method
resourcesDir =  getpref('ColorTracking','CalDataFolder');
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

% Get the mac-boyn coordinates of the adapting patch
% vector angle in mac-boyn sl plane
adaptDir  = 270;
% vector magnitude in mac-boyn sl plane
adaptDist = 0.0126;
% convert to s and l coordinates 
[lMod,sMod] = pol2cart(deg2rad(adaptDir),adaptDist);
% add to the background
lAdapt = lMod+lsBackground(1);
sAdapt = sMod+lsBackground(2);

% go from mac-boyn to cone space
[LMSfactors] = calcMacBoynLmsFactors(T_cones_ss2,T_CIE_Y2);
[LMSadapt] = MacBoynToLMS(lAdapt,sAdapt,Y,LMSfactors);

%% get the background settings
bgSetting = PrimaryToSettings(calObj,bgPrimaries);

%% get the adapt field settings
LMSadapt= bgExcitations + (bgExcitations .* [0;0;-.5]);
adaptSettings = SensorToSettings(calObj,LMSadapt)';

%% get the target field settings
LMSExcitations = ContrastToExcitations([0,0,-.1]',bgExcitations)
targetSettings = SensorToSettings(calObj,LMSExcitations);

%% Show the stuff
PsychDefaultSetup(2);

screens = Screen('Screens');
screenNumber = max(screens);

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, adaptSettings);

[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
baseRect = [0 0 150 150];
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
fixRectSize = [0 0 5 5];
fixationRect = CenterRectOnPointd(fixRectSize, xCenter, yCenter);
% put up the fixation sqaure
Screen('FillRect', window, [0,0,0], fixationRect);
Screen('Flip', window);
pause

% put up the adapt sqaure
Screen('FillRect', window, bgSetting, windowRect);
Screen('FillRect', window, [0,0,0], fixationRect);
Screen('Flip', window);

pause(0.400)

% put up the target sqaure
Screen('FillRect', window, targetSettings, centeredRect);
Screen('FillRect', window, [0,0,0], fixationRect);
Screen('Flip', window);
pause(.04);

Screen('FillRect', window, bgSetting, windowRect);
Screen('FillRect', window, [0,0,0], fixationRect);
Screen('Flip', window);
pause(.3)
sca



