subjId = 'JNK';
%% load the stim

if ~exist('theStimPatch','var')
    filePath = fullfile(getpref('ColorTracking','dropboxPath'),'CNST_materials','ColorTrackingTask','stimCache','TTR',subjId);
    fileName = 'stimCache.mat';
    load(fullfile(filePath,fileName),'theStimPatch','expParams');
end
%%
resourcesDir =  getpref('ColorTracking','CalDataFolder');
load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
calCell = 4;
cal = cals{calCell};
calObj = ObjectToHandleCalOrCalStruct(cal);
gammaMethod = 2;
SetGammaMethod(calObj,gammaMethod);
%% Load the cone fundamentals
load T_cones_ss2.mat
load T_CIE_Y2.mat

% Set the sensor space to cone coordinates
SetSensorColorSpace(calObj,T_cones_ss2,S_cones_ss2);

% set the background primaries
bgPrimaries = [0.5;0.5;0.5];
bgSettings = PrimaryToSettings(calObj,bgPrimaries);
% set the target modulation
targetMod = [0.05;0;0.2];

% get the excitations of the background
bgExcitations = PrimaryToSensor(calObj,bgPrimaries);

%% generate noise only trials
linNoise = linspace(expParams.noise(1),expParams.noise(2),2.^8);
noiseContrast   = repmat(linNoise,[3,1]);
noiseExcitation = ContrastToExcitations(noiseContrast,bgExcitations);
noiseSettings  = SensorToSettings(calObj,noiseExcitation);


%% Show the stuff
numFrames = size(theStimPatch,4)

PsychDefaultSetup(2);

screens = Screen('Screens');
screenNumber = max(screens);

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, bgSettings);

for ii = 1:size(theStimPatch,5)
    for jj= 1:numFrames
        stimTex(jj) = Screen('MakeTexture', window, theStimPatch(:,:,:,jj,ii));
        im  = noiseSettings(:,randi([1,256],[1,expParams.imgSzXYpxl(1)*expParams.imgSzXYpxl(2)]));
        noiseInterval = reshape(im',[expParams.imgSzXYpxl(1),expParams.imgSzXYpxl(2),3]);
        noiseTex(jj) = Screen('MakeTexture', window, noiseInterval);
    end

    % make fixation dot
    [xCenter, yCenter] = RectCenter(windowRect);
    fixRectSize = [0 0 5 5];
    fixationRect = CenterRectOnPointd(fixRectSize, xCenter, yCenter);

    centeredRect = CenterRectOnPointd(windowRect, xCenter, yCenter);
    % show it
    intIndx = randperm(2);
    for bb = 1:length(intIndx)
        % The signal
        if intIndx(bb) == 1
            for kk = 1:numFrames
                Screen('DrawTextures', window, stimTex(kk));
                Screen('FillRect', window, [0,0,0], fixationRect);
                Screen('Flip', window);
            end
            
            Screen('FillRect', window, bgSettings, centeredRect);
            Screen('Flip', window);
            if bb == 1
            pause(expParams.intervalGap )
            end
        % the noise    
        elseif intIndx(bb) == 2
            for kk = 1:numFrames
                Screen('DrawTextures', window, noiseTex(kk));
                Screen('FillRect', window, [0,0,0], fixationRect);
                Screen('Flip', window);
            end
            Screen('FillRect', window, bgSettings, centeredRect);
            Screen('Flip', window);
            if bb == 1
            pause(expParams.intervalGap )
            end
        end
    end
    pause
end
sca



