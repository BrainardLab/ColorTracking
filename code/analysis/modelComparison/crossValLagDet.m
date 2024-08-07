function [] = crossValLagDet(subjID,varargin)

% Cross-Validation model comaprison code.
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('subjID',@ischar);
p.addParameter('fitMethod','LGS',@ischar);
p.addParameter('nCrossValIter',15,@isnumeric);
p.addParameter('makeAndSavePlot',false,@islogical);
p.addParameter('fitErrorScalar',5,@isnumeric);
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
modelType = p.Results.fitMethod;
nCrossValIter = p.Results.nCrossValIter;
fitErrorScalar = p.Results.fitErrorScalar;

rStdK = 1.5;
initType = 'RND';
smpBgnEnd = 1;
bPLOTxcorr = false;
maxLagSec = 2;

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

nContrastTrk = size(SsplitTrk,2);
nDirectionTrk = size(SsplitTrk,1);

%% Initialize the model objects
% The Lag Model CTM
lagObjCTM = tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 2,'fminconAlgorithm','active-set');

% the Lag Model Indiv
lagObjIndiv = tfeCTMIndiv('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');
a = tfeLSDIndiv('verbosity','none','dimension',2, 'numMechanism', 2 ,'fminconAlgorithm','active-set');
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
    
    % %%%%%%%%%% DETECTION %%%%%%%%%%%%%
    for jj = 1:nDirectionDet
        for kk = 1:nContrastDet
            
            % Split the runs into train and test
            testSetDet  = structElementSelect(SsplitDet(jj,kk),testSetIndxDet,size(SsplitDet(jj,kk).cmpIntrvl,1));
            trainSetDet = structElementSelect(SsplitDet(jj,kk),trainSetIndxDet,size(SsplitDet(jj,kk).cmpIntrvl,1));
            
            % training
            pcTrain(kk,jj,ii) = (sum(trainSetDet.R == trainSetDet.cmpIntrvl))./length(trainSetDet.R);
            train_cL_Det(jj,kk,ii) = abs(trainSetDet.targetContrast(1)).*cosd(trainSetDet.targetContrastAngle(1));
            train_cS_Det(jj,kk,ii) = abs(trainSetDet.targetContrast(1)).*sind(trainSetDet.targetContrastAngle(1));
            
            train_angles(jj,kk,ii) = trainSetDet.targetContrastAngle(1);
            train_contrasts(jj,kk,ii) = abs(trainSetDet.targetContrast(1));

            % testing
            pcTest(kk,jj,ii)  = (sum(testSetDet.R == testSetDet.cmpIntrvl))./length(testSetDet.R);
            
            
        end
    end
    
    % %%%%%%%%%% TRACKING %%%%%%%%%%%%%
    for jj = 1:nDirectionTrk
        for kk = 1:nContrastTrk
            
            % Split the runs into train and test
            testSet = structElementSelect(SsplitTrk(jj,kk),testSetIndxTrk,size(SsplitTrk(jj,kk).tgtXmm,2));
            trainSet = structElementSelect(SsplitTrk(jj,kk),trainSetIndxTrk,size(SsplitTrk(jj,kk).tgtXmm,2));
            
            % testing
            [rTest, rLagValTest,rAllTest] = xcorrEasy(diff(testSet.tgtXmm),diff(testSet.rspXmm),[testSet.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr);
            rhoXXstdTest = std(rAllTest,[],2);
            [rSmoothTest,rParamTest,tSecFitTest,negLLTest] = xcorrFitMLE(rLagValTest,rTest,rhoXXstdTest,rStdK,modelType,initType);
            lagsTestMat(jj,kk,ii) = rParamTest(2);
            test_cL_Trk(jj,kk,ii) = testSet.MaxContrastLMS(1,1);
            test_cS_Trk(jj,kk,ii) = testSet.MaxContrastLMS(1,3);
            
            % training
            [rTrain, rLagValTrain,rAllTrain] = xcorrEasy(diff(trainSet.tgtXmm),diff(trainSet.rspXmm),[trainSet.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr);
            rhoXXstdTrain = std(rAllTrain,[],2);
            [rSmoothTrain,rParamTrain,tSecFitTrain,negLLTrain] = xcorrFitMLE(rLagValTrain,rTrain,rhoXXstdTrain,rStdK,modelType,initType);
            lagsTrainMat(jj,kk,ii) = rParamTrain(2);
            train_cL_Trk(jj,kk,ii) = trainSet.MaxContrastLMS(1,1);
            train_cS_Trk(jj,kk,ii) = trainSet.MaxContrastLMS(1,3);
        end
    end
    
    %% %%%%%%%%%% TRACKING %%%%%%%%%%%%%
    % Make the training packet
    tmpLagMat = lagsTrainMat(:,:,ii)';
    tmpcLMat = train_cL_Trk(:,:,ii)';
    tmpcSMat = train_cS_Trk(:,:,ii)';
    lagVec = tmpLagMat(:)';
    train_cLTrk = tmpcLMat(:)';
    train_cSTrk = tmpcSMat(:)';
    timebaseTrk = 1:length(lagVec);

    
    % Initialize the packet
    thePacketTrk.response.values   = lagVec;
    thePacketTrk.response.timebase = timebaseTrk;
    
    % The stimulus
    thePacketTrk.stimulus.values   = [train_cLTrk;train_cSTrk];
    thePacketTrk.stimulus.timebase = timebaseTrk;
    
    % The kernel
    thePacketTrk.kernel.values   = [];
    thePacketTrk.kernel.timebase = [];
    
    % The metadata
    thePacketTrk.metaData.stimDirections = atand(train_cSTrk./train_cLTrk);
    thePacketTrk.metaData.stimContrasts  = vecnorm([train_cLTrk',train_cSTrk']');
    
    
    %% %%%%%%%%%% DETECTION %%%%%%%%%%%%%
    % Put stuff in packet format
    tmpPcMat = pcTrain(:,:,ii)';
    pcVec = tmpPcMat(:)';
    tmpcLDet= train_cL_Det(:,:,ii)';
    tmpcSDet = train_cS_Det(:,:,ii)';
    train_cLDet = tmpcLDet(:)';
    train_cSDet = tmpcSDet(:)';
    timebaseDet = 1:length(pcVec);
    train_angles =train_angles';
    train_contrasts = train_contrasts';
    
    % Initialize the packet
    thePacketDet.response.values   = pcVec;
    thePacketDet.response.timebase = timebaseDet;
    
    % The stimulus
    thePacketDet.stimulus.values   = [train_cLDet;train_cSDet];
    thePacketDet.stimulus.timebase = timebaseDet;
    
    % The kernel
    thePacketDet.kernel.values = [];
    thePacketDet.kernel.timebase = [];
    
    % The metadata
    thePacketDet.metaData.stimDirections = train_angles(:)';
    thePacketDet.metaData.stimContrasts  = train_contrasts(:)';
    
    %% Fit the models
    
   
    
end



end