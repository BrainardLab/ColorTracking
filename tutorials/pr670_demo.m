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

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %  MEASUREMENT 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% target_xy = [.39,.48]';
% targetXYZRaw = xyYToXYZ([target_xy ; 1]);
% midpointXYZ = PrimaryToSensor(calObj,[.5 .5 .5]');
% rawScale = targetXYZRaw\midpointXYZ;
% targetXYZ = rawScale*targetXYZRaw;
% imSettings = SensorToSettings(calObj,targetXYZ);
% imPrimary = SettingsToPrimary(calObj,imSettings);
% 
% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, imSettings');
% [xyYDesired] = XYZToxyY(targetXYZ);
% fprintf('\n ** MEASUREMENT 1 **\n')
% fprintf('CIE Desired (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', xyYDesired(1), xyYDesired(2), xyYDesired(3));
% 
% rawMeasurement= pr670obj.measure;
% A = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,pr670obj.userS);
% measuredXYZ = A * rawMeasurement';
% measured_xyY = XYZToxyY(measuredXYZ);
% fprintf('CIE MEasured (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', measured_xyY(1), measured_xyY(2), measured_xyY(3));
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %  MEASUREMENT 2
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% target_xy = [.3,.3]';
% targetXYZRaw = xyYToXYZ([target_xy ; 1]);
% midpointXYZ = PrimaryToSensor(calObj,[.5 .5 .5]');
% rawScale = targetXYZRaw\midpointXYZ;
% targetXYZ = rawScale*targetXYZRaw;
% imSettings = SensorToSettings(calObj,targetXYZ);
% imPrimary = SettingsToPrimary(calObj,imSettings);
% 
% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, imSettings');
% [xyYDesired] = XYZToxyY(targetXYZ);
% fprintf('\n ** MEASUREMENT 2 **\n')
% fprintf('CIE Desired (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', xyYDesired(1), xyYDesired(2), xyYDesired(3));
% 
% rawMeasurement= pr670obj.measure;
% A = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,pr670obj.userS);
% measuredXYZ = A * rawMeasurement';
% measured_xyY = XYZToxyY(measuredXYZ);
% fprintf('CIE MEasured (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', measured_xyY(1), measured_xyY(2), measured_xyY(3));
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %  MEASUREMENT 3
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% target_xy = [.62,.33]';
% targetXYZRaw = xyYToXYZ([target_xy ; 1]);
% midpointXYZ = PrimaryToSensor(calObj,[.5 .5 .5]');
% rawScale = targetXYZRaw\midpointXYZ;
% targetXYZ = rawScale*targetXYZRaw;
% imSettings = SensorToSettings(calObj,targetXYZ);
% imPrimary = SettingsToPrimary(calObj,imSettings);
% 
% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, imSettings');
% [xyYDesired] = XYZToxyY(targetXYZ);
% fprintf('\n ** MEASUREMENT 3 **\n')
% fprintf('CIE Desired (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', xyYDesired(1), xyYDesired(2), xyYDesired(3));
% 
% rawMeasurement= pr670obj.measure;
% A = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,pr670obj.userS);
% measuredXYZ = A * rawMeasurement';
% measured_xyY = XYZToxyY(measuredXYZ);
% fprintf('CIE MEasured (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', measured_xyY(1), measured_xyY(2), measured_xyY(3));
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %  MEASUREMENT 4
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% target_xy = [.297,.607]';
% targetXYZRaw = xyYToXYZ([target_xy ; 1]);
% midpointXYZ = PrimaryToSensor(calObj,[.5 .5 .5]');
% rawScale = targetXYZRaw\midpointXYZ;
% targetXYZ = rawScale*targetXYZRaw;
% imSettings = SensorToSettings(calObj,targetXYZ);
% imPrimary = SettingsToPrimary(calObj,imSettings);
% 
% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, imSettings');
% [xyYDesired] = XYZToxyY(targetXYZ);
% fprintf('\n ** MEASUREMENT 4 **\n')
% fprintf('CIE Desired (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', xyYDesired(1), xyYDesired(2), xyYDesired(3));
% 
% rawMeasurement= pr670obj.measure;
% A = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,pr670obj.userS);
% measuredXYZ = A * rawMeasurement';
% measured_xyY = XYZToxyY(measuredXYZ);
% fprintf('CIE MEasured (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', measured_xyY(1), measured_xyY(2), measured_xyY(3));
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %  MEASUREMENT 5
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% target_xy = [.158,.08]';
% targetXYZRaw = xyYToXYZ([target_xy ; 1]);
% midpointXYZ = PrimaryToSensor(calObj,[.5 .5 .5]');
% rawScale = targetXYZRaw\midpointXYZ;
% targetXYZ = rawScale*targetXYZRaw;
% imSettings = SensorToSettings(calObj,targetXYZ);
% imPrimary = SettingsToPrimary(calObj,imSettings);
% 
% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, imSettings');
% [xyYDesired] = XYZToxyY(targetXYZ);
% fprintf('\n ** MEASUREMENT 5 **\n')
% fprintf('CIE Desired (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', xyYDesired(1), xyYDesired(2), xyYDesired(3));
% 
% rawMeasurement= pr670obj.measure;
% A = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,pr670obj.userS);
% measuredXYZ = A * rawMeasurement';
% measured_xyY = XYZToxyY(measuredXYZ);
% fprintf('CIE MEasured (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', measured_xyY(1), measured_xyY(2), measured_xyY(3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  MEASUREMENT 6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target_xy = [.637,.333]';
targetXYZRaw = xyYToXYZ([target_xy ; 1]);
midpointXYZ = PrimaryToSensor(calObj,[.5 .5 .5]');
rawScale = targetXYZRaw\midpointXYZ;
targetXYZ = rawScale*targetXYZRaw;
imSettings = SensorToSettings(calObj,targetXYZ);
imPrimary = SettingsToPrimary(calObj,imSettings)

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, imSettings');
[xyYDesired] = XYZToxyY(targetXYZ);
fprintf('\n ** MEASUREMENT 6 **\n')
fprintf('CIE Desired (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', xyYDesired(1), xyYDesired(2), xyYDesired(3));

rawMeasurement= pr670obj.measure;
A = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,pr670obj.userS);
measuredXYZ = A * rawMeasurement';
measured_xyY = XYZToxyY(measuredXYZ);
fprintf('CIE MEasured (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', measured_xyY(1), measured_xyY(2), measured_xyY(3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  MEASUREMENT 7
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target_xy = [.295,.611]';
targetXYZRaw = xyYToXYZ([target_xy ; 1]);
midpointXYZ = PrimaryToSensor(calObj,[.5 .5 .5]');
rawScale = targetXYZRaw\midpointXYZ;
targetXYZ = rawScale*targetXYZRaw;
imSettings = SensorToSettings(calObj,targetXYZ);
imPrimary = SettingsToPrimary(calObj,imSettings)

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, imSettings');
[xyYDesired] = XYZToxyY(targetXYZ);
fprintf('\n ** MEASUREMENT 7 **\n')
fprintf('CIE Desired (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', xyYDesired(1), xyYDesired(2), xyYDesired(3));

rawMeasurement= pr670obj.measure;
A = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,pr670obj.userS);
measuredXYZ = A * rawMeasurement';
measured_xyY = XYZToxyY(measuredXYZ);
fprintf('CIE MEasured (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', measured_xyY(1), measured_xyY(2), measured_xyY(3));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  MEASUREMENT 8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target_xy = [.154,.075]';
targetXYZRaw = xyYToXYZ([target_xy ; 1]);
midpointXYZ = PrimaryToSensor(calObj,[.5 .5 .5]');
rawScale = targetXYZRaw\midpointXYZ;
targetXYZ = rawScale*targetXYZRaw;
imSettings = SensorToSettings(calObj,targetXYZ);
imPrimary = SettingsToPrimary(calObj,imSettings)

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, imSettings');
[xyYDesired] = XYZToxyY(targetXYZ);
fprintf('\n ** MEASUREMENT 8 **\n')
fprintf('CIE Desired (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', xyYDesired(1), xyYDesired(2), xyYDesired(3));

rawMeasurement= pr670obj.measure;
A = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,pr670obj.userS);
measuredXYZ = A * rawMeasurement';
measured_xyY = XYZToxyY(measuredXYZ);
fprintf('CIE MEasured (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', measured_xyY(1), measured_xyY(2), measured_xyY(3));

%% end of measurements

pr670obj.shutDown();

sca;