% Clear the workspace
close all;
clearvars;
sca;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

%% get monitor calibration info
% Determine location of resourcesDir
[codeDir,~] = fileparts(which(mfilename));
[rootDir,~] = fileparts(codeDir);
resourcesDir = sprintf('%s/calFiles',rootDir);

% Select the calibration file for a particular display (here a ViewSonic display)
displayCalFileName = sprintf('%s/ViewSonicProbe', resourcesDir);

% Load the calibration file
load(displayCalFileName, 'cals');

% Construct a calStructOBJ from the latest calibration
[calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(cals{end});


% Define black and white
white = WhiteIndex(screenNumber);

% Speficy primary values for background
backgroundPrimaries = [.3 .3 .3]';

% Open an on screen window
% To  settings
gammaMethod = 1;
SetGammaMethod(calStructOBJ, gammaMethod, 1024);
greyScreen = PrimaryToSettings(calStructOBJ,backgroundPrimaries);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, greyScreen);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Grating size in pixels
gratingSizePix = 600;

% Grating frequency in cycles / pixel
freqCyclesPerPix = 0.01;

% Drift speed cycles per second
cyclesPerSecond = 1;

% Define Half-Size of the grating image.
texsize = gratingSizePix / 2;

% First we compute pixels per cycle rounded to the nearest pixel
pixPerCycle = ceil(1 / freqCyclesPerPix);

% Frequency in Radians
freqRad = freqCyclesPerPix * 2 * pi;

% This is the visible size of the grating
visibleSize = 2 * texsize + 1;

% Define our grating. Note it is only 1 pixel high. PTB will make it a full
% grating upon drawing
x = meshgrid(-texsize:texsize + pixPerCycle, 1);
grating = backgroundPrimaries * cos(freqRad*x) + backgroundPrimaries;

% Speficy LMS contrast vector
LMScontrastModulation1 = 0.12.*[.7071 -.7071 0];
LMScontrastModulation2 = 0.12.*[.7071 .7071 0];
angle = 0;

[stimPrimariesMod1,coneExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,backgroundPrimaries,LMScontrastModulation1, angle,'phase',90);

for ii = 1: length(backgroundPrimaries)
    background(ii,:) =  backgroundPrimaries(ii) .* ones([1 imgInfo.rows*imgInfo.cols]);
end

contrastSteps = 0.01;
% Fs = 60;                  % samples per second
% dt = 1/Fs;                % seconds per sample
StopTime = 1;             % seconds
timebase = (0:contrastSteps:StopTime-contrastSteps)';  % seconds
Fc = 1;
%contrasts = cos(2*pi*Fc*timebase);
contrasts = ones(size(timebase));
phaseMod2 = 0:360/length(contrasts):360-(360/length(contrasts));
for jj = 1:length(contrasts)
    
    [stimPrimariesMod2,coneExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,backgroundPrimaries,LMScontrastModulation2, angle,'phase',phaseMod2(jj));
    
    stimPrimaries = (contrasts(jj)*(stimPrimariesMod1+stimPrimariesMod2)) + background;
    
    % To  settings
    gammaMethod = 1;
    SetGammaMethod(calStructOBJ, gammaMethod, 1024);
    settings = PrimaryToSettings(calStructOBJ,stimPrimaries);
    
    %  Back to image format
    mask = reshape(settings', [imgInfo.rows  imgInfo.cols 3]);
    masks(:,:,:,jj) = mask;
    
    % Make our grating mask texture
    gratingMaskTex(jj) = Screen('MakeTexture', window, masks(:,:,:,jj));
end

% Make a destination rectangle for our textures and center this on the
% screen
dstRect = [0 0 visibleSize visibleSize];
dstRect = CenterRect(dstRect, windowRect);

% We set PTB to wait one frame before re-drawing
waitframes = 1;

% Calculate the wait duration
waitDuration = waitframes * ifi;

% Recompute pixPerCycle, this time without the ceil() operation from above.
% Otherwise we will get wrong drift speed due to rounding errors
pixPerCycle = 1 / freqCyclesPerPix;

% Translate requested speed of the grating (in cycles per second) into
% a shift value in "pixels per frame"
shiftPerFrame = cyclesPerSecond * pixPerCycle * waitDuration;

% Sync us to the vertical retrace
vbl = Screen('Flip', window);

% Set the frame counter to zero, we need this to 'drift' our grating
frameCounter = 0;

% Loop until a key is pressed
indx = 1;
while ~KbCheck
    
    % Draw grating mask
    Screen('DrawTexture', window, gratingMaskTex(indx));
    
    % Flip to the screen on the next vertical retrace
    vbl = Screen('Flip', window);
    
   indx = indx+1;
   if indx> length(contrasts)
     indx = 1;
   end
end

% Clear the screen
sca;
close all;