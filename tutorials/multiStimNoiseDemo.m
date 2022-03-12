subjId = 'JNK';
%% load the stim
filePath = fullfile(getpref('ColorTracking','dropboxPath'),'CNST_materials','ColorTrackingTask','stimCache','TTR',subjId);
fileName = 'stimCache.mat';
load(fullfile(filePath,fileName),'theStimPatch','expParams');

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



%% Show the stuff
numFrames = size(theStimPatch,4)

PsychDefaultSetup(2);

screens = Screen('Screens');
screenNumber = max(screens);

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, bgSettings);

for ii = 1:size(theStimPatch,5)
    for jj= 1:numFrames
        stimTex(jj) = Screen('MakeTexture', window, theStimPatch(:,:,:,jj,ii));
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
    pause
    
end
sca



