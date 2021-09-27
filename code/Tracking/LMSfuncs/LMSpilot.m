function [] = LMSpilot(expType)

close all; 
clear all;
sca;

subjID = 'JNK';

MaxContrastLMS = LMSstimulusContrast('experiment',expType);
nTrialsReps = 1;
nTrials = nTrialsReps * size(MaxContrastLMS,1);

% BWoct = 0.7025;
% BWort = 0.562;
% BWoct = 5.444;
% BWort = 1.714;
BWoct = 0.932;
BWort = 0.605;

ExpLMStracking(subjID,65,nTrials,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', MaxContrastLMS, [0.5], [0.5], [1], [1], [0], [0], 0, BWoct, BWort, 0, 0, 0, 0);