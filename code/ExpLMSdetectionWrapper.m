%%

% SET RANDOM SEED
randSeed = 2;
rng(randSeed);

% SPECIFY EXPERIMENT DIRECTIONS
expDirection = 'directionCheck';
MaxContrastLMS = LMSstimulusContrast('experiment',expDirection);
% SPECIFY NUMBER OF REPEATS 
nRepeats = 20;

% SPECIFY COMPARISON INTERVALS
cmpIntrvl = repmat([ones([1 nRepeats/2]) zeros([1 nRepeats/2])],[size(MaxContrastLMS,1) 1]);
for i = 1:size(MaxContrastLMS,1); cmpIntrvlPerm(i,:) = randperm(nRepeats); end
for i = 1:size(MaxContrastLMS,1); cmpIntrvl(i,:) = cmpIntrvl(i,cmpIntrvlPerm(i,:)); end

% SPECIFY RANDOM INDICES
for i = 1:nRepeats
   indRnd(:,i) = randperm(size(MaxContrastLMS,1))'; 
end

% [stm,S] = LSDstimulusGeneration(MaxContrastLMS,1,0,0,0.932,cmpIntrvl);