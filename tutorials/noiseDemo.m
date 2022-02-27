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

%% Generate the chromatic gabor in 3xn format
% get the contrast image
sizeDeg   = [2 2];
smpPerDeg = 75;
theFreq  = 2;
theAngle = 0;
thePhase = 0;
theStdev = 0.25;
contrastImage = generateStimContrastProfile(sizeDeg,smpPerDeg,theFreq,theAngle,thePhase,theStdev);

% get the number of frames for an interval
screenHz = 1/60;
stimDuration = 2;
numFrames = round(stimDuration./screenHz);

% get the ramp on and ramp off weighting vector
rampOnDur  = 0.5;
rampOffDur = 0.5;
rampVec = ones(1,numFrames);
rampOn  = cos(linspace(pi/2,0,round(rampOnDur./screenHz)));
rampOff = cos(linspace(0,pi/2,round(rampOffDur./screenHz)));
rampVec(1:length(rampOn)) = rampOn;
rampVec(end-(length(rampOff)-1):end) = rampOff;

% add the chromatic bits
[contrastLMS] = generateStimContrasts(0,90,.5);
[~,stimExcitations,~] = generateChromaticGabor(calObj,contrastImage,bgExcitations,contrastLMS','rampOnOff',rampVec);

%% set up the noise and the ramp on and off
noiseSize = 150;
noiseMin = -0.7;
noiseMax =  0.7;

%% generate the frames of the interval
for ii = 1:numFrames
    noiseMod = round((noiseMax-noiseMin).*rand(noiseSize,noiseSize) + noiseMin,3);
    noiseMat = repmat(noiseMod(:),1,3)';
    noiseExcitations =bgExcitations.*noiseMat;
    theStimVec = stimExcitations(:,:,ii)+ noiseExcitations;
    theStimSet = SensorToSettings(calObj,theStimVec);

    theStimPatch(:,:,:,ii) = reshape(theStimSet',[noiseSize,noiseSize,3]);

end

%% Show the movie

%% Show the stuff
PsychDefaultSetup(2);

screens = Screen('Screens');
screenNumber = max(screens);

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, bgSettings);

for jj= 1:numFrames
    stimTex(jj) = Screen('MakeTexture', window, theStimPatch(:,:,:,jj));
end

% make fixation dot
[xCenter, yCenter] = RectCenter(windowRect);
fixRectSize = [0 0 5 5];
fixationRect = CenterRectOnPointd(fixRectSize, xCenter, yCenter);


% show it
for kk = 1:numFrames
    Screen('DrawTextures', window, stimTex(kk));
    Screen('FillRect', window, [0,0,0], fixationRect);
    Screen('Flip', window);
end

sca



