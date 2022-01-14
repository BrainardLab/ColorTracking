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
calCell = 3;
cal = cals{calCell};
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

% PsychDefaultSetup(2);
% screens = Screen('Screens');
% screenNumber = max(screens);

% ------------- BURGE LAB CODE --------------
% PTB-3 CORRECTLY INSTALLED AND FUNCTIONAL
AssertOpenGL;
bSKIPSYNCTEST = 0;
% SETUP PSYCHTOOLBOX
% PREPARE PSYCHIMAGING
PsychImaging('PrepareConfiguration');
% FLOATING POINT NUMBERS
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
% USE NORMALIZED [0 1] RANGE FOR COLOR AND LUMINANCE LEVELS
PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
% SKIP SYNCTESTS OR NOT
Screen('Preference', 'SkipSyncTests', bSKIPSYNCTEST);
% DISPLAY SCREEN WITH MAX ID FOR EXPERIMENT
screenNumber = max(Screen('Screens')); % SCREEN, ONSCREEN WINDOW WITH GRAY BACKGROUND
% ------------ END BURGE LAB CODE ------------

% get the background settings and exitations
bgSettings = PrimaryToSettings(calObj,[0.5,0.5,0.5]');
bgExcitations = SettingsToSensor(calObj,bgSettings);

% ptb set up stuff
% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, bgSettings);
% ------------- BURGE LAB CODE --------------
% OPEN WINDOW

[window,windowRect] = BitsPlusPlus('OpenWindowBits++',screenNumber,[128 128 128]');

% ------------ END BURGE LAB CODE ------------
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

Screen('FillRect', window, bgSettings, centeredRect);
Screen('Flip', window);
bgWaitTimeSecs = 1;
pause(bgWaitTimeSecs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  MEASUREMENT SET 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

contrastLMSPos = LMSstimulusContrast('experiment','Experiment1-Pos');
maxExp1Pos = contrastLMSPos(3:6:end,:)';
contrastLMSNeg = LMSstimulusContrast('experiment','Experiment1-Neg');
maxExp1Neg = contrastLMSNeg(3:6:end,:)';
target_coneContrast = [maxExp1Pos,maxExp1Neg];

%% Make the square
imSettings = [255 255 255];
Screen('FillRect', window, imSettings, centeredRect);
bPlusPlusMode = 2;

for jj = 1:nMeasurements
    for ii = 1:size(target_coneContrast,2)
        % Calc the settings from the modulation
        ccModulation = target_coneContrast(:,ii);
        
        [theta, targetContrast] = cart2pol(ccModulation(1),ccModulation(3));
        targetContrastAngle = rad2deg(theta);
        
        [lookupTableSettings, badSetting] = makeLookUpTableForCC(calObj,targetContrast,targetContrastAngle,bgSettings);
        
        % put up the sqaure
        Screen('LoadNormalizedGammaTable', window, lookupTableSettings',bPlusPlusMode);
        Screen('FillRect', window, imSettings, centeredRect);
        Screen('Flip', window);
        
        % print stuff
        fprintf('\n ** MEASUREMENT DIRECTION %2.2f° **\n',atand(ccModulation(3)./ccModulation(1)))
        if any(badSetting ~= 0)
            fprintf('WARNING: SETTING OUT OF GAMUT\n');
        end
        fprintf('Cone Contrast Nominal (L,M,S): %4.2f, %4.2f,  %4.2f\n', ccModulation(1), ccModulation(2), ccModulation(3));
        
        % measure
        rawMeasurement= pr670obj.measure;
        % compute the xyY if the measured spectrum
        A = SplineCmf(S,T_cones,pr670obj.userS);
        measuredLMSexcitation = A * rawMeasurement';
        measuredCC(:,ii,jj) = ExcitationsToContrast(measuredLMSexcitation,bgExcitations);
        fprintf('CC Measurement%2.0f (L,M,S): %4.2f, %4.2f,  %4.2f\n',jj, measuredCC(1,ii,jj), measuredCC(2,ii,jj), measuredCC(3,ii,jj));
    end
end
measurementInfo.date = date;
measurementInfo.monitor = 'ViewSonicG220fb';
measurementInfo.calFile = 'ViewSonicG220fb_670.mat';
measurementInfo.calCell = calCell;
measurementInfo.radiometer = 'PR670';
measurementInfo.bgWaitTimeSecs = bgWaitTimeSecs;
% Save measurements
savePath = '/home/brainardlab/labDropbox/CNST_materials/ColorTrackingTask/monitorValiadtions/';
saveName = fullfile(savePath,'pr670_CC_measurements.mat');
save(saveName,'measuredCC','measurementInfo')

%% Print our summary
meanMeasuredCC = mean(measuredCC,3);
semMeasured = std(measuredCC,0,3)./sqrt(size(measuredCC,3));
diffContrast = target_coneContrast - meanMeasuredCC;
percentDiff = 100* (target_coneContrast - meanMeasuredCC)./ target_coneContrast;
angles = atand(target_coneContrast(3,:)./target_coneContrast(1,:));
contrasts = vecnorm(target_coneContrast) .* [1 1 1 1 1 1 -1 -1 -1 -1 -1 -1];
fprintf('\n**  MEASUREMENT SUMMARY  **\n');
for ii= 1:size(meanMeasuredCC,2)
    fprintf('\nDirection = %2.2fdeg -- Contrast = %1.4f\n', angles(ii), contrasts(ii));
    fprintf('Cone Contrast Nominal (L,M,S): %4.4f, %4.4f,  %4.4f\n', target_coneContrast(1,ii), target_coneContrast(2,ii), target_coneContrast(3,ii));
    fprintf('Cone Contrast Measure (L,M,S): %4.4f ±%4.4f, %4.4f ±%4.4f,  %4.4f ±%4.4f\n', meanMeasuredCC(1,ii), semMeasured(1,ii),meanMeasuredCC(2,ii), semMeasured(2,ii),meanMeasuredCC(3,ii),semMeasured(3,ii));
    fprintf('Nominal - Measured (L,M,S): %4.4f, %3.4f,  %3.4f\n', diffContrast(1,ii), diffContrast(2,ii), diffContrast(3,ii));
    fprintf('Percent Difference (L,S): %3.2f, %3.2f\n', percentDiff(1,ii), percentDiff(3,ii));
end

%% end of measurements
pr670obj.shutDown();

sca;