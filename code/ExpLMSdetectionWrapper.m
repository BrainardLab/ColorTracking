%%

% SET RANDOM SEED
randSeed = 2;
rng(randSeed);

% SPECIFY EXPERIMENT DIRECTIONS
expDirection1 = 'directionCheck';
% SPECIFY EXPERIMENT DIRECTIONS
expDirection2 = 'directionCheck';

% GENERATE STIMULI CONTRASTS
MaxContrastLMS1 = LMSstimulusContrast('experiment',expDirection1);
MaxContrastLMS2 = LMSstimulusContrast('experiment',expDirection2);
% SPECIFY NUMBER OF REPEATS 
nRepeats = 20;

% SPECIFY COMPARISON INTERVALS
cmpIntrvl1 = repmat([ones([1 nRepeats/2]) zeros([1 nRepeats/2])],[size(MaxContrastLMS1,1) 1]);
for i = 1:size(MaxContrastLMS1,1); cmpIntrvl1perm(i,:) = randperm(nRepeats); end
for i = 1:size(MaxContrastLMS1,1); cmpIntrvl1(i,:) = cmpIntrvl1(i,cmpIntrvl1perm(i,:)); end

% SPECIFY RANDOM INDICES
for i = 1:nRepeats
   indRnd1(:,i) = randperm(size(MaxContrastLMS1,1))'; 
end

% SPECIFY COMPARISON INTERVALS
cmpIntrvl2 = repmat([ones([1 nRepeats/2]) zeros([1 nRepeats/2])],[size(MaxContrastLMS2,1) 1]);
for i = 1:size(MaxContrastLMS2,1); cmpIntrvl2perm(i,:) = randperm(nRepeats); end
for i = 1:size(MaxContrastLMS2,1); cmpIntrvl2(i,:) = cmpIntrvl2(i,cmpIntrvl2perm(i,:)); end

% SPECIFY RANDOM INDICES
for i = 1:nRepeats
   indRnd2(:,i) = randperm(size(MaxContrastLMS2,1))'; 
end

% [stm,S] = LSDstimulusGeneration(MaxContrastLMS1,1,0,0,0.932,cmpIntrvl);
