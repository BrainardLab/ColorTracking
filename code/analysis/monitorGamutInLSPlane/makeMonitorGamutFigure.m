% Make a figure showing our monitor gamut in the LS contrast plane

% Load typical calibration file from the experiment
resourcesDir =  getpref('ColorTracking','CalDataFolder');
load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
cal = cals{4};
calObj = ObjectToHandleCalOrCalStruct(cal);

%% Make this a 12-bit device as far as the calibration file goes
nDeviceBits = 12;
nDeviceLevels = 2^nDeviceBits;
CalibrateFitGamma(calObj, nDeviceLevels);
nPrimaries = calObj.get('nDevices');

% Can change gammaMethod to 1 for unquantized analysis
gammaMethod = 1;
SetGammaMethod(calObj,gammaMethod);

% Set wavelength support.
Scolor = calObj.get('S');

% Zero out ambient?
NOAMBIENT = false;
if (NOAMBIENT)
    calObj.set('P_ambient',zeros(size(calObj.get('P_ambient'))));
end

%% Cone fundamentals and XYZ CMFs.
psiParamsStruct.coneParams = DefaultConeParams('cie_asano');
psiParamsStruct.coneParams.fieldSizeDegrees = 2;
psiParamsStruct.coneParams.ageYears = 30;
T_cones = ComputeObserverFundamentals(psiParamsStruct.coneParams,Scolor);

SetSensorColorSpace(calObj,T_cones,Scolor);
bgPrimary = [0.5 0.5 0.5]';
bgSettings = PrimaryToSettings(calObj,bgPrimary);
D.bgd        = bgPrimary';

% Gamma Correct
D.correctedBgd = bgSettings';

S.lookupTableSettings = [];
for i = 1:length(targetContrastAngle)
    [lookupTableSettings,badIndex] = makeLookUpTableForCC(calObj,targetContrast(i),targetContrastAngle(i),D.correctedBgd');
    if any(badIndex ~= 0)
        warning('WARNING: %2.2f is out of gamut\n',targetContrast(i));
    end
    S.lookupTableSettings(:,:,i) = lookupTableSettings';
end

% MAKE INITIAL GAMMA TABLE
lookupTableDesiredMonochromeContrastsCal = [linspace(-1,-2/256,256/2-1) 0 linspace(2/256,1,256/2)];
lookupTableDesiredContrastCal = 1*[1;1;1]*lookupTableDesiredMonochromeContrastsCal;
bgExcitations = SettingsToSensor(calObj,bgSettings);
lookupTableDesiredExcitationsCal = ContrastToExcitation(lookupTableDesiredContrastCal,bgExcitations);
[lookupTableSettingsInit, ~] = SensorToSettings(calObj,lookupTableDesiredExcitationsCal);
S.lookupTableSettingsInit = lookupTableSettingsInit';

% *** REPLACE THIS WHEN THE PROPER STIMULUS IS READY ***
t = 1;
stm = generateStimContrastProfile(S.imgSzXYdeg(t,:),S.smpPerDeg(t),S.frqCpdL(t),S.ortDeg(t),S.phsDegL(t),bandwidthOct2sigma(S.frqCpdL(t),S.BWoct(t)));
stm = stm./2 + 0.5;
stm = round(stm.*255);
% *******

S.stmLE = stm;
S.stmRE = stm;

