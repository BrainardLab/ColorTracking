%%

% This function is the 'master function' for running the detection
% experiment. It specifies all the conditions to be run, and the random
% order to be used. The code is complicated because it is attempting to
% preserve the practice of running positive and negative angles of cone
% contrast modulations in separate blocks. 

subjName = 'MAB';

% SET RANDOM SEED
% randSeed = 2;
% rng(randSeed);

% targetContrast1 = 1.5.*[0.0016 0.0032 0.0048 0.0064 0.008 0.0096 0.002 0.004 0.006 0.008 0.01 0.012 0.002 0.004 0.006 0.008 0.01 0.012 0.0065 0.013 0.0195 0.026 0.0325 0.039 0.0065 0.013 0.0195 0.026 0.0325 0.039 0.013 0.026 0.039 0.052 0.065 0.078]';
targetContrastAngle1 = [-75 -75 -75 -75 -75 -75 -45 -45 -45 -45 -45 -45 0 0 0 0 0 0 45 45 45 45 45 45 75 75 75 75 75 75 90 90 90 90 90 90]';
% targetContrast2 = -1.5.*[0.0016 0.0032 0.0048 0.0064 0.008 0.0096 0.002 0.004 0.006 0.008 0.01 0.012 0.002 0.004 0.006 0.008 0.01 0.012 0.0065 0.013 0.0195 0.026 0.0325 0.039 0.0065 0.013 0.0195 0.026 0.0325 0.039 0.013 0.026 0.039 0.052 0.065 0.078]';
targetContrastAngle2 = targetContrastAngle1;
% targetContrast = [targetContrast1; targetContrast2];
targetContrastAngle = [targetContrastAngle1; targetContrastAngle2];

if strcmp(subjName,'BMC')
    maxContrasts = [0.04, 0.0125, 0.01, 0.0125, 0.04, 0.09]';
elseif strcmp(subjName,'MAB')
    maxContrasts = [0.06, 0.025, 0.0175, 0.02, 0.07, 0.18];
elseif strcmp(subjName,'KAS')
    maxContrasts= [0.04, 0.015, 0.01, 0.015, 0.04, 0.15]';
else
    maxContrasts = [0.07, 0.02, 0.02, 0.02, 0.07, 0.18]';
end
 targetContrast1 = [linspace(maxContrasts(1)/6,maxContrasts(1),6),...
                    linspace(maxContrasts(2)/6,maxContrasts(2),6),...
                    linspace(maxContrasts(3)/6,maxContrasts(3),6),...
                    linspace(maxContrasts(4)/6,maxContrasts(4),6),...
                    linspace(maxContrasts(5)/6,maxContrasts(5),6),...
                    linspace(maxContrasts(6)/6,maxContrasts(6),6)]';

targetContrast2 = -targetContrast1;
targetContrast = [targetContrast1; targetContrast2];

% SPECIFY NUMBER OF REPEATS 
nRepeats = 10;

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
indStimCounter = [];

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
    
%     % INDICES FOR RANDOMIZING 
%     indRndPreNeg = randperm(length(indRndTmpNeg));
%     indRndPrePos = randperm(length(indRndTmpPos));
%     % RANDOMIZE INDICES
%     indRndTmpNeg = indRndTmpNeg(indRndPreNeg);     
%     indRndTmpPos = indRndTmpPos(indRndPrePos);   
%     % RANDOMIZE CMP INTERVALS
%     cmpIntrvlNeg = cmpIntrvlNeg(indRndPreNeg);
%     cmpIntrvlPos = cmpIntrvlPos(indRndPrePos);
    
    indRndPenultimate = [indRndPenultimate indRndTmpNeg indRndTmpPos];
    cmpIntrvlPenultimate = [cmpIntrvlPenultimate cmpIntrvlNeg cmpIntrvlPos];
    indStimCounter(end+1) = length(indStimNeg);
    indStimCounter(end+1) = length(indStimPos);
end

if length(unique(indStimCounter))>1
   error('ExpLMSdetectionWrapper: uneven number of contrasts per direction!'); 
end

nTrialPerRun = 60;
nPartitions = size(indRndPenultimate,1)./nTrialPerRun;
indRnd = [];
cmpIntrvl = [];
for i = 1:nPartitions
    indSelection = ((i-1)*nTrialPerRun+1):((i-1)*nTrialPerRun+nTrialPerRun);
    
    indRndTmp = indRndPenultimate(indSelection,:);
    cmpIntrvlTmp = cmpIntrvlPenultimate(indSelection,:);

    indRndPractice = [];
    for j = 1:size(indRndTmp,2)
        practiceAngle = unique(targetContrastAngle(indRndTmp(:,j)));
        potentialPracticeContrasts = targetContrast(targetContrastAngle==practiceAngle);
        if sum(targetContrast(indRndTmp(:,j)))<0
            maxPracticeContrast=min(potentialPracticeContrasts);
        else
            maxPracticeContrast=max(potentialPracticeContrasts);
        end
        
        indRndPractice(j) = find(targetContrastAngle==practiceAngle & abs(targetContrast-maxPracticeContrast)<0.001);
    end
    indRndPractice = [indRndPractice; indRndPractice; indRndPractice];
    cmpIntrvlPractice = round(rand(size(indRndPractice))); 
    
    indPermBlock = randperm(size(indRndTmp,2));
%    indPermRun = randperm(size(indRndTmp,1));
    indPermRun = [];
    for k1 = 1:size(indRndTmp,2)
        indPermRunTmp = [];
        for k2 = 1:size(indRndTmp,1)/indStimCounter(1)
            indPermRunTmp = [indPermRunTmp; (k2-1)*indStimCounter(1)+randperm(indStimCounter(1))'];
        end
        indPermRun(:,k1) = indPermRunTmp;
    end
    for k1 = 1:size(indRndTmp,2)
       indRndTmp(:,k1) = indRndTmp(indPermRun(:,k1),k1);
       cmpIntrvlTmp(:,k1) = cmpIntrvlTmp(indPermRun(:,k1),k1);
    end
    
    indRnd = [indRnd [indRndPractice(:,indPermBlock); indRndTmp(:,indPermBlock)]];    
    cmpIntrvl = [cmpIntrvl [cmpIntrvlPractice(:,indPermBlock); cmpIntrvlTmp(:,indPermBlock)]];
end

%% SANITY CHECKS

testA = [];
for i = 1:length(targetContrastAngleUnq)
    targetContrastSanityCheck = targetContrast(indRnd);
    targetContrastAngleSanityCheck = targetContrastAngle(indRnd);
    indPosSanityCheck = targetContrastAngle(indRnd)==targetContrastAngleUnq(i) & targetContrast(indRnd)>0;
    indNegSanityCheck = targetContrastAngle(indRnd)==targetContrastAngleUnq(i) & targetContrast(indRnd)<0;
    targetContrastUnqSanityCheck = unique(targetContrastSanityCheck(indPosSanityCheck));
    for j = 1:length(targetContrastUnqSanityCheck)
        indFinalSanityCheck = targetContrastAngleSanityCheck==targetContrastAngleUnq(i) & abs(targetContrastSanityCheck-targetContrastUnqSanityCheck(j))<0.0001;
        testA(i,j,1) = sum(cmpIntrvl(indFinalSanityCheck));
        testA(i,j,2) = unique(targetContrastAngleSanityCheck(indFinalSanityCheck));
        testA(i,j,3) = unique(targetContrastSanityCheck(indFinalSanityCheck));
        testA(i,j,4) = length(cmpIntrvl(indFinalSanityCheck));
    end
end
