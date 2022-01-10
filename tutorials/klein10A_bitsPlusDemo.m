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
% [rootDir,~] = fileparts(which(mfilename));
% resourcesDir = sprintf('%s/resources',rootDir);
% setpref('BrainardLabToolbox','CalDataFolder',resourcesDir);
% cal = LoadCalFile('ViewSonicG220fb');
% calObj = ObjectToHandleCalOrCalStruct(cal);

resourcesDir =  getpref('CorticalColorMapping','CalDataFolder');
load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
cal = cals{3};
calObj = ObjectToHandleCalOrCalStruct(cal);

%% Make this a 14-bit device as far as the calibration file goes (FOR NOW)
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

bgPrimary = [0.5 0.5 0.5]';
bgSettings = PrimaryToSettings(calObj,bgPrimary);
% bgPrimary = SettingsToPrimary(calObj,bgSettings);
bgExcitations = SettingsToSensor(calObj,bgSettings);
% imSettings = [88:10:148];
imSettings = 124:132;

%% MAKING LOOKUP TABLE
        
targetContrastDir = [1 1 1]'; targetContrastDir = targetContrastDir/norm(targetContrastDir);
targetContrast = 0.18;

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

%% KLEIN STUFF

bUseKlein = 1;
bSingleShot = 1;

if bUseKlein==1
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
end

% OPENING NEW WINDOW WITH BITS PLUS PLUS IN MIND
[window,windowRect] = BitsPlusPlus('OpenWindowBits++',screenNumber,[128 128 128]');

[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
baseRect = [0 0 150 150];
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
% put up the sqaure
aimingSettings = [.3,.7,1].*256-1;
Screen('FillRect', window, aimingSettings, centeredRect);
Screen('Flip', window);
fprintf('Aim/focus the radiometer and hit enter:\n');
pause; 
% SAVE CURRENT GAMMA TABLE SO CAN USE IT TO RESTORE LATER
% [saveGamma,~]=Screen('ReadNormalizedGammaTable',window);
saveGamma = repmat(linspace(0,1,256)',[1 3]);

% ------------ TURN AIMING LIGHTS OFF ---------------------------------
disp('Hit enter to turn lights off'); pause;

if bUseKlein==1
    [status] = K10A_device('sendCommand', 'Lights OFF');
end

bPlusPlusMode = 2;
% LOAD NEW GAMMA TABLE AND FLIP
Screen('LoadNormalizedGammaTable', window, lookupTableSettings,bPlusPlusMode);
Screen('Flip', window);

if bUseKlein==1
    % ------------- ENABLE AUTO-RANGE -------------------------------------
    [status, response] = K10A_device('sendCommand', 'EnableAutoRanging');

    % ----------- LOCK THE RANGE FOR STREAMING -----------------------
    disp('Select a luminance range');
    disp('Range 1: Can measure down to 0.001 cd/m^2, saturates at around  20 cd/m^2');
    disp('Range 2: Can measure down to 0.010 cd/m^2, saturates at around 240 cd/m^2');
    disp('Range 3: Can measure down to 0.400 cd/m^2, saturates at around 800 cd/m^2');
    disp('Range 4: Saturates above 2000 cd/m^2');
    disp('Range 5: Saturates above xxxx cd/m^2');
    disp('Range 6: Saturates above yyyy cd/m^2');
    luminanceRange = input('Range [1-6] : ');

    [status, response] = K10A_device('sendCommand', 'DisableAutoRanging');
    switch luminanceRange
        case 1
            [status, response] = K10A_device('sendCommand', 'LockInRange1');
        case 2
            [status, response] = K10A_device('sendCommand', 'LockInRange2');
        case 3
            [status, response] = K10A_device('sendCommand', 'LockInRange3');
        case 4
            [status, response] = K10A_device('sendCommand', 'LockInRange4');
        case 5
            [status, response] = K10A_device('sendCommand', 'LockInRange5');
        case 6
            [status, response] = K10A_device('sendCommand', 'LockInRange6');
        otherwise
            [status, response] = K10A_device('sendCommand', 'LockInRange2');
    end
end
disp('Hit enter for the last time');
pause(10);
%% ------------- GET SOME CORRECTED xyY MEASUREMENTS -------------------

nMeasurements = 100;
lumMeas = [];
imSettingsMeas = [];

for m = 1:nMeasurements
    testPermInds = randperm(length(imSettings));
%    testPermInds = 1:length(imSettings);
    for k = 1:length(testPermInds)
        texTest = Screen('MakeTexture', window, imSettings(testPermInds(k)));
        Screen('DrawTexture', window, texTest, [], centeredRect);
        Screen('Flip', window);
        pause(0.1);
       if bUseKlein==1
           if bSingleShot==1
               [status, response] = K10A_device('sendCommand', 'SingleShot XYZ');
               fprintf('response[%d]:%s\n', k, response);         
               indLum = strfind(response,'Lum:');
               lumMeas(end+1) = str2num(response(indLum+4:indLum+10));
               imSettingsMeas(end+1) = imSettings(testPermInds(k));
               display(['Measurement ' num2str(length(lumMeas))]);
           else
               streamDurationInSeconds = 1.5;
               [status, uncorrectedYdata256HzStream, ...
                correctedXdata8HzStream, ...
                correctedYdata8HzStream, ...
                correctedZdata8HzStream] = ...
                K10A_device('sendCommand', 'Standard Stream', streamDurationInSeconds);
                lumMeas = [lumMeas; correctedYdata8HzStream'];
                imSettingsMeas = [imSettingsMeas; imSettings(testPermInds(k)).*ones([length(correctedYdata8HzStream) 1])];
                display([num2str(length(lumMeas)) ' Measurements']);
           end
       end
    end
end

% for k = 1:length(imSettings)
%     texTest = Screen('MakeTexture', window, imSettings(k));
%     Screen('DrawTexture', window, texTest, [], [100 100 windowRect(3)-100 windowRect(4)-100]);
%     Screen('Flip', window);
%     pause(1);
%    [status, response] = K10A_device('sendCommand', 'SingleShot XYZ');
%    fprintf('response[%d]:%s\n', k, response);
%    indLum = strfind(response,'Lum:');
%    lumMeas(end+1) = str2num(response(indLum+4:indLum+9));
%    imSettingsMeas(end+1) = imSettings(k);
%    display(['Measurement ' num2str(length(lumMeas))]);
% end

if bUseKlein==1
    status = K10A_device('close');
    if (status == 0)
        disp('Closed previously-opened Klein port');
    elseif (status == -1)
        disp('Could not close previously-opened Klein port');
    end
end

% RESTORE GAMMA TABLE AND FLIP
Screen('LoadNormalizedGammaTable', window, saveGamma,bPlusPlusMode);
Screen('Flip', window);

% Clear the screen.
sca;

%%

meanLum = [];

for i = 1:length(imSettings)
    ind = imSettingsMeas == imSettings(i);
    meanLum(i) = mean(lumMeas(ind));
end

figure; 
plot(imSettings,meanLum,'ko');
formatFigure('Settings','Y');
