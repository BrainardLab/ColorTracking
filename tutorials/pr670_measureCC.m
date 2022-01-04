% PR670 check that we are getting the correct cone contrasts.
% Use a cal file to set primaries to a corresponding XYZ/xyY and use the klien
% to measure the CRT and see if we recover the XYZ/xyY.

%% Clear
clear; close all;

pr670obj = [];
devicePortString = '/dev/ttyACM0';
verb = 0;
pr670obj = PR670dev('verbosity', verb, 'devicePortString', devicePortString);

%% Verbose?
%
% Set to true to get more output
VERBOSE = false;

%% Load cal file

resourcesDir =  getpref('CorticalColorMapping','CalDataFolder');
load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
cal = cals{1};
calObj = ObjectToHandleCalOrCalStruct(cal);

%% Make this a 8-bit device as far as the calibration file goes (FOR NOW)
nDeviceBits = 8;
nDeviceLevels = 2^nDeviceBits;
CalibrateFitGamma(calObj, nDeviceLevels);
nPrimaries = calObj.get('nDevices');
nMeasurements = 15;

%% Setting gammaMethod to do quantizes at the calibration file bit depth.
%
% Can change gammaMethod to 1 for unquantized analysis
gammaMethod = 2;
SetGammaMethod(calObj,gammaMethod);

% Set wavelength support.
S = calObj.get('S');

% Zero out ambient?
NOAMBIENT = true;
if (NOAMBIENT)
    calObj.set('P_ambient',zeros(size(calObj.get('P_ambient'))));
end

%% Get the Cone fundamentals.
psiParamsStruct.coneParams = DefaultConeParams('cie_asano');
psiParamsStruct.coneParams.fieldSizeDegrees = 2;
psiParamsStruct.coneParams.ageYears = 30;
T_cones = ComputeObserverFundamentals(psiParamsStruct.coneParams,S);

SetSensorColorSpace(calObj,T_cones,S);

PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);

% get the background settings and exitations
bgSettings = PrimaryToSettings(calObj,[0.5,0.5,0.5]');
bgExcitations = SettingsToSensor(calObj,bgSettings);

% ptb set up stuff
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, bgSettings);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
baseRect = [0 0 150 150];
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);

% put up the aiming sqaure
imSettings = [.3,.7,1];
Screen('FillRect', window, imSettings, centeredRect);
Screen('Flip', window);
fprintf('Aim/focus the radiometer and hit enter:\n');
pause;

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, bgSettings);
pause; %% ADD WAIT FOR 3600 here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  MEASUREMENT SET 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

contrastLMSPos = LMSstimulusContrast('experiment','Experiment1-Pos');
maxExp1Pos = contrastLMSPos(1:6:end,:)';
contrastLMSNeg = LMSstimulusContrast('experiment','Experiment1-Neg');
maxExp1Neg = contrastLMSNeg(1:6:end,:)';

target_coneContrast = [maxExp1Pos,maxExp1Neg];
for jj = 1:nMeasurements
    for ii = 1:size(target_coneContrast,2)
        % Calc the settings from the modulation
        ccModulation = target_coneContrast(:,ii);
        modExcitation = bgExcitations + (bgExcitations.*ccModulation);
        [imSettings,badSetting] = SensorToSettings(calObj,modExcitation);
        
        % put up the sqaure
        Screen('FillRect', window, imSettings, centeredRect);
        Screen('Flip', window);
        
        % print stuff
        fprintf('\n ** MEASUREMENT DIRECTION %2.2f° **\n',atand(ccModulation(3)./ccModulation(1)))
        if badSetting ~= 0
            fprintf('WARNING: SETTING OUT OF GAMUT\n');
        end
        fprintf('Cone Contrast Nominal (L,M,S): %4.2f, %4.2f,  %4.2f', ccModulation(1), ccModulation(2), ccModulation(3));
        
        % measure
        rawMeasurement= pr670obj.measure;
        % compute the xyY if the measured spectrum
        A = SplineCmf(S,T_cones,pr670obj.userS);
        measuredLMSexcitation = A * rawMeasurement';
        measuredCC(:,ii,jj) = (measuredLMSexcitation-bgExcitations)./bgExcitations;
        fprintf('CC Measurement %2.0f (L,M,S): %4.2f, %4.2f,  %4.2f',jj, measuredCC(1,ii,jj), measuredCC(2,ii,jj), measuredCC(3,ii,jj));
    end
end

%% end of measurements

pr670obj.shutDown();

sca;