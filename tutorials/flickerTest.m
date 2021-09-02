fclose all;
clearvars;

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


% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, 0.3);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 50);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);


baseRect = [0 0 200 200];
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);

rectColor = [1, 0, 0];

rectImg = ones(1,1);

contrastSteps = 0.01;
Fs = 60;                  % samples per second
dt = 1/Fs;                % seconds per sample
StopTime = 4;             % seconds
timebase = (0:contrastSteps:StopTime-contrastSteps)';  % seconds
Fc = [1,2,4,8,12,16] ;

counter = 1;
for ff = 1:length(Fc)

contrastMod = cos(2*pi*Fc(ff)*timebase);

contrastMod = (contrastMod + abs(min(contrastMod)));
contrastMod = contrastMod./max(contrastMod);

for jj = 1:length(contrastMod)
    goodImg =  rectImg .* contrastMod(jj);
    
    
    % Draw grating mask
    squareTex(counter) = Screen('MakeTexture', window, goodImg);
    counter = counter+1;
    
end

end
% Construct our text string
textString = 'Prepare the device';

% Text output of mouse position draw in the centre of the screen
DrawFormattedText(window, textString, xCenter-210 , yCenter - round( (4)/2)- 35, 0);

% Flip to the screen
Screen('Flip', window);
WaitForKeyPress 

%% Start Recording

% Loop the animation 
for ii = 1:length(squareTex)  
        % Draw grating mask
 
    Screen('DrawTexture', window, squareTex(ii),[], centeredRect);
    % Flip to the screen on the next vertical retrace
    vbl = Screen('Flip', window);
end

% Stop Recording


% Clear the screen
sca;