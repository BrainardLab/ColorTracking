function [lagsRMSEglobal,lagsRMSEperDir,stabilityEst] = crossValidateOneMechModel(subjID,varargin)

% Cross-Validation code for the one mechanism model
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('subjID',@ischar);
p.addParameter('fitMethod','LGS',@ischar);
p.addParameter('nCrossValIter',15,@isnumeric);
p.addParameter('makeAndSavePlot',false,@islogical);
p.addParameter('fitErrorScalar',1000,@isnumeric);
p.parse(subjID,varargin{:});

% get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end

% get prefs
projectName = 'CorticalColorMapping';
crossValCacheFolder = getpref(projectName,'crossValCacheFolder');

% Load the cross val data cache
dataCacheName = fullfile(crossValCacheFolder,[subjCode '_crossVal_chached.mat']);
load(dataCacheName);


modelType = p.Results.fitMethod;
nCrossValIter = p.Results.nCrossValIter;
fitErrorScalar = p.Results.fitErrorScalar;

rStdK = 1.5;
initType = 'RND';
smpBgnEnd = 1;
bPLOTxcorr = false;
maxLagSec = 2;

% reshape Ssplit
splitCell = [];
for ii = 1:size(Ssplit,3)
    splitCell = [splitCell;Ssplit(:,:,ii)];
end

% Get the sizes
nContrasts = size(splitCell,2);
nDirections = size(splitCell,1);

% init mats
lagsTestMat  =zeros(nDirections,nContrasts,nCrossValIter);
lagsTrainMat =zeros(nDirections,nContrasts,nCrossValIter);

% loop over nCrossValIter
for ii = 1:nCrossValIter
    shuffleOrder = randperm(20);
    testSetIndx = shuffleOrder(1:10);
    trainSetIndx = shuffleOrder(11:20);

    parfor jj = 1:nDirections
        for kk = 1:nContrasts
            
            % Split the runs into train and test
            testSet = structElementSelect(splitCell{jj,kk},testSetIndx,size(splitCell{jj,kk}.tgtXmm,2));
            trainSet = structElementSelect(splitCell{jj,kk},trainSetIndx,size(splitCell{jj,kk}.tgtXmm,2));
            
            % testing
            [rTest, rLagValTrain,rAllTest] = xcorrEasy(diff(testSet.tgtXmm),diff(testSet.rspXmm),[testSet.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr);
            rhoXXstdTest = std(rAllTest,[],2);
            [rSmoothTest,rParamTest,tSecFitTest,negLLTest] = xcorrFitMLE(rLagValTrain,rTest,rhoXXstdTest,rStdK,modelType,initType);
            lagsTestMat(jj,kk,ii) = rParamTest(2);
            test_cL(jj,kk,ii) = testSet.MaxContrastLMS(1,1);
            test_cS(jj,kk,ii) = testSet.MaxContrastLMS(1,3);
            
            % training
            [rTrain, rLagValTrain,rAllTrain] = xcorrEasy(diff(trainSet.tgtXmm),diff(trainSet.rspXmm),[trainSet.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr);
            rhoXXstdTrain = std(rAllTrain,[],2);
            [rSmoothTrain,rParamTrain,tSecFitTrain,negLLTrain] = xcorrFitMLE(rLagValTrain,rTrain,rhoXXstdTrain,rStdK,modelType,initType);
            lagsTrainMat(jj,kk,ii) = rParamTrain(2);
            train_cL(jj,kk,ii) = trainSet.MaxContrastLMS(1,1);
            train_cS(jj,kk,ii) = trainSet.MaxContrastLMS(1,3);
        end
    end

    %% Make the training packet
    tmpLagMat = lagsTrainMat(:,:,ii)';
    tmpcLMat = test_cL(:,:,ii)';
    tmpcSMat = test_cS(:,:,ii)';
    lagVec = tmpLagMat(:)';
    train_cLVec = tmpcLMat(:)';
    train_cSVec = tmpcSMat(:)';
    timebase = 1:length(lagVec);
    
    % Initialize the packet
    thePacket.response.values   = lagVec;
    thePacket.response.timebase = timebase;
    
    % The stimulus
    thePacket.stimulus.values   = [train_cLVec;train_cSVec];
    thePacket.stimulus.timebase = timebase;
    
    
    thePacket.kernel.values = [];
    thePacket.kernel.timebase = [];
    
    thePacket.metaData.stimDirections = atand(train_cSVec./train_cSVec);
    thePacket.metaData.stimContrasts  = vecnorm([train_cLVec',train_cSVec']');
    
    %% Make the fit object
    theDimension= size(thePacket.stimulus.values, 1);
    numMechanism = 1;
    defaultParamsInfo = [];
    startParams = [];
    ctmOBJ = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', numMechanism ,'fminconAlgorithm','active-set');
    
    [fitParams,fVal,objFitResponses] = ctmOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
        'initialParams',startParams, 'fitErrorScalar',fitErrorScalar);
    lagsFromFit = ctmOBJ.computeResponse(fitParams,thePacket.stimulus,thePacket.kernel);
    
    lagsFromFitMat =  reshape(lagsFromFit.values,size(lagsTestMat(:,:,ii)'))';
    tmpTestMat = lagsTestMat(:,:,ii);
    lagsRMSEglobal(ii)  = sqrt(mean((tmpTestMat(:) - lagsFromFitMat(:)).^2));
    lagsRMSEperDir(:,:,ii) = sqrt((tmpTestMat - lagsFromFitMat).^2);
    stabilityEst(:,:,ii) = lagsTestMat(:,:,ii) - lagsTrainMat(:,:,ii);
end
saveCrossVal = fullfile(crossValCacheFolder, [subjCode '_crossVal_out.mat']);

save(saveCrossVal,'lagsRMSEglobal','lagsRMSEperDir','stabilityEst')
end
