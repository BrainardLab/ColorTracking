function expParams = loadExpParams(subjId)

% Set the background primaries
expParams.bgPrimaries = [0.5 0.5 0.5]';

% The contrast gabor image parameters
expParams.frqCpd = 1;
expParams.phsDeg = 0;
expParams.ortDeg = 0;
expParams.BWoct  = 0.932;
expParams.StDev  = bandwidthOct2sigma(expParams.frqCpd,expParams.BWoct);
expParams.imgSzXYdeg = [4 4];
expParams.smpPerDeg  = 128;
expParams.imgSzXYpxl = expParams.imgSzXYdeg .* expParams.smpPerDeg;
% Set the chromatic directions
expParams.stimDirection = [-75,-45,0,45,75,90];

% Set the adaptation field
expParams.adaptatTime     = 120; % seconds
expParams.apadtatDir      = 270; % degrees
expParams.adaptatContrast = 0.8; % contrast

% Set the trial structure
expParams.intervalDur   = 0.4;
expParams.intervalGap   = 0.2;
expParams.screenHz      = 1/60;

% Set ramp on and ramp off time 
expParams.rampOnDur  = 0.5;
expParams.rampOffDur = 0.5;

% Set the achromatic noise contrast
noiseMin = -0.3;
noiseMax =  0.3;
expParams.noise = [noiseMin,noiseMax];

% Set the stimulus contrasts
expParams.nContrastLevels = 6;

% get the subject specific  
if strcmp(subjId,'BMC')
    maxContrasts = [0.04, 0.0125, 0.01, 0.0125, 0.04, 0.09]';
elseif strcmp(subjId,'MAB')
    maxContrasts = [0.06, 0.025, 0.0175, 0.02, 0.07, 0.18];
elseif strcmp(subjId,'KAS')
    maxContrasts= [0.04, 0.015, 0.01, 0.015, 0.04, 0.15]';
else
    maxContrasts = [0.07, 0.02, 0.02, 0.02, 0.07, 0.18]';
end

expParams.targetContrastsPos = zeros(length(maxContrasts),expParams.nContrastLevels);
for ii = 1:length(maxContrasts)
expParams.targetContrastsPos(:,ii) = linspace(maxContrasts(ii)/expParams.nContrastLevels, ...
    maxContrasts(ii),expParams.nContrastLevels)';
end
expParams.targetContrastsNeg = -expParams.targetContrastsPos;

expParams.targetDirections = repmat(expParams.stimDirection,6,1);
