function [stm,adaptSettings,S] = TTstimulusGeneration(targetContrast,targetContrastAngle,frqCpd,phsDeg,ortDeg,BWoct,cmpIntrvl)

% function [stm,S] = LSDstimulusGeneration(targetContrast,targetContrastAngle,frqCpd,phsDeg,ortDeg,BWoct,cmpIntrvl)
%
% example call: 
%               targetContrast = [0.1 0.1]';
%               targetContrastAngle = [45 75]';
%               cmpIntrvl = [ones([floor(length(targetContrast)/2) 1]); zeros([ceil(length(targetContrast)/2) 1])];
%               [stm,~] = LSDstimulusGeneration(targetContrast,targetContrastAngle,1,0,0,0.932,cmpIntrvl);
%
% generates chromatic gabor stimuli for LMS experiment
%
% inputs: 
%             trlPerRun     : trials per run.  must be multiple of number of phase disparities (phsDspArcmin)
%             MaxContrastLMS: cone contrasts 
%                                   [nCnd x 3]
%             frqCpd        : frequencies for std OR left  stimulus
%                                   [ nCnd x nCmp ]
%             phsDeg        : phase of std OR left stimulus in deg
%                                   [    scalar   ] -> same     phase   for all  components
%                                   [ nCnd x nCmp ] -> unique   phase   for each component
%             ortDeg        : orientation in degrees
%                                   [    scalar   ]
%             BWoct         : frequency   bandwidth in octaves
%                                   [    scalar   ] -> same   bandwidth for all  components
%                                   [  1   x nCmp ] -> unique bandwidth for each component
%             cmpIntrvl     : comparison intervals

% DISPLAY PARAMETERS (CMPINFO)
D.cmpInfo = psyComputerInfo;

S = struct;

trlPerRun = length(targetContrastAngle);
% HARD-CODED STRUCT FIELDS
S.trlPerRun    = trlPerRun;
S.imgSzXYdeg    = repmat(2.*[2 2],[S.trlPerRun, 1]);
S.smpPerDeg     = repmat(128,     [S.trlPerRun, 1]);

% TURN INPUT PARAMETERS INTO STRUCT FIELDS
nCmp = size(frqCpd,2);
frqCpd     = imresize(frqCpd,[S.trlPerRun nCmp],'nearest');
phsDeg     = imresize(phsDeg,[S.trlPerRun nCmp],'nearest');
S.targetContrast = imresize(targetContrast,[S.trlPerRun nCmp],'nearest');
S.targetContrastAngle = imresize(targetContrastAngle,[S.trlPerRun nCmp],'nearest');
S.ortDeg      = imresize(ortDeg,[S.trlPerRun, nCmp],'nearest');
S.BWoct       = imresize(BWoct,[S.trlPerRun,1],'nearest');

S.frqCpdL = frqCpd;
S.frqCpdR = frqCpd;
S.phsDegL = phsDeg;
S.phsDegR = phsDeg;

S.cmpIntrvl = cmpIntrvl;

% LOAD CALIBRATION FILES
if     strcmp(D.cmpInfo.localHostName,'jburge-marr')
    load('/Volumes/Data/BurgeLabCalibrationData/ViewSonicG220fb.mat');
    cal = cals{1};
elseif strcmp(D.cmpInfo.localHostName,'ben-Precision-7520')
    load('/home/ben/Documents/VisionScience/Data/BurgeLabCalibrationData/ViewSonicG220fb.mat');
    cal = cals{1};
else
    resourcesDir =  getpref('ColorTracking','CalDataFolder');
    load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
    cal = cals{4};
end

calObj = ObjectToHandleCalOrCalStruct(cal);
%% Make this a 12-bit device as far as the calibration file goes
nDeviceBits = 12;
nDeviceLevels = 2^nDeviceBits;
CalibrateFitGamma(calObj, nDeviceLevels);
nPrimaries = calObj.get('nDevices');
% Can change gammaMethod to 1 for unquantized analysis
gammaMethod = 2;
SetGammaMethod(calObj,gammaMethod);
% Set wavelength support.
Scolor = calObj.get('S');

% Zero out ambient?
NOAMBIENT = true;
if (NOAMBIENT)
    calObj.set('P_ambient',zeros(size(calObj.get('P_ambient'))));
end

%% Cone fundamentals
psiParamsStruct.coneParams = DefaultConeParams('cie_asano');
psiParamsStruct.coneParams.fieldSizeDegrees = 2;
psiParamsStruct.coneParams.ageYears = 30;
T_cones = ComputeObserverFundamentals(psiParamsStruct.coneParams,Scolor);

SetSensorColorSpace(calObj,T_cones,Scolor);
bgPrimary = [0.5 0.5 0.5]';
bgSettings = PrimaryToSettings(calObj,bgPrimary);
D.bgd        = bgPrimary';

%% Calculate the settings of the adapting background 
bgExcitations = SettingsToSensor(calObj,bgSettings);
LMSadapt= bgExcitations + (bgExcitations .* [0;0;-0.5]);
adaptSettings = SensorToSettings(calObj,LMSadapt)';

% Gamma Correct
D.correctedBgd = bgSettings';

S.lookupTableSettings = [];
contrastImage = generateStimContrastProfile(S.imgSzXYdeg(1,:),S.smpPerDeg(1),S.frqCpdL(1),S.ortDeg(1),S.phsDegL(1),bandwidthOct2sigma(S.frqCpdL(1),S.BWoct(1)));

% loop over stimus directions 
for ii = 1:length(targetContrastAngle)
    [contrastLMS] = generateStimContrasts(0,targetContrastAngle(ii),targetContrast(ii))
    [stm(:,:,:,ii),~,~] = generateChromaticGabor(calObj,contrastImage,bgExcitations,contrastLMS');
%% ADD l=m=s noise
end

S.stmLE = stm;
S.stmRE = stm;

end