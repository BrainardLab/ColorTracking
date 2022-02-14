function [] = crossValidateOneVsTwoMech(subjID,varargin)

% Cross-Validation caomaprison code for comaping the one mechanism model vs
% the two mechanism model
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
projectName = 'ColorTracking';
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

%% Make the fit object
theDimension= 2;
defaultParamsInfo = [];
startParams = [];

% the one mechaism object
ctmObjOneMech = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', 1 ,'fminconAlgorithm','active-set');

% the two mechanism model
ctmObjTwoMech = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');



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
    
    
    
    % fit the one mechanism model
    [fitParamsOneMech,fVal,objFitResponsesOneMech] = ctmObjOneMech.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
        'initialParams',startParams, 'fitErrorScalar',fitErrorScalar);
    % compute the one mechanism response
    lagsFromFitOneMech = ctmObjOneMech.computeResponse(fitParamsOneMech,thePacket.stimulus,thePacket.kernel);
    
    % fit the two mechanism model
    [fitParamsTwoMech,fVal,objFitResponsesTwoMech] = ctmObjTwoMech.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
        'initialParams',startParams, 'fitErrorScalar',fitErrorScalar);
    % compute the two mechanism response
    lagsFromFitTwoMech = ctmObjTwoMech.computeResponse(fitParamsTwoMech,thePacket.stimulus,thePacket.kernel);
    
    lagsFromFitMatOneMech =  reshape(lagsFromFitOneMech.values,size(lagsTestMat(:,:,ii)'))';
    lagsFromFitMatTwoMech =  reshape(lagsFromFitTwoMech.values,size(lagsTestMat(:,:,ii)'))';
    
    % get the test vals
    tmpTestMat = lagsTestMat(:,:,ii);
    
    % One mech RMSE
    lagsRMSEglobalOneMech(ii)  = sqrt(mean((tmpTestMat(:) - lagsFromFitMatOneMech(:)).^2));
    lagsRMSEperDirOneMech(:,:,ii) = sqrt((tmpTestMat - lagsFromFitMatOneMech).^2);
    
    % Two mech RMSE
    lagsRMSEglobalTwoMech(ii)  = sqrt(mean((tmpTestMat(:) - lagsFromFitMatTwoMech(:)).^2));
    lagsRMSEperTwoMech(:,:,ii) = sqrt((tmpTestMat - lagsFromFitMatTwoMech).^2);
    
    stabilityEst(:,:,ii) = lagsTestMat(:,:,ii) - lagsTrainMat(:,:,ii);
end
saveCrossVal = fullfile(crossValCacheFolder, [subjCode '_crossVal_out.mat']);

save(saveCrossVal,'lagsRMSEglobalOneMech','lagsRMSEperDirOneMech','lagsRMSEglobalTwoMech','lagsRMSEperTwoMech','stabilityEst')

% Take the mean of the RMSE across crossval iterations
meanRmseOneMech = mean(lagsRMSEglobalOneMech);
meanRmseTwoMech = mean(lagsRMSEglobalTwoMech);

% Plot
if p.Results.makeAndSavePlot
    %% Plot it
    meanRMSEbar = figure; hold on;
    set(gca,'Box', 'off','linewidth',3,'FontSize',12);
    X = categorical({'One Mech','Two Mech'});
    X = reordercats(X,{'One Mech','Two Mech'});
    b = bar(X,[meanRmseOneMech;meanRmseTwoMech]);
    %     er = errorbar(X,[rSquaredIampMean;rSquaredNrMean]);
    %     er.Color = [0 0 0];
    %     er.LineStyle = 'none';
    %     er.LineWidth = 2;
    b.FaceColor = 'flat';
    b.CData(1,:) = [199, 128, 35]./255;
    b.CData(2,:) = [138, 154, 91]./255;
    b.EdgeColor = [.33,.33,.33];
    b.LineWidth = 2;
    hXLabel = xlabel('Models');
    hYLabel = ylabel('Mean RMSE');
    hTitle  = title('Cross Validated RMSE');
    set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
    set([hXLabel, hYLabel,],'FontSize', 14);
    set( hTitle, 'FontSize', 14,'FontWeight' , 'bold');
    ylim([0,.2])
    set(gca,'TickDir', 'out');
    set(gcf, 'Color', 'white' );
    
    modelTxtOneMech  = ['{One Mechanism Model: ' num2str(round(meanRmseOneMech,4)) '}'];
    modelTxtTwoMEch  = ['{Two Mechanism Model: ' num2str(round(meanRmseTwoMech,4)) '}'];
    
    theTextHandle = text(gca, .6,.18 , modelTxtOneMech, 'Interpreter', 'latex');
    set(theTextHandle,'FontSize', 12, 'Color', [0.3 0.3 0.3], 'BackgroundColor', [1 1 1]);
    
    theTextHandle = text(gca, .6,0.17, modelTxtTwoMEch, 'Interpreter', 'latex');
    set(theTextHandle,'FontSize', 12, 'Color', [0.3 0.3 0.3], 'BackgroundColor', [1 1 1]);
    
    %% Save it
    
    set(meanRMSEbar, 'Renderer', 'Painters');
    figureSizeInches = [6 5.5];
    set(meanRMSEbar, 'PaperUnits', 'inches');
    set(meanRMSEbar, 'PaperSize',figureSizeInches);
    set(meanRMSEbar, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
    figNameRMSEmeanRMSEbar = fullfile(getpref('ColorTracking','figureSavePath'), ...
        [subjID,'_Cross_Val_RMSE_OneVsTwoMech.pdf']);
    print(meanRMSEbar, figNameRMSEmeanRMSEbar, '-dpdf', '-r300');
    
    display(['COMPLETED: ',subjID])
end

end
