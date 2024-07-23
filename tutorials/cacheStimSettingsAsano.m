clear; close all;

%% Get the stimuli settings for angles in the LS plane
% Load a CRT calibration file
cal = LoadCalFile('ViewSonicG220fb',[],getpref('ColorTracking','CalFolder'));
nMonitorBits = 14;
% Make calibration file compatible with current system
[calStructOBJ, inputArgIsACalStructOBJ] = ObjectToHandleCalOrCalStruct(cal);

% Load Stockman and Sharpe 2 deg Cone Fund.
load T_cones_ss2

%%
theAngles = 80:0.05:100;
stimSettings = zeros(3,length(theAngles));
theContrasts = zeros(1,length(theAngles));
for ii = 1:length(theAngles)
    [stimSettings(:,ii),theContrasts(ii)] = calcStimSettings4AsanoBoot(calStructOBJ,S_cones_ss2, T_cones_ss2,theAngles(ii),nMonitorBits);
end