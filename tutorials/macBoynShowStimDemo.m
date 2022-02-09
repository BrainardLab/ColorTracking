close all 
clear all

resourcesDir =  getpref('CorticalColorMapping','CalDataFolder');
load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
calCell = 4;
cal = cals{calCell};
calObj = ObjectToHandleCalOrCalStruct(cal);
gammaMethod = 2;
SetGammaMethod(calObj,gammaMethod);
% S = calObj.get('S')'

%% Set up the background
bgPrimaries = [.5,.5,.5];

load T_xyzCIEPhys2.mat %T_xyzJuddVos % Judd-Vos XYZ Color matching function
SetSensorColorSpace(calObj,T_xyzCIEPhys2,S_xyzCIEPhys2);
% backround xyz
bgXYZ= PrimaryToSensor(calObj,bgPrimaries');
Y = bgXYZ(2);

load T_cones_ss2.mat
load T_CIE_Y2.mat

% background lms
SetSensorColorSpace(calObj,T_cones_ss2,S_cones_ss2);
bgExcitations = PrimaryToSensor(calObj,bgPrimaries')

% background mac-boyn
lsBackground = LMSToMacBoyn(bgExcitations,T_cones_ss2,T_CIE_Y2);

% Get the sl coordinates of the adapting patch
adaptDir  = 270;
adaptDist = 0.0126;
[lMod,sMod] = pol2cart(deg2rad(adaptDir),adaptDist);
lAdapt = lMod+lsBackground(1);
sAdapt = sMod+lsBackground(2);

% Get the sl coordinates of the adapting patch
adaptDir  = 90;
adaptDist = 0.0126;
[lMod,sMod] = pol2cart(deg2rad(adaptDir),adaptDist);
lTarget = lMod+lsBackground(1);
sTarget = sMod+lsBackground(2);

%% go from mac-boyn to cone space
[LMSfactors] = calcMacBoynLmsFactors(T_cones_ss2,T_CIE_Y2);
[LMSadapt] = MacBoynToLMS(lAdapt,sAdapt,Y,LMSfactors);

%% go from mac-boyn to cone space
[LMStarget] = MacBoynToLMS(lTarget,sTarget,Y,LMSfactors);

%% get the background settings
bgSetting = PrimaryToSettings(calObj,bgPrimaries);

%% get the adapt field setting
adaptSettings = SensorToSettings(calObj,LMSadapt)';

%% get the adapt field setting
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

% put up the aiming sqaure
Screen('FillRect', window, adaptSettings, centeredRect);
Screen('Flip', window);

pause

% put up the aiming sqaure
Screen('FillRect', window, targetSettings, centeredRect);
Screen('Flip', window);
pause;
sca


