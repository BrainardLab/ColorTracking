function [] = crossValidateOneMechModel(subjID,expNameCell,varargin)

% Cross-Validation code for the one mechanism model
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('subjID',@ischar);
p.addRequired('expNameCell',@iscell);
p.addParameter('fitMethod','LGS',@ischar);
p.addParameter('numRuns',20,@isnumeric);
p.addParameter('isBootstrap',false,@islogical);
p.addParameter('nBootIters',5,@isnumeric);
p.addParameter('plotRawData',false,@islogical);
p.parse(subjID,expNameCell,varargin{:});

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


modelType = p.Results.fitMethod;

% Load the cross val data cache
dataCacheName = fullfile(crossValCacheFolder,[subjCode '_crossVal_chached.mat']);
load(dataCacheName);
% function to take out the relvant  subfields and split the struct in half for train test

rStdK = 1.5;
initType = 'RND';
smpBgnEnd = 1;
bPLOTxcorr = false;
maxLagSec = 2;

for ii = 1:nCrossValIter
    shuffleOrder = randperm(20);
    testSetIndx = shuffleOrder(1:10);
    trainSetIndx = shuffleOrder(11:20);
    
    for ii = (6x6x3)
        for jj
            for kk
                testSet = structElementSelect(Ssplit{ii,jj,kk},1:10,20);
                trainSet = structElementSelect(Ssplit{ii,jj,kk},1:10,20);
                
                % testing
                
                % split for each cell S{i,j,k}.
                [r, rLagVal,rAll] = xcorrEasy(diff(S.tgtXmm),diff(S.rspXmm),[S.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr);
                rhoXXstd = std(rAll,[],2);
                
                [rSmooth(:,i),rParam(:,i),tSecFit(:,i),negLL(:,i)] = xcorrFitMLE(rLagVal,r,rhoXXstd,rStdK,modelType,initType);
                
                lagsTestMat = rParam
                
                % training
                
                
                [r, rLagVal,rAll] = xcorrEasy(diff(S.tgtXmm),diff(S.rspXmm),[S.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr);
                rhoXXstd = std(rAll,[],2);
                [rSmooth(:,i),rParam(:,i),tSecFit(:,i),negLL(:,i)] = xcorrFitMLE(rLagVal,r,rhoXXstd,rStdK,modelType,initType);
                lagsTrainMat
                
                
                %% Make the packet
                lagVec = lagsMat(:)';
                timebase = 1:length(lagVec);
                
                % Initialize the packet
                thePacket.response.values   = lagVec;
                thePacket.response.timebase = timebase;
                
                % The stimulus
                thePacket.stimulus.values   = [cL(:),cS(:)]';
                thePacket.stimulus.timebase = timebase;
                
                
                thePacket.kernel.values = [];
                thePacket.kernel.timebase = [];
                
                thePacket.metaData.stimDirections = atand(cS(:)./cL(:));
                thePacket.metaData.stimContrasts  = vecnorm([cS(:),cL(:)]')';
                
                matrixContrasts = reshape(thePacket.metaData.stimContrasts,size(lagsMat));
                
                %% Make the fit object
                theDimension= size(thePacket.stimulus.values, 1);
                numMechanism = 1;
                
                ctmOBJ = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', numMechanism ,'fminconAlgorithm','active-set');
                
                [fitParams,fVal,objFitResponses] = ctmOBJ.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
                    'initialParams',startParams, 'fitErrorScalar',fitErrorScalar);
                lagsFromFit = ctmOBJ.computeResponse(fitParams,thePacket.stimulus,thePacket.kernel);
                
                
                lagsRMSE(:,:,:,loop)  = sqrt(mean(lagsTestMat.^2 - lagsFromFit.^2));
                
                stabilityEst = lagsTestMat - lagsTrainMat
            end
        end
    end
end
