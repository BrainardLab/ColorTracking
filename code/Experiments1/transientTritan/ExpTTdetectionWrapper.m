%%

% This function is the 'master function' for running the detection
% experiment. It specifies all the conditions to be run, and the random
% order to be used. The code is complicated because it is attempting to
% preserve the practice of running positive and negative angles of cone
% contrast modulations in separate blocks. 

subjName = 'BMC';
expParams = loadExpParams(subjName);

targetContrastAngle1 = expParams.targetDirections(:);
targetContrastAngle2 = targetContrastAngle1;
targetContrastAngle  = [targetContrastAngle1; targetContrastAngle2];

targetContrast1 = expParams.targetContrastsPos(:);
targetContrast2 = -targetContrast1;
targetContrast  = [targetContrast1; targetContrast2];

% SPECIFY NUMBER OF REPEATS 
nRepeats = 10;


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
