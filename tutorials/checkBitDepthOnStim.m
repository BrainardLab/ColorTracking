% script to check if the bit depth quantitization will affect the chromatic
% direction and contrast with the standard CRT and 8 bit graphics card (no
% bits ++ or bits #)

%% Clear
clear; close all;

%% Verbose?
%
% Set to true to get more output
VERBOSE = false;

%% Get the subject specific null direction 
%% Load the data
load('dataCache_subj3.mat')

%% Make the packet
lagVec = lags(:)';
timebase = 1:length(lagVec);

% Initialize the packet
thePacket.response.values   = lagVec;
thePacket.response.timebase = timebase;

% The stimulus
thePacket.stimulus.values   = [cL,cS]';
thePacket.stimulus.timebase = timebase;


thePacket.kernel.values = [];
thePacket.kernel.timebase = [];

thePacket.metaData.stimDirections = atand(cS./cL);
thePacket.metaData.stimContrasts  = vecnorm([cS,cL]')';

%% Make the fit object
theDimension= size(thePacket.stimulus.values, 1);
numMechanism = 1;
defaultParamsInfo = [];
fitErrorScalar    = 1000;

ctmOBJ = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', numMechanism ,'fminconAlgorithm','active-set');

startParams.weightL = 50;
startParams.weightS = 2;
% startParams.weightL_2 = 0;
% startParams.weightS_2  = 0;
startParams.minLag = 0.3;
startParams.amplitude = 0.2;

[fitParams,fVal,objFitResponses] = ctmOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',startParams, 'fitErrorScalar',fitErrorScalar);


%% Print the params
fprintf('\ntfeCTM parameters:\n');
ctmOBJ.paramPrint(fitParams)

%% Get the null direction 
nullDirection = atand(fitParams.weightL ./ fitParams.weightS);
nullDirection = 90;
fprintf('The null direction is: %1.2f\n',nullDirection)

coneCompS = sind(nullDirection);
coneCompL = cosd(nullDirection);

%% Load cal file
[rootDir,~] = fileparts(which(mfilename));
resourcesDir = sprintf('%s/resources',rootDir);
setpref('BrainardLabToolbox','CalDataFolder',resourcesDir);
cal = LoadCalFile('BOLDScreen');
calObj = ObjectToHandleCalOrCalStruct(cal);

%% Make this a 12-bit device as far as the calibration file goes
nDeviceBits = 8;
nDeviceLevels = 2^nDeviceBits;
CalibrateFitGamma(calObj, nDeviceLevels);
nPrimaries = calObj.get('nDevices');

%% Setting gammaMethod to do quantizes at the calibration file bit depth.
%
% Can change gammaMethod to 1 for unquantized analysis
gammaMethod = 2;
SetGammaMethod(calObj,gammaMethod);

% If not happy with fit to gamma curves in calibration file, can refit
% using code below.  There are many options for gammaMethod,
% CalibrateFitGamma.  The 'crtPolyLinear' method is our default for CRTs,
% but other choices may fit the data better for other displays.
% gammaMethod = 'crtPolyLinear';
% calObj.set('gamma.fitType',gammaMethod);
% CalibrateFitGamma(screenCalObj, nDeviceLevels);

% Set wavelength support.
S = calObj.get('S');

%% Set key stimulus parameters
%
% Specify the chromaticity, but we'll chose the luminance based
% on the range available in the device.
targetBgxy = [0.326 0.372]';

% Target color direction and max contrasts.
%
% This is the basic desired modulation direction positive excursion. We go
% equally in positive and negative directions.  Make this unit vector
% length, as that is good convention for contrast. That is, we  express
% contrast in any color direction relative to the unit-length contrast
% vector for that direction.
targetContrastDir = [coneCompL 0 coneCompS]'; targetContrastDir = targetContrastDir/norm(targetContrastDir);
targetContrast = 0.15;
plotAxisLimit = 100*targetContrast;

%% Cone fundamentals and XYZ CMFs.
psiParamsStruct.coneParams = DefaultConeParams('cie_asano');
psiParamsStruct.coneParams.fieldSizeDegrees = 2;
psiParamsStruct.coneParams.ageYears = 30;
T_cones = ComputeObserverFundamentals(psiParamsStruct.coneParams,S);
load T_xyzJuddVos % Judd-Vos XYZ Color matching function
T_xyz = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,S);

%% Image spatial parameters.
sineFreqCyclesPerImage = 4;
gaborSdImageFraction = 0.15;

% Image size in pixels
imageN = 512;

%% Find background primaries to acheive desired xy at intensity scale of display.
%
% Set parametersfor getting desired background primaries.
%
% Set color space to work in XYZ first, then find right scale factor to
% make background near the center of the device.
%
% Also note that we obtain background primaries from the bgSettings, so
% that any quantization is taken into account.
SetSensorColorSpace(calObj,T_xyz,S);
targetBgXYZRaw = xyYToXYZ([targetBgxy ; 1]);
midpointXYZ = PrimaryToSensor(calObj,[0.5 0.5 0.5]');
rawBgScale = targetBgXYZRaw\midpointXYZ;
targetBgXYZ = rawBgScale*targetBgXYZRaw;
bgSettings = SensorToSettings(calObj,targetBgXYZ);
bgPrimary = SettingsToPrimary(calObj,bgSettings);

%% Now work in cones and get background cone excitations
SetSensorColorSpace(calObj,T_cones,S);
bgExcitations = SettingsToSensor(calObj,bgSettings);

%% Figure out maximum contrast we can obtain in the specified color direction.
% 
% This doesn't take monitor ambient into account, but that effect should be
% small and not an issue as long as we stay away from the very edge of the
% gamut.
targetExcitationsDir = ContrastToExcitation(targetContrastDir,bgExcitations);
targetPrimaryDir = SensorToPrimary(calObj,targetExcitationsDir);
maximumContrast = MaximizeGamutContrast(targetPrimaryDir,bgPrimary);
fprintf('Maximum contrast available in target direction is %d%%, requested is %d%%\n', ...
    round(100*maximumContrast),round(100*targetContrast));
if (targetContrast > maximumContrast)
    error('Requested contrast exceeds maximum available within gamut');
end

%% Make monochrome Gabor patch in range -1 to 1.
%
% This is our monochrome contrast modulation image.  Multiply
% by the target contrast vector to get the LMS contrast image.
% This monochrome image is in the range [-1,1].
fprintf('Making monocrome Gabor contrast image ...');
centerN = imageN/2;
gaborSdPixels = gaborSdImageFraction*imageN;
rawMonochromeSineImage = MakeSineImage(0,sineFreqCyclesPerImage,imageN);
gaussianWindow = normpdf(MakeRadiusMat(imageN,imageN,centerN,centerN),0,gaborSdPixels);
gaussianWindow = gaussianWindow/max(gaussianWindow(:));
desiredMonochromeContrastGaborImage = rawMonochromeSineImage.*gaussianWindow;
desiredMonochromeContrastGaborCal = ImageToCalFormat(desiredMonochromeContrastGaborImage);
fprintf('done\n')

% Compute the desired cone excigtation gabor image, without any quantization.
fprintf('Computing desired image ...')
desiredContrastGaborCal = targetContrast*targetContrastDir*desiredMonochromeContrastGaborCal;
desiredExcitationsGaborCal = ContrastToExcitation(desiredContrastGaborCal,bgExcitations);
desiredContrastGaborImage = CalFormatToImage(desiredContrastGaborCal,imageN,imageN);
fprintf('done\n')

%% Convert to cone excitations, primaries, settings, ...
%
% If we had a true color dislay with quantization at the level specified in
% the calbration file, we could use our standard methods to compute the
% settings that would produce our desired image. When that gammaMethod is
% 2, this is done at the bit depth of the calibration file.
%
% Note that because Bits++/Bits# are lookup table based, we don't actually
% have a true color 12 bit display.  But this calculation gives us a basis
% for comparison.  Also note that this is not the fully optimized
% calculation for s true color display, becuase it quantizes each device
% primary independently of the other, and a joint calculation method can do
% better. Implementing a joint calculation method at 12 bits would require
% some thought. We do do joint quantization once we set up the lookup
% table, and that actually causes the lookup table method to work better
% than this method for some cases.
%
% This calculation is slow even as is, so we can turn it off when we're not
% exploring peformance.
DOSTANDARD = true;
if (DOSTANDARD)
    fprintf('Standard method computations, slow but useful for comparison purposes ...')
    standardSettingsGaborCal = SensorToSettings(calObj,desiredExcitationsGaborCal);
    standardExcitationsGaborCal = SettingsToSensor(calObj,standardSettingsGaborCal);
    standardContrastGaborCal = ExcitationsToContrast(standardExcitationsGaborCal,bgExcitations);
    standardContrastGaborImage = CalFormatToImage(standardContrastGaborCal,imageN,imageN);
    fprintf('done\n')

    % Plot desired and standard method on slice through LMS contrast image, for
    % the standard method, which assumes a true color display. By looking at
    % this plot for variuos choices of nDeviceBits (set at top of the script,
    % you can see the effect of the display bit depth in a conceptually direct
    % way.
    %
    % Note that the y-axis in this plot is individual cone contrast, which is
    % not the same as the vector length contrast of the modulation.
    figure; hold on
    plot(1:imageN,100*standardContrastGaborImage(centerN,:,1),'r+','MarkerFaceColor','r','MarkerSize',4);
    plot(1:imageN,100*desiredContrastGaborImage(centerN,:,1),'r','LineWidth',0.5);
    plot(1:imageN,100*standardContrastGaborImage(centerN,:,2),'g+','MarkerFaceColor','g','MarkerSize',4);
    plot(1:imageN,100*desiredContrastGaborImage(centerN,:,2),'g','LineWidth',0.5);
    plot(1:imageN,100*standardContrastGaborImage(centerN,:,3),'b+','MarkerFaceColor','b','MarkerSize',4);
    plot(1:imageN,100*desiredContrastGaborImage(centerN,:,3),'b','LineWidth',0.5);
    if (gammaMethod == 2)
        title('Image Slice, Standard SensorToSettings Method, Quantized Gamma, LMS Cone Contrast');
    else
        title('Image Slice, Standard SensorToSettings Method, No Quantization, LMS Cone Contrast');
    end
    xlabel('x position (pixels)')
    ylabel('LMS Cone Contrast (%)');
    ylim([-plotAxisLimit plotAxisLimit]);
end

%% Print out modualtion summary 
desiredAngles = atand(desiredContrastGaborCal(3,:)./desiredContrastGaborCal(1,:));
standardAngles = atand(standardContrastGaborCal(3,:)./standardContrastGaborCal(1,:));
[desiredMax, desiredMax_indxmax] = max(vecnorm(desiredContrastGaborCal));
[standardMax, standardMax_indxmax] = max(vecnorm(desiredContrastGaborCal));
fprintf('<strong> Modulation Summary: </strong> The Contrast\n')
fprintf('The nominal contrast set by user            : %1.4f\n',targetContrast);
fprintf('The nominal contrast after gaussian window  : %1.4f\n',desiredMax);
fprintf('The actual contrast after the 8-bit quantize: %1.4f\n',standardMax);
fprintf('<strong> Modulation Summary: </strong> The Angle\n')
fprintf('The nominal angle set by user               : %1.2f\n',nullDirection)
fprintf('The nominal angle after gaussian window     : %1.2f\n',desiredAngles(desiredMax_indxmax))
fprintf('The actual angle after the 8-bit quantize   : %1.2f\n',standardAngles(standardMax_indxmax))