% Make a figure showing our monitor gamut in the LS contrast plane

%% Initialize
clear; close all;

%% Where to write figure
figureDir = getpref('ColorTracking','figureSavePath');
if (~exist(figureDir,'dir'))
    mkdir(figureDir);
end

%% Load typical calibration file from the experiment
whichExperiment = 'detection';
switch (whichExperiment)
    case 'tracking'
        % Was used with 1024 levels, but hardware is 8-bit.
        whichCalFile = 'ViewSonicG220fb.mat';
        whichCalNumber = 1;
        nDeviceBits = 8;
        whichCones = 'ss2';
        NOAMBIENT = false;
    case 'detection'
        % Was done with 12-bit.
        whichCalFile = 'ViewSonicG220fb_670.mat';
        whichCalNumber = 4;
        nDeviceBits = 20;
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
CalibrateFitGamma(calObjCones1, nDeviceLevels);
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
SetSensorColorSpace(calObjCones1,T_cones1,Scolor);

%% XYZ cal object
calObjXYZ = ObjectToHandleCalOrCalStruct(cal);
calObjXYZ1 = ObjectToHandleCalOrCalStruct(cal);

% Get gamma correct
CalibrateFitGamma(calObjXYZ, nDeviceLevels);
CalibrateFitGamma(calObjXYZ1, nDeviceLevels);
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
plot([-100 100],[0 0],'k:','LineWidth',0.5);
plot([0 0],[-100 100],'k:','LineWidth',0.5);
plot(100*gamutContrast(1,:),100*gamutContrast(3,:),'k','LineWidth',2);
xlim([-100 100])
ylim([-100 100]);
axis('square');
xlabel('L Cone Contrast (%)')
ylabel('S Cone Contrast (%)');
saveas(gcf,fullfile(figureDir,sprintf('MonitorGamutFigure_%s.pdf',whichExperiment)),'pdf');

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

%% Convert cone contrasts with respect to first calibration to second.
%
% Use this code to correct the stimuli for further analysis.  The tracking
% contrasts were fine although subject to quantization.  We just have to
% live with the quantization, in part because we don't know the exact
% location of the quantization steps in the hardwared used to drive the
% monitor in that experiment and in part because we can't really do
% anything about quantization splatter into the M cone plane beyone
% acknowledge it.
%
% These analyses are for the peak of the Gabor in the image; the actual
% contrasts vary across the image but we just summarize them with the max.
%
%  Subject ID options are 'MAB', 'BMC', 'KAS'
subjID = 'MAB';
switch (whichExperiment)
    case 'tracking'
        contrastPlotLim = 1.0;
        contrastDevPlotLim = 0.02;
        angleDevLim = 4;
        expNameCell = { 'Experiment1-Pos' 'Experiment2-Pos' ['Experiment3-' subjID '-Pos']};
        expContrastLMS = [];
        for ii = 1:length(expNameCell)
            expContrastLMS = [expContrastLMS ; LMSstimulusContrast('experiment',expNameCell{ii})];
        end
        for ii = 1:size(expContrastLMS,1)
            targetAnglesFromFunction(ii) = round(atand(expContrastLMS(ii,3)/expContrastLMS(ii,1)),2);
            targetContrastsFromFunction(ii) = norm([expContrastLMS(ii,1) expContrastLMS(ii,3)]);
        end

        % Get unique angles, dealing with 180 degree symmetry.
        targetAngleRaw = unique(targetAnglesFromFunction);

        for aa = 1:length(targetAngleRaw)
            index = find(targetAnglesFromFunction == targetAngleRaw(aa));
            targetContrast(:,aa) = targetContrastsFromFunction(index);
        end
    case {'detection', 'detectionRaw'}
        contrastPlotLim = 1.0;
        contrastDevPlotLim = 0.02;
        angleDevLim = 2;

        % Don't want corrected data here, because we are going to figure
        % out how to correct it.
        CORRECTED = false;
        [targetContrast,targetAngleRaw] = getContrastLSD(subjID,'combined',CORRECTED);
        targetAngleRaw = targetAngleRaw';
end
for cc = 1:size(targetContrast,1)
    targetAngle(cc,:) = targetAngleRaw;
    for aa = 1:length(targetAngleRaw)
        fprintf('Angle %0.1f, vector length contrast %0.1f\n',targetAngle(cc,aa),100*targetContrast(cc,aa));

        % Convert from cone contrast to cone excitation direction.
        targetContrastDir = [cosd(targetAngle(cc,aa)) 0 sind(targetAngle(cc,aa))]';
        targetConeContrast(:,cc,aa) = (targetContrast(cc,aa)*targetContrastDir);

        % Convert from cone contrast to cone excitation direction.  The
        % multiplication by imageScaleFactor handles the fact that the
        % maximum contrast value in the displayed sine phase Gabor is not 1
        % but rather a smaller number.
        targetConeExcitations =  (imageScaleFactor*targetConeContrast(:,cc,aa).* bgCones) + bgCones;

        % Compute settings we would have used using first calibration
        [theSettings,badIndex] = SensorToSettings(calObjCones,targetConeExcitations);
        if (any(badIndex))
            fprintf('   Out of gamut\n');
        end

        % Go back to contrast with both calibrations
        obtainedCones(:,cc,aa) = SettingsToSensor(calObjCones,theSettings);
        obtainedCones1(:,cc,aa) = SettingsToSensor(calObjCones1,theSettings);
        obtainedConeContrast(:,cc,aa) = ((obtainedCones(:,cc,aa)-bgCones) ./ bgCones)/imageScaleFactor;
        obtainedConeContrast1(:,cc,aa) = ((obtainedCones1(:,cc,aa)-bgCones1) ./ bgCones1)/imageScaleFactor;

        % Need to deal with angle sign flipping which can happen for small
        % contrasts. This is OK because we run both plus and minus angle
        % in the experiments (I think) so keeping them all the same sign
        % for analysis purposes is OK and really the only thing we can do.
        obtainedAngle(cc,aa) = round(atand(obtainedConeContrast(3,cc,aa)/obtainedConeContrast(1,cc,aa)),2);
        if (targetAngle(cc,aa) > 0 && obtainedAngle(cc,aa) < 0)
            obtainedAngle(cc,aa) = obtainedAngle(cc,aa) + 180;
        end
        if (targetAngle(cc,aa) < 0 && obtainedAngle(cc,aa) > 0)
            obtainedAngle(cc,aa) = obtainedAngle(cc,aa) - 180;
        end
        obtainedAngle1(cc,aa) = round(atand(obtainedConeContrast1(3,cc,aa)/obtainedConeContrast1(1,cc,aa)),2);
        if (targetAngle(cc,aa) > 0 && obtainedAngle1(cc,aa) < 0)
            obtainedAngle1(cc,aa) = obtainedAngle1(cc,aa) + 180;
        end
        if (targetAngle(cc,aa) < 0 && obtainedAngle1(cc,aa) > 0)
            obtainedAngle1(cc,aa) = obtainedAngle1(cc,aa) - 180;
        end

        % The obtained values in obtainedContrast1 include M cone splatter.
        % Can also restrict this to just LS plane, but for the correction
        % we decided to apply, the M cone splatter is neglible (less than
        % 0.01% for the cases I checked by hand - MAB max contrasts for no
        % quantization) so leaving it this way.
        % Not entirely clear what the in principle right was is.
        obtainedContrast(cc,aa) = norm(obtainedConeContrast(:,cc,aa));
        obtainedContrast1(cc,aa) = norm(obtainedConeContrast1(:,cc,aa));
        obtainedContrast1LSOnly(cc,aa) = norm(obtainedConeContrast1([1 3],cc,aa));
        angleDeviation(cc,aa) = obtainedAngle(cc,aa)-targetAngle(cc,aa);
        angleDeviation1(cc,aa) = obtainedAngle1(cc,aa)-targetAngle(cc,aa);
        contrastDeviation(cc,aa) = obtainedContrast(cc,aa) - targetContrast(cc,aa);
        contrastDeviation1(cc,aa) = obtainedContrast1(cc,aa) - targetContrast(cc,aa);
        
        LConeTargetContrast(cc,aa) = targetConeContrast(1,cc,aa);
        LConeContrast1(cc,aa) = obtainedConeContrast1(1,cc,aa);
        LConeContrastDeviation1(cc,aa) = obtainedConeContrast1(1,cc,aa)-targetConeContrast(1,cc,aa);
        MConeTargetContrast(cc,aa) = targetConeContrast(2,cc,aa);
        MConeContrast1(cc,aa) = obtainedConeContrast1(2,cc,aa);
        MConeContrastDeviation1(cc,aa) = obtainedConeContrast1(2,cc,aa)-targetConeContrast(2,cc,aa);
        SConeTargetContrast(cc,aa) = targetConeContrast(3,cc,aa);
        SConeContrast1(cc,aa) = obtainedConeContrast1(3,cc,aa);
        SConeContrastDeviation1(cc,aa) = obtainedConeContrast1(3,cc,aa)-targetConeContrast(3,cc,aa);

        % Report out
        fprintf('   Target contrasts:                   L cone contrast %7.3f%%, M, %7.3f%%, S %7.3f%%, angle %7.3f, vector length %0.2f%%\n', ...
            100*targetConeContrast(1,cc,aa),100*targetConeContrast(2,cc,aa),100*targetConeContrast(3,cc,aa), ...
            targetAngle(cc,aa),100*targetContrast(cc,aa));
        fprintf('   Had ambient/cones used been right:  L cone contrast %7.3f%%, M, %7.3f%%, S %7.3f%%, angle %7.3f, vector length %0.2f%%\n', ...
            100*obtainedConeContrast(1,cc,aa),100*obtainedConeContrast(2,cc,aa),100*obtainedConeContrast(3,cc,aa), ...
            obtainedAngle(cc,aa),100*obtainedContrast(cc,aa));
        fprintf('   What we actually got:               L cone contrast %7.3f%%, M, %7.3f%%, S %7.3f%%, angle %7.3f, vector length %0.2f%%, vector length LS only %0.2f%%\n', ...
            100*obtainedConeContrast1(1,cc,aa),100*obtainedConeContrast1(2,cc,aa),100*obtainedConeContrast1(3,cc,aa), ...
            obtainedAngle1(cc,aa),100*obtainedContrast1(cc,aa),100*obtainedContrast1LSOnly(cc,aa));
    end
end

% Compute values to use
meanObtainedAngle = mean(obtainedAngle,1);
meanObtainedAngle1 = mean(obtainedAngle1,1);
meanAngleDeviation = meanObtainedAngle-targetAngle;
meanAngleDeviation1 = meanObtainedAngle1-targetAngle;
targetAngleToUse = mean(obtainedAngle1,1);
targetContrastToUse = obtainedContrast1;
maxTargetContrastToUse = max(targetContrastToUse,[],1);

% Diagnostic plots
figure; clf; 
set(gcf,'Position',[10 10 1500 1200]);
subplot(3,4,1); hold on;
plot(targetAngleRaw,targetAngleToUse,'ro','MarkerFaceColor','r','MarkerSize',10);
plot([-100 100],[-100 100],'k');
xlim([-100 100]); ylim([-100 100]);
axis('square');
xlabel('Target Angle (deg)'); ylabel('Obtained Angle (deg)');
title([whichExperiment ' ' subjID ' Bits ' num2str(nDeviceBits)]);
subplot(3,4,2); hold on;
plot(100*targetContrast(:),100*targetContrastToUse(:),'ro','MarkerFaceColor','r','MarkerSize',10);
plot([0 100*contrastPlotLim],[0 100*contrastPlotLim],'k');
xlim([0 100*contrastPlotLim]); ylim([0 100*contrastPlotLim]);
axis('square');
xlabel('Target Contrast (%)'); ylabel('Obtained Contrast (%)');
subplot(3,4,5); hold on;
plot(targetAngleRaw,targetAngleToUse-targetAngleRaw,'ro','MarkerFaceColor','r','MarkerSize',10);
plot([-100 100],[0 0],'k');
xlim([-100 100]); ylim([-angleDevLim angleDevLim]);
axis('square');
xlabel('Target Angle (deg)'); ylabel('Obtained Angle Deviation (deg)');
subplot(3,4,6); hold on;
plot(100*targetContrast(:),100*targetContrastToUse(:)-100*targetContrast(:),'ro','MarkerFaceColor','r','MarkerSize',10);
plot([0 100*contrastPlotLim],[0 0],'k');
xlim([0 100*contrastPlotLim]); ylim([100*-contrastDevPlotLim 100*contrastDevPlotLim]);
axis('square');
xlabel('Target Contrast (%)'); ylabel('Obtained Contrast Deviation (%)');

subplot(3,4,3); hold on;
plot(100*LConeTargetContrast(:),100*LConeContrast1(:),'ro','MarkerFaceColor','r','MarkerSize',10);
plot([-5 20],[-5 20],'k');
xlim([-5 20]); ylim([-5 20]);
axis('square');
xlabel('L Cone Target Contrast (%)'); ylabel('L Cone Contrast(%)');
subplot(3,4,7); hold on;
plot(100*MConeTargetContrast(:),100*MConeContrast1(:),'ro','MarkerFaceColor','r','MarkerSize',10);
plot([-5 5],[-2 2],'k');
xlim([-5 5]); ylim([-2 2]);
axis('square');
xlabel('M Cone Target Contrast (%)'); ylabel('M Cone Contrast (%)');
subplot(3,4,11); hold on;
plot(100*SConeTargetContrast(:),100*SConeContrast1(:),'ro','MarkerFaceColor','r','MarkerSize',10);
plot([-90 90],[-90 90],'k');
xlim([-90 90]); ylim([-90 90]);
axis('square');
xlabel('SCone Target Contrast (%)'); ylabel('S Cone Contrast(%)');

subplot(3,4,4); hold on;
plot(100*LConeTargetContrast(:),100*LConeContrastDeviation1(:),'ro','MarkerFaceColor','r','MarkerSize',10);
plot([0 20],[0 0],'k');
xlim([0 20]); ylim([-2 2]);
axis('square');
xlabel('L Cone Target Contrast (%)'); ylabel('L Cone Contrast Deviation (%)');
subplot(3,4,8); hold on;
plot(100*MConeTargetContrast(:),100*MConeContrastDeviation1(:),'ro','MarkerFaceColor','r','MarkerSize',10);
plot([-5 5],[0 0],'k');
xlim([-5 5]); ylim([-2 2]);
axis('square');
xlabel('M Cone Target Contrast (%)'); ylabel('M Cone Contrast Deviation (%)');
subplot(3,4,12); hold on;
plot(100*SConeTargetContrast(:),100*SConeContrastDeviation1(:),'ro','MarkerFaceColor','r','MarkerSize',10);
plot([-90 90],[0 0],'k');
xlim([-90 90]); ylim([-2 2]);
axis('square');
xlabel('S Cone Target Contrast (%)'); ylabel('S Cone Contrast Deviation (%)');

% The angular deviations start to lose meaning as the contrast gets very
% small
fprintf('\n    Had ambient/cones used been right: Max abs mean angle deviation %0.4f, max abs vector length deviation %0.4f\n',max(abs(meanAngleDeviation(:))),max(abs(contrastDeviation(:))));
fprintf('\n    What we actually got:              Max abs mean angle deviation %0.4f, max abs vector length deviation %0.4f\n',max(abs(meanAngleDeviation1(:))),max(abs(contrastDeviation1(:))));

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
