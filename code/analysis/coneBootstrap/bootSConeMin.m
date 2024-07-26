%    Asano et al. give the following population SD's for the individual
%    difference parameters (their Table 5, Step 2 numbers:
%       Lens    - 18.7%
%       Macular - 36.5%
%       L Density - 9%
%       M Density - 9%
%       S Density - 7.4%
%       L Shift   - 2 nm
%       M Shift   - 1.5 nm
%       S Shift   - 1.3 nm

clear; close all;

%% Get the stimuli settings for angles in the LS plane
% Load a CRT calibration file
cal = LoadCalFile('ViewSonicG220fb',[],getpref('ColorTracking','CalFolder'));

% Make calibration file compatible with current system
[calStructOBJ, inputArgIsACalStructOBJ] = ObjectToHandleCalOrCalStruct(cal);

% Set number of bits for display
nMonitorBits = 14;
nInputLevels = 2.^nMonitorBits;
CalibrateFitGamma(calStructOBJ, nInputLevels);
SetGammaMethod(calStructOBJ,2);

% load the stim settings ans max contrasts for angles -10:.25:110
load cacheStimSettingAsanoBoot.mat

%% Baseline fundamentals
S = [380 5 81];
coneParams = DefaultConeParams('cie_asano');
coneParams.indDiffParams;

[~,T] = ComputeObserverFundamentals(coneParams,S);

load T_cones_ss2
%% Outer loop over Asano parameters
theAngles = 80:0.05:100;
nAsanoBoots = 10000;

% init vars
minLumAngle     = zeros(1,nAsanoBoots);
minLContrasts   = zeros(1,nAsanoBoots);
minLumContrasts = zeros(1,nAsanoBoots);

for aa = 1:nAsanoBoots

    % Draw 8 parameters with standard deviations as in comment above
    drawLens     = normrnd(0,18.7);
    drawMacular  = normrnd(0,36.5);
    drawLDensity = normrnd(0,9);
    drawMDensity = normrnd(0,9);
    drawSDensity = normrnd(0,7.4);
    drawLShift   = normrnd(0,2);
    drawMShift   = normrnd(0,1.5);
    drawSShift   = normrnd(0,1.3);
%     drawLens     = 0;
%     drawMacular  = 0;
%     drawLDensity = 0;
%     drawMDensity = 0;
%     drawSDensity = 0;
%     drawLShift   = 0;
%     drawMShift   = 0;
%     drawSShift   = 0;
    while drawMacular > 100 || drawMacular < -100
            drawMacular  = normrnd(0,36.5);
    end
    % Construct cone fundamentas with those parameters
    tmpConeParams = coneParams;
    tmpConeParams.indDiffParams.lambdaMaxShift = [drawLShift drawMShift drawSShift];
    tmpConeParams.indDiffParams.dphotopigment  = [drawLDensity drawMDensity drawSDensity];
    tmpConeParams.indDiffParams.dlens = drawLens;
    tmpConeParams.indDiffParams.dmac = drawMacular;
    tmpConeParams.fieldSizeDegrees = 2;
    [~,T1] = ComputeObserverFundamentals(tmpConeParams,S_cones_ss2)

    %% Standard initialization of calibration structure
    SetSensorColorSpace(calStructOBJ,T1,S_cones_ss2);
   

    %% Set the background
    backgroundPrimaries = [0.50 0.5 0.50]'; %SensorToSettings(calStructOBJ,backgroundLMS);
    backgroundLMS_hat = SettingsToSensor(calStructOBJ,PrimaryToSettings(calStructOBJ,backgroundPrimaries));

    comparisonLMS = SettingsToSensor(calStructOBJ,stimSettings);
    
    backgroundLMS = repmat(backgroundLMS_hat,[1,size(comparisonLMS,2)]);

    contrasts = ExcitationsToContrast(comparisonLMS,backgroundLMS);
    w = 2;
    m = [w,0,0;...
         0,1,0;...
         0 ,0,1];

    wContrasts = m*contrasts;
    lumVec = vecnorm(wContrasts(1:2,:));

    minLumAngle(aa)     = theAngles(find(lumVec == min(lumVec)));
    minLContrasts(aa)   = contrasts(2,find(lumVec == min(lumVec)));
    minLumContrasts(aa) = lumVec(find(lumVec == min(lumVec)));
   
end

%% Plot distribution of theta's
figure
h1 = histogram(minLumAngle,77);
ylabel('Count')
xlabel('Angle in LS Plane')
title('Minimun Luminance Angle')
set(gcf,'Color','w');
xlim([87 93])
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'off'      , ...
    'YMinorTick'  , 'off'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'LineWidth'   , 1, ...
    'FontSize'    , 12);
axis square

figure
h2 = histogram(minLContrasts,77);
ylabel('Count')
xlabel('L Cone Contrast')
title('L Cone Contrast at Minimun Luminance Angle')
set(gcf,'Color','w');
xlim([-0.06 0.06])
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'off'      , ...
    'YMinorTick'  , 'off'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'LineWidth'   , 1, ...
    'FontSize'    , 12);
axis square

figure
h1 = histogram(minLumContrasts,77);
ylabel('Count')
xlabel('Luminance Contrast')
title('Luminance Contrast at Minimun Luminance Angle')
set(gcf,'Color','w');
ylim([0 550])
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'off'      , ...
    'YMinorTick'  , 'off'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'LineWidth'   , 1, ...
    'FontSize'    , 12);
axis square
