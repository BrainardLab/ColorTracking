function [theStimPatch] = makeAndCacheStimuli(subjId,varargin)

% Input Parser
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('subjId',@ischar);
p.addParameter('fileName','stimCache.mat',@ischar)
p.parse(subjId, varargin{:});

%% Get the Cal object and cone_ss and set gamma method
resourcesDir =  getpref('ColorTracking','CalDataFolder');
load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
calCell = 4;
cal = cals{calCell};
calObj = ObjectToHandleCalOrCalStruct(cal);
gammaMethod = 0;
SetGammaMethod(calObj,gammaMethod);
% Load the cone fundamentals
load T_cones_ss2.mat
load T_CIE_Y2.mat
% Set the sensor space to cone coordinates
SetSensorColorSpace(calObj,T_cones_ss2,S_cones_ss2);

%% Get the Experiemnt paramters
expParams = loadExpParams(subjId);

%% Make the contrast image || make it have the same properties as the
% detection task
contrastImage = generateStimContrastProfile(expParams.imgSzXYdeg,expParams.smpPerDeg ,expParams.frqCpd,...
    expParams.ortDeg, expParams.phsDeg ,expParams.StDev);

%% Make chromatic and temproal components of the stimuli
%
% get the number of frames for an interval
screenHz = expParams.screenHz;
stimDuration = expParams.intervalDur;
numFrames = round(stimDuration./screenHz);

% get the ramp on and ramp off weighting vector
rampOnDur  = expParams.rampOnDur;
rampOffDur = expParams.rampOffDur;
rampVec = ones(1,numFrames);
rampOn  = cos(linspace(pi/2,0,round(rampOnDur./screenHz)));
rampOff = cos(linspace(0,pi/2,round(rampOffDur./screenHz)));
rampVec(1:length(rampOn)) = rampOn;
rampVec(end-(length(rampOff)-1):end) = rampOff;

% Get the LMS contrast
theContrasts  = expParams.targetContrastsPos(:)';
theDirections = expParams.targetDirections(:)';

% get the excitations of the background
bgExcitations = PrimaryToSensor(calObj,expParams.bgPrimaries);

theStimPatch = zeros(expParams.imgSzXYpxl(1),expParams.imgSzXYpxl(2),3,numFrames,length(theDirections));

for ii = 1:length(theDirections)

    [contrastLMS] = generateStimContrasts(0,theDirections(ii),theContrasts(ii));

    theStimPatch(:,:,:,:,ii) = generateChromaticGabor(calObj,contrastImage,bgExcitations,contrastLMS','rampOnOff',rampVec,'addNoise',expParams.noise);
end


%% save the stim

filePath = fullfile(getpref('ColorTracking','dropboxPath'),'CNST_materials','ColorTrackingTask','stimCache','TTR',subjId);
fileName = p.Results.fileName;
save(fullfile(filePath,fileName),'theStimPatch','expParams','-v7.3');
end