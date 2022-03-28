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
expParams.smpPerDeg  = 24;
expParams.imgSzXYpxl = expParams.imgSzXYdeg .* expParams.smpPerDeg;
% Set the chromatic directions
expParams.stimDirection = [94,93,92,91,90,89,88,87,86];


% Set the adaptation field
expParams.adaptatTime     = 120; % seconds
expParams.apadtatDir      = 270; % degrees
expParams.adaptatContrast = 0.8; % contrast

% Set the trial structure
expParams.intervalDur   = 0.4;
expParams.intervalGap   = 0.2;
expParams.screenHz      = 1/60;

% Set ramp on and ramp off time
expParams.rampOnDur  = 0.1;
expParams.rampOffDur = 0.1;

% Set the achromatic noise contrast
noiseMin = -0.07;
noiseMax =  0.07;
expParams.noise = [noiseMin,noiseMax];

% Set the stimulus contrasts
expParams.nContrastLevels = 6;

% get the subject specific
if strcmp(subjId,'BMC')
    maxContrasts = [0.4, 0.4, 0.4, 0.4, 0.4, 0.4,0.4, 0.4, 0.4]';
elseif strcmp(subjId,'MAB')
    maxContrasts = [0.06, 0.025, 0.0175, 0.02, 0.07, 0.18];
elseif strcmp(subjId,'KAS')
    maxContrasts= [0.04, 0.015, 0.01, 0.015, 0.04, 0.15]';
elseif strcmp(subjId,'JNK')
    maxContrasts= [0.4 0.4 0.4]';
else
    maxContrasts = [0.07, 0.02, 0.02, 0.02, 0.07, 0.18]';
end
if ~(length(maxContrasts)==length(expParams.stimDirection))
    error('# OF MAX CONTRAST AND # OF DIRECTIONS DO NOT MATCH!!!')
end
expParams.targetContrastsPos = zeros(expParams.nContrastLevels,length(maxContrasts));
for ii = 1:length(maxContrasts)
    expParams.targetContrastsPos(:,ii) = linspace(maxContrasts(ii)/expParams.nContrastLevels, ...
        maxContrasts(ii),expParams.nContrastLevels)';
end
expParams.targetContrastsNeg = -expParams.targetContrastsPos;

expParams.targetDirections = repmat(expParams.stimDirection,expParams.nContrastLevels,1);
