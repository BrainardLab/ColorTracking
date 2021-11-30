% t_BitsPlusControl
%
% Illustrate/explore how to set up image and lookup table for color
% modulations, using a Bits++/Bits# interface.
%

% History:
%    11/18/2021  Started on it

%% Clear
clear; close all;

%% Verbose?
%
% Set to true to get more output
VERBOSE = false;

%% Load cal file
[rootDir,~] = fileparts(which(mfilename));
resourcesDir = sprintf('%s/resources',rootDir);
setpref('BrainardLabToolbox','CalDataFolder',resourcesDir);
cal = LoadCalFile('ViewSonicG220fb');
calObj = ObjectToHandleCalOrCalStruct(cal);

%% Make this a 12-bit device as far as the calibration file goes
nDeviceBits = 12;
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
targetBgxy = [0.3127 0.3290]';

% Target color direction and max contrasts.
%
% This is the basic desired modulation direction positive excursion. We go
% equally in positive and negative directions.  Make this unit vector
% length, as that is good convention for contrast. That is, we  express
% contrast in any color direction relative to the unit-length contrast
% vector for that direction.
targetContrastDir = [1 -1 0]'; targetContrastDir = targetContrastDir/norm(targetContrastDir);
targetContrast = 0.01;
plotAxisLimit = 100*targetContrast;

%% Cone fundamentals and XYZ CMFs.
psiParamsStruct.coneParams = DefaultConeParams('cie_asano');
psiParamsStruct.coneParams.fieldSizeDegrees = 2;
psiParamsStruct.coneParams.ageYears = 30;
T_cones = ComputeObserverFundamentals(psiParamsStruct.coneParams,S);
load T_xyzJuddVos % Judd-Vos XYZ Color matching function
T_xyz = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,S);

%% Image spatial parameters.
sineFreqCyclesPerImage = 6;
gaborSdImageFraction = 0.1;

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

%% Build a lookup table.
%
% For lookup table hardware, we have to build the lookup table.  We can
% either allocate the lookup table bits across the maximum contrast
% available in the specified direction, which means we only need to build
% one table per direction, or do it in an image specific way (which makes
% better use of the bits. Set lookupTableMethod string below to switch back
% and forth. For low contrast modulations, this shows that we are better
% off building a separate lookup table for each desired contrast. This
% calculation is quite fast, and we should be able to write the lookup
% table fast as well, so not a problem.  We'll need to check the frame
% buffer write speed to verify, though.
%
% The particular way used below of buiding the contrasts to be represented
% by the lookup table ensures that the lookup table it always contains zero
% contrast, which in turn means that we can produce the desired background
% predisely. The background plays a special role in the computation of
% contrast, so we don't want it subject to quantizaiton errors.
%
% The variable lookupTableSettingsIntegers contains the nDeviceBits (i.e.
% 12 bit for Bits++/Bits# case) integer values that get written into the
% Bits++/Bits# lookup table to produce the image. By convention these are
% nFrameBufferLevels by nPrimaries matrices, obtained as the transpose of
% cal format. This convention has to do with the way DHB likes to draw the
% lookup table.
fprintf('Building lookup table ...');
lookupTableMethod = 'targetContrast';
nFrameBufferBits = 8;
nFrameBufferLevels = 2^nFrameBufferBits;
lookupTableDesiredMonochromeContrastsCal = [linspace(-1,-2/nFrameBufferLevels,nFrameBufferLevels/2-1) 0 linspace(2/nFrameBufferLevels,1,nFrameBufferLevels/2)];
switch (lookupTableMethod)
    case 'targetContrast'
        lookupTableDesiredContrastCal = targetContrast*targetContrastDir*lookupTableDesiredMonochromeContrastsCal;
    case 'maximumContrast'
        lookupTableDesiredContrastCal = maximumContrast*targetContrastDir*lookupTableDesiredMonochromeContrastsCal;
end
lookupTableDesiredExcitationsCal = ContrastToExcitation(lookupTableDesiredContrastCal,bgExcitations);
lookupTableSettings = SensorToSettings(calObj,lookupTableDesiredExcitationsCal)';
lookupTableSettingsIntegers = round(lookupTableSettings*(nDeviceLevels-1));
lookupTableExcitationsCal = SettingsToSensor(calObj,lookupTableSettings');
lookupTableContrastCal = ExcitationsToContrast(lookupTableExcitationsCal,bgExcitations);
fprintf('done\n')

%% Construct the image that looks up into the lookup table.
%
% We know the cone contrasts we want at each pixel, and we know the
% contrasts we can produce with the lookup table since we computed those just
% above. So what we need to do at
% each pixel is find the contrasts in the lookup table closest to those we
% want and store the index into that entry of the lookup table.  The
% cleanest way to do this is to exhaustively search the contrasts
% represented by the lookup table for the closest available to each desired
% contrast. This is a little slow if we do it pixel by pixel, but we can
% speed it up as described and illustrated below.
%
% Set up Matlab point cloud with all the cone contrasts the lookup table
% can produce.  A point cloud is wonderful bit of code that builds a data
% structure that enables very fast exhaustive search of the vector values in the
% point cloud, for example to find the nearest neighbor to a passed
% vector.
fprintf('Setting up point cloud ...');
ptCld = pointCloud(lookupTableContrastCal');
fprintf('done\n')

% We can search the point cloud faster if we first quantize the desired
% image to some high number of levels. This doesn't limit the quality of
% our result because in the end we're limited by the display quantization,
% not this quantization. Here we add bits to the number of device bits.
% Adding two seems to work well and be fast, but for reasons I don't fully
% understand you can drop down quite a bit lower without obvious loss of
% quality in the cases I've looked at. Using -8 (quantize to 4 bits) does
% make things bad for the default modulation (1% L-M grating), but using -6
% has hardly any effect at all.
fprintf('Building frame buffer image ...');
addedSearchBits = 2;
nSearchBits = nDeviceBits+addedSearchBits;
nSearchLevels = 2^nSearchBits;
searchMonochromeContrastGaborCal = 2*(PrimariesToIntegerPrimaries((desiredMonochromeContrastGaborCal+1)/2,nSearchLevels)/(nSearchLevels-1))-1;
searchContrastGaborCal = targetContrast*targetContrastDir*searchMonochromeContrastGaborCal;

% Search the lookup table. We use a routine in the BrainardLabToolbox that does this for
% us. The returned values we take here are the indices into
% the passed lookup table that come as close as possible to producing the desired
% image contrasts. Thus these form the RGB image we write into the frame buffer, that
% is then used to lookup through the lookup table.  The RGB image just
% duplicates this monochrome image in each primary channel, so that R=G=B.
% One could do fancier things without the restriction R=G=B for the frame
% buffer image, but thinking through how to optimze for that case would be
% a bit of work, and the R=G=B method works great for modulations that lie
% along a line in color space.
[~,lookupTableSettingsIntegersGaborCal] = SettingsFromPointCloud(ptCld,searchContrastGaborCal,lookupTableSettings','verbose',false);
frameBufferSettingsIntegersGaborCal = lookupTableSettingsIntegersGaborCal([1 1 1]',:);
fprintf('done\n')

%% Check that the lookup table and image generation code worked as desired.
% 
% We Reconstruct what will be shown on dispaly explicitly from frame buffer
% image and the lookup table, and then compute the contrasts that we get
% for it.
%
% First use each of the R, G, B channels of the frame buffer image to look
% up the corresponding nDeviceBits setting from the lookup table. We do it
% separately so that this code would still work even if we didn't enforce
% R=G=B, as we do above. It's hardly any harder to write the general case
% here (lookup R from R, G from G, B from B) and if we ever relax the R=G=B
% assumption this part of the code will still work.
lookedUpSettingsIntegersGaborCal = zeros(size(frameBufferSettingsIntegersGaborCal));
for pp = 1:nPrimaries
    lookedUpSettingsIntegersGaborCal(pp,:) = ...
        lookupTableSettingsIntegers(frameBufferSettingsIntegersGaborCal(pp,:)',pp)';
end

% Convert the integer settings to settings on [0,1]
lookedUpSettingsGaborCal = lookedUpSettingsIntegersGaborCal/(nDeviceLevels-1);

% Compute excitations and contrasts from settings using standard methods,
% and convert t image format.
lookedUpExcitationsGaborCal = SettingsToSensor(calObj,lookedUpSettingsGaborCal);
lookedUpContrastGaborCal = ExcitationsToContrast(lookedUpExcitationsGaborCal,bgExcitations);
lookedUpContrastGaborImage = CalFormatToImage(lookedUpContrastGaborCal,imageN,imageN);

% Plot what we get along with the original continuous desired cone
% contrasts.
figure; hold on
plot(1:imageN,100*lookedUpContrastGaborImage(centerN,:,1),'r+','MarkerFaceColor','r','MarkerSize',4);
plot(1:imageN,100*desiredContrastGaborImage(centerN,:,1),'r','LineWidth',0.5);
plot(1:imageN,100*lookedUpContrastGaborImage(centerN,:,2),'g+','MarkerFaceColor','g','MarkerSize',4);
plot(1:imageN,100*desiredContrastGaborImage(centerN,:,2),'g','LineWidth',0.5);
plot(1:imageN,100*lookedUpContrastGaborImage(centerN,:,3),'b+','MarkerFaceColor','b','MarkerSize',4);
plot(1:imageN,100*desiredContrastGaborImage(centerN,:,3),'b','LineWidth',0.5);
if (gammaMethod == 2)
    title('Image Slice, Lookup Table Method, Quantized Gamma, LMS Cone Contrast');
else
    title('Image Slice, Lookup Table Method Method, No Quantization, LMS Cone Contrast');
end
xlabel('x position (pixels)')
ylabel('LMS Cone Contrast (%)');
ylim([-plotAxisLimit plotAxisLimit]);

