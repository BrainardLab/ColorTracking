%% runLMSpilot

% SUBJECT NAME
subjID = 'JNK';
% COLOR DIRECTIONS TO RUN
expDirection = 'directionCheck';
% COMPUTE CONTRASTS IN LMS SPACE
MaxContrastLMS = LMSstimulusContrast('experiment',expDirection);
% DETERMINE NUMBER OF TRIALS PER CONDITION, AND THUS TOTAL NUMBER OF TRIALS PER BLOCK
nTrialsReps = 1;
nTrials = nTrialsReps * size(MaxContrastLMS,1);

% OCTAVE AND ORIENTATION BANDWIDTHS
% BWoct = 0.7025;
% BWort = 0.562;
% BWoct = 5.444;
% BWort = 1.714;
BWoct = 0.932;
BWort = 0.605;

% GENERATE STIMULI
[~,S] = LMSstimulusGeneration(nTrials,MaxContrastLMS,1,0,0,BWoct);

% subjID = 'KAS';
% 
% LMSpilot(subjID,'Experiment2-Pos')
% LMSpilot(subjID,'Experiment2-Neg')
% LMSpilot(subjID,'Experiment2-Pos')
% LMSpilot(subjID,'Experiment2-Neg')
% LMSpilot(subjID,'Experiment2-Pos')
% LMSpilot(subjID,'Experiment2-Neg')
% LMSpilot(subjID,'Experiment2-Pos')
% LMSpilot(subjID,'Experiment2-Neg')
% LMSpilot(subjID,'Experiment2-Pos')
% LMSpilot(subjID,'Experiment2-Neg')

ExpLMStrackingExpOnly(S,subjID,65,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', [0.5], [0.5],[pi*(60/180)], 0, 0, 0, 0);