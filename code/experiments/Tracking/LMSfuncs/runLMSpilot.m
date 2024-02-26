%% runLMSpilot

% SUBJECT NAME
subjID = 'JNK';
% COLOR DIRECTIONS TO RUN
expDirection1 = 'Experiment3-BMC-Pos';
% COLOR DIRECTIONS TO RUN
expDirection2 = 'Experiment3-BMC-Neg';
% COMPUTE CONTRASTS IN LMS SPACE
MaxContrastLMS1 = LMSstimulusContrast('experiment',expDirection1);
% COMPUTE CONTRASTS IN LMS SPACE
MaxContrastLMS2 = LMSstimulusContrast('experiment',expDirection2);
if ~isequal(size(MaxContrastLMS1,1),size(MaxContrastLMS2,1))
   error('runLMSpilot.m: Hmm, there are different numbers of trials in each block.'); 
end
% DETERMINE NUMBER OF TRIALS PER CONDITION, AND THUS TOTAL NUMBER OF TRIALS PER BLOCK
nTrialsReps = 1;
nTrials = nTrialsReps * size(MaxContrastLMS1,1);

% OCTAVE AND ORIENTATION BANDWIDTHS
% BWoct = 0.7025;
% BWort = 0.562;
% BWoct = 5.444;
% BWort = 1.714;
BWoct = 0.932;
BWort = 0.605;

% GENERATE STIMULI
[~,S1] = LMSstimulusGeneration(nTrials,MaxContrastLMS1,1,0,0,BWoct);
[~,S2] = LMSstimulusGeneration(nTrials,MaxContrastLMS2,1,0,0,BWoct);

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

ExpLMStrackingExpOnly(S1,subjID,65,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', [0.5], [0.5],[pi*(60/180)], 0, 0, 0, 0);
ExpLMStrackingExpOnly(S2,subjID,65,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', [0.5], [0.5],[pi*(60/180)], 0, 0, 0, 0);
ExpLMStrackingExpOnly(S1,subjID,65,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', [0.5], [0.5],[pi*(60/180)], 0, 0, 0, 0);
ExpLMStrackingExpOnly(S2,subjID,65,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', [0.5], [0.5],[pi*(60/180)], 0, 0, 0, 0);
ExpLMStrackingExpOnly(S1,subjID,65,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', [0.5], [0.5],[pi*(60/180)], 0, 0, 0, 0);
ExpLMStrackingExpOnly(S2,subjID,65,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', [0.5], [0.5],[pi*(60/180)], 0, 0, 0, 0);
ExpLMStrackingExpOnly(S1,subjID,65,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', [0.5], [0.5],[pi*(60/180)], 0, 0, 0, 0);
ExpLMStrackingExpOnly(S2,subjID,65,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', [0.5], [0.5],[pi*(60/180)], 0, 0, 0, 0);
ExpLMStrackingExpOnly(S1,subjID,65,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', [0.5], [0.5],[pi*(60/180)], 0, 0, 0, 0);
ExpLMStrackingExpOnly(S2,subjID,65,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', [0.5], [0.5],[pi*(60/180)], 0, 0, 0, 0);

