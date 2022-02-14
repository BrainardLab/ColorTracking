savePath = '/Users/michael/labDropbox/CNST_materials/ColorTrackingTask/monitorValiadtions/';


resourcesDir =  getpref('ColorTracking','CalDataFolder');
load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
calCell = 3;
cal = cals{calCell};
calObj = ObjectToHandleCalOrCalStruct(cal);Pp

% Set wavelength support.
S = calObj.get('S');

gammaMethod = 2;
SetGammaMethod(calObj,gammaMethod);

nDeviceBits = 12;
nDeviceLevels = 2^nDeviceBits;
CalibrateFitGamma(calObj, nDeviceLevels);


bgPrimaries = [.5 .5 .5];
bgSettings = PrimaryToSettings(calObj,bgPrimaries);


bitSteps12 = 1/2^12;
nominal12BitsSpacing = (bgSettings(1) - 10*bitSteps12):bitSteps12:(bgSettings(1) + 10*bitSteps12);
settingsBit12 = repmat(nominal12BitsSpacing ,[3,1])
%% Make this a 8-bit device as far as the calibration file goes (FOR NOW)
nDeviceBits = 8;
nDeviceLevels = 2^nDeviceBits;
CalibrateFitGamma(calObj, nDeviceLevels);

settingsBit8 = PrimaryToSettings(calObj,SettingsToPrimary(calObj,settingsBit12));

%% Make this a 10-bit device as far as the calibration file goes (FOR NOW)
nDeviceBits = 10;
nDeviceLevels = 2^nDeviceBits;
CalibrateFitGamma(calObj, nDeviceLevels);

settingsBit10 = PrimaryToSettings(calObj,SettingsToPrimary(calObj,settingsBit12));

%% Make this a 11-bit device as far as the calibration file goes (FOR NOW)
nDeviceBits = 11;
nDeviceLevels = 2^nDeviceBits;
CalibrateFitGamma(calObj, nDeviceLevels);

settingsBit11 = PrimaryToSettings(calObj,SettingsToPrimary(calObj,settingsBit12));

load T_xyzJuddVos % Judd-Vos XYZ Color matching function
T_xyz = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,S);

SetSensorColorSpace(calObj,T_xyz,S);

xyzBits12 = SettingsToSensor(calObj,settingsBit12);
xyzBits11 = SettingsToSensor(calObj,settingsBit11);
xyzBits10 = SettingsToSensor(calObj,settingsBit10);
xyzBits8 = SettingsToSensor(calObj,settingsBit8);


%%


tcHndl = figure;
hold on;
plot(nominal12BitsSpacing,xyzBits12(2,:),'-.','Color',[20,20,20]./255,...
    'LineWidth',2.5)
plot(nominal12BitsSpacing,xyzBits11(2,:),'Color',[190,186,218]./255,...
    'LineWidth',2.5)
plot(nominal12BitsSpacing,xyzBits10(2,:),'Color',[251,128,114]./255,...
    'LineWidth',2.5)
plot(nominal12BitsSpacing,xyzBits8(2,:),'Color',[128,177,211]./255,...
    'LineWidth',2.5)

hTitle = title('Bit Depth Quantization');
hXLabel = xlabel('Nominal 12-Bit Settings');
hYLabel = ylabel('Luminance (cd/m^2)');

ticksY = 30:.1:32;
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'FontSize'    , 16        , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , ticksY, ...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');

set(gcf, 'Color', 'white' );
legend('12 Bit','11 Bit', '10 Bit', '8 Bit','Location','Southeast')
%% Format fonts
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 18);
set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');

figureSizeInches = [8 8];
set(tcHndl, 'PaperUnits', 'inches');
set(tcHndl, 'PaperSize',figureSizeInches);
set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
figNameTc =  fullfile(savePath,'bitDepthQuantizeRef.pdf');
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');
