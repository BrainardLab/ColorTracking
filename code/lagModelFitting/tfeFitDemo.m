%% LOAD DATA
subjID  = 'KAS';
expName = 'LS1';
theRuns = 1:20;

figSavePath = '/Users/michael/labDropbox/CNST_analysis/ColorTracking/Results/';

if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end

Sall = loadPSYdataLMSall('TRK', subjID, expName, 'CGB', {theRuns}, 'jburge-hubel', 'local');

%% SORT TRIALS BY COLOR ANGLE
plotRawData = 0;
uniqColorDirs = unique(round(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1)),2));

switch expName
    
    case 'LS1'
        uniqColorDirs = uniqColorDirs([3 6 5 1 4 2]); %% CHECK THIS IS CORRECT
    case 'LS2'
        uniqColorDirs = uniqColorDirs([4 5 6 3 2 1]);
end

for ii = 1:length(uniqColorDirs)
    
    % 0 DEG IN SL PLANE
    ind = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-uniqColorDirs(ii))<0.001;
    
    S = structElementSelect(Sall,ind,size(Sall.tgtXmm,2));
    % LMS ANALYSIS TO ESTIMATE LAGS
    [~,~,rParams(:,:,ii)] = LMSxcorrAnalysis(S,'LGS','bPLOTfitsAndRaw',plotRawData);
    
end

%% Get the lags from rParams
lags = flipud(squeeze(rParams(2,:,:)));

% Get the cone contrasts
MaxContrastLMS = LMSstimulusContrast('experiment','Experiment1-Pos');
cL = MaxContrastLMS(:,1);
cS = MaxContrastLMS(:,3);

%% set up the mechanisms
%initial weight estimates [0.7 0.3 0.997 0.003 2.5/1000 0.3];
a1 = 0.7;
b1 = .5;
a2 = .5;
b2 = .5;
minLag1 = 0.3;
decay1 = .25;
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
% ub = [100,100,100,100,5,100,1,1];
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
m1_hat =  abs(a1_hat.*cL + b1_hat.*cS);
m2_hat =  abs(a2_hat.*cL + b2_hat.*cS);

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
plotColors = [230 172 178; ...
    194  171  253; ...
    36   210  201; ...
    32   140  163; ...
    253  182    44; ...
    252  153  233;...
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
tcHndl2 = figure;hold on
% Names for plotting
clear plotNames
plotNames.title  = 'Lag Vs. Contrast';
plotNames.xlabel  = 'Contrast (%)';
plotNames.ylabel = 'Lag (s)';
legendLocation = 'northeastoutside';
sz = 12;
yLimVals = [0.2 0.6];
semiLog = true;
for jj = 1:length(uniqColorDirs)
    plotNames.legend{jj} = sprintf('%s°',num2str(uniqColorDirs(jj)));
end

numLines = size(lagsFromFitMat,1);


% Loop over the lines
for ii = 1:numLines
    
    scatter(matrixContrasts(:,ii),lags(:,ii),sz.^2, ...
        'MarkerEdgeColor',.3*plotColors(:,ii),...
        'MarkerFaceColor',plotColors(:,ii),...
        'LineWidth',2);
    
end
% Loop over the lines
for ii = 1:numLines
    
    plot(matrixContrasts(:,ii),lagsFromFitMat(:,ii),'--', ...
        'Color',plotColors(:,ii),...
        'LineWidth',2);
    
end

axis square;

if semiLog
    set(gca,'Xscale','log');
end

set(gca,'XTick',[0.03 0.1 0.3 1]);

ylim(yLimVals)

autoTicksY = yLimVals(1):(yLimVals(2)-yLimVals(1))/4:yLimVals(2);

set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'FontSize'    , 16        , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , autoTicksY, ...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');

set(gcf, 'Color', 'white' );


% Add labels
if isfield(plotNames,'title')
    hTitle  = title (plotNames.title);
end
if isfield(plotNames,'xlabel')
    hXLabel = xlabel(plotNames.xlabel);
end
if isfield(plotNames,'ylabel')
    hYLabel = ylabel(plotNames.ylabel);
end

% Add Legend
if isfield(plotNames,'legend')
    legend(plotNames.legend,'Location',legendLocation);
end
%% Format fonts
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 18);
set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');

%% Save it!
figureSizeInches = [8 8];
set(tcHndl2, 'PaperUnits', 'inches');
set(tcHndl2, 'PaperSize',figureSizeInches);
set(tcHndl2, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
%figNameTc =  fullfile(figSavePath,[subjCode, '_LagVsContrast.pdf']);
% Save it
%print(tcHndl, figNameTc, '-dpdf', '-r300');



