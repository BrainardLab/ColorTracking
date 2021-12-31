% Klein10A check Demo.
% Use a cal file to set primaries to a corresponding XYZ/xyY and use the klien
% to measure the CRT and see if we recover the XYZ/xyY.

%% Clear
clear; close all;

pr670obj = [];
devicePortString = '/dev/ttyACM0';
verb = 0;
pr670obj = PR670dev('verbosity', verb, 'devicePortString', devicePortString);

%% Verbose?
%
% Set to true to get more output
VERBOSE = false;

%% Load cal file

resourcesDir =  getpref('CorticalColorMapping','CalDataFolder');
load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
cal = cals{1};
calObj = ObjectToHandleCalOrCalStruct(cal);

%% Make this a 8-bit device as far as the calibration file goes (FOR NOW)
nDeviceBits = 8;
nDeviceLevels = 2^nDeviceBits;
CalibrateFitGamma(calObj, nDeviceLevels);
nPrimaries = calObj.get('nDevices');


%% Setting gammaMethod to do quantizes at the calibration file bit depth.
%
% Can change gammaMethod to 1 for unquantized analysis
gammaMethod = 2;
SetGammaMethod(calObj,gammaMethod);

% Set wavelength support.
S = calObj.get('S');

% Zero out ambient?
NOAMBIENT = true;
if (NOAMBIENT)
    calObj.set('P_ambient',zeros(size(calObj.get('P_ambient'))));
end

%% Cone fundamentals and XYZ CMFs.
load T_xyzJuddVos % Judd-Vos XYZ Color matching function
T_xyz = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,S);

SetSensorColorSpace(calObj,T_xyz,S);
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);

% get the background settings
bgSettings = PrimaryToSettings(calObj,[0.5,0.5,0.5]');
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, bgSettings);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
baseRect = [0 0 150 150];
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
% put up the sqaure
imSettings = [.3,.7,1];
Screen('FillRect', window, imSettings, centeredRect);
Screen('Flip', window);
fprintf('Aim/focus the radiometer and hit enter:\n');
pause;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  MEASUREMENT SET 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target_xy = [[.39,.48]',[.3,.3]',[.4,.4]',[.297,.607]',[.158,.08]'];


for ii = 1:size(target_xy,2)
    % Calc the settings from the xy
    targetXYZRaw = xyYToXYZ([target_xy(:,ii) ; 1]);
    midpointXYZ = PrimaryToSensor(calObj,[.5 .5 .5]');
    rawScale = targetXYZRaw\midpointXYZ;
    targetXYZ = rawScale*targetXYZRaw;
    [imSettings,badSetting] = SensorToSettings(calObj,targetXYZ);
    imPrimary = SettingsToPrimary(calObj,imSettings);
    
    % put up the sqaure
    Screen('FillRect', window, imSettings, centeredRect);
    Screen('Flip', window);
    
    % print stuff
    [xyYDesired] = XYZToxyY(targetXYZ);
    xyYSettings  = XYZToxyY(SettingsToSensor(calObj,imSettings));
    fprintf('\n ** MEASUREMENT %2.0f **\n',ii)
    if badSetting ~= 0
        fprintf('WARNING: SETTING OUT OF GAMUT\n');
    end
    fprintf('The Settings  (R,G,B): (%4.2f, %4.2f, %4.2f)\n', imSettings(1), imSettings(2), imSettings(3));
    fprintf('CIE Desired   (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', xyYDesired(1), xyYDesired(2), xyYDesired(3));
    fprintf('CIE Settings  (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', xyYSettings(1), xyYSettings(2), xyYSettings(3));
    
    % measure
    rawMeasurement= pr670obj.measure;
    % compute the xyY if the measured spectrum
    A = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,pr670obj.userS);
    measuredXYZ = A * rawMeasurement';
    measured_xyY = XYZToxyY(measuredXYZ);
    fprintf('CIE MEasured  (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', measured_xyY(1), measured_xyY(2), measured_xyY(3));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  MEASUREMENT SET 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

theSettings  = [[1,0,0]',[0,1,0]',[0,0,1]'];

for jj = 1:size(theSettings,2)
    % Calc the settings from the xy
    
    imSettings = theSettings(:,jj);
    imPrimary = SettingsToPrimary(calObj,imSettings);
    
    % put up the sqaure
    Screen('FillRect', window, imSettings, centeredRect);
    Screen('Flip', window);
    
    % print stuff
    xyYSettings  = XYZToxyY(SettingsToSensor(calObj,imSettings));
    fprintf('\n ** MEASUREMENT %2.0f **\n',ii+jj)
    fprintf('The Settings  (R,G,B): (%4.2f, %4.2f, %4.2f)\n', imSettings(1), imSettings(2), imSettings(3));
    fprintf('CIE Settings  (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', xyYSettings(1), xyYSettings(2), xyYSettings(3));
    
    % measure
    rawMeasurement= pr670obj.measure;
    % compute the xyY if the measured spectrum
    A = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,pr670obj.userS);
    measuredXYZ = A * rawMeasurement';
    measured_xyY = XYZToxyY(measuredXYZ);
    fprintf('CIE MEasured  (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', measured_xyY(1), measured_xyY(2), measured_xyY(3));
end

%% end of measurements

pr670obj.shutDown();

sca;