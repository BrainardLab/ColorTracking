%% LOAD DATA from Exp 1
subjID  = 'KAS';
expName = 'LS1';

numRuns = 20;

theRuns = 1:numRuns;



if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end

Sall = loadPSYdataLMSall('TRK', subjID, expName, 'CGB', {theRuns}, 'jburge-hubel', 'local');

% SORT TRIALS BY COLOR ANGLE
plotRawData = 0;
uniqColorDirs1 = unique(round(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1)),2));

switch expName
    
    case 'LS1'
        uniqColorDirs1 = uniqColorDirs1([3 6 5 1 4 2]);
    case 'LS2'
        uniqColorDirs1 = uniqColorDirs1([4 5 6 3 2 1]);
end

for ii = 1:length(uniqColorDirs1)
    
    % 0 DEG IN SL PLANE
    ind = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-uniqColorDirs1(ii))<0.001;
    
    S = structElementSelect(Sall,ind,size(Sall.tgtXmm,2));
    % LMS ANALYSIS TO ESTIMATE LAGS
    [~,~,rParamsGMA(:,:,ii),negLL_GMA(ii,:)] = LMSxcorrAnalysis(S,'GMA','bPLOTfitsAndRaw',plotRawData);
    %[~,~,rParamsLGS(:,:,ii),negLL_LGS(ii,:)] = LMSxcorrAnalysis(S,'LGS','bPLOTfitsAndRaw',plotRawData);
end

% % Get the lags from rParams
% if mean(negLL_LGS(:)) < mean(negLL_GMA(:))
%     lagsLS1 = flipud(squeeze(rParamsLGS(2,:,:)));
% elseif  mean(negLL_GMA(:)) <  mean(negLL_LGS(:))
    lagsLS1 = flipud((squeeze(rParamsGMA(3,:,:))-1).*squeeze(rParamsGMA(2,:,:))+ squeeze(rParamsGMA(4,:,:)));
% else 
%     lagsLS1_1 = flipud(squeeze(negLL_LGS(2,:,:)));
%     lagsLS1_2 = flipud((squeeze(rParamsGMA(3,:,:))-1).*squeeze(rParamsGMA(2,:,:))+ squeeze(rParamsGMA(4,:,:)));
%     lagsLS1 = (lagsLS1_1 + lagsLS1_2)./2;
% end
%% LOAD DATA from Exp 2
expName = 'LS2';
theRuns = 1:numRuns;

Sall = loadPSYdataLMSall('TRK', subjID, expName, 'CGB', {theRuns}, 'jburge-hubel', 'local');

% SORT TRIALS BY COLOR ANGLE
uniqColorDirs2 = unique(round(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1)),2));

switch expName
    
    case 'LS1'
        uniqColorDirs2 = uniqColorDirs2([3 6 5 1 4 2]);
    case 'LS2'
        uniqColorDirs2 = uniqColorDirs2([4 5 6 3 2 1]);
end

for ii = 1:length(uniqColorDirs2)
    
    % 0 DEG IN SL PLANE
    ind = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-uniqColorDirs2(ii))<0.001;
    
    S = structElementSelect(Sall,ind,size(Sall.tgtXmm,2));
    % LMS ANALYSIS TO ESTIMATE LAGS
    [~,~,rParams(:,:,ii)] = LMSxcorrAnalysis(S,'GMA','bPLOTfitsAndRaw',plotRawData);
    
end


% Get the lags from rParams
%lagsLS2 = flipud(squeeze(rParams(2,:,:)));
lagsLS2 = flipud((squeeze(rParams(3,:,:))-1).*squeeze(rParams(2,:,:))+ squeeze(rParams(4,:,:)));

lags = [lagsLS1,lagsLS2];

%% Get the stimuli
% Get the cone contrasts for LS1
MaxContrastLS1 = LMSstimulusContrast('experiment','Experiment1-Pos');
cL_LS1 = MaxContrastLS1(:,1);
cS_LS1 = MaxContrastLS1(:,3);

% Get the cone contrasts for LS2
MaxContrastLS2 = LMSstimulusContrast('experiment','Experiment2-Pos');
cL_LS2 = MaxContrastLS2(:,1);
cS_LS2 = MaxContrastLS2(:,3);

MaxContrastLMS = [MaxContrastLS1;MaxContrastLS2];
cL = [cL_LS1;cL_LS2];
cS = [cS_LS1;cS_LS2];

%% set up the mechanisms
%initial weight estimates [0.7 0.3 0.997 0.003 2.5/1000 0.3];
a1 = 50;
b1 = 2;
a2 = 60;
b2 = 6;
minLag1 = 0.3;
decay1 = 0.2;
% c1 = .5;
% c2 = .5;

%p = [a1,b1,a2,b2,minLag1,decay1,c1,c2];
p = [a1,b1,a2,b2,minLag1,decay1];

%% Search for it
A =[];
aa = [];
Aeq =[];%[0,0,0,0,0,0,1,1];
aaeq =[];%[1];
nlcon =[];

% lb =[0,0,0,0,0,0,0,0];
% ub = [100,0,0,100,5,100,1,1];
lb =[0,0,0,0,0,0];
ub = [100,100,100,100,5,100];

options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','iter','LargeScale','off','Algorithm','active-set');

p_hat = fmincon(@(p) objectiveFunc(p,lags(:),cL,cS),p,A,aa,Aeq,aaeq,lb,ub,nlcon,options);

%% break up p
a1_hat      = p_hat(1);
b1_hat      = p_hat(2);
a2_hat      = p_hat(3);
b2_hat      = p_hat(4);
minLag1_hat = p_hat(5);
decay1_hat  = p_hat(6);
% c1_hat      = p_hat(7);
% c2_hat      = p_hat(8);

%% Use the recovered weights
% m1_hat =  sqrt(a1_hat.*cL.^2 + b1_hat.*cS.^2);
% m2_hat =  sqrt(a2_hat.*cL.^2 + b2_hat.*cS.^2);
m1_hat =  abs(a1_hat.*cL - b1_hat.*cS);
m2_hat =  abs(a2_hat.*cL - b2_hat.*cS);

%% Contrast-Lag nonlinearity
Lag1_hat =  minLag1_hat +  decay1_hat.* exp(-1.*m1_hat);
Lag2_hat =  minLag1_hat +  decay1_hat.* exp(-1.*m2_hat);
%Lag1_hat =  minLag1_hat + decay1_hat./m1_hat;
%Lag2_hat =  minLag1_hat + decay1_hat./m2_hat;


%% objective function
lagsFromFit = min([Lag1_hat'; Lag2_hat'])';
%lagsFromFit = c1_hat.*Lag1_hat - c2_hat.*Lag2_hat;
lagsFromFitMat = reshape(lagsFromFit,size(lags));
%% PLOT IT

% Set the colors
plotColors = [230 172  178; ...
    194  171  253; ...
    36   210  201; ...
    32   140  163; ...
    253  182   44; ...
    252  153  233; ...
    235   64   52; ...
    255  118  109; ...
    121   12  126; ...
    179  107  183; ...
    185  177   91; ...
    225  218  145;...
    ]'./255;

% Get the l2 norm of the cone contrasts
vecContrast = sqrt(MaxContrastLMS(:,1).^2+MaxContrastLMS(:,3).^2);
matrixContrasts = reshape(vecContrast,size(lags));


legendLocation = 'northeast';

% sub plot 1 - mechanism outputs
tcHndl1 = figure;
subplot(1,3,1); hold on
plotNames.title  = 'M1 and M2 Outputs';
plotNames.xlabel = 'Stimuli';
plotNames.ylabel = 'Mechanism Output';
plotNames.legend = {'M1','M2'};

simplePlot(m1_hat,[0, 0,.5],m2_hat,[0,.5,.5],plotNames,legendLocation)

subplot(1,3,2); hold on
plotNames.title  = 'Lag1 and Lag2 Outputs';
plotNames.xlabel = 'Stimuli';
plotNames.ylabel = 'Lag Output';
plotNames.legend = {'Lag1','Lag2'};

simplePlot(Lag1_hat,[0, 0,.5],Lag2_hat,[0,.5,.5],plotNames,legendLocation)
% init the plot
subplot(1,3,3);
hold on;
plotNames.title  = 'Model Fit';
plotNames.xlabel = 'Stimuli';
plotNames.ylabel = 'Lag (S)';
plotNames.legend = {'Lag','Predicted Lag'};

simplePlot(lags(:),[0, 0,0],lagsFromFit,[220 195 256]./256,plotNames,legendLocation)


%%
% get the number of lines to plot
uniqColorDirs = [uniqColorDirs1; uniqColorDirs2];

shuffIndx = [1 2 3 4 5 6 7 10 8 11 9 12];

% Sort the directions to make the +/- direction pairs
matrixContrastsShuff= matrixContrasts(:,shuffIndx);
lagsShuff = lags(:,shuffIndx);
uniqColorDirsShuff = uniqColorDirs(shuffIndx);
lagsFromFitMatShuff = lagsFromFitMat(:,shuffIndx);

% Plot the inividual color direction +/- pairs
figSaveInfo.figSavePath = '/Users/michael/labDropbox/CNST_analysis/ColorTracking/Results/';
figSaveInfo.subjCode    = subjCode;
figSaveInfo.figureSizeInches = [18 12];
plotDirectionPairs(matrixContrastsShuff,lagsShuff,lagsFromFitMatShuff,uniqColorDirsShuff,plotColors,figSaveInfo)