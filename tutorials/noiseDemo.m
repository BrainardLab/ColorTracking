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

% set the target modulation
targetMod = [0.05;0;0.2];

% get the excitations of the background
bgExcitations = PrimaryToSensor(calObj,bgPrimaries);

% add the modulation around the background
tgtExcitations = bgExcitations + (bgExcitations.*targetMod);

% get the setting of the target
tgtSettings = SensorToSettings(calObj,tgtExcitations);

% make the target patch 
patchSize = 150;
tmpPatch = repmat(tgtSettings,1,patchSize,patchSize); % use repmat to create a 3x10x10 copy
tgtPatch = permute(tmpPatch,[3 2 1]);

% make the noise 
noiseSize = 150;
noiseDirections = [1;1;1];

noiseMin = -0.07;
noiseMax =  0.07;
noiseMod = round((noiseMax-noiseMin).*rand(noiseSize,noiseSize) + noiseMin,3);
noiseMat = repmat(noiseMod(:),1,3)';
noiseExcitations = bgExcitations + (bgExcitations.*noiseMat);
SensorToSettings(calObj,noiseExcitations);
noisePatch = reshape(noiseExcitations',[noiseSize,noiseSize,3]);
test = reshape(noiseMat',[noiseSize,noiseSize,3]);

noiseMat











