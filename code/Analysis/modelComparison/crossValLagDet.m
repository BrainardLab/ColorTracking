function [] = crossValLagDet(subjID,varargin)

% Cross-Validation model comaprison code.
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
nCrossValIter = p.Results.nCrossValIter;
projectName = 'ColorTracking';
crossValCacheFolder = getpref(projectName,'crossValCacheFolder');

% Load the cross val data cache
dataCacheTrackName = fullfile(crossValCacheFolder,[subjCode '_crossValTrack_chached.mat']);
load(dataCacheTrackName);

% reshape Ssplit
SsplitTrk = [];
for ii = 1:size(SsplitTrack,3)
    SsplitTrk = [SsplitTrk;SsplitTrack(:,:,ii)];
end


% Load the Detection data
dataCacheDetName = fullfile(crossValCacheFolder,[subjCode '_crossValDet_chached.mat']);
load(dataCacheDetName);

nContrastDet = size(SsplitDet,2);
nDirectionDet = size(SsplitDet,1);

nContrastDet = size(SsplitDet,2);
nDirectionDet = size(SsplitDet,1);

% loop over nCrossValIter
for ii = 1:nCrossValIter
    
    % shuffle order for detection
    shuffleOrderDet = randperm(40);
    testSetIndxDet = shuffleOrderDet(1:20);
    trainSetIndxDet = shuffleOrderDet(21:40);
    
    % shuffle order for tracking
    shuffleOrderTrk = randperm(20);
    testSetIndxTrk = shuffleOrderTrk(1:10);
    trainSetIndxTrk = shuffleOrderTrk(11:20);
    
    for jj = 1:nDirectionDet
        for kk = 1:nContrastDet
            % %%%%%%%%%% DETECTION %%%%%%%%%%%%%
            % Split the runs into train and test
            testSetDet  = structElementSelect(SsplitDet(jj,kk),testSetIndxDet,size(SsplitDet(jj,kk).cmpIntrvl,1));
            trainSetDet = structElementSelect(SsplitDet(jj,kk),trainSetIndxDet,size(SsplitDet(jj,kk).cmpIntrvl,1));
            
            % training
            pcTrain(kk,jj,ii) = (sum(testSetDet.R == testSetDet.cmpIntrvl))./length(testSetDet.R);
            
            % testing
            pcTest(kk,jj,ii)  = (sum(trainSetDet.R == trainSetDet.cmpIntrvl))./length(trainSetDet.R);
            
            
        end
    end
    
    for jj = 1:nDirectionTrk
        for kk = 1:nContrastTrk
            % %%%%%%%%%% TRACKING %%%%%%%%%%%%%
            % Split the runs into train and test
            testSet = structElementSelect(splitCell{jj,kk},testSetIndxTrk,size(splitCell{jj,kk}.tgtXmm,2));
            trainSet = structElementSelect(splitCell{jj,kk},trainSetIndxTrk,size(splitCell{jj,kk}.tgtXmm,2));
            
            % testing
            [rTest, rLagValTest,rAllTest] = xcorrEasy(diff(testSet.tgtXmm),diff(testSet.rspXmm),[testSet.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr);
            rhoXXstdTest = std(rAllTest,[],2);
            [rSmoothTest,rParamTest,tSecFitTest,negLLTest] = xcorrFitMLE(rLagValTest,rTest,rhoXXstdTest,rStdK,modelType,initType);
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
    
    % The kernel
    thePacket.kernel.values = [];
    thePacket.kernel.timebase = [];
    
    % The metadata
    thePacket.metaData.stimDirections = atand(train_cSVec./train_cLVec);
    thePacket.metaData.stimContrasts  = vecnorm([train_cLVec',train_cSVec']');
    
    
    
end



end