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
nDeviceBits = 14;
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
load T_xyz1931.mat % Judd-Vos XYZ Color matching function
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);

SetSensorColorSpace(calObj,T_xyz,S);

target_xy = [0.326 0.372]';

targetXYZRaw = xyYToXYZ([target_xy ; 1]);
midpointXYZ = PrimaryToSensor(calObj,[.5 .5 .5]');
rawScale = targetXYZRaw\midpointXYZ;
targetXYZ = rawScale*targetXYZRaw;
bgSettings = SensorToSettings(calObj,targetXYZ);
bgPrimary = SettingsToPrimary(calObj,bgSettings);
bgExcitations = SettingsToSensor(calObj,bgSettings);
imSettings = 128;

%% MAKING LOOKUP TABLE

targetContrastDir = [1 0 0]'; targetContrastDir = targetContrastDir/norm(targetContrastDir);
targetContrast = 0.3;

fprintf('Building lookup table ...');
lookupTableMethod = 'targetContrast';
nFrameBufferBits = 8;
nFrameBufferLevels = 2^nFrameBufferBits;
lookupTableDesiredMonochromeContrastsCal = [linspace(-1,-2/nFrameBufferLevels,nFrameBufferLevels/2-1) 0 linspace(2/nFrameBufferLevels,1,nFrameBufferLevels/2)];
switch (lookupTableMethod)
    case 'targetContrast'
        lookupTableDesiredContrastCal = targetContrast*targetContrastDir*lookupTableDesiredMonochromeContrastsCal;
    case 'maximumContrast'
        lookupTableDesiredContrastCal = maximumContrast*targetContrastDir*lookupTableDesiredMonochromeContrastsCal;
end
lookupTableDesiredExcitationsCal = ContrastToExcitation(lookupTableDesiredContrastCal,bgExcitations);
lookupTableSettings = SensorToSettings(calObj,lookupTableDesiredExcitationsCal)';

%% PSYCTOOLBOX STUFF

PsychDefaultSetup(2);

screens = Screen('Screens');

screenNumber = max(screens);

% OPENING NEW WINDOW WITH BITS PLUS PLUS IN MIND
[window,windowRect] = BitsPlusPlus('OpenWindowBits++',screenNumber,imSettings.*[1 1 1]);

% SAVE CURRENT GAMMA TABLE SO CAN USE IT TO RESTORE LATER
[saveGamma,~]=Screen('ReadNormalizedGammaTable',window);

% lookupTableSettings = repmat(linspace(0,1,256)',[1 3]);
bPlusPlusMode = 2;
% LOAD NEW GAMMA TABLE
Screen('LoadNormalizedGammaTable', window, lookupTableSettings,bPlusPlusMode);
Screen('Flip', window);
pause;
%% KLEIN STUFF

% % ------ OPEN THE DEVICE ----------------------------------------------
% status = K10A_device('open', '/dev/ttyUSB0');
% if (status == 0)
%     disp('Opened Klein port');
% elseif (status == -1)
%     disp('Could not open Klein port');
% elseif (status == 1)
%     disp('Klein port was already opened');
% elseif (status == -99)
%     disp('Invalided serial port');
% end
% 
% % ----- SETUP DEFAULT COMMUNICATION PARAMS ----------------------------
% speed     = 9600;
% wordSize  = 8;
% parity    = 'n';
% timeOut   = 50000;
% 
% status = K10A_device('updateSettings', speed, wordSize, parity,timeOut);
% if (status == 0)
%     disp('Update communication settings in Klein port');
% elseif (status == -1)
%     disp('Could not update settings in Klein port');
% elseif (status == 1)
%     disp('Klein port is not open');
% end
% 
% 
% % ----- READ ANY DATA AVAILABLE AT THE PORT ---------------------------
% [status, dataRead] = K10A_device('readPort');
% if ((status == 0) && (length(dataRead) > 0))
%     fprintf('Read data: %s (%d chars)\n', dataRead, length(dataRead));
% end
% 
% 
% % ----- WRITE SOME DUMMY DATA TO THE PORT -----------------------------
% status = K10A_device('writePort', 'Do you feel lucky, punk?');
% 
% 
% % ----- READ ANY DATA AVAILABLE AT THE PORT ----------------------------
% [status, dataRead] = K10A_device('readPort');
% if ((status == 0) && (length(dataRead) > 0))
%     fprintf('Read data: %s (%d chars)\n', dataRead, length(dataRead));
% end
% 
% 
% % ------------- GET THE SERIAL NO OF THE KLEIN METER ------------------
% [status, modelAndSerialNo] = ...
%     K10A_device('sendCommand', 'Model and SerialNo');
% fprintf('Serial no and model: %s\n', modelAndSerialNo);
% 
% 
% % ------------ GET THE FIRMWARE REVISION OF THE KLEIN METER -----------
% [status, response] = K10A_device('sendCommand', 'FlickerCal & Firmware');
% fprintf('>>> Firmware version: %s\n', response(20:20+7-1));
% 
% 
% % ------------ TURN AIMING LIGHTS ON ----------------------------------
% [status] = K10A_device('sendCommand', 'Lights ON');
% 
% % ------------ TURN AIMING LIGHTS OFF ---------------------------------
% disp('Hit enter to turn lights off'); pause;
% [status] = K10A_device('sendCommand', 'Lights OFF');
% 
% 
% % ------------- ENABLE AUTO-RANGE -------------------------------------
% [status, response] = K10A_device('sendCommand', 'EnableAutoRanging');
% 
% % ----------- LOCK THE RANGE FOR STREAMING -----------------------
% [status, response] = K10A_device('sendCommand', 'DisableAutoRanging');
% [status, response] = K10A_device('sendCommand', 'LockInRange2');
% 
% % ------------- GET SOME CORRECTED xyY MEASUREMENTS -------------------

for k = 1:20
    texTest = Screen('MakeTexture', window, (1/255).*(imSettings+k*5), [], [], 2);
    Screen('DrawTexture', window, texTest, [], [200 200 windowRect(3)-200 windowRect(4)-200]);
    Screen('Flip', window);
%    [status, response] = K10A_device('sendCommand', 'SingleShot XYZ');
%    fprintf('response[%d]:%s\n', k, response);
    imSettings+k*10
    pause;
end

% status = K10A_device('close');
% if (status == 0)
%     disp('Closed previously-opened Klein port');
% elseif (status == -1)
%     disp('Could not close previously-opened Klein port');
% end

% saveGamma = repmat(linspace(0,1,256)',[1 3]);
% RESTORE GAMMA TABLE
Screen('LoadNormalizedGammaTable', window, saveGamma,bPlusPlusMode);

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