% TRACKING STIM TO MAC_BOYN

%% Load cal file
resourcesDir =  getpref('ColorTracking','CalDataFolder');
load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
calCell = 3;
cal = cals{calCell};
calObj = ObjectToHandleCalOrCalStruct(cal);
S = calObj.get('S');

%% Load the Luminance Function
load T_CIE_Y2
T_xyz = SplineCmf(S_CIE_Y2,T_CIE_Y2,S);

%% Load the Cone Fundamentals
psiParamsStruct.coneParams = DefaultConeParams('cie_asano');
psiParamsStruct.coneParams.fieldSizeDegrees = 2;
psiParamsStruct.coneParams.ageYears = 30;
T_cones = ComputeObserverFundamentals(psiParamsStruct.coneParams,S);

%% Set the sensor space to CC
SetSensorColorSpace(calObj,T_cones,S);

%% Calcluate the background excitations
bgPrimaries = [0.5, 0.5, 0.5]';
bgExcitations = PrimaryToSensor(calObj,bgPrimaries);

%% Get the stim used in exp 1
contrastLMSPos = LMSstimulusContrast('experiment','Experiment1-Pos');
contrastLMSNeg = LMSstimulusContrast('experiment','Experiment1-Neg');
% maxExp1Pos = contrastLMSPos(3:6:end,:)';
% maxExp1Neg = contrastLMSNeg(3:6:end,:)';
maxExp1Pos = contrastLMSPos';
maxExp1Neg = contrastLMSNeg';
stimContrasts = [maxExp1Pos,maxExp1Neg];

%% Get the excitations of the monitor gamut 
thePrimaries = [[1;0;0],[0;1;0],[0;0;1]];
mpExcitations = PrimaryToSensor(calObj,thePrimaries);

%% Get excitations from contrast
stimExcitations = ContrastToExcitations(stimContrasts,bgExcitations);

%% Convert to Mac Boyn
stimMacBoyn = LMSToMacBoyn(stimExcitations,T_cones,T_xyz);

%% Convert the Background
bgMacBoyn = LMSToMacBoyn(bgExcitations,T_cones,T_xyz);

%% Convert the gamut
mpMacBoyn = LMSToMacBoyn(mpExcitations,T_cones,T_xyz);
mpMacBoynClosed = [mpMacBoyn,mpMacBoyn(:,1)];

%% Plot it
figure; hold on;
scatter(stimMacBoyn(1,:)',stimMacBoyn(2,:)',16,'r');
plot(bgMacBoyn(1),bgMacBoyn(2),'bs','MarkerFaceColor','b','MarkerSize',6);
plot(mpMacBoynClosed(1,:)',mpMacBoynClosed(2,:)','k--','LineWidth',1.5);
%xlim([0.55 .9]); ylim([0,.2]);
xlim([0.575 .875]); ylim([0,.3]);
axis square
xlabel('l chromaticity'); ylabel('s chromaticity');
title('Tracking Stim In Mac-Boyn');
legend('Stimuli','Background','Monitor Gamut')