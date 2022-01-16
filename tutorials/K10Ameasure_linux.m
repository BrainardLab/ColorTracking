% K10Ademo_linux
% K10Ademo- Demonstrates the usage of the K10A_device driver for
% controlling the Klein K10A luminance meter.
%
% Syntax:
% K10Ademo
%
% Description:
% K10demo demostrates the different commands that can be sent to the K10A_device
% driver which enables the user to conduct high temporal frequency measurements
% across a very large range of luminance levels (0.001 to 4000+ cd/m^2)
%
% Controls:
% 'q'         - Terminates infinite stream and exits the demo
%
% History:
% 1/30/2014   npc    Wrote it.
% 1/31/2013   npc    Updated 'SingleShot XYZ' command to return both XYZ and xyY.
%                    Updated 'Standard Stream' command to return an 8Hz stream of the raw corrected XYZ instead of the xyY values.
%

% ----- COMPILE THE DRIVER (JUST IN CASE IT HAS NOT BEEN COMPILED) ----
disp('Compiling KleinK10A device driver ...');
currentDir = pwd;
programName = 'K10Ademo.m';
d = which(programName);
k = findstr(d, programName);
d = d(1:k-1);
cd(d);
mex('K10A_device.c');
cd(currentDir);
disp('KleinK10A device driver compiled sucessfully!')
% ------ SET THE VERBOSITY LEVEL (1=minimum, 5=intermediate, 10=full)--
status = K10A_device('setVerbosityLevel', 1);

KbName('UnifyKeyNames')
key_SPACE  = KbName('space');
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

% ------------ GET THE FIRMWARE REVISION OF THE KLEIN METER -----------
[status, response] = K10A_device('sendCommand', 'FlickerCal & Firmware');
fprintf('>>> Firmware version: %s\n', response(20:20+7-1));


% ------------ TURN AIMING LIGHTS ON ----------------------------------
[status] = K10A_device('sendCommand', 'Lights ON');

% ------------ TURN AIMING LIGHTS OFF ---------------------------------
disp('Hit enter to turn lights off'); pause;
[status] = K10A_device('sendCommand', 'Lights OFF');


[status, response] = K10A_device('sendCommand', 'LockInRange2');

% INITIALIZE KEYBOARD QUEUE
fprintf('Hit the space key to measure');

pause;

% STREAM DATA AND UPDATE PLOT EVERY streamDurationInSeconds
streamDurationInSeconds = 15;

    % ---- STREAM FOR SPECIFIED DURATION --------------------------
    [status, uncorrectedYdata256HzStream, ...
        correctedXdata8HzStream, ...
        correctedYdata8HzStream, ...
        correctedZdata8HzStream] = ...
        K10A_device('sendCommand', 'Standard Stream', streamDurationInSeconds);
    % -------------------------------------------------------------
    
    % ----- COMPUTE xy CIE COORDINATES ----------------------------
    meanY = mean(correctedYdata8HzStream);

    
   
    % ---- PLOT RESPONSE ------------------------------------------
    h= figure;
    time = [1:length(uncorrectedYdata256HzStream)]/256.0 * 1000.0;
plot(correctedYdata8HzStream);    drawnow;

% -------- DISABLE KEYBOARD CAPTURE -------------------------------
ListenChar(0);

% -------- ENABLE AUTO-RANGE --------------------------------------
[status, response] = K10A_device('sendCommand', 'EnableAutoRanging');


% -------- GET SOME CORRECTED xyY MEASUREMENTS --------------------
for k=1:5
    [status, response] = K10A_device('sendCommand', 'SingleShot XYZ');
    fprintf('response[%d]:%s\n', k, response);
end


% ------ CLOSE THE DEVICE -----------------------------------------
status = K10A_device('close');
if (status == 0)
    disp('Closed previously-opened Klein port');
elseif (status == -1)
    disp('Could not close previously-opened Klein port');
end



