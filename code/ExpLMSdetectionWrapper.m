%%

% SET RANDOM SEED
randSeed = 2;
rng(randSeed);

targetContrast = [0.002 0.004 0.006 0.008 0.01 0.012]';
targetContrastAngle = [0 0 0 0 0 0]';
% SPECIFY NUMBER OF REPEATS 
nRepeats = 20;

% SPECIFY COMPARISON INTERVALS
cmpIntrvl1 = repmat([ones([1 nRepeats/2]) zeros([1 nRepeats/2])],[size(targetContrastAngle,1) 1]);
for i = 1:size(targetContrastAngle,1); cmpIntrvl1perm(i,:) = randperm(nRepeats); end
for i = 1:size(targetContrastAngle,1); cmpIntrvl1(i,:) = cmpIntrvl1(i,cmpIntrvl1perm(i,:)); end

% SPECIFY RANDOM INDICES
for i = 1:nRepeats
   indRnd1(:,i) = randperm(size(targetContrastAngle,1))'; 
end

% SPECIFY COMPARISON INTERVALS
cmpIntrvl2 = repmat([ones([1 nRepeats/2]) zeros([1 nRepeats/2])],[size(targetContrastAngle,1) 1]);
for i = 1:size(targetContrastAngle,1); cmpIntrvl2perm(i,:) = randperm(nRepeats); end
for i = 1:size(targetContrastAngle,1); cmpIntrvl2(i,:) = cmpIntrvl2(i,cmpIntrvl2perm(i,:)); end

% SPECIFY RANDOM INDICES
for i = 1:nRepeats
   indRnd2(:,i) = randperm(size(targetContrastAngle,1))'; 
end

