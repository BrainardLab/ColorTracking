%%

% This function is the 'master function' for running the detection
% experiment. It specifies all the conditions to be run, and the random
% order to be used. The code is complicated because it is attempting to
% preserve the practice of running positive and negative angles of cone
% contrast modulations in separate blocks. 

% SET RANDOM SEED
randSeed = 2;
rng(randSeed);

targetContrast1 = 1.5.*[0.0016 0.0032 0.0048 0.0064 0.008 0.0096 0.002 0.004 0.006 0.008 0.01 0.012 0.002 0.004 0.006 0.008 0.01 0.012 0.0065 0.013 0.0195 0.026 0.0325 0.039 0.0065 0.013 0.0195 0.026 0.0325 0.039 0.013 0.026 0.039 0.052 0.065 0.078]';
targetContrastAngle1 = [0 0 0 0 0 0 45 45 45 45 45 45 -45 -45 -45 -45 -45 -45 75 75 75 75 75 75 -75 -75 -75 -75 -75 -75 90 90 90 90 90 90]';
targetContrast2 = -1.5.*[0.0016 0.0032 0.0048 0.0064 0.008 0.0096 0.002 0.004 0.006 0.008 0.01 0.012 0.002 0.004 0.006 0.008 0.01 0.012 0.0065 0.013 0.0195 0.026 0.0325 0.039 0.0065 0.013 0.0195 0.026 0.0325 0.039 0.013 0.026 0.039 0.052 0.065 0.078]';
targetContrastAngle2 = [0 0 0 0 0 0 45 45 45 45 45 45 -45 -45 -45 -45 -45 -45 75 75 75 75 75 75 -75 -75 -75 -75 -75 -75 90 90 90 90 90 90]';
targetContrast = [targetContrast1; targetContrast2];
targetContrastAngle = [targetContrastAngle1; targetContrastAngle2];

% SPECIFY NUMBER OF REPEATS 
nRepeats = 20;

% %% COMPLETELY INTERMIXED CONDITIONS
% 
% % SPECIFY COMPARISON INTERVALS
% cmpIntrvlAll = repmat([ones([1 nRepeats/2]) zeros([1 nRepeats/2])],[size(targetContrastAngle,1) 1]);
% for i = 1:size(targetContrastAngle,1); cmpIntrvlperm(i,:) = randperm(nRepeats); end
% for i = 1:size(targetContrastAngle,1); cmpIntrvlAll(i,:) = cmpIntrvlAll(i,cmpIntrvlperm(i,:)); end
% 
% % SPECIFY RANDOM INDICES
% for i = 1:nRepeats
%    indRnd1(:,i) = randperm(size(targetContrastAngle,1)/2)'; 
% end
% 
% % SPECIFY RANDOM INDICES
% for i = 1:nRepeats
%    indRnd2(:,i) = randperm(size(targetContrastAngle,1)/2)'+size(targetContrastAngle,1)/2; 
% end
% 
% indRnd = [];
% cmpIntrvl = [];
% for i = 1:size(indRnd1,2)
%     indRnd(:,i*2-1) = indRnd1(:,i);
%     indRnd(:,i*2) = indRnd2(:,i);
%     cmpIntrvl(1:size(indRnd1,1),i*2-1) = cmpIntrvlAll(1:size(indRnd1),i);
%     cmpIntrvl(1:size(indRnd1,1),i*2) = cmpIntrvlAll((size(indRnd1,1)+1):(2*size(indRnd1)),i);
% end

%% FOR BLOCKED CONDITIONS

indRndPenultimate = [];
cmpIntrvlPenultimate = [];
targetContrastAngleUnq = unique(targetContrastAngle);
for i = 1:length(targetContrastAngleUnq)
    indStim = find(abs(targetContrastAngle-targetContrastAngleUnq(i))<0.001);
    indStimNeg = indStim(targetContrast(indStim)<0);
    indStimPos = indStim(targetContrast(indStim)>0);
    cmpIntrvlNeg = generateCmpIntrvlLSD(length(indStimNeg),nRepeats);
    cmpIntrvlPos = generateCmpIntrvlLSD(length(indStimPos),nRepeats);
    
    indRndTmpNeg = repmat(indStimNeg,[nRepeats 1]);
    indRndTmpPos = repmat(indStimPos,[nRepeats 1]);
    cmpIntrvlNeg = cmpIntrvlNeg(:);
    cmpIntrvlPos = cmpIntrvlPos(:);
    
    % INDICES FOR RANDOMIZING 
    indRndPreNeg = randperm(length(indRndTmpNeg));
    indRndPrePos = randperm(length(indRndTmpPos));
    % RANDOMIZE INDICES
    indRndTmpNeg = indRndTmpNeg(indRndPreNeg);     
    indRndTmpPos = indRndTmpPos(indRndPrePos);   
    % RANDOMIZE CMP INTERVALS
    cmpIntrvlNeg = cmpIntrvlNeg(indRndPreNeg);
    cmpIntrvlPos = cmpIntrvlPos(indRndPrePos);
    
    indRndPenultimate = [indRndPenultimate indRndTmpNeg indRndTmpPos];
    cmpIntrvlPenultimate = [cmpIntrvlPenultimate cmpIntrvlNeg cmpIntrvlPos];
end

nTrialPerRun = 10;
nPartitions = size(indRndPenultimate,1)./nTrialPerRun;
indRnd = [];
cmpIntrvl = [];
for i = 1:nPartitions
    indSelection = ((i-1)*nTrialPerRun+1):((i-1)*nTrialPerRun+nTrialPerRun);
    
    indRndTmp = indRndPenultimate(indSelection,:);
    cmpIntrvlTmp = cmpIntrvlPenultimate(indSelection,:);
    
    indPermBlock = randperm(size(indRndTmp,2));
    
    indRnd = [indRnd; indRndTmp(:,indPermBlock)];    
    cmpIntrvl = [cmpIntrvl; cmpIntrvlTmp(:,indPermBlock)];
end

%% SANITY CHECKS

sanityCheckInd = 1;
sanityCheckContrasts = targetContrast(indRndPenultimate(:,sanityCheckInd));
sanityCheckContrastsUnq = unique(sanityCheckContrasts);
for i = 1:length(sanityCheckContrastsUnq)
    indTestForCmpBalance = abs(sanityCheckContrasts-sanityCheckContrastsUnq(i))<0.001;
%    sum(indTestForCmpBalance)
    cmpBalanced = cmpIntrvlPenultimate(indTestForCmpBalance,sanityCheckInd);
    sum(cmpBalanced)
end
