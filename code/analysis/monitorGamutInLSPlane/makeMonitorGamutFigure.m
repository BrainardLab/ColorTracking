% Make a figure showing our monitor gamut in the LS contrast plane

%% Initialize
clear; close all;

%% Where to write figure
figureDir = getpref('ColorTracking','figureSavePath');

%% Load typical calibration file from the experiment
whichExperiment = 'detection';
switch (whichExperiment)
    case 'tracking'
        whichCalFile = 'ViewSonicG220fb.mat';
        whichCalNumber = 1;
        nDeviceBits = 8;
        whichCones = 'ss2';
        NOAMBIENT = false;
    case 'detection'
        whichCalFile = 'ViewSonicG220fb_670.mat';
        whichCalNumber = 1;
        nDeviceBits = 12;
        whichCones = 'asano';
        NOAMBIENT = true;
end
resourcesDir =  getpref('ColorTracking','CalDataFolder');
load(fullfile(resourcesDir,whichCalFile),'cals');
cal = cals{whichCalNumber};

%% Cone cal object
calObjCones = ObjectToHandleCalOrCalStruct(cal);

% Make the bit depth correct as far as the calibration file goes.
nDeviceLevels = 2^nDeviceBits;
CalibrateFitGamma(calObjCones, nDeviceLevels);
nPrimaries = calObjCones.get('nDevices');

% Can change gammaMethod to 1 for unquantized analysis
gammaMethod = 2;
SetGammaMethod(calObjCones,gammaMethod);

% Set wavelength support.
Scolor = calObjCones.get('S');

% Zero out ambient?
if (NOAMBIENT)
    calObjCones.set('P_ambient',zeros(size(calObjCones.get('P_ambient'))));
end

% Cone fundamentals. Methods say cones were SS 2-deg. That is
% what was loaded in the tracking code.  In the detection code,
% it was ComputeObserverFundamentals with parameters below, which
% are not quite T_cones_ss2.
switch (whichCones)
    case 'asano'
        psiParamsStruct.coneParams = DefaultConeParams('cie_asano');
        psiParamsStruct.coneParams.fieldSizeDegrees = 2;
        psiParamsStruct.coneParams.ageYears = 30;
        T_cones = ComputeObserverFundamentals(psiParamsStruct.coneParams,Scolor);
    case 'ss2'
        load T_cones_ss2
        T_cones = SplineCmf(S_cones_ss2,T_cones_ss2,Scolor);
end
SetSensorColorSpace(calObjCones,T_cones,Scolor);

%% XYZ cal object
calObjXYZ = ObjectToHandleCalOrCalStruct(cal);

% Get gamma correct
CalibrateFitGamma(calObjXYZ, nDeviceLevels);
SetGammaMethod(calObjXYZ,gammaMethod);
if (NOAMBIENT)
    calObjXYZ.set('P_ambient',zeros(size(calObjCones.get('P_ambient'))));
end

%% Image scale factor
% 
% We report a nominal max contrast which is the contrast that would have been
% shown had the 100% contrast Gabor image been in cosine phase.  But ours
% were in sin phase.  The maximum value of the Gabor was 0.9221 as we
% found it by stepping through the tracking code, and 0.9608 as we found
% it by looking at S.stmLE in the detection code saved data. We divide
% our maximum gamut contrasts by this to get the real maximum contrast we
% report. Not sure why there is a difference.
imageScaleFactor = 0.9221; % 0.9221; 0.9608;

% XYZ
USE1931XYZ = true;
if (USE1931XYZ)
    load T_xyz1931.mat
    T_xyz = 683*SplineCmf(S_xyz1931,T_xyz1931,Scolor);
else
    load T_xyzCIEPhys2.mat
    T_xyz = 683*SplineCmf(S_xyzCIEPhys2,T_xyzCIEPhys2,Scolor);
end
SetSensorColorSpace(calObjXYZ,T_xyz,Scolor);

%% Compute ambient
ambientCones = SettingsToSensor(calObjCones,[0 0 0]');
ambientXYZ = SettingsToSensor(calObjXYZ,[0 0 0']');

%% Compute the background, taking quantization into account
%
% The paper says the background was 30.75 cd/m2, x = 0.326, y = 0.372;
SPECIFIEDBG = false;
if (SPECIFIEDBG)
    bgxyYTarget = [0.326, 0.372 30.75]';
    bgXYZTarget = xyYToXYZ(bgxyYTarget);
    bgPrimary = SettingsToPrimary(calObjXYZ,SensorToSettings(calObjXYZ,bgXYZTarget));
    bgXYZ = PrimaryToSensor(calObjXYZ,bgPrimary);
else
    bgPrimary = SettingsToPrimary(calObjCones,PrimaryToSettings(calObjCones,[0.5 0.5 0.5]'));
    bgXYZ = PrimaryToSensor(calObjXYZ,bgPrimary);
end
bgxyY = XYZToxyY(bgXYZ);
bgCones = PrimaryToSensor(calObjCones,bgPrimary);

% Print basic info and report on monitor
fprintf('\nExperiment %s, calibration file %s, calibration number %d, calibration date %s\n', ...
    whichExperiment,whichCalFile,whichCalNumber,calObjXYZ.cal.describe.date);
fprintf('\nNOAMBIENT = %d, cone option %s\n',NOAMBIENT,whichCones);
fprintf('\nBackground x,y = %0.4f, %0.4f\n',bgxyY(1),bgxyY(2));
fprintf('Background Y = %0.2f cd/m2, ambient %0.3f cd/m2\n',bgXYZ(2),ambientXYZ(2));

% Compute monitor primary xyY to try to understand what drifted
primaryXYZ = PrimaryToSensor(calObjXYZ,[[1 0 0]' [0 1 0]' [0 0 1]']);
primaryxyY = XYZToxyY(primaryXYZ);
fprintf('\nRed primary xyY: %0.4f, %0.4f, %0.2f cd/m2\n',primaryxyY(1,1),primaryxyY(2,1),primaryxyY(3,1));
fprintf('Green primary xyY: %0.4f, %0.4f, %0.2f cd/m2\n',primaryxyY(1,2),primaryxyY(2,2),primaryxyY(3,2));
fprintf('Blue primary xyY: %0.4f, %0.4f, %0.2f cd/m2\n',primaryxyY(1,3),primaryxyY(2,3),primaryxyY(3,3));
fprintf('\n');

%% Max contrast
%
% Find maximum in gamut contrast for a set of color directions.  We
% are not going to worry about device quantization since we used
% high-bit depth hardware
nAngles = 1000;
theAngles = linspace(0,2*pi,nAngles);
for aa = 1:nAngles
    % Get a unit contrast vector at the specified angle
    unitContrastDir = [cos(theAngles(aa)) 0 sin(theAngles(aa))]';

    % Convert from cone contrast to cone excitation direction.
    % Don't care about length here as that is handled by the contrast
    % maximization code below.
    unitConesDir = unitContrastDir .* bgCones;

    % Convert the direction to the desired direction in primary space.
    % Since this is desired, we do not go into settings here. Adding
    % and subtracting the background handles the ambient correctly.
    unitPrimaryDir = SensorToPrimary(calObjCones,unitConesDir + bgCones) - SensorToPrimary(calObjCones,bgCones);

    % Find out how far we can go in the desired direction and scale the
    % unitPrimaryDir by that amount
    [s,sPos,sNeg] = MaximizeGamutContrast(unitPrimaryDir,bgPrimary);
    gamutPrimaryDir = s*unitPrimaryDir;
    if (any(gamutPrimaryDir+bgPrimary < -1e-3) | any(gamutPrimaryDir+bgPrimary > 1+1e-3))
        error('Somehow primaries got too far out of gamut\n');
    end
    if (any(-gamutPrimaryDir+bgPrimary < -1e-3) | any(-gamutPrimaryDir+bgPrimary > 1+1e-3))
        error('Somehow primaries got too far out of gamut\n');
    end
    gamutDevPos1 = abs(gamutPrimaryDir+bgPrimary - 1);
    gamutDevNeg1 = abs(gamutPrimaryDir+bgPrimary);
    gamutDevPos2 = abs(-gamutPrimaryDir+bgPrimary - 1);
    gamutDevNeg2 = abs(-gamutPrimaryDir+bgPrimary);
    gamutDev = min([gamutDevPos1 gamutDevNeg1 gamutDevPos2 gamutDevNeg2]);
    if (gamutDev > 1e-3)
        error('Did not get primaries close enough to gamut edge');
    end

    % Get the settings that as closely as possible approximate what we
    % want.  One of these should be very close to 1 or 0, and none should
    % be less than 0 or more than 1.
    gamutSettings = PrimaryToSettings(calObjCones,gamutPrimaryDir + bgPrimary);
    if (any(gamutSettings < 0) | any(gamutSettings > 1))
        error('Somehow settings got out of gamut\n');
    end

    % Figure out the cone excitations for the settings we computed, and
    % then convert to contrast as our maximum contrast in this direction.
    %
    % Dividing by imageScaleFactor handles the sine phase of the Gabor
    gamutCones = SettingsToSensor(calObjCones,gamutSettings);
    gamutContrast(:,aa) = ((gamutCones-bgCones) ./ bgCones)/imageScaleFactor;
    vectorLengthContrast(aa) = norm(gamutContrast(:,aa));
end

%gamutContrast

% Make a plot of the gamut in the LS contrast plane
figure; clf; hold on;
%plot(100*gamutContrast(1,:),100*gamutContrast(3,:),'ko','MarkerSize',8);
plot([-100 100],[0 0],'k:','LineWidth',0.5);
plot([0 0],[-100 100],'k:','LineWidth',0.5);
plot(100*gamutContrast(1,:),100*gamutContrast(3,:),'k','LineWidth',2);
xlim([-100 100])
ylim([-100 100]);
axis('square');
xlabel('L Cone Contrast (%)')
ylabel('S Cone Contrast (%)');
saveas(gcf,fullfile(figureDir,'MonitorGamutFigure.pdf'),'pdf')

% This does the same computation for specific stimulus angles
theSpecificAngles = [0   90.0000   75.0000  -75.0000   45.0000  -45.0000   78.7500   82.5000   86.2000  -78.7500  -82.5000  -86.2000   89.6000   88.6000   87.6000   22.5000   -1.4000  -22.5000];
for aa = 1:length(theSpecificAngles)
  
    % Convert from cone contrast to cone excitation direction.
    % Don't care about length here as that is handled by the contrast
    % maximization code below.
    unitContrastDir = [cosd(theSpecificAngles(aa)) 0 sind(theSpecificAngles(aa))]';

    % Convert from cone contrast to cone excitation direction.
    % Don't care about length here as that is handled by the contrast
    % maximization code below.
    unitConesDir = unitContrastDir .* bgCones;

    % Convert the direction to the desired direction in primary space.
    % Since this is desired, we do not go into settings here. Adding
    % and subtracting the background handles the ambient correctly.
    unitPrimaryDir = SensorToPrimary(calObjCones,unitConesDir + bgCones) - SensorToPrimary(calObjCones,bgCones);

    % Find out how far we can go in the desired direction and scale the
    % unitPrimaryDir by that amount
    [s,sPos(aa),sNeg(aa)] = MaximizeGamutContrast(unitPrimaryDir,bgPrimary);
    if (sPos(aa) < sNeg(aa))
        gamutLimitSign(aa) = 1;
    else
        gamutLimitSign(aa) = -1;
    end
    gamutPrimaryDir = s*unitPrimaryDir;
    if (any(gamutPrimaryDir+bgPrimary < -1e-3) | any(gamutPrimaryDir+bgPrimary > 1+1e-3))
        error('Somehow primaries got too far out of gamut\n');
    end
    if (any(-gamutPrimaryDir+bgPrimary < -1e-3) | any(-gamutPrimaryDir+bgPrimary > 1+1e-3))
        error('Somehow primaries got too far out of gamut\n');
    end
    gamutDevPos1 = abs(gamutPrimaryDir+bgPrimary - 1);
    gamutDevNeg1 = abs(gamutPrimaryDir+bgPrimary);
    gamutDevPos2 = abs(-gamutPrimaryDir+bgPrimary - 1);
    gamutDevNeg2 = abs(-gamutPrimaryDir+bgPrimary);
    gamutDev = min([gamutDevPos1 gamutDevNeg1 gamutDevPos2 gamutDevNeg2]);
    if (gamutDev > 1e-3)
        error('Did not get primaries close enough to gamut edge');
    end

    % Get the settings that as closely as possible approximate what we
    % want.  One of these should be very close to 1 or 0, and none should
    % be less than 0 or more than 1.
    gamutSettings = PrimaryToSettings(calObjCones,gamutPrimaryDir + bgPrimary);
    if (any(gamutSettings < 0) | any(gamutSettings > 1))
        error('Somehow settings got out of gamut\n');
    end

    % Figure out the cone excitations for the settings we computed, and
    % then convert to contrast as our maximum contrast in this direction.
    %
    % Dividing by imageScaleFactor handles the sine phase of the Gabor
    gamutCones = SettingsToSensor(calObjCones,gamutSettings);
    specificGamutContrast(:,aa) = ((gamutCones-bgCones) ./ bgCones)/imageScaleFactor;
    specificVectorLengthContrast(aa) = norm(specificGamutContrast(:,aa));
    fprintf('Angle %0.1f, L cone contrast %0.3f%%, M, %0.3f%%, S %0.3f%%, vector length %0.1f%%\n', ...
        theSpecificAngles(aa),100*specificGamutContrast(1,aa),100*specificGamutContrast(2,aa),100*specificGamutContrast(3,aa), ...
        100*specificVectorLengthContrast(aa));
end
specificVectorLengthContrast

% CF MAB data from Tracking
%
% uniqueColorDirs(:)'
% 
% ans =
% 
%          0   90.0000   75.0000  -75.0000   45.0000  -45.0000   78.7500   82.5000   86.2000  -78.7500  -82.5000  -86.2000   89.6000   88.6000   87.6000   22.5000   -1.4000  -22.5000
% 
% matrixContrasts(1,:)
% 
% ans =
% 
%     0.1800    0.8500    0.6500    0.7800    0.2500    0.2600    0.8300    0.8500    0.8500    0.8400    0.8400    0.8400    0.8500    0.8500    0.8500    0.1900    0.1800    0.1900
% 
% cals{1} - August 31 cal, used for tracking experiment
% specificVectorLengthContrast =
% 
%     0.1863    0.8513    0.6556    0.7990    0.2569    0.2710    0.8438    0.8734    0.8605    0.8462    0.8442    0.8458    0.8521    0.8542    0.8567    0.1999    0.1865    0.2039