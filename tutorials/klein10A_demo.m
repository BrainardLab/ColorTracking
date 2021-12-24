% Klein10A check Demo.
% Use a cal file to set primaries to a corresponding XYZ/xyY and use the klien
% to measure the CRT and see if we recover the XYZ/xyY.
%% Clear
clear; close all;

%% Verbose?
%
% Set to true to get more output
VERBOSE = false;

%% Load cal file
[rootDir,~] = fileparts(which(mfilename));
resourcesDir = sprintf('%s/resources',rootDir);
setpref('BrainardLabToolbox','CalDataFolder',resourcesDir);
cal = LoadCalFile('ViewSonicG220fb');
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

target_xy = [.5,.2]';

targetXYZRaw = xyYToXYZ([target_xy ; 1]);
midpointXYZ = PrimaryToSensor(calObj,[1 1 1]');
rawScale = targetXYZRaw\midpointXYZ;
targetXYZ = rawScale*targetXYZRaw;
imSettings = SensorToSettings(calObj,targetXYZ);
imPrimary = SettingsToPrimary(calObj,imSettings);


PsychDefaultSetup(2);


screens = Screen('Screens');

screenNumber = max(screens);

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, imSettings');


% ------ OPEN THE DEVICE ----------------------------------------------
status = K10A_device('open', '/dev/ttyUSB0');
if (status == 0)
    disp('Opened Klein port');
elseif (status == -1)
    disp('Could not open Klein port');
elseif (status == 1)
    disp('Klein port was already opened');
elseif (status == -99)
    disp('Invalided serial port');
end

% ----- SETUP DEFAULT COMMUNICATION PARAMS ----------------------------
speed     = 9600;
wordSize  = 8;
parity    = 'n';
timeOut   = 50000;

status = K10A_device('updateSettings', speed, wordSize, parity,timeOut);
if (status == 0)
    disp('Update communication settings in Klein port');
elseif (status == -1)
    disp('Could not update settings in Klein port');
elseif (status == 1)
    disp('Klein port is not open');
end


% ----- READ ANY DATA AVAILABLE AT THE PORT ---------------------------
[status, dataRead] = K10A_device('readPort');
if ((status == 0) && (length(dataRead) > 0))
    fprintf('Read data: %s (%d chars)\n', dataRead, length(dataRead));
end


% ----- WRITE SOME DUMMY DATA TO THE PORT -----------------------------
status = K10A_device('writePort', 'Do you feel lucky, punk?');


% ----- READ ANY DATA AVAILABLE AT THE PORT ----------------------------
[status, dataRead] = K10A_device('readPort');
if ((status == 0) && (length(dataRead) > 0))
    fprintf('Read data: %s (%d chars)\n', dataRead, length(dataRead));
end


% ------------- GET THE SERIAL NO OF THE KLEIN METER ------------------
[status, modelAndSerialNo] = ...
    K10A_device('sendCommand', 'Model and SerialNo');
fprintf('Serial no and model: %s\n', modelAndSerialNo);


% ------------ GET THE FIRMWARE REVISION OF THE KLEIN METER -----------
[status, response] = K10A_device('sendCommand', 'FlickerCal & Firmware');
fprintf('>>> Firmware version: %s\n', response(20:20+7-1));


% ------------ TURN AIMING LIGHTS ON ----------------------------------
[status] = K10A_device('sendCommand', 'Lights ON');

% ------------ TURN AIMING LIGHTS OFF ---------------------------------
disp('Hit enter to turn lights off'); pause;
[status] = K10A_device('sendCommand', 'Lights OFF');


% ------------- ENABLE AUTO-RANGE -------------------------------------
[status, response] = K10A_device('sendCommand', 'EnableAutoRanging');

% ----------- LOCK THE RANGE FOR STREAMING -----------------------
[status, response] = K10A_device('sendCommand', 'DisableAutoRanging');
[status, response] = K10A_device('sendCommand', 'LockInRange2');

% ------------- GET SOME CORRECTED xyY MEASUREMENTS -------------------
[xyYDesired] = XYZToxyY(targetXYZ);
fprintf('CIE (x,y): (%4.2f, %4.2f) Ylum: %4.4f Cd/m^2\n', xyYDesired(1), xyYDesired(2), xyYDesired(3));

[status, response] = K10A_device('sendCommand', 'SingleShot XYZ');
fprintf('response[%d]:%s\n', 1, response);

[status, response] = K10A_device('sendCommand', 'SingleShot XYZ');
fprintf('response[%d]:%s\n', 2, response);

status = K10A_device('close');
if (status == 0)
    disp('Closed previously-opened Klein port');
elseif (status == -1)
    disp('Could not close previously-opened Klein port');
end

% Clear the screen.
sca;

% % OPENING NEW WINDOW WITH BITS PLUS PLUS IN MIND
% [win,winRect] = BitsPlusPlus('OpenWindowBits++',screenid,[0.5 0.5 0.5].*256);
%
% % SAVE CURRENT GAMMA TABLE SO CAN USE IT TO RESTORE LATER
% [saveGamma,~]=Screen('ReadNormalizedGammaTable',win);
%
% bPlusPlusMode = 2;
% % LOAD NEW GAMMA TABLE
% Screen('LoadNormalizedGammaTable', win, newCLUT1,bPlusPlusMode);
%
% % RESTORE GAMMA TABLE
% Screen('LoadNormalizedGammaTable', win, saveGamma,bPlusPlusMode);
%
% % LOOPING AND UPDATING TEXTURE. REMEMBER THAT imSettings IS INTEGER
% pause;
% for k = 1:5
%     imSettings = imSettings+1;
%     texTest = Screen('MakeTexture', window, imSettings, [], [], 2);
%     Screen('DrawTexture', window, texTest, [], [200 200 windowRect(3)-200 windowRect(4)-200]);
%     Screen('Flip', window);
%     pause;
% end