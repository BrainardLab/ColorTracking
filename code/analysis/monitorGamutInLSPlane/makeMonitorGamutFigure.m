% Make a figure showing our monitor gamut in the LS contrast plane

%% Initialize
clear; %close all;

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
        whichCalNumber = 4;
        nDeviceBits = 12;
        whichCones = 'asano';
        NOAMBIENT = true;
    case 'detectionRaw'
        whichCalFile = 'ViewSonicG220fb_670.mat';
        whichCalNumber = 4;
        nDeviceBits = 12;
        whichCones = 'ss2';
        NOAMBIENT = false;
end
resourcesDir =  getpref('ColorTracking','CalDataFolder');
load(fullfile(resourcesDir,whichCalFile),'cals');
cal = cals{whichCalNumber};

%% Cone cal object
calObjCones = ObjectToHandleCalOrCalStruct(cal);
calObjCones1 = ObjectToHandleCalOrCalStruct(cal);

% Make the bit depth correct as far as the calibration file goes.
nDeviceLevels = 2^nDeviceBits;
CalibrateFitGamma(calObjCones, nDeviceLevels);
nPrimaries = calObjCones.get('nDevices');

% Set gamma mode. A value of 2 was used in the experiment
%   gammaMode == 0 - search table using linear interpolation via interp1.
%   gammaMode == 1 - inverse table lookup.  Fast but less accurate.
%   gammaMode == 2 - exhaustive search
gammaMode = 2;
SetGammaMethod(calObjCones,gammaMode);
SetGammaMethod(calObjCones1,gammaMode);

% Set wavelength support.
Scolor = calObjCones.get('S');

% Zero out ambient?  We don't zero out the 1 version of the cal object.
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

        % We always define T_cones1 to be the ss2.
        load T_cones_ss2
        T_cones1 = SplineCmf(S_cones_ss2,T_cones_ss2,Scolor);
    case 'ss2'
        load T_cones_ss2
        T_cones = SplineCmf(S_cones_ss2,T_cones_ss2,Scolor);
        T_cones1 = T_cones;
end
SetSensorColorSpace(calObjCones,T_cones,Scolor);
SetSensorColorSpace(calObjCones1,T_cones,Scolor);

%% XYZ cal object
calObjXYZ = ObjectToHandleCalOrCalStruct(cal);
calObjXYZ1 = ObjectToHandleCalOrCalStruct(cal);

% Get gamma correct
CalibrateFitGamma(calObjXYZ, nDeviceLevels);
SetGammaMethod(calObjXYZ,gammaMode);
SetGammaMethod(calObjXYZ1,gammaMode);
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
% report. The difference is that the 0.9221 is the contrast number, while
% the stimulus value represents excitations.  We care about contrast for
% this purpose.
imageScaleFactor = 0.9221; % 0.9221; 0.9608;

%% XYZ
USE1931XYZ = true;
if (USE1931XYZ)
    load T_xyz1931.mat
    T_xyz = 683*SplineCmf(S_xyz1931,T_xyz1931,Scolor);
else
    load T_xyzCIEPhys2.mat
    T_xyz = 683*SplineCmf(S_xyzCIEPhys2,T_xyzCIEPhys2,Scolor);
end
SetSensorColorSpace(calObjXYZ,T_xyz,Scolor);
SetSensorColorSpace(calObjXYZ1,T_xyz,Scolor);

%% Compute ambient
ambientCones = SettingsToSensor(calObjCones,[0 0 0]');
ambientCones1 = SettingsToSensor(calObjCones1,[0 0 0]');
ambientXYZ = SettingsToSensor(calObjXYZ,[0 0 0']');
ambientXYZ1 = SettingsToSensor(calObjXYZ1,[0 0 0']');

%% Compute the background, taking quantization into account
%
% The paper says the background was 30.75 cd/m2, x = 0.326, y = 0.372;
% But, it was alayws set via backround linear rgb = [0.5 0.5 0.5].  THe
% xyY values correspond to specified value.
%
% The calculations here account for display quantization.
SPECIFIEDBG = false;
if (SPECIFIEDBG)
    bgxyYTarget = [0.326, 0.372 30.75]';
    bgXYZTarget = xyYToXYZ(bgxyYTarget);
    bgPrimary = SettingsToPrimary(calObjXYZ,SensorToSettings(calObjXYZ,bgXYZTarget));
    bgPrimary1 = SettingsToPrimary(calObjXYZ1,SensorToSettings(calObjXYZ1,bgXYZTarget));
else
    bgPrimary = SettingsToPrimary(calObjCones,PrimaryToSettings(calObjCones,[0.5 0.5 0.5]'));
    bgPrimary1 = SettingsToPrimary(calObjCones1,PrimaryToSettings(calObjCones1,[0.5 0.5 0.5]'));
end
bgXYZ = PrimaryToSensor(calObjXYZ,bgPrimary);
bgXYZ1 = PrimaryToSensor(calObjXYZ1,bgPrimary1);
bgxyY = XYZToxyY(bgXYZ);
bgxyY1 = XYZToxyY(bgXYZ1);
bgCones = PrimaryToSensor(calObjCones,bgPrimary);
bgCones1 = PrimaryToSensor(calObjCones1,bgPrimary1);

% Print basic info and report on monitor
fprintf('\nExperiment %s, calibration file %s, calibration number %d, calibration date %s\n', ...
    whichExperiment,whichCalFile,whichCalNumber,calObjXYZ.cal.describe.date);
fprintf('\nNOAMBIENT = %d, cone option %s\n',NOAMBIENT,whichCones);
fprintf('\nBackground x,y = %0.4f, %0.4f\n',bgxyY(1),bgxyY(2));
fprintf('Background Y = %0.2f cd/m2, ambient %0.3f cd/m2\n',bgXYZ(2),ambientXYZ(2));
fprintf('\nBackground with ambient x,y = %0.4f, %0.4f\n',bgxyY1(1),bgxyY1(2));
fprintf('Background with ambient Y = %0.2f cd/m2, ambient %0.3f cd/m2\n',bgXYZ1(2),ambientXYZ1(2));

% Compute monitor primary xyY to try to understand what drifted
primaryXYZ = PrimaryToSensor(calObjXYZ,[[1 0 0]' [0 1 0]' [0 0 1]']);
primaryxyY = XYZToxyY(primaryXYZ);
primaryXYZ1 = PrimaryToSensor(calObjXYZ1,[[1 0 0]' [0 1 0]' [0 0 1]']);
primaryxyY1 = XYZToxyY(primaryXYZ1);
fprintf('\nRed primary xyY: %0.4f, %0.4f, %0.2f cd/m2\n',primaryxyY(1,1),primaryxyY(2,1),primaryxyY(3,1));
fprintf('Green primary xyY: %0.4f, %0.4f, %0.2f cd/m2\n',primaryxyY(1,2),primaryxyY(2,2),primaryxyY(3,2));
fprintf('Blue primary xyY: %0.4f, %0.4f, %0.2f cd/m2\n',primaryxyY(1,3),primaryxyY(2,3),primaryxyY(3,3));
fprintf('With ambient: Red primary xyY: %0.4f, %0.4f, %0.2f cd/m2\n',primaryxyY1(1,1),primaryxyY1(2,1),primaryxyY1(3,1));
fprintf('With ambient: Green primary xyY: %0.4f, %0.4f, %0.2f cd/m2\n',primaryxyY1(1,2),primaryxyY1(2,2),primaryxyY1(3,2));
fprintf('With ambient: Blue primary xyY: %0.4f, %0.4f, %0.2f cd/m2\n',primaryxyY1(1,3),primaryxyY1(2,3),primaryxyY1(3,3));

% Express background spd in terms of primaries.  Not entirely clear this
% means anything important.
bgSpd = cal.processedData.P_ambient;
bgWeights = cal.processedData.P_device\bgSpd;
fprintf('\nAmbient linear rgb weights: %0.3f %0.3f %0.3f\n',bgWeights(1),bgWeights(2),bgWeights(3));
fprintf('\n');

%% Max contrast
%
% Find maximum in gamut contrast for a set of color directions.
% This calculation does not worry about quantization.  It is
% done for the main case.  Because we care about this primarily
% for the tracking experiment, since the experimental specification
% matched what we intended for tha experiment.
nAngles = 1000;
theAngles = linspace(0,2*pi,nAngles);
for aa = 1:nAngles
    % Get a unit contrast vector at the specified angle
    targetContrastDir = [cos(theAngles(aa)) 0 sin(theAngles(aa))]';

    % Convert from cone contrast to cone excitation direction.
    % Don't care about length here as that is handled by the contrast
    % maximization code below.
    theConesDir = targetContrastDir .* bgCones;

    % Convert the direction to the desired direction in primary space.
    % Since this is desired, we do not go into settings here. Adding
    % and subtracting the background handles the ambient correctly.
    thePrimaryDir = SensorToPrimary(calObjCones,theConesDir + bgCones) - SensorToPrimary(calObjCones,bgCones);

    % Find out how far we can go in the desired direction and scale the
    % unitPrimaryDir by that amount
    [s,sPos,sNeg] = MaximizeGamutContrast(thePrimaryDir,bgPrimary);
    gamutPrimaryDir = s*thePrimaryDir;
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
    [gamutSettings,badIndex] = PrimaryToSettings(calObjCones,gamutPrimaryDir + bgPrimary);
    if (any(badIndex))
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
    targetContrastDir = [cosd(theSpecificAngles(aa)) 0 sind(theSpecificAngles(aa))]';

    % Convert from cone contrast to cone excitation direction.
    % Don't care about length here as that is handled by the contrast
    % maximization code below.
    theConesDir = targetContrastDir .* bgCones;

    % Convert the direction to the desired direction in primary space.
    % Since this is desired, we do not go into settings here. Adding
    % and subtracting the background handles the ambient correctly.
    thePrimaryDir = SensorToPrimary(calObjCones,theConesDir + bgCones) - SensorToPrimary(calObjCones,bgCones);

    % Find out how far we can go in the desired direction and scale the
    % unitPrimaryDir by that amount
    [s,sPos(aa),sNeg(aa)] = MaximizeGamutContrast(thePrimaryDir,bgPrimary);
    if (sPos(aa) < sNeg(aa))
        gamutLimitSign(aa) = 1;
    else
        gamutLimitSign(aa) = -1;
    end
    gamutPrimaryDir = s*thePrimaryDir;
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
    [gamutSettings,badIndex] = PrimaryToSettings(calObjCones,gamutPrimaryDir + bgPrimary);
    if (any(badIndex))
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

% Look at these variables to get a table of max gamut contrasts in these
% angular directions
specificVectorLengthContrast;
theSpecificAngles;
clear theSpecficAngles

%% Convert cone contrasts with respect to first calibration to second.
%
% Angles from paper Figure 5 labels, contrasts read off of those graphs
% roughly by eye.  If we go to 16 bit depth, the match would have been very
% good, had the detection calibration been used the way it should have
% been.
theDetectionSpecificAngles = [-86.25 -82.5 -78.75 -75   -45    0      45    75    78.75 82.5 86.25 90];
theVectorLengthContrasts =   [ 0.05   0.03  0.02   0.017 0.005 0.003  0.004 0.015 0.02  0.03 0.04  0.05];
for aa = 1:length(theDetectionSpecificAngles)
    fprintf('Angle %0.1f, vector length contrast %0.1f\n',theDetectionSpecificAngles(aa),100*theVectorLengthContrasts(aa));

    % Convert from cone contrast to cone excitation direction.
    % Don't care about length here as that is handled by the contrast
    % maximization code below.
    targetContrastDir = [cosd(theDetectionSpecificAngles(aa)) 0 sind(theDetectionSpecificAngles(aa))]';
    targetConeContrast(:,aa) = (theVectorLengthContrasts(aa)*targetContrastDir);

    % Convert from cone contrast to cone excitation direction.
    % Don't care about length here as that is handled by the contrast
    % maximization code below.
    targetCones =  (targetConeContrast(:,aa).* bgCones) + bgCones;

    % Compute settings we would have used using first calibration
    [theSettings,badIndex] = SensorToSettings(calObjCones,targetCones);
    if (any(badIndex))
        fprintf('   Out of gamut\n');
    end

    % Go back to contrast with both calibrations
    obtainedCones(:,aa) = SettingsToSensor(calObjCones,theSettings);
    obtainedCones1(:,aa) = SettingsToSensor(calObjCones1,theSettings);
    obtainedConeContrast(:,aa) = ((obtainedCones(:,aa)-bgCones) ./ bgCones);
    obtainedConeContrast1(:,aa) = ((obtainedCones1(:,aa)-bgCones1) ./ bgCones1);
    obtainedAngle(aa) = atand(obtainedConeContrast(3,aa)/obtainedConeContrast(1,aa));
    obtainedAngle1(aa) = atand(obtainedConeContrast1(3,aa)/obtainedConeContrast1(1,aa));
    obtainedVectorLength(aa) = norm(obtainedConeContrast(:,aa));
    obtainedVectorLength1(aa) = norm(obtainedConeContrast1(:,aa));
    angleDeviation(aa) = obtainedAngle(aa)-theDetectionSpecificAngles(aa);
    angleDeviation1(aa) = obtainedAngle1(aa)-theDetectionSpecificAngles(aa);
    vectorLengthDeviation(aa) = obtainedVectorLength(aa) - theVectorLengthContrasts(aa);
    vectorLengthDeviation1(aa) = obtainedVectorLength1(aa) - theVectorLengthContrasts(aa);

    % Figure out the cone excitations for the settings we computed, and
    % then convert to contrast as our maximum contrast in this direction.
    %
    % Dividing by imageScaleFactor handles the sine phase of the Gabor
    fprintf('   Target contrasts:                   L cone contrast %7.3f%%, M, %7.3f%%, S %7.3f%%, angle %7.1f, vector length %0.1f%%\n', ...
        100*targetConeContrast(1,aa),100*targetConeContrast(2,aa),100*targetConeContrast(3,aa), ...
        theDetectionSpecificAngles(aa),100*theVectorLengthContrasts(aa));
    fprintf('   Had ambient/cones used been right:  L cone contrast %7.3f%%, M, %7.3f%%, S %7.3f%%, angle %7.1f, vector length %0.1f%%\n', ...
        100*obtainedConeContrast(1,aa),100*obtainedConeContrast(2,aa),100*obtainedConeContrast(3,aa), ...
        obtainedAngle(aa),100*obtainedVectorLength(aa));
    fprintf('   What we actually got:               L cone contrast %7.3f%%, M, %7.3f%%, S %7.3f%%, angle %7.1f, vector length %0.1f%%\n', ...
        100*obtainedConeContrast1(1,aa),100*obtainedConeContrast1(2,aa),100*obtainedConeContrast1(3,aa), ...
        obtainedAngle1(aa),100*obtainedVectorLength1(aa));
end
fprintf('\n    Had ambient/cones used been right: Max abs angle deviation %0.4f, max abs vector length deviation %0.4f\n',max(abs(angleDeviation)),max(abs(vectorLengthDeviation)));
fprintf('\n    What we actually got:              Max abs angle deviation %0.4f, max abs vector length deviation %0.4f\n',max(abs(angleDeviation1)),max(abs(vectorLengthDeviation1)));

%% Gamut chromaticity plot for comparisons
%
% This code plots the chromaticities from the tracking experiment, the
% detection experiment without the ambient zeroed, and some measurements we
% by hand on 8/2/24.  Numbers here were entered by hand.

% 'tracking'
% Background x,y = 0.3258, 0.3722
% Background Y = 30.75 cd/m2, ambient 0.670 cd/m2
% 
% Red primary xyY: 0.6023, 0.3258, 12.84 cd/m2
% Green primary xyY: 0.2959, 0.5942, 44.93 cd/m2
% Blue primary xyY: 0.1600, 0.0805, 4.21 cd/m2
trackingRed_xy = [0.6023, 0.3258]';
trackingGreen_xy = [0.2959, 0.5942]';
trackingBlue_xy = [0.1600 0.0805]';
trackingBg_xy = [0.3258, 0.3722]';
trackingAmbientWeights = [0.014 0.010 0.022];

% 'detectionRaw'
% 
% These are from the first of the detection calibrations, but the fourth
% does not differ much.
%
% Background x,y = 0.2976, 0.3360
% Background Y = 31.55 cd/m2, ambient 0.658 cd/m2
% 
% Red primary xyY: 0.6075, 0.3294, 11.95 cd/m2
% Green primary xyY: 0.2932, 0.5973, 46.22 cd/m2
% Blue primary xyY: 0.1548, 0.0730, 5.58 cd/m2
detectionRawRed_xy = [0.6075, 0.3294]';
detectionRawGreen_xy = [0.2932, 0.5973]';
detectionRawBlue_xy = [0.1548, 0.0730]';
detectionRawBg_xy = [0.2976, 0.3360]';
detectionRawAmbientWeights = [0.014 0.009 0.015]';

% Direct hand-held measurements of red and bg, driving monitor
% with VGA from a Mac M1 laptop. 8/2/24. DHB and FH.
%
% 650 luminances were 12.1 and 12.1 cd/m2 for red, and 34.7 for bg
% 670 luminances were 12.07 and 12.07 and not recorded for third measurement.
% Hand-held makes luminances noisy.
remeasureRed650_xy = mean([[0.621 0.329]', [0.621 0.328]'],2);
remeasureRed670_xy = mean([[0.6196 0.3292]', [0.6215 0.3298]', [0.6236, 0.3289]'],2);
remeasureBg650_xy = [0.308 0.346]';
remeasureBg670_xy = [0.3047 0.3421]';

figure; clf; hold on;
plot(trackingRed_xy(1),trackingRed_xy(2),'ro','MarkerFaceColor','r','MarkerSize',16);
plot(trackingGreen_xy(1),trackingGreen_xy(2),'go','MarkerFaceColor','g','MarkerSize',16);
plot(trackingBlue_xy(1),trackingBlue_xy(2),'bo','MarkerFaceColor','b','MarkerSize',16);
plot(trackingBg_xy(1),trackingBg_xy(2),'ko','MarkerFaceColor','k','MarkerSize',16);

plot(detectionRawRed_xy(1),detectionRawRed_xy(2),'s','Color',[0.9 0.1 0.1],'MarkerFaceColor',[0.9 0.1 0.1],'MarkerSize',12);
plot(detectionRawGreen_xy(1),detectionRawGreen_xy(2),'s','Color',[0.1 0.9 0.1],'MarkerFaceColor',[0.1 0.9 0.1],'MarkerSize',12);
plot(detectionRawBlue_xy(1),detectionRawBlue_xy(2),'s','Color',[0.1 0.1 0.9],'MarkerFaceColor',[0.1 0.1 0.9],'MarkerSize',12);
plot(detectionRawBg_xy(1),detectionRawBg_xy(2),'s','Color',[0.25 0.25 0.25],'MarkerFaceColor',[0.25 0.25 0.25],'MarkerSize',12);

plot(remeasureBg650_xy(1),remeasureBg650_xy(2),'>','Color',[0.5 0.5 0.5],'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',10);
plot(remeasureRed650_xy(1),remeasureRed650_xy(2),'>','Color',[0.8 0.2 0.2],'MarkerFaceColor',[0.8 0.2 0.2],'MarkerSize',10);

plot(remeasureBg670_xy(1),remeasureBg670_xy(2),'^','Color',[0.5 0.5 0.5],'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',10);
plot(remeasureRed670_xy(1),remeasureRed670_xy(2),'^','Color',[0.8 0.2 0.2],'MarkerFaceColor',[0.8 0.2 0.2],'MarkerSize',10);

xlabel('x chromaticity');
ylabel('y chromaticity');
xlim([0 1]); ylim([0 1]);
