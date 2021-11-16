function rampDemonNoBitsPlus(benchmark)
% gradientDemo([benchmark=0])
%
% This demo creates a smooth gradient from one end of the screen to the
% next. Originally created to test Bits++ device.

% History:
% 11/08/2021 modified from ProceduralSquareWaveDemo.m .

% EITHER [] OR 2
% bPlusPlusMode = 2;

% Default to mode 0 - Just a nice demo.
if nargin < 1
    benchmark = 0;
end

bUsePhotoDiode = 1;
% CREATE NEW GAMMA TABLE
newCLUT1 = repmat(linspace(0,1.0,256)',[1 3]);
% CREATE ANOTHER GAMMA TABLE
newCLUT2 = repmat(linspace(0,0.125,256)',[1 3]);
leaveOutGuns = [];
if ~isempty(leaveOutGuns)
    newCLUT1(:,leaveOutGuns(1)) = zeros([256 1]);
    newCLUT1(:,leaveOutGuns(2)) = zeros([256 1]);
    newCLUT2(:,leaveOutGuns(1)) = zeros([256 1]);
    newCLUT2(:,leaveOutGuns(2)) = zeros([256 1]);
end
% HOW LONG TO DISPLAY EACH GAMMA TABLE
tSecCLUT1 = 5;
tSecCLUT2 = 100;
rampTest = 6./256;

if bUsePhotoDiode==1
    % Instantiate a LabJack object to handle communication with the device
    labjackOBJ = LabJackU6('verbosity', 1);

    % Set up sampling parameters
    samplingParams = struct(...
        'channelIDs', [1], ...         % list of  channels to aquire from (AIN1, AIN2, AIN3)
        'frequencyInHz', 5*1000 ...    % using an 7 KHz sampling rate
        );

    % Configure analog input sampling
    labjackOBJ.configureAnalogDataStream(samplingParams.channelIDs, samplingParams.frequencyInHz);

    durationInSeconds = tSecCLUT2*0.6;
end

% Setup defaults and unit color range:
PsychDefaultSetup(2);

% Disable synctests for this quick demo:
oldSyncLevel = Screen('Preference', 'SkipSyncTests', 2);

% Choose screen with maximum id - the secondary display:
screenid = max(Screen('Screens'));

% Open a window 
PsychImaging('PrepareConfiguration');

% OPEN WINDOW WITH BITS++ FUNCTION
[win,winRect]= PsychImaging('OpenWindow', screenid, 0.5);
% [win,winRect] = BitsPlusPlus('OpenWindowBits++',screenid,[0.5 0.5 0.5].*256);

% SIZE OF STIMULUS ON SCREEN
stimRect = [0 round((winRect(4)*0.4)) winRect(3) round((winRect(4)*0.6))];

% SAVE CURRENT GAMMA TABLE SO CAN USE IT TO RESTORE LATER
[saveGamma,~]=Screen('ReadNormalizedGammaTable',win);

% LOAD NEW GAMMA TABLE
Screen('LoadNormalizedGammaTable', win, newCLUT1);

% CREATE GRADIENT RUNNING FROM MIN TO MAX VALUE
gradientTest = linspace(0,1,256).*256;
% Build a procedural gabor texture for a grating with a support of tw x th
% pixels, and a RGB color offset of 0.5 -- a 50% gray.
% squarewavetex = CreateProceduralSquareWaveGrating(win, res, res, [.5 .5 .5 0], res/2);
gradientTex = Screen('MakeTexture',win,gradientTest);

% Draw the grating once, just to make sure the gfx-hardware is ready for the
% benchmark run below and doesn't do one time setup work inside the
% benchmark loop:
% Screen('DrawTexture', win, squarewavetex, [], [], tilt, [], [], [], [], [], [phase, freq, contrast, 0]);
Screen('DrawTexture', win, gradientTex, [], stimRect);

% Perform initial flip to gray background and sync us to the retrace:
vbl = Screen('Flip', win);
tstart = vbl;
count = 0;

% Animation loop
while GetSecs < tstart + tSecCLUT1
    count = count + 1;

    % Draw the texture:
     Screen('DrawTexture', win, gradientTex, [], stimRect);
    if benchmark > 0
        % Go as fast as you can without any sync to retrace and without
        % clearing the backbuffer -- we want to measure gabor drawing speed,
        % not how fast the display is going etc.
        Screen('Flip', win, 0, 2, 2);
    else
        % Go at normal refresh rate for good looking gabors:
        Screen('Flip', win);
    end
end

% LOAD NEW GAMMA TABLE
Screen('LoadNormalizedGammaTable', win, newCLUT2);

rampTex = Screen('MakeTexture',win,rampTest);
% Draw the texture:
 Screen('DrawTexture', win, rampTex, [], winRect);
 Screen('Flip', win);

if bUsePhotoDiode==1
   % Aquire the data
   labjackOBJ.startDataStreamingForSpecifiedDuration(durationInSeconds);
end

% Animation loop
while GetSecs < tstart + tSecCLUT2
    count = count + 1;
    rampTest = rampTest+1./256
    rampTex = Screen('MakeTexture',win,rampTest);
    % Draw the texture:
     Screen('DrawTexture', win, rampTex, [], winRect);
    if benchmark > 0
        % Go as fast as you can without any sync to retrace and without
        % clearing the backbuffer -- we want to measure gabor drawing speed,
        % not how fast the display is going etc.
        Screen('Flip', win, 0, 2, 2);
    else
        % Go at normal refresh rate for good looking gabors:
        Screen('Flip', win);
    end
    pause(floor(durationInSeconds./9));
end

% RESTORE GAMMA TABLE
Screen('LoadNormalizedGammaTable', win, saveGamma);
% A final synced flip, so we can be sure all drawing is finished when we
% reach this point; print some stats
tend = Screen('Flip', win);
avgfps = count / (tend - tstart);
fprintf('\nPresented a total of %i frames at ~%.2g FPS...\n',count,avgfps);

if bUsePhotoDiode==1
   % Close-up shop
   labjackOBJ.shutdown(); 
end

% Close window, release all ressources:
sca

% Restore old settings for sync-tests:
Screen('Preference', 'SkipSyncTests', oldSyncLevel);
