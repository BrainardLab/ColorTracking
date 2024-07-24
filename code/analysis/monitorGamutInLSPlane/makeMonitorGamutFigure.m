% Make a figure showing our monitor gamut in the LS contrast plane

% Initialize
clear; close all;

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

% Cone fundamentals
psiParamsStruct.coneParams = DefaultConeParams('cie_asano');
psiParamsStruct.coneParams.fieldSizeDegrees = 2;
psiParamsStruct.coneParams.ageYears = 30;
T_cones = ComputeObserverFundamentals(psiParamsStruct.coneParams,Scolor);
SetSensorColorSpace(calObj,T_cones,Scolor);

% Compute the background
bgPrimary = [0.5 0.5 0.5]';
bgCones = PrimaryToSensor(calObj,bgPrimary);

% Find maximum in gamut contrast for a set of color directions.  We
% are not going to worry about device quantization since we used
% high-bit depth hardware
nAngles = 1000;
theAngles = linspace(0,2*pi,nAngles);
for aa = 1:nAngles
    unitContrastDir = [cos(theAngles(aa)) 0 sin(theAngles(aa))]';
    unitConesDir = unitContrastDir .* bgCones;
    unitPrimaryDir = SensorToPrimary(calObj,unitConesDir + bgCones) - SensorToPrimary(calObj,bgCones);

    [s,sPos,sNeg] = MaximizeGamutContrast(unitPrimaryDir,bgPrimary);
    gamutPrimaryDir = s*unitPrimaryDir;

    gamutCones = PrimaryToSensor(calObj,gamutPrimaryDir + bgPrimary);
    gamutContrast(:,aa) = (gamutCones-bgCones) ./ bgCones;
    vectorLengthContrast(aa) = norm(gamutContrast(:,aa));
end
%gamutContrast

% Make a plot of the gamut in the LS contrast plane
figure; clf; hold on;
%plot(100*gamutContrast(1,:),100*gamutContrast(3,:),'ko','MarkerSize',8);
plot([-100 100],[0 0],'k:','LineWidth',0.5);
plot([0 0],[-100 100],'k:','LineWidth',0.5);
plot(100*gamutContrast(1,:),100*gamutContrast(3,:),'k','LineWidth',1);
xlim([-100 100])
ylim([-100 100]);
axis('square');
xlabel('L Cone Contrast (%)')
ylabel('S Cone Contrast (%)');