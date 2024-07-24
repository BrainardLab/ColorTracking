% Make a figure showing our monitor gamut in the LS contrast plane

%% Initialize
clear; close all;

%% Where to write figure
figureDir = getpref('ColorTracking','figureSavePath');

%% Load typical calibration file from the experiment
resourcesDir =  getpref('ColorTracking','CalDataFolder');
load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
cal = cals{4};

%% Cone cal object
calObjCones = ObjectToHandleCalOrCalStruct(cal);

% Make this a 12-bit device as far as the calibration file goes
nDeviceBits = 12;
nDeviceLevels = 2^nDeviceBits;
CalibrateFitGamma(calObjCones, nDeviceLevels);
nPrimaries = calObjCones.get('nDevices');

% Can change gammaMethod to 1 for unquantized analysis
gammaMethod = 2;
SetGammaMethod(calObjCones,gammaMethod);

% Set wavelength support.
Scolor = calObjCones.get('S');

% Zero out ambient?
% [HOW WAS THIS SET FOR THE EXPERIMENT???]
NOAMBIENT = true;
if (NOAMBIENT)
    calObjCones.set('P_ambient',zeros(size(calObjCones.get('P_ambient'))));
end

% Cone fundamentals. 
psiParamsStruct.coneParams = DefaultConeParams('cie_asano');
psiParamsStruct.coneParams.fieldSizeDegrees = 2;
psiParamsStruct.coneParams.ageYears = 30;
T_cones = ComputeObserverFundamentals(psiParamsStruct.coneParams,Scolor);
SetSensorColorSpace(calObjCones,T_cones,Scolor);

%% XYZ cal object
calObjXYZ = ObjectToHandleCalOrCalStruct(cal);

% Make this a 12-bit device as far as the calibration file goes
nDeviceBits = 12;
nDeviceLevels = 2^nDeviceBits;
CalibrateFitGamma(calObjXYZ, nDeviceLevels);
SetGammaMethod(calObjXYZ,gammaMethod);
if (NOAMBIENT)
    calObjXYZ.set('P_ambient',zeros(size(calObjCones.get('P_ambient'))));
end

% XYZ
%
load T_xyzCIEPhys2.mat
T_xyz = 683*SplineCmf(S_xyzCIEPhys2,T_xyzCIEPhys2,Scolor);
% load T_xyz1931.mat
% T_xyz = 683*SplineCmf(S_xyz1931,T_xyz1931,Scolor);
SetSensorColorSpace(calObjXYZ,T_xyz,Scolor);

%% Compute ambient
ambientCones = SettingsToSensor(calObjCones,[0 0 0]');
ambientXYZ = SettingsToSensor(calObjXYZ,[0 0 0']');

%% Compute the background, taking quantization into account
bgPrimary = SettingsToPrimary(calObjCones,PrimaryToSettings(calObjCones,[0.5 0.5 0.5]'));
bgCones = PrimaryToSensor(calObjCones,bgPrimary);
bgXYZ = PrimaryToSensor(calObjXYZ,bgPrimary);
bgxyY = XYZToxyY(bgXYZ);
fprintf('\nBackground x,y = %0.3f, %0.3f\n',bgxyY(1),bgxyY(2));
fprintf('Background Y = %0.1f cd/m2, ambient %0.3f cd/m2\n\n',bgXYZ(2),ambientXYZ(2));

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
    gamutDevPos = abs(gamutPrimaryDir+bgPrimary - 1);
    gamutDevNeg = abs(gamutPrimaryDir+bgPrimary);
    gamutDev = min([gamutDevPos gamutDevNeg]);
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
    gamutCones = SettingsToSensor(calObjCones,gamutSettings);
    gamutContrast(:,aa) = (gamutCones-bgCones) ./ bgCones;
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
theSpecificAngles = [-75 -45 -22.5 0 22.5 45 75 90];
for aa = 1:length(theSpecificAngles)
  
    % Convert from cone contrast to cone excitation direction.
    % Don't care about length here as that is handled by the contrast
    % maximization code below.
    unitContrastDir = [cosd(theSpecificAngles(aa)) 0 sind(theSpecificAngles(aa))]';

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
    gamutDevPos = abs(gamutPrimaryDir+bgPrimary - 1);
    gamutDevNeg = abs(gamutPrimaryDir+bgPrimary);
    gamutDev = min([gamutDevPos gamutDevNeg]);
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
    gamutCones = SettingsToSensor(calObjCones,gamutSettings);
    specificGamutContrast(:,aa) = (gamutCones-bgCones) ./ bgCones;
    specificVectorLengthContrast(aa) = norm(specificGamutContrast(:,aa));
    fprintf('Angle %0.1f, L cone contrast %0.3f%%, M, %0.3f%%, S %0.3f%%, vector length %0.1f%%\n', ...
        theSpecificAngles(aa),100*specificGamutContrast(1,aa),100*specificGamutContrast(2,aa),100*specificGamutContrast(3,aa), ...
        100*specificVectorLengthContrast(aa));
end