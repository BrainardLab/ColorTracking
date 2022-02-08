%% LOAD DATA FROM CACHE
numRuns = 20;
load('dataCache_subj3.mat')

uniqColorDirs = unique(round(atand(cS./cL),2));
%% FIT IT

[p_hat,lagsFromFit,m1_hat,m2_hat,Lag1_hat,Lag2_hat] = fitWithFmincon(lags(:),[cL,cS]');

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
vecContrast = sqrt(cL.^2+cS.^2);
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